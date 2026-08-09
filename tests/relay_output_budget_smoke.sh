#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELAY_TEST_TMP_ROOT="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
export RELAY_STATE_ROOT="${RELAY_STATE_ROOT:-$RELAY_TEST_TMP_ROOT/relay-test-state-${UID:-0}-$$}"
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
grep -q '"status":"completed"' <<<"$result"
grep -q '"max_output_bytes":16' <<<"$result"
grep -q '"output_truncated":true' <<<"$result"
test -f "$WORK/OUTPUT_BUDGET.txt"

invalid="$WORK/invalid-timeout.json"
printf '%s' '{"version":"1.0.0","name":"invalid-timeout","goal":"reject","repository":"/tmp/relay-output-budget-workspace","actions":[{"type":"run_command","command":"git status --short","timeout_ms":0}]}' > "$invalid"
set +e
rejected="$($KUJO run "$ROOT/main.kujo" -- missions run "$invalid" --fixture --json 2>&1)"
rc=$?
set -e
test "$rc" -ne 0
grep -q 'timeout_ms must be between' <<<"$rejected"
echo "PASS relay output budget smoke"
