#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELAY_TEST_TMP_ROOT="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
export RELAY_STATE_ROOT="${RELAY_STATE_ROOT:-$RELAY_TEST_TMP_ROOT/relay-test-state-${UID:-0}-$$}"
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
grep -q 'Relay source tree' <<<"$doctor"
printf '%s' "$doctor" | jq -e '(.checks | map(select(.name == "Relay run store posture"))[0]) | .ok == true and .limit == 4096 and .exceeded == false' >/dev/null
printf '%s' "$doctor" | jq -e 'all(.checks[] | select(.name | endswith(" version")); .safe == true and (.version | length > 0))' >/dev/null
printf '%s' "$doctor" | jq -e 'all(.checks[] | select(has("path") and .required == true); .safe == true)' >/dev/null
capability_fixture="$(jq -cn --arg root "$ROOT" '{root:$root,run_id:"relay-doctor-stale",session_id:"relay-doctor-stale-session",workspace:"/tmp",nonce:"relay-doctor-stale-nonce",max_calls:1,ttl_ms:1000}')"
RELAY_CAPABILITY_FIXTURE="$capability_fixture" "$KUJO" run "$ROOT/tests/relay_capability_fixture.kujo" --interpreter >/dev/null
sleep 2
stale_doctor="$(RELAY_ROOT="$ROOT" "$KUJO" run "$ROOT/main.kujo" -- doctor --json)"
printf '%s' "$stale_doctor" | jq -e '(.checks | map(select(.name == "Agents SDK capability registry"))[0].stale) >= 1 and (.checks | map(select(.name == "Agents SDK capability registry"))[0].cleaned == 0)' >/dev/null
repair_doctor="$(RELAY_ROOT="$ROOT" "$KUJO" run "$ROOT/main.kujo" -- doctor --repair --json)"
printf '%s' "$repair_doctor" | jq -e '(.checks | map(select(.name == "Agents SDK capability registry"))[0].cleaned) >= 1' >/dev/null
clean_doctor="$(RELAY_ROOT="$ROOT" "$KUJO" run "$ROOT/main.kujo" -- doctor --json)"
printf '%s' "$clean_doctor" | jq -e '(.checks | map(select(.name == "Agents SDK capability registry"))[0].stale) == 0' >/dev/null
locked_fixture="$(jq -cn --arg root "$ROOT" '{root:$root,run_id:"relay-doctor-locked",session_id:"relay-doctor-locked-session",workspace:"/tmp",nonce:"relay-doctor-locked-nonce",max_calls:1,ttl_ms:1000}')"
RELAY_CAPABILITY_FIXTURE="$locked_fixture" "$KUJO" run "$ROOT/tests/relay_capability_fixture.kujo" --interpreter >/dev/null
locked_path="$RELAY_STATE_ROOT/capabilities/$(printf '%s' 'relay-doctor-locked|relay-doctor-locked-session' | shasum -a 256 | awk '{print $1}').json"
mkdir "$locked_path.lock"
now_ms="$(($(date +%s) * 1000))"
jq -n --argjson now "$now_ms" '{contract_version:"relay-capability-lock-v1",owner_id:"cli-active-lock",purpose:"doctor-test",acquired_at_ms:$now,lease_expires_at_ms:($now + 60000)}' > "$locked_path.lock/owner.json"
sleep 2
locked_doctor="$(RELAY_ROOT="$ROOT" "$KUJO" run "$ROOT/main.kujo" -- doctor --repair --json)"
printf '%s' "$locked_doctor" | jq -e '(.checks | map(select(.name == "Agents SDK capability registry"))[0].locked) >= 1 and (.checks | map(select(.name == "Agents SDK capability registry"))[0].cleaned == 0)' >/dev/null
test -f "$locked_path"
expired_ms="$((now_ms - 1000))"
jq -n --argjson now "$now_ms" --argjson expired "$expired_ms" '{contract_version:"relay-capability-lock-v1",owner_id:"cli-expired-lock",purpose:"doctor-test",acquired_at_ms:($now - 60000),lease_expires_at_ms:$expired}' > "$locked_path.lock/owner.json"
unlocked_doctor="$(RELAY_ROOT="$ROOT" "$KUJO" run "$ROOT/main.kujo" -- doctor --repair --json)"
printf '%s' "$unlocked_doctor" | jq -e '(.checks | map(select(.name == "Agents SDK capability registry"))[0].cleaned) >= 1' >/dev/null
jq -e 'select(.lock == "capability" and .previous_owner_id == "cli-expired-lock" and .reason == "expired_lease" and (.integrity_sha256 | length == 64))' "$RELAY_STATE_ROOT/lock-recovery.jsonl" >/dev/null
normalized_doctor="$(RELAY_OFFLINE_FIXTURE=1 "$KUJO" run "$ROOT/main.kujo" -- doctor --json)"
printf '%s' "$normalized_doctor" | jq -e '.ok == true and .mode == "fixture"' >/dev/null
normalized_probe="$(RELAY_OFFLINE_FIXTURE=YES "$KUJO" run "$ROOT/main.kujo" -- models probe fixture-model --json)"
printf '%s' "$normalized_probe" | jq -e '.ok == true and .offline == true' >/dev/null
models="$($KUJO run "$ROOT/main.kujo" -- models list --json)"
printf '%s' "$models" | jq -e '.ok == true and .models[0].tool_planning == false and .models[0].tool_execution == "declared_mission_only" and .models[1].tool_planning == "opt_in_provider_profile" and .models[1].tool_execution == "policy_bound_agents_sdk" and (.models[1].capabilities | index("provider_tool_planning")) != null and (.routing.tool_planning == false)' >/dev/null
printf '%s' "$normalized_probe" | jq -e '.routing.tool_planning == false and .routing.tool_execution == "declared_mission_only"' >/dev/null

