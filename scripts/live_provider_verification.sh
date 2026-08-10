#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT="${1:-}"
KUJO="${KUJO_BIN:-}"

test "${RELAY_LIVE_PROVIDER_APPROVED:-false}" = "true"
test -n "$OUTPUT" && test ! -e "$OUTPUT"
test -x "$KUJO"
test "${RELAY_OFFLINE_FIXTURE:-true}" = "false"
test "${RELAY_WATCHDOG_VERIFY:-false}" = "true"
test -n "${RELAY_WATCHDOG_URL:-}"
test -n "${RELAY_EXPECTED_COMMIT:-}"
test "$(git -C "$ROOT" rev-parse HEAD)" = "$RELAY_EXPECTED_COMMIT"
test -z "$(git -C "$ROOT" status --porcelain)"
test -n "${RELAY_LIVE_MODEL:-}"
test -n "${RELAY_LIVE_PROVIDER:-}"
test -f "${RELAY_LIVE_MISSION:-}"
test "${RELAY_WATCHDOG_DEPLOYED_REVISION:-}" = "$(jq -r '.dependencies.watchdog.revision' "$ROOT/release/dependencies.json")"
jq -e '.version == "1.0.0" and .agent_tool_mode == "provider" and (.agent_tool_allowlist | length) > 0 and .budgets.max_tool_calls <= 16 and .budgets.max_tool_turns <= 4 and .budgets.max_tokens <= 65536' "$RELAY_LIVE_MISSION" >/dev/null

for dependency in kujo ai-sdk agents-sdk watchdog; do
  expected="$(jq -r --arg dependency "$dependency" '.dependencies[$dependency].revision' "$ROOT/release/dependencies.json")"
  path="$ROOT/../$dependency"
  test -d "$path/.git"
  test "$(git -C "$path" rev-parse HEAD)" = "$expected"
done

mkdir -p "$OUTPUT"
export RELAY_CORRELATION_ID="${RELAY_CORRELATION_ID:-relay-live-$(date -u +%Y%m%dT%H%M%SZ)}"
"$ROOT/bin/relay" chat "Bounded Relay v1 release verification" --model "$RELAY_LIVE_MODEL" --provider "$RELAY_LIVE_PROVIDER" --json > "$OUTPUT/chat.json"
jq -e '.ok == true and .relay_telemetry.route == "watchdog_proxy" and .relay_watchdog_verification.correlation.matched == true and .relay_watchdog_verification.usage_reconciliation.available == true and .relay_watchdog_verification.usage_reconciliation.matched == true' "$OUTPUT/chat.json" >/dev/null

"$ROOT/bin/relay" missions run "$RELAY_LIVE_MISSION" --json > "$OUTPUT/mission.json"
run_id="$(jq -r '.run.run_id // .run_id' "$OUTPUT/mission.json")"
run_dir="$(jq -r '.run_dir' "$OUTPUT/mission.json")"
test -n "$run_id" && test "$run_id" != "null"
test -d "$run_dir"
"$ROOT/bin/relay" runs verify "$run_id" --json > "$OUTPUT/verify.json"
"$ROOT/bin/relay" runs export "$run_id" --output "$OUTPUT/export.json" --json > "$OUTPUT/export-command.json"
jq -e '.ok == true and .integrity_valid == true and .tool_results_required == true and .tool_results_valid == true' "$OUTPUT/verify.json" >/dev/null
jq -e --arg run_id "$run_id" '.contract_version == "relay-tool-result-bundle-v1" and .run_id == $run_id and (.results | length) > 0' "$run_dir/tool-results.json" >/dev/null
cp "$run_dir/tool-results.json" "$OUTPUT/tool-results.json"

api_key_name="${RELAY_API_KEY_ENV:-OPENAI_API_KEY}"
for secret_name in RELAY_WATCHDOG_PROXY_TOKEN RELAY_WATCHDOG_API_TOKEN "$api_key_name"; do
  secret_value="${!secret_name:-}"
  if [[ -n "$secret_value" ]] && grep -R -F -- "$secret_value" "$OUTPUT" >/dev/null; then
    echo "FAIL live provider evidence contains a configured secret" >&2
    exit 1
  fi
done

jq -n \
  --arg format relay-live-provider-proof-v1 \
  --arg relay_version "$(cat "$ROOT/VERSION")" \
  --arg relay_commit "$RELAY_EXPECTED_COMMIT" \
  --arg kujo_revision "$(cat "$ROOT/RUNTIME_VERSION")" \
  --arg watchdog_revision "$(jq -r '.dependencies.watchdog.revision' "$ROOT/release/dependencies.json")" \
  --arg ai_sdk_revision "$(jq -r '.dependencies["ai-sdk"].revision' "$ROOT/release/dependencies.json")" \
  --arg agents_sdk_revision "$(jq -r '.dependencies["agents-sdk"].revision' "$ROOT/release/dependencies.json")" \
  --arg provider "$RELAY_LIVE_PROVIDER" \
  --arg model "$RELAY_LIVE_MODEL" \
  --arg watchdog_upstream_profile "${RELAY_WATCHDOG_UPSTREAM_PROFILE:-}" \
  --arg correlation_id "$RELAY_CORRELATION_ID" \
  --arg run_id "$run_id" \
  '{format:$format,relay_version:$relay_version,relay_commit:$relay_commit,kujo_revision:$kujo_revision,watchdog_revision:$watchdog_revision,ai_sdk_revision:$ai_sdk_revision,agents_sdk_revision:$agents_sdk_revision,provider:$provider,model:$model,watchdog_upstream_profile:$watchdog_upstream_profile,correlation_id:$correlation_id,run_id:$run_id,watchdog_bypassed:false,chat_verified:true,usage_reconciled:true,tool_results_verified:true,run_verified:true,export_verified:true,secrets_recorded:false}' > "$OUTPUT/proof.json"

echo "PASS live Watchdog/provider proof: $OUTPUT/proof.json"
