#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELAY_TEST_TMP_ROOT="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
export RELAY_STATE_ROOT="${RELAY_STATE_ROOT:-$RELAY_TEST_TMP_ROOT/relay-test-state-${UID:-0}-$$}"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
# Propagate the selected runtime into the nested Agents SDK bridge. The bridge
# deliberately rejects a payload binary that differs from trusted KUJO_BIN;
# leaving KUJO_BIN unset here makes an explicitly supplied absolute KUJO path
# compare unequal to the bridge's relative fallback.
export KUJO_BIN="$KUJO"
AGENTS_SDK="${RELAY_AGENTS_SDK_PATH:-$ROOT/../agents-sdk}"
WORK="/tmp/relay-agents-sdk-tools-workspace"

rm -rf "$WORK"
rm -rf "$RELAY_STATE_ROOT/capabilities"
trap 'rm -rf "$RELAY_STATE_ROOT/capabilities"' EXIT
mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline

export RELAY_ROOT="$ROOT"

issue_capability() {
  local run_id="$1"
  local session_id="$2"
  local nonce="$3"
  local max_calls="${4:-4}"
  local ttl_ms="${5:-180000}"
  local fixture
  fixture="$(jq -cn --arg root "$ROOT" --arg run_id "$run_id" --arg session_id "$session_id" --arg work "$WORK" --arg nonce "$nonce" --argjson max_calls "$max_calls" --argjson ttl_ms "$ttl_ms" '{root:$root,run_id:$run_id,session_id:$session_id,workspace:$work,nonce:$nonce,max_calls:$max_calls,ttl_ms:$ttl_ms}')"
  RELAY_CAPABILITY_FIXTURE="$fixture" "$KUJO" run "$ROOT/tests/relay_capability_fixture.kujo" --interpreter
}

set +e
result="$("$KUJO" run "$ROOT/main.kujo" -- missions run "$ROOT/examples/agents-sdk-tools-mission.json" --fixture --skip-agent-smoke --json)"
result_exit=$?
set -e
if [[ "$result_exit" -ne 0 ]] || ! printf '%s' "$result" | jq -e '.ok == true and .run.status == "completed" and .run.agent_sdk_tools.ok == true and (.run.events | any(.payload.kind == "agents_sdk_tool_registry"))' >/dev/null; then
  echo "Relay Agents SDK fixture mission did not satisfy its JSON contract" >&2
  printf '%s' "$result" | jq -c '{ok, error, run: {status: .run.status, failure: .run.failure, agent_sdk_tools: .run.agent_sdk_tools}}' >&2 || true
  exit 1
fi
test -f "$WORK/RELAY_AGENT_TOOL_OUTPUT.txt"
grep -q 'Agents SDK tool registry' "$WORK/RELAY_AGENT_TOOL_OUTPUT.txt"

# Provider/Agents SDK workers must preserve the mission's script provenance
# policy when they delegate a command to Relay.
mkdir -p "$WORK/scripts"
printf '#!/bin/sh\nprintf pinned-agent-script\n' > "$WORK/scripts/pinned.sh"
chmod +x "$WORK/scripts/pinned.sh"
script_sha="$(ruby -rdigest -e 'print Digest::SHA256.file(ARGV.fetch(0)).hexdigest' "$WORK/scripts/pinned.sh")"
script_nonce="relay-script-provenance-smoke-private-nonce"
script_capability="$(printf '%s' "relay-script-provenance|relay-script-provenance-session|$WORK|$script_nonce|relay-agent-tools" | shasum -a 256 | awk '{print $1}')"
script_fixture="$(issue_capability relay-script-provenance relay-script-provenance-session "$script_nonce" 1)"
script_secret="$(printf '%s' "$script_fixture" | jq -r .secret)"
script_payload="$(jq -cn --arg root "$ROOT" --arg kujo "$KUJO" --arg work "$WORK" --arg capability "$script_capability" --arg nonce "$script_nonce" --arg secret "$script_secret" --arg sha "$script_sha" '{relay_root:$root,kujo_bin:$kujo,capability:$capability,capability_nonce:$nonce,capability_secret:$secret,run_id:"relay-script-provenance",session_id:"relay-script-provenance-session",workspace:$work,approval_approved:false,mission_spec:{allow_writes:false,approval:{approved:false},allowed_commands:["bash"],allowed_script_hashes:{"scripts/pinned.sh":$sha},budgets:{max_tool_calls:1,max_output_bytes:1048576,max_write_bytes:1048576}},tool_calls:[{name:"relay.run_command",input:{command:"bash scripts/pinned.sh"}}]}')"
script_output="$(cd "$AGENTS_SDK" && RELAY_AGENT_PAYLOAD="$script_payload" "$KUJO" run "$ROOT/src/agent_bridge.kujo" --interpreter 2>&1)"
printf '%s' "$script_output" | jq -e '.ok == true and (.tool_calls | any(.tool_name == "relay.run_command" and .ok == true and (.output.stdout | contains("pinned-agent-script"))))' >/dev/null