for invalid_command in "models unknown" "agents unknown" "models probe" "benchmark unknown $ROOT" "benchmark run"; do
  set +e
  invalid_command_output="$($KUJO run "$ROOT/main.kujo" -- $invalid_command --json 2>&1)"
  invalid_command_status=$?
  set -e
  test "$invalid_command_status" -ne 0
  grep -q 'error' <<<"$invalid_command_output"
done

profile_doctor="$(env -u OPENAI_API_KEY RELAY_OFFLINE_FIXTURE=false RELAY_WATCHDOG_URL='https://watchdog.example.invalid/proxy/v1' RELAY_WATCHDOG_UPSTREAM_PROFILE='shared-provider' "$KUJO" run "$ROOT/main.kujo" -- doctor --json 2>&1 || true)"
printf '%s' "$profile_doctor" | jq -e '(.checks | map(select(.name == "live provider credential"))[0]) | .ok == true and .configured == false and .upstream_profile_configured == true' >/dev/null
unsafe_bridge="/tmp/relay-external-ai-bridge-$$.kujo"
printf '%s' 'print({"ok":true})' > "$unsafe_bridge"
set +e
unsafe_bridge_output="$(RELAY_AI_BRIDGE="$unsafe_bridge" "$KUJO" run "$ROOT/main.kujo" -- chat unsafe-bridge --fixture --json 2>&1)"
unsafe_bridge_status=$?
set -e
rm -f "$unsafe_bridge"
test "$unsafe_bridge_status" -ne 0
printf '%s' "$unsafe_bridge_output" | jq -e '.error.code == "invalid_ai_bridge_path"' >/dev/null
if grep -q "$unsafe_bridge" <<<"$unsafe_bridge_output"; then
  echo "unsafe AI bridge path leaked into output" >&2
  exit 1
