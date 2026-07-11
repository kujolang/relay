#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WORK="/tmp/relay-output-budget-workspace"

rm -rf "$WORK"
mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline

export RELAY_ROOT="$ROOT"
result="$($KUJO run "$ROOT/main.kujo" -- missions run "$ROOT/examples/output-budget-mission.json" --fixture --skip-agent-smoke --json)"
printf '%s' "$result" | grep -q '"status":"completed"'
printf '%s' "$result" | grep -q '"max_output_bytes":16'
printf '%s' "$result" | grep -q '"output_truncated":true'
test -f "$WORK/OUTPUT_BUDGET.txt"

invalid="$WORK/invalid-timeout.json"
printf '%s' '{"name":"invalid-timeout","goal":"reject","repository":"/tmp/relay-output-budget-workspace","actions":[{"type":"run_command","command":"git status --short","timeout_ms":0}]}' > "$invalid"
set +e
rejected="$($KUJO run "$ROOT/main.kujo" -- missions run "$invalid" --fixture --json 2>&1)"
rc=$?
set -e
test "$rc" -ne 0
printf '%s' "$rejected" | grep -q 'timeout_ms must be between'
echo "PASS relay output budget smoke"
