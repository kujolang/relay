#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
AGENTS_SDK="${RELAY_AGENTS_SDK_PATH:-$ROOT/../agents-sdk}"
AI_SDK="${RELAY_AI_SDK_PATH:-$ROOT/../ai-sdk}"

large_payload="$(ruby -rjson -e 'print JSON.generate({payload:"x" * 140000})')"

set +e
ai_output="$(RELAY_AI_PAYLOAD="$large_payload" bash -lc "cd '$AI_SDK' && '$KUJO' run '$ROOT/src/ai_bridge.kujo' --interpreter" 2>&1)"
ai_rc=$?
set -e
test "$ai_rc" -ne 0
printf '%s' "$ai_output" | grep -q 'payload_too_large'

set +e
ai_invalid="$(RELAY_AI_PAYLOAD='[' bash -lc "cd '$AI_SDK' && '$KUJO' run '$ROOT/src/ai_bridge.kujo' --interpreter" 2>&1)"
ai_invalid_rc=$?
set -e
test "$ai_invalid_rc" -ne 0
printf '%s' "$ai_invalid" | grep -q 'invalid_payload'

set +e
agent_output="$(RELAY_ROOT="$ROOT" KUJO_BIN="$KUJO" RELAY_AGENT_PAYLOAD="$large_payload" bash -lc "cd '$AGENTS_SDK' && '$KUJO' run '$ROOT/src/agent_bridge.kujo' --interpreter" 2>&1)"
agent_rc=$?
set -e
test "$agent_rc" -ne 0
printf '%s' "$agent_output" | grep -q 'payload_too_large'

set +e
agent_invalid="$(RELAY_ROOT="$ROOT" KUJO_BIN="$KUJO" RELAY_AGENT_PAYLOAD='[' bash -lc "cd '$AGENTS_SDK' && '$KUJO' run '$ROOT/src/agent_bridge.kujo' --interpreter" 2>&1)"
agent_invalid_rc=$?
set -e
test "$agent_invalid_rc" -ne 0
printf '%s' "$agent_invalid" | grep -q 'invalid_payload'

export RELAY_ROOT="$ROOT"
set +e
tool_output="$(RELAY_TOOL_REQUEST="$large_payload" "$KUJO" run "$ROOT/main.kujo" -- tools execute --json 2>&1)"
tool_rc=$?
set -e
test "$tool_rc" -ne 0
printf '%s' "$tool_output" | grep -q '128 KiB safety limit'

echo "PASS relay input boundary smoke"