denied_nonce="relay-denied-smoke-private-nonce"
denied_capability="$(printf '%s' "relay-denied-smoke|relay-denied-smoke-session|$WORK|$denied_nonce|relay-agent-tools" | shasum -a 256 | awk '{print $1}')"
denied_fixture="$(issue_capability relay-denied-smoke relay-denied-smoke-session "$denied_nonce" 4)"
denied_secret="$(printf '%s' "$denied_fixture" | jq -r .secret)"
denied_payload="$(jq -cn --arg root "$ROOT" --arg kujo "$KUJO" --arg work "$WORK" --arg capability "$denied_capability" --arg nonce "$denied_nonce" --arg secret "$denied_secret" '{relay_root:$root,kujo_bin:$kujo,capability:$capability,capability_nonce:$nonce,capability_secret:$secret,run_id:"relay-denied-smoke",session_id:"relay-denied-smoke-session",workspace:$work,approval_approved:false,mission_spec:{allow_writes:true,approval:{approved:false},allowed_commands:["git"],budgets:{max_output_bytes:1048576,max_write_bytes:1048576}},tool_calls:[{name:"relay.write_file",input:{path:"RELAY_AGENT_TOOL_DENIED.txt",content:"must not be written\n"}}]}')"
set +e
denied_output="$(RELAY_AGENT_PAYLOAD="$denied_payload" "$KUJO" run "$ROOT/src/agent_bridge.kujo" --interpreter 2>&1)"
denied_exit=$?
set -e
test "$denied_exit" -ne 0
[[ "$denied_output" == *'"error_kind":"approval_denied"'* ]]
test ! -e "$WORK/RELAY_AGENT_TOOL_DENIED.txt"

tampered_payload="$(printf '%s' "$denied_payload" | jq '.relay_root="/tmp" | .approval_approved=true | .mission_spec.approval.approved=true')"
set +e
tampered_output="$(RELAY_AGENT_PAYLOAD="$tampered_payload" "$KUJO" run "$ROOT/src/agent_bridge.kujo" --interpreter 2>&1)"
tampered_exit=$?
set -e
test "$tampered_exit" -ne 0
[[ "$tampered_output" == *'relay_root_mismatch'* ]]
test ! -e "$WORK/RELAY_AGENT_TOOL_DENIED.txt"

direct_nonce="relay-direct-policy-private-nonce"
direct_capability="$(printf '%s' "relay-direct-policy|relay-direct-policy-session|$WORK|$direct_nonce|relay-agent-tools" | shasum -a 256 | awk '{print $1}')"
direct_fixture="$(issue_capability relay-direct-policy relay-direct-policy-session "$direct_nonce" 4)"
direct_secret="$(printf '%s' "$direct_fixture" | jq -r .secret)"
direct_payload="$(jq -cn --arg work "$WORK" --arg capability "$direct_capability" --arg nonce "$direct_nonce" '{capability:$capability,capability_nonce:$nonce,run_id:"relay-direct-policy",session_id:"relay-direct-policy-session",workspace:$work,mission_spec:{allow_writes:true,approval:{approved:false},allowed_commands:["git"],budgets:{max_output_bytes:1048576,max_write_bytes:1048576}},tool_name:"relay.write_file",input:{path:"RELAY_AGENT_TOOL_DIRECT_DENIED.txt",content:"must not be written\n"}}')"
set +e
direct_output="$(RELAY_TOOL_REQUEST="$direct_payload" RELAY_TOOL_CAPABILITY="$direct_capability" RELAY_TOOL_CAPABILITY_SECRET="$direct_secret" "$KUJO" run "$ROOT/main.kujo" -- tools execute --json 2>&1)"
direct_exit=$?
set -e
test "$direct_exit" -ne 0
[[ "$direct_output" == *'write-enabled tool requests require approval.approved=true'* ]]
test ! -e "$WORK/RELAY_AGENT_TOOL_DIRECT_DENIED.txt"

