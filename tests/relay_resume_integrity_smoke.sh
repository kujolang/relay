#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WORK="/tmp/relay-resume-integrity-workspace"
SPEC="/tmp/relay-resume-integrity-mission.json"

rm -rf "$WORK" "$ROOT/.relay" "$SPEC"
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
printf '%s' "$paused" | grep -q '"ok":true'
printf '%s' "$paused" | grep -q '"status":"paused"'
run_id="$(printf '%s' "$paused" | ruby -rjson -e 'print JSON.parse(STDIN.read)["run"]["run_id"]')"
run_dir="$ROOT/.relay/runs/$run_id"
test -n "$run_id"
test -f "$run_dir/state.json"

cp "$run_dir/state.json" "$run_dir/state.clean.json"
ruby -rjson -e 'path=ARGV.fetch(0); state=JSON.parse(File.read(path)); state["repository"]="/tmp"; File.write(path, JSON.generate(state))' "$run_dir/state.json"
set +e
workspace_tamper="$($KUJO run "$ROOT/main.kujo" -- missions resume "$run_id" --json 2>&1)"
workspace_rc=$?
set -e
test "$workspace_rc" -ne 0
printf '%s' "$workspace_tamper" | grep -q 'state_integrity_failure'
test ! -e "$WORK/RESUME_INTEGRITY_OUTPUT.txt"

cp "$run_dir/state.clean.json" "$run_dir/state.json"
ruby -rjson -e 'path=ARGV.fetch(0); state=JSON.parse(File.read(path)); state["mission_spec"]["allow_writes"]=false; File.write(path, JSON.generate(state))' "$run_dir/state.json"
set +e
policy_tamper="$($KUJO run "$ROOT/main.kujo" -- missions resume "$run_id" --json 2>&1)"
policy_rc=$?
set -e
test "$policy_rc" -ne 0
printf '%s' "$policy_tamper" | grep -q 'state_integrity_failure'
test ! -e "$WORK/RESUME_INTEGRITY_OUTPUT.txt"

cp "$run_dir/state.clean.json" "$run_dir/state.json"
cancelled="$($KUJO run "$ROOT/main.kujo" -- missions cancel "$run_id" --json)"
printf '%s' "$cancelled" | grep -q '"ok":true'
printf '%s' "$cancelled" | grep -q '"status":"cancelled"'
test ! -e "$WORK/RESUME_INTEGRITY_OUTPUT.txt"

echo "PASS relay resume integrity smoke"
