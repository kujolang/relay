#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WATCHDOG_ROOT="${RELAY_WATCHDOG_ROOT:-$ROOT/../watchdog}"
WORK="/tmp/relay-provider-tools-workspace"
MISSION="/tmp/relay-provider-tools-mission.json"
STUB_PORT="${RELAY_PROVIDER_TOOL_STUB_PORT:-18774}"
WATCHDOG_PORT="${RELAY_PROVIDER_TOOL_WATCHDOG_PORT:-18775}"
STUB_LOG="/tmp/relay-provider-tools-stub.log"
WATCHDOG_LOG="/tmp/relay-provider-tools-watchdog.log"
DB_PATH="/tmp/relay-provider-tools-$$.db"

rm -rf "$WORK" "$MISSION" "$STUB_LOG" "$WATCHDOG_LOG" "$DB_PATH" "$ROOT/.relay"
trap 'kill "${watchdog_pid:-}" 2>/dev/null || true; kill "${stub_pid:-}" 2>/dev/null || true; wait "${watchdog_pid:-}" 2>/dev/null || true; wait "${stub_pid:-}" 2>/dev/null || true; rm -rf "$WORK" "$MISSION" "$ROOT/.relay"; rm -f "$DB_PATH" "$DB_PATH-wal" "$DB_PATH-shm" "$STUB_LOG" "$WATCHDOG_LOG"' EXIT

mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline
ruby -rjson -e 'spec=JSON.parse(File.read(ARGV.fetch(0))); spec["repository"]=ARGV.fetch(1); File.write(ARGV.fetch(2), JSON.generate(spec))' "$ROOT/examples/provider-tools-mission.json" "$WORK" "$MISSION"

test -f "$WATCHDOG_ROOT/dashboard_server.kujo"
RELAY_TEST_PORT="$STUB_PORT" RELAY_TEST_CORRELATION="relay-provider-tool-correlation" "$KUJO" run "$ROOT/tests/relay_watchdog_stub.kujo" --interpreter >"$STUB_LOG" 2>&1 &
stub_pid=$!
WDG_PORT="$WATCHDOG_PORT" \
WDG_DB_PATH="$DB_PATH" \
WDG_UPSTREAM_BASE_URL="http://127.0.0.1:$STUB_PORT/v1" \
WDG_API_AUTH_MODE=token \
WDG_API_AUTH_TOKEN=relay-api-token \
WDG_PROXY_AUTHZ_MODE=token \
WDG_PROXY_AUTHZ_TOKEN=relay-proxy-token \
WDG_DEPLOYMENT_PROFILE=local \
"$KUJO" run --interpreter "$WATCHDOG_ROOT/dashboard_server.kujo" >"$WATCHDOG_LOG" 2>&1 &
watchdog_pid=$!

ready=0
for _ in $(seq 1 100); do
  if curl -fsS "http://127.0.0.1:$WATCHDOG_PORT/healthz" >/dev/null 2>&1; then ready=1; break; fi
  sleep 0.05
done
test "$ready" -eq 1

export RELAY_ROOT="$ROOT"
export RELAY_OFFLINE_FIXTURE=false
export RELAY_WATCHDOG_URL="http://127.0.0.1:$WATCHDOG_PORT/proxy/v1"
export RELAY_WATCHDOG_API_URL="http://127.0.0.1:$WATCHDOG_PORT"
export RELAY_WATCHDOG_PROXY_TOKEN=relay-proxy-token
export RELAY_WATCHDOG_API_TOKEN=relay-api-token
export RELAY_WATCHDOG_VERIFY=true
export RELAY_CORRELATION_ID=relay-provider-tool-correlation
export OPENAI_API_KEY=relay-stub-provider-key
export KUJO_AI_SDK_ALLOW_INSECURE_LOCALHOST=true

result="$($KUJO run "$ROOT/main.kujo" -- missions run "$MISSION" --skip-agent-smoke --json)"
printf '%s' "$result" | jq -e '.ok == true and .run.status == "completed" and .run.agent_sdk_tools.provider_generated == true and (.run.agent_sdk_tools.calls | length) == 1 and .run.agent_sdk_tools.turns == 2 and (.run.telemetry.correlation_id | length) > 0' >/dev/null
run_id="$(printf '%s' "$result" | jq -r '.run.run_id')"
test -f "$WORK/PROVIDER_TOOL_OUTPUT.txt"
grep -q 'provider-generated tool call' "$WORK/PROVIDER_TOOL_OUTPUT.txt"
test -f "$ROOT/.relay/runs/$run_id/tool-results.json"
jq -e --arg run_id "$run_id" '.contract_version == "relay-tool-result-bundle-v1" and .run_id == $run_id and (.results | length) == 1 and .results[0].result.ok == true' "$ROOT/.relay/runs/$run_id/tool-results.json" >/dev/null

events="$($KUJO run "$ROOT/main.kujo" -- runs events "$run_id" --json)"
printf '%s' "$events" | jq -e '.ok == true and any(.events[]; .kind == "tool_plan_resolved" and .payload.provider_generated == true) and any(.events[]; .kind == "tool_result_persisted")' >/dev/null
verified="$($KUJO run "$ROOT/main.kujo" -- runs verify "$run_id" --json)"
printf '%s' "$verified" | jq -e '.ok == true and .tool_results_required == true and .tool_results_valid == true' >/dev/null

# Provider-generated tool results are required evidence, not merely an
# informational artifact. A tampered bundle must invalidate verification.
cp "$ROOT/.relay/runs/$run_id/tool-results.json" "$ROOT/.relay/runs/$run_id/tool-results.json.backup"
jq '.results[0].result.ok = false' "$ROOT/.relay/runs/$run_id/tool-results.json.backup" >"$ROOT/.relay/runs/$run_id/tool-results.json"
set +e
tampered_tool_results="$($KUJO run "$ROOT/main.kujo" -- runs verify "$run_id" --json 2>&1)"
tampered_tool_results_rc=$?
set -e
test "$tampered_tool_results_rc" -ne 0
printf '%s' "$tampered_tool_results" | jq -e '.ok == false and .tool_results_required == true and .tool_results_valid == false and .integrity_valid == false' >/dev/null
mv "$ROOT/.relay/runs/$run_id/tool-results.json.backup" "$ROOT/.relay/runs/$run_id/tool-results.json"
if printf '%s' "$result" | grep -q 'relay-proxy-token\|relay-api-token\|relay-stub-provider-key'; then
  echo "provider tool smoke leaked a credential" >&2
  exit 1
fi

echo "PASS relay provider tool smoke"
