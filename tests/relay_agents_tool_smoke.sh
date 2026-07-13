#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
AGENTS_SDK="${RELAY_AGENTS_SDK_PATH:-$ROOT/../agents-sdk}"
WORK="/tmp/relay-agents-sdk-tools-workspace"

rm -rf "$WORK"
mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline

export RELAY_ROOT="$ROOT"
result="$($KUJO run "$ROOT/main.kujo" -- missions run "$ROOT/examples/agents-sdk-tools-mission.json" --fixture --skip-agent-smoke --json)"
[[ "$result" == *'"status":"completed"'* ]]
[[ "$result" == *'"agents_sdk_tools"'* ]]
[[ "$result" == *'"kind":"agents_sdk_tool_registry"'* ]]
test -f "$WORK/RELAY_AGENT_TOOL_OUTPUT.txt"
grep -q 'Agents SDK tool registry' "$WORK/RELAY_AGENT_TOOL_OUTPUT.txt"

denied_capability="$(printf '%s' "relay-denied-smoke|relay-denied-smoke-session|$WORK|relay-agent-tools" | shasum -a 256 | awk '{print $1}')"
denied_payload="$(jq -cn --arg root "$ROOT" --arg kujo "$KUJO" --arg work "$WORK" --arg capability "$denied_capability" '{relay_root:$root,kujo_bin:$kujo,capability:$capability,run_id:"relay-denied-smoke",session_id:"relay-denied-smoke-session",workspace:$work,approval_approved:false,mission_spec:{allow_writes:true,approval:{approved:false},allowed_commands:["git"],budgets:{max_output_bytes:1048576,max_write_bytes:1048576}},tool_calls:[{name:"relay.write_file",input:{path:"RELAY_AGENT_TOOL_DENIED.txt",content:"must not be written\n"}}]}')"
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

direct_capability="$(printf '%s' "relay-direct-policy|relay-direct-policy-session|$WORK|relay-agent-tools" | shasum -a 256 | awk '{print $1}')"
direct_payload="$(jq -cn --arg work "$WORK" --arg capability "$direct_capability" '{capability:$capability,run_id:"relay-direct-policy",session_id:"relay-direct-policy-session",workspace:$work,mission_spec:{allow_writes:true,approval:{approved:false},allowed_commands:["git"],budgets:{max_output_bytes:1048576,max_write_bytes:1048576}},tool_name:"relay.write_file",input:{path:"RELAY_AGENT_TOOL_DIRECT_DENIED.txt",content:"must not be written\n"}}')"
set +e
direct_output="$(RELAY_TOOL_REQUEST="$direct_payload" RELAY_TOOL_CAPABILITY="$direct_capability" "$KUJO" run "$ROOT/main.kujo" -- tools execute --json 2>&1)"
direct_exit=$?
set -e
test "$direct_exit" -ne 0
[[ "$direct_output" == *'write-enabled tool requests require approval.approved=true'* ]]
test ! -e "$WORK/RELAY_AGENT_TOOL_DIRECT_DENIED.txt"

timeout_payload="$(jq -cn --arg work "$WORK" --arg capability "$direct_capability" '{capability:$capability,run_id:"relay-direct-policy",session_id:"relay-direct-policy-session",workspace:$work,mission_spec:{allow_writes:false,approval:{approved:false},allowed_commands:["git"],budgets:{max_output_bytes:1048576,max_write_bytes:1048576}},tool_name:"relay.run_command",input:{command:"git status --short",timeout_ms:0}}')"
set +e
timeout_output="$(RELAY_TOOL_REQUEST="$timeout_payload" RELAY_TOOL_CAPABILITY="$direct_capability" "$KUJO" run "$ROOT/main.kujo" -- tools execute --json 2>&1)"
timeout_exit=$?
set -e
test "$timeout_exit" -ne 0
[[ "$timeout_output" == *'tool timeout_ms must be between 1 and 600000'* ]]

secret_failure_payload="$(jq -cn --arg root "$ROOT" --arg kujo "$KUJO" --arg work "$WORK" --arg capability "$direct_capability" '{relay_root:$root,kujo_bin:$kujo,capability:$capability,run_id:"relay-direct-policy",session_id:"relay-direct-policy-session",workspace:$work,approval_approved:false,mission_spec:{allow_writes:false,approval:{approved:false},allowed_commands:["git"],budgets:{max_output_bytes:1048576,max_write_bytes:1048576}},tool_calls:[{name:"relay.run_command",input:{command:"git status --short"}}],output_text:"Authorization: Bearer sk-secret-leak-probe"}')"
set +e
secret_failure_output="$(cd "$AGENTS_SDK" && RELAY_AGENT_PAYLOAD="$secret_failure_payload" "$KUJO" run "$ROOT/src/agent_bridge.kujo" --interpreter 2>&1)"
secret_failure_exit=$?
set -e
test "$secret_failure_exit" -eq 0
if printf '%s' "$secret_failure_output" | grep -q 'sk-secret-leak-probe'; then
  echo "Agents SDK bridge leaked a credential-shaped output value" >&2
  exit 1
fi

budget_payload="$(jq -cn --arg work "$WORK" --arg capability "$direct_capability" '{capability:$capability,run_id:"relay-direct-policy",session_id:"relay-direct-policy-session",workspace:$work,mission_spec:{allow_writes:false,approval:{approved:false},allowed_commands:["git"],budgets:{max_output_bytes:0,max_write_bytes:1048576}},tool_name:"relay.run_command",input:{command:"git status --short"}}')"
set +e
budget_output="$(RELAY_TOOL_REQUEST="$budget_payload" RELAY_TOOL_CAPABILITY="$direct_capability" "$KUJO" run "$ROOT/main.kujo" -- tools execute --json 2>&1)"
budget_exit=$?
set -e
test "$budget_exit" -ne 0
[[ "$budget_output" == *'tool budgets must be between 1 and 8388608 bytes'* ]]

budget_capability="$(printf '%s' "relay-budget-smoke|relay-budget-smoke-session|$WORK|relay-agent-tools" | shasum -a 256 | awk '{print $1}')"
budget_payload="$(jq -cn --arg root "$ROOT" --arg kujo "$KUJO" --arg work "$WORK" --arg capability "$budget_capability" '{relay_root:$root,kujo_bin:$kujo,capability:$capability,run_id:"relay-budget-smoke",session_id:"relay-budget-smoke-session",workspace:$work,approval_approved:false,mission_spec:{allow_writes:false,approval:{approved:false},allowed_commands:["git"],budgets:{max_tool_calls:1,max_output_bytes:1048576,max_write_bytes:1048576}},tool_calls:[{name:"relay.run_command",input:{command:"git status --short"}},{name:"relay.run_command",input:{command:"git status --short"}}]}')"
set +e
budget_output="$(RELAY_AGENT_PAYLOAD="$budget_payload" "$KUJO" run "$ROOT/src/agent_bridge.kujo" --interpreter 2>&1)"
budget_exit=$?
set -e
test "$budget_exit" -ne 0
[[ "$budget_output" == *'budget_exceeded'* ]]

echo "PASS relay Agents SDK tool smoke"
