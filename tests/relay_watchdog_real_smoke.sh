#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WATCHDOG_ROOT="${RELAY_WATCHDOG_ROOT:-$ROOT/../watchdog}"
STUB_PORT="${RELAY_TEST_PORT:-18772}"
WATCHDOG_PORT="${RELAY_WATCHDOG_TEST_PORT:-18773}"
CORRELATION="relay-real-watchdog-correlation"
STUB_LOG="/tmp/relay-watchdog-real-stub.log"
WATCHDOG_LOG="/tmp/relay-watchdog-real-server.log"
DB_PATH="/tmp/relay-watchdog-real-$$.db"

test -f "$WATCHDOG_ROOT/dashboard_server.kujo"
rm -f "$STUB_LOG" "$WATCHDOG_LOG" "$DB_PATH"

RELAY_TEST_PORT="$STUB_PORT" RELAY_TEST_CORRELATION="$CORRELATION" "$KUJO" run "$ROOT/tests/relay_watchdog_stub.kujo" --interpreter >"$STUB_LOG" 2>&1 &
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

cleanup() {
  kill "$watchdog_pid" 2>/dev/null || true
  kill "$stub_pid" 2>/dev/null || true
  wait "$watchdog_pid" 2>/dev/null || true
  wait "$stub_pid" 2>/dev/null || true
  rm -f "$DB_PATH" "$DB_PATH"-wal "$DB_PATH"-shm
}
trap cleanup EXIT

ready=0
for _ in $(seq 1 80); do
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
export RELAY_CORRELATION_ID="$CORRELATION"
export OPENAI_API_KEY=relay-stub-provider-key
export KUJO_AI_SDK_ALLOW_INSECURE_LOCALHOST=true

result="$($KUJO run "$ROOT/main.kujo" -- chat watchdog-real-smoke --model stub-model --provider openai-compatible --json)"
printf '%s' "$result" | grep -q 'relay-watchdog-upstream-ok'
printf '%s' "$result" | grep -q '"ok":true'
printf '%s' "$result" | grep -q '"route":"watchdog_proxy"'
printf '%s' "$result" | grep -q '"matched":true'
printf '%s' "$result" | grep -q '"usage_reconciliation"'
printf '%s' "$result" | grep -q '"correlation_id":"relay-real-watchdog-correlation"'
if printf '%s' "$result" | grep -q 'relay-proxy-token\|relay-api-token\|relay-stub-provider-key'; then
  echo "Watchdog/provider secret leaked into output" >&2
  exit 1
fi

echo "PASS relay real Watchdog smoke"