replay_nonce="relay-replay-smoke-private-nonce"
replay_capability="$(printf '%s' "relay-replay-smoke|relay-replay-smoke-session|$WORK|$replay_nonce|relay-agent-tools" | shasum -a 256 | awk '{print $1}')"
replay_fixture="$(issue_capability relay-replay-smoke relay-replay-smoke-session "$replay_nonce" 1)"
replay_secret="$(printf '%s' "$replay_fixture" | jq -r .secret)"
replay_payload="$(jq -cn --arg work "$WORK" --arg capability "$replay_capability" --arg nonce "$replay_nonce" '{capability:$capability,capability_nonce:$nonce,run_id:"relay-replay-smoke",session_id:"relay-replay-smoke-session",workspace:$work,mission_spec:{allow_writes:false,approval:{approved:false},allowed_commands:["git"],budgets:{max_output_bytes:1048576,max_write_bytes:1048576}},tool_name:"relay.run_command",input:{command:"git status --short"}}')"
replay_first="$(RELAY_TOOL_REQUEST="$replay_payload" RELAY_TOOL_CAPABILITY="$replay_capability" RELAY_TOOL_CAPABILITY_SECRET="$replay_secret" "$KUJO" run "$ROOT/main.kujo" -- tools execute --json)"
printf '%s' "$replay_first" | jq -e '.ok == true and .tool_name == "relay.run_command"' >/dev/null
set +e
replay_second="$(RELAY_TOOL_REQUEST="$replay_payload" RELAY_TOOL_CAPABILITY="$replay_capability" RELAY_TOOL_CAPABILITY_SECRET="$replay_secret" "$KUJO" run "$ROOT/main.kujo" -- tools execute --json 2>&1)"
replay_exit=$?
set -e
test "$replay_exit" -ne 0
[[ "$replay_second" == *'capability_replay_detected'* ]]

expiry_nonce="relay-expiry-smoke-private-nonce"
expiry_capability="$(printf '%s' "relay-expiry-smoke|relay-expiry-smoke-session|$WORK|$expiry_nonce|relay-agent-tools" | shasum -a 256 | awk '{print $1}')"
expiry_fixture="$(issue_capability relay-expiry-smoke relay-expiry-smoke-session "$expiry_nonce" 1 1000)"
expiry_secret="$(printf '%s' "$expiry_fixture" | jq -r .secret)"
expiry_payload="$(jq -cn --arg work "$WORK" --arg capability "$expiry_capability" --arg nonce "$expiry_nonce" '{capability:$capability,capability_nonce:$nonce,run_id:"relay-expiry-smoke",session_id:"relay-expiry-smoke-session",workspace:$work,mission_spec:{allow_writes:false,approval:{approved:false},allowed_commands:["git"],budgets:{max_output_bytes:1048576,max_write_bytes:1048576}},tool_name:"relay.run_command",input:{command:"git status --short"}}')"
sleep 2
set +e
expiry_output="$(RELAY_TOOL_REQUEST="$expiry_payload" RELAY_TOOL_CAPABILITY="$expiry_capability" RELAY_TOOL_CAPABILITY_SECRET="$expiry_secret" "$KUJO" run "$ROOT/main.kujo" -- tools execute --json 2>&1)"
expiry_exit=$?
set -e
test "$expiry_exit" -ne 0
[[ "$expiry_output" == *'capability_expired'* ]]

legacy_payload="$(printf '%s' "$direct_payload" | jq 'del(.capability_nonce)')"
set +e
legacy_output="$(RELAY_TOOL_REQUEST="$legacy_payload" RELAY_TOOL_CAPABILITY="$direct_capability" "$KUJO" run "$ROOT/main.kujo" -- tools execute --json 2>&1)"
legacy_exit=$?
set -e
test "$legacy_exit" -ne 0
[[ "$legacy_output" == *'tool capability is invalid'* ]]