fi
set +e
unsafe_bridge_doctor="$(RELAY_AI_BRIDGE="$unsafe_bridge" "$KUJO" run "$ROOT/main.kujo" -- doctor --json 2>&1)"
unsafe_bridge_doctor_status=$?
set -e
test "$unsafe_bridge_doctor_status" -ne 0
printf '%s' "$unsafe_bridge_doctor" | jq -e '.ok == false and (.checks | map(select(.name == "AI bridge source"))[0].safe == false)' >/dev/null
runtime_hash="$(shasum -a 256 "$KUJO" | awk '{print $1}')"
hash_doctor="$(RELAY_KUJO_SHA256="$runtime_hash" "$KUJO" run "$ROOT/main.kujo" -- doctor --json)"
printf '%s' "$hash_doctor" | jq -e '.ok == true and (.checks | map(select(.name == "Kujo runtime hash"))[0].matched == true)' >/dev/null
set +e
wrong_hash_doctor="$(RELAY_KUJO_SHA256="$(printf '%064d' 0)" "$KUJO" run "$ROOT/main.kujo" -- doctor --json 2>&1)"
wrong_hash_status=$?
set -e
test "$wrong_hash_status" -ne 0
printf '%s' "$wrong_hash_doctor" | jq -e '.ok == false and (.checks | map(select(.name == "Kujo runtime hash"))[0].error == "hash_mismatch")' >/dev/null

doctor_link_root="/tmp/relay-doctor-link-$$"
rm -rf "$doctor_link_root"
mkdir -p "$doctor_link_root"
ln -s "$KUJO" "$doctor_link_root/kujo"
set +e
unsafe_dependency_doctor="$(KUJO_BIN="$doctor_link_root/kujo" "$KUJO" run "$ROOT/main.kujo" -- doctor --json 2>&1)"
unsafe_dependency_status=$?
set -e
test "$unsafe_dependency_status" -ne 0
printf '%s' "$unsafe_dependency_doctor" | jq -e '.ok == false and (.checks | map(select(.name == "kujo runtime"))[0].safe == false) and ((.checks | map(select(.name == "kujo runtime"))[0].symlink == true) or (.checks | map(select(.name == "kujo runtime"))[0].symlink_component == true))' >/dev/null
rm -rf "$doctor_link_root"

packwrite_link_root="/tmp/relay-packwrite-link-$$"
rm -rf "$packwrite_link_root"
mkdir -p "$packwrite_link_root"
ln -s "$ROOT/../packwrite/bin/packwrite" "$packwrite_link_root/packwrite"
set +e
unsafe_packwrite_doctor="$(RELAY_PACKWRITE_BIN="$packwrite_link_root/packwrite" "$KUJO" run "$ROOT/main.kujo" -- doctor --json 2>&1)"
unsafe_packwrite_status=$?
set -e
test "$unsafe_packwrite_status" -ne 0
printf '%s' "$unsafe_packwrite_doctor" | jq -e '.ok == false and (.checks | map(select(.name == "PackWrite binary"))[0].safe == false) and ((.checks | map(select(.name == "PackWrite binary"))[0].symlink == true) or (.checks | map(select(.name == "PackWrite binary"))[0].symlink_component == true))' >/dev/null
rm -rf "$packwrite_link_root"

launcher_link_root="/tmp/relay-kujo-launcher-link-$$"
rm -rf "$launcher_link_root"
mkdir -p "$launcher_link_root"
ln -s "$KUJO" "$launcher_link_root/kujo"
set +e
unsafe_launcher="$(KUJO="$launcher_link_root/kujo" "$ROOT/bin/relay" help 2>&1)"
unsafe_launcher_status=$?
set -e
test "$unsafe_launcher_status" -ne 0
case "$unsafe_launcher" in
  *"refusing symlinked Kujo runtime path"*) ;;
  *) exit 1 ;;
esac
rm -rf "$launcher_link_root"

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
grep -q '"watchdog_auth_configured":true' <<<"$token_output"
if grep -q 'relay-test-proxy-token' <<<"$token_output"; then
  echo "Watchdog proxy token leaked into fixture output" >&2
  exit 1
fi

route_output="$(RELAY_WATCHDOG_URL='https://watchdog.example.com/proxy/v1' "$KUJO" run "$ROOT/main.kujo" -- chat route-boundary --fixture --json)"
grep -q '"watchdog_route"' <<<"$route_output"
if grep -q 'watchdog.example.com' <<<"$route_output"; then
  echo "Watchdog route leaked into fixture telemetry" >&2
  exit 1
fi

