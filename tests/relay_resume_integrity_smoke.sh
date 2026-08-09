#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELAY_TEST_TMP_ROOT="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
export RELAY_STATE_ROOT="${RELAY_STATE_ROOT:-$RELAY_TEST_TMP_ROOT/relay-test-state-${UID:-0}-$$}"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WORK="/tmp/relay-resume-integrity-workspace"
SPEC="/tmp/relay-resume-integrity-mission.json"

rm -rf "$WORK" "$RELAY_STATE_ROOT" "$SPEC"
mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline
ruby -rjson -e 'spec=JSON.parse(File.read(ARGV.fetch(0))); spec["repository"]=ARGV.fetch(1); spec["actions"][0]["path"]="RESUME_INTEGRITY_OUTPUT.txt"; File.write(ARGV.fetch(2), JSON.generate(spec))' "$ROOT/examples/fixture-mission.json" "$WORK" "$SPEC"

export RELAY_ROOT="$ROOT"
paused="$($KUJO run "$ROOT/main.kujo" -- missions run "$SPEC" --fixture --pause-after-plan --json)"
grep -q '"ok":true' <<<"$paused"
grep -q '"status":"paused"' <<<"$paused"
run_id="$(printf '%s' "$paused" | ruby -rjson -e 'print JSON.parse(STDIN.read)["run"]["run_id"]')"
run_dir="$RELAY_STATE_ROOT/runs/$run_id"
test -n "$run_id"
test -f "$run_dir/state.json"

cp "$run_dir/state.json" "$run_dir/state.clean.json"
ruby -rjson -e 'path=ARGV.fetch(0); state=JSON.parse(File.read(path)); state["repository"]="/tmp"; File.write(path, JSON.generate(state))' "$run_dir/state.json"
set +e
workspace_tamper="$($KUJO run "$ROOT/main.kujo" -- missions resume "$run_id" --json 2>&1)"
workspace_rc=$?
set -e
test "$workspace_rc" -ne 0
grep -q 'state_integrity_failure' <<<"$workspace_tamper"
test ! -e "$WORK/RESUME_INTEGRITY_OUTPUT.txt"

cp "$run_dir/state.clean.json" "$run_dir/state.json"
ruby -rjson -e 'path=ARGV.fetch(0); state=JSON.parse(File.read(path)); state["mission_spec"]["allow_writes"]=false; File.write(path, JSON.generate(state))' "$run_dir/state.json"
set +e
policy_tamper="$($KUJO run "$ROOT/main.kujo" -- missions resume "$run_id" --json 2>&1)"
policy_rc=$?
set -e
test "$policy_rc" -ne 0
grep -q 'state_integrity_failure' <<<"$policy_tamper"
test ! -e "$WORK/RESUME_INTEGRITY_OUTPUT.txt"

cp "$run_dir/state.clean.json" "$run_dir/state.json"
cancelled="$($KUJO run "$ROOT/main.kujo" -- missions cancel "$run_id" --json)"
grep -q '"ok":true' <<<"$cancelled"
grep -q '"status":"cancelled"' <<<"$cancelled"
test ! -e "$WORK/RESUME_INTEGRITY_OUTPUT.txt"

echo "PASS relay resume integrity smoke"
