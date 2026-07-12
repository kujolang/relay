#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"

json="$($KUJO run "$ROOT/main.kujo" -- agents validate --json)"
case "$json" in
  *'"ok":true'*) ;;
  *) echo "agents validation did not pass" >&2; exit 1 ;;
esac

doctor="$($KUJO run "$ROOT/main.kujo" -- doctor --json)"
case "$doctor" in
  *'"ok":true'*'"mode":"fixture"'*) ;;
  *) echo "fixture doctor contract did not pass" >&2; exit 1 ;;
esac
printf '%s' "$doctor" | grep -q 'Relay source tree'

probe="$($KUJO run "$ROOT/main.kujo" -- models probe fixture-model --fixture --json)"
case "$probe" in
  *'"ok":true'*'"model":"fixture-model"'*) ;;
  *) echo "model probe contract did not pass" >&2; exit 1 ;;
esac

chat="$($KUJO run "$ROOT/main.kujo" -- chat smoke --fixture --json)"
case "$chat" in
  *'"ok":true'*'"relay_telemetry"'*) ;;
  *) echo "fixture chat contract did not pass" >&2; exit 1 ;;
esac

token_output="$(RELAY_WATCHDOG_PROXY_TOKEN='relay-test-proxy-token' "$KUJO" run "$ROOT/main.kujo" -- chat token-boundary --fixture --json)"
printf '%s' "$token_output" | grep -q '"watchdog_auth_configured":true'
if printf '%s' "$token_output" | grep -q 'relay-test-proxy-token'; then
  echo "Watchdog proxy token leaked into fixture output" >&2
  exit 1
fi

route_output="$(RELAY_WATCHDOG_URL='https://watchdog.example.com/proxy/v1' "$KUJO" run "$ROOT/main.kujo" -- chat route-boundary --fixture --json)"
printf '%s' "$route_output" | grep -q '"watchdog_route"'
if printf '%s' "$route_output" | grep -q 'watchdog.example.com'; then
  echo "Watchdog route leaked into fixture telemetry" >&2
  exit 1
fi

set +e
credential_route_output="$(RELAY_WATCHDOG_URL='https://user:route-secret@watchdog.example.com/proxy/v1' "$KUJO" run "$ROOT/main.kujo" -- chat credential-route-boundary --fixture --json 2>&1)"
credential_route_status=$?
set -e
test "$credential_route_status" -ne 0
printf '%s' "$credential_route_output" | grep -q '"reason":"embedded_credentials"'
if printf '%s' "$credential_route_output" | grep -q 'route-secret\|watchdog.example.com'; then
  echo "Credential-bearing Watchdog route leaked into fixture telemetry" >&2
  exit 1
fi

correlation_output="$(RELAY_CORRELATION_ID='relay&extra=1' "$KUJO" run "$ROOT/main.kujo" -- chat correlation-boundary --fixture --json)"
printf '%s' "$correlation_output" | grep -q '"correlation_id":"relay-ai-'
if printf '%s' "$correlation_output" | grep -q 'relay&extra=1'; then
  echo "Unsafe correlation ID reached telemetry" >&2
  exit 1
fi

set +e
invalid_watchdog="$(RELAY_OFFLINE_FIXTURE=false RELAY_WATCHDOG_URL='file:///tmp/watchdog' "$KUJO" run "$ROOT/main.kujo" -- chat invalid-route --json 2>&1)"
watchdog_status=$?
set -e
test "$watchdog_status" -ne 0
printf '%s' "$invalid_watchdog" | grep -q 'invalid_watchdog_route'

set +e
external_http_watchdog="$(RELAY_OFFLINE_FIXTURE=false RELAY_WATCHDOG_URL='http://watchdog.example.com/proxy/v1' "$KUJO" run "$ROOT/main.kujo" -- chat external-http-route --json 2>&1)"
external_http_status=$?
set -e
test "$external_http_status" -ne 0
printf '%s' "$external_http_watchdog" | grep -q 'invalid_watchdog_route'

set +e
unsafe_doctor="$(RELAY_OFFLINE_FIXTURE=false RELAY_WATCHDOG_URL='http://watchdog.example.com/proxy/v1' "$KUJO" run "$ROOT/main.kujo" -- doctor --json 2>&1)"
unsafe_doctor_status=$?
set -e
test "$unsafe_doctor_status" -ne 0
printf '%s' "$unsafe_doctor" | grep -q '"valid":false'
if printf '%s' "$unsafe_doctor" | grep -q 'watchdog.example.com'; then
  echo "doctor leaked the configured Watchdog route" >&2
  exit 1
fi

set +e
credential_doctor="$(RELAY_OFFLINE_FIXTURE=false RELAY_WATCHDOG_URL='https://user:route-secret@watchdog.example.com/proxy/v1' "$KUJO" run "$ROOT/main.kujo" -- doctor --json 2>&1)"
credential_doctor_status=$?
set -e
test "$credential_doctor_status" -ne 0
printf '%s' "$credential_doctor" | grep -q 'embedded_credentials'
if printf '%s' "$credential_doctor" | grep -q 'route-secret\|watchdog.example.com'; then
  echo "doctor leaked an unsafe Watchdog route" >&2
  exit 1
fi

stream="$($KUJO run "$ROOT/main.kujo" -- chat stream-boundary --fixture --stream --json)"
printf '%s' "$stream" | grep -q '"type":"delta"'
printf '%s' "$stream" | grep -q '"type":"done"'
test "$(printf '%s' "$stream" | grep -o '"type":"done"' | wc -l | tr -d ' ')" -eq 1

set +e
invalid="$($KUJO run "$ROOT/main.kujo" -- missions run "$ROOT/examples/invalid-approval-mission.json" --fixture --json 2>&1)"
status=$?
set -e
test "$status" -ne 0
case "$invalid" in
  *"approval.approved=true"*) ;;
  *) echo "unapproved write mission was not rejected" >&2; exit 1 ;;
esac

set +e
invalid_tool="$($KUJO run "$ROOT/main.kujo" -- missions run "$ROOT/examples/invalid-agent-tool-mission.json" --fixture --json 2>&1)"
tool_status=$?
set -e
test "$tool_status" -ne 0
printf '%s' "$invalid_tool" | grep -q 'agent tool is not supported'

echo "PASS relay CLI smoke"