set +e
credential_route_output="$(RELAY_WATCHDOG_URL='https://user:route-secret@watchdog.example.com/proxy/v1' "$KUJO" run "$ROOT/main.kujo" -- chat credential-route-boundary --fixture --json 2>&1)"
credential_route_status=$?
set -e
test "$credential_route_status" -ne 0
grep -q '"reason":"embedded_credentials"' <<<"$credential_route_output"
if grep -q 'route-secret\|watchdog.example.com' <<<"$credential_route_output"; then
  echo "Credential-bearing Watchdog route leaked into fixture telemetry" >&2
  exit 1
fi

correlation_output="$(RELAY_CORRELATION_ID='relay&extra=1' "$KUJO" run "$ROOT/main.kujo" -- chat correlation-boundary --fixture --json)"
grep -q '"correlation_id":"relay-ai-' <<<"$correlation_output"
if grep -q 'relay&extra=1' <<<"$correlation_output"; then
  echo "Unsafe correlation ID reached telemetry" >&2
  exit 1
fi

set +e
invalid_watchdog="$(RELAY_OFFLINE_FIXTURE=false RELAY_WATCHDOG_URL='file:///tmp/watchdog' "$KUJO" run "$ROOT/main.kujo" -- chat invalid-route --json 2>&1)"
watchdog_status=$?
set -e
test "$watchdog_status" -ne 0
grep -q 'invalid_watchdog_route' <<<"$invalid_watchdog"

set +e
external_http_watchdog="$(RELAY_OFFLINE_FIXTURE=false RELAY_WATCHDOG_URL='http://watchdog.example.com/proxy/v1' "$KUJO" run "$ROOT/main.kujo" -- chat external-http-route --json 2>&1)"
external_http_status=$?
set -e
test "$external_http_status" -ne 0
grep -q 'invalid_watchdog_route' <<<"$external_http_watchdog"

set +e
unsafe_doctor="$(RELAY_OFFLINE_FIXTURE=false RELAY_WATCHDOG_URL='http://watchdog.example.com/proxy/v1' "$KUJO" run "$ROOT/main.kujo" -- doctor --json 2>&1)"
unsafe_doctor_status=$?
set -e
test "$unsafe_doctor_status" -ne 0
grep -q '"valid":false' <<<"$unsafe_doctor"
if grep -q 'watchdog.example.com' <<<"$unsafe_doctor"; then
  echo "doctor leaked the configured Watchdog route" >&2
  exit 1
fi

set +e
credential_doctor="$(RELAY_OFFLINE_FIXTURE=false RELAY_WATCHDOG_URL='https://user:route-secret@watchdog.example.com/proxy/v1' "$KUJO" run "$ROOT/main.kujo" -- doctor --json 2>&1)"
credential_doctor_status=$?
set -e
test "$credential_doctor_status" -ne 0
grep -q 'embedded_credentials' <<<"$credential_doctor"
if grep -q 'route-secret\|watchdog.example.com' <<<"$credential_doctor"; then
  echo "doctor leaked an unsafe Watchdog route" >&2
  exit 1
fi

set +e
unreachable_doctor="$(RELAY_OFFLINE_FIXTURE=false RELAY_WATCHDOG_URL='https://127.0.0.1:1/proxy/v1' RELAY_WATCHDOG_VERIFY=true "$KUJO" run "$ROOT/main.kujo" -- doctor --json 2>&1)"
unreachable_doctor_status=$?
set -e
test "$unreachable_doctor_status" -ne 0
grep -q 'Watchdog HTTP request failed' <<<"$unreachable_doctor"
if grep -q '127.0.0.1:1\|proxy/v1' <<<"$unreachable_doctor"; then
  echo "doctor leaked the configured Watchdog endpoint on request failure" >&2
  exit 1
fi

stream="$($KUJO run "$ROOT/main.kujo" -- chat stream-boundary --fixture --stream --json)"
grep -q '"type":"delta"' <<<"$stream"
grep -q '"type":"done"' <<<"$stream"
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
grep -q 'agent tool is not supported' <<<"$invalid_tool"

echo "PASS relay CLI smoke"
