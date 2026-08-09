#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELAY_TEST_TMP_ROOT="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
export RELAY_STATE_ROOT="${RELAY_STATE_ROOT:-$RELAY_TEST_TMP_ROOT/relay-test-state-${UID:-0}-$$}"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
PORT="${RELAY_TEST_PORT:-18770}"
CORRELATION="relay-test-correlation"
LOG="/tmp/relay-watchdog-stub.log"

rm -f "$LOG"
RELAY_TEST_PORT="$PORT" RELAY_TEST_CORRELATION="$CORRELATION" "$KUJO" run "$ROOT/tests/relay_watchdog_stub.kujo" --interpreter >"$LOG" 2>&1 &
stub_pid=$!
cleanup() { kill "$stub_pid" 2>/dev/null || true; wait "$stub_pid" 2>/dev/null || true; }
trap cleanup EXIT

ready=0
for _ in $(seq 1 40); do
  if curl -fsS "http://127.0.0.1:$PORT/healthz" >/dev/null 2>&1; then ready=1; break; fi
  sleep 0.05
done
test "$ready" -eq 1

export RELAY_ROOT="$ROOT"
export RELAY_OFFLINE_FIXTURE=false
export RELAY_WATCHDOG_URL="http://127.0.0.1:$PORT/proxy/v1"
export RELAY_WATCHDOG_API_URL="http://127.0.0.1:$PORT"
export RELAY_WATCHDOG_PROXY_TOKEN=relay-proxy-token
export RELAY_WATCHDOG_API_TOKEN=relay-api-token
export RELAY_WATCHDOG_VERIFY=true
export RELAY_CORRELATION_ID="$CORRELATION"
export OPENAI_API_KEY=relay-stub-provider-key
export KUJO_AI_SDK_ALLOW_INSECURE_LOCALHOST=true

result="$($KUJO run "$ROOT/main.kujo" -- chat watchdog-smoke --model stub-model --provider openai-compatible --json)"
grep -q '"ok":true' <<<"$result"
grep -q '"route":"watchdog_proxy"' <<<"$result"
grep -q '"relay_watchdog_verification"' <<<"$result"
grep -q '"usage_reconciliation"' <<<"$result"
printf '%s' "$result" | jq -e '.relay_watchdog_verification.correlation.request_id == "stub-request" and .relay_watchdog_verification.usage_reconciliation.available == true and .relay_watchdog_verification.usage_reconciliation.matched == true' >/dev/null
grep -q '"correlation_id":"relay-test-correlation"' <<<"$result"
if grep -q 'relay-proxy-token\|relay-api-token\|relay-stub-provider-key' <<<"$result"; then
  echo "Watchdog/provider secret leaked into output" >&2
  exit 1
fi

set +e
missing="$(RELAY_CORRELATION_ID=relay-missing-correlation "$KUJO" run "$ROOT/main.kujo" -- chat watchdog-smoke --model stub-model --provider openai-compatible --json 2>&1)"
missing_rc=$?
set -e
test "$missing_rc" -ne 0
grep -q 'watchdog_telemetry_unverified' <<<"$missing"

echo "PASS relay Watchdog contract smoke"