timeout_payload="$(jq -cn --arg work "$WORK" --arg capability "$direct_capability" --arg nonce "$direct_nonce" '{capability:$capability,capability_nonce:$nonce,run_id:"relay-direct-policy",session_id:"relay-direct-policy-session",workspace:$work,mission_spec:{allow_writes:false,approval:{approved:false},allowed_commands:["git"],budgets:{max_output_bytes:1048576,max_write_bytes:1048576}},tool_name:"relay.run_command",input:{command:"git status --short",timeout_ms:0}}')"
set +e
timeout_output="$(RELAY_TOOL_REQUEST="$timeout_payload" RELAY_TOOL_CAPABILITY="$direct_capability" RELAY_TOOL_CAPABILITY_SECRET="$direct_secret" "$KUJO" run "$ROOT/main.kujo" -- tools execute --json 2>&1)"
timeout_exit=$?
set -e
test "$timeout_exit" -ne 0
[[ "$timeout_output" == *'tool timeout_ms must be between 1 and 600000'* ]]

secret_failure_payload="$(jq -cn --arg root "$ROOT" --arg kujo "$KUJO" --arg work "$WORK" --arg capability "$direct_capability" --arg nonce "$direct_nonce" --arg secret "$direct_secret" '{relay_root:$root,kujo_bin:$kujo,capability:$capability,capability_nonce:$nonce,capability_secret:$secret,run_id:"relay-direct-policy",session_id:"relay-direct-policy-session",workspace:$work,approval_approved:false,mission_spec:{allow_writes:false,approval:{approved:false},allowed_commands:["git"],budgets:{max_output_bytes:1048576,max_write_bytes:1048576}},tool_calls:[{name:"relay.run_command",input:{command:"git status --short"}}],output_text:"Authorization: Bearer sk-secret-leak-probe"}')"
set +e
secret_failure_output="$(cd "$AGENTS_SDK" && RELAY_AGENT_PAYLOAD="$secret_failure_payload" "$KUJO" run "$ROOT/src/agent_bridge.kujo" --interpreter 2>&1)"
secret_failure_exit=$?
set -e
test "$secret_failure_exit" -eq 0
if printf '%s' "$secret_failure_output" | grep -q 'sk-secret-leak-probe'; then
  echo "Agents SDK bridge leaked a credential-shaped output value" >&2
  exit 1
fi

budget_payload="$(jq -cn --arg work "$WORK" --arg capability "$direct_capability" --arg nonce "$direct_nonce" '{capability:$capability,capability_nonce:$nonce,run_id:"relay-direct-policy",session_id:"relay-direct-policy-session",workspace:$work,mission_spec:{allow_writes:false,approval:{approved:false},allowed_commands:["git"],budgets:{max_output_bytes:0,max_write_bytes:1048576}},tool_name:"relay.run_command",input:{command:"git status --short"}}')"
set +e
budget_output="$(RELAY_TOOL_REQUEST="$budget_payload" RELAY_TOOL_CAPABILITY="$direct_capability" "$KUJO" run "$ROOT/main.kujo" -- tools execute --json 2>&1)"
budget_exit=$?
set -e
test "$budget_exit" -ne 0
[[ "$budget_output" == *'tool budgets must be between 1 and 8388608 bytes'* ]]

budget_nonce="relay-budget-smoke-private-nonce"
budget_capability="$(printf '%s' "relay-budget-smoke|relay-budget-smoke-session|$WORK|$budget_nonce|relay-agent-tools" | shasum -a 256 | awk '{print $1}')"
budget_fixture="$(issue_capability relay-budget-smoke relay-budget-smoke-session "$budget_nonce" 1)"
budget_secret="$(printf '%s' "$budget_fixture" | jq -r .secret)"
budget_payload="$(jq -cn --arg root "$ROOT" --arg kujo "$KUJO" --arg work "$WORK" --arg capability "$budget_capability" --arg nonce "$budget_nonce" --arg secret "$budget_secret" '{relay_root:$root,kujo_bin:$kujo,capability:$capability,capability_nonce:$nonce,capability_secret:$secret,run_id:"relay-budget-smoke",session_id:"relay-budget-smoke-session",workspace:$work,approval_approved:false,mission_spec:{allow_writes:false,approval:{approved:false},allowed_commands:["git"],budgets:{max_tool_calls:1,max_output_bytes:1048576,max_write_bytes:1048576}},tool_calls:[{name:"relay.run_command",input:{command:"git status --short"}},{name:"relay.run_command",input:{command:"git status --short"}}]}')"
set +e
budget_output="$(RELAY_AGENT_PAYLOAD="$budget_payload" "$KUJO" run "$ROOT/src/agent_bridge.kujo" --interpreter 2>&1)"
budget_exit=$?
set -e
test "$budget_exit" -ne 0
[[ "$budget_output" == *'budget_exceeded'* ]]

echo "PASS relay Agents SDK tool smoke"
