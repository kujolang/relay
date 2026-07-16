#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELAY_TEST_TMP_ROOT="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
export RELAY_STATE_ROOT="${RELAY_STATE_ROOT:-$RELAY_TEST_TMP_ROOT/relay-test-state-${UID:-0}-$$}"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WORK="/tmp/relay-source-workspace"

rm -rf "$WORK"
mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
printf 'source baseline\n' > "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline
baseline="$(git -C "$WORK" rev-parse HEAD)"

export RELAY_ROOT="$ROOT"
result="$($KUJO run "$ROOT/main.kujo" -- missions run "$ROOT/examples/worktree-mission.json" --fixture --skip-agent-smoke --json)"
printf '%s' "$result" | grep -q '"ok":true'
printf '%s' "$result" | grep -q '"status":"completed"'
printf '%s' "$result" | grep -q '"mode":"worktree"'
run_dir="$(printf '%s' "$result" | ruby -rjson -e 'd=JSON.parse(STDIN.read); print d["run_dir"]')"
test -f "$run_dir/workspace/WORKTREE_OUTPUT.txt"
test ! -e "$WORK/WORKTREE_OUTPUT.txt"
test "$(git -C "$WORK" rev-parse HEAD)" = "$baseline"
state_path="$run_dir/state.json"
cp "$state_path" "$state_path.backup"
ruby -rjson -e 'path=ARGV.fetch(0); data=JSON.parse(File.read(path)); data["workspace"]["path"]="/tmp/relay-forbidden-worktree"; File.write(path, JSON.generate(data))' "$state_path"
set +e
tampered_cleanup="$($KUJO run "$ROOT/main.kujo" -- missions cleanup "$(printf '%s' "$result" | ruby -rjson -e 'd=JSON.parse(STDIN.read); print d["run"]["run_id"]')" --confirm --json 2>&1)"
tampered_rc=$?
set -e
test "$tampered_rc" -ne 0
printf '%s' "$tampered_cleanup" | grep -q 'state_integrity_failure'
mv "$state_path.backup" "$state_path"
set +e
cleanup="$($KUJO run "$ROOT/main.kujo" -- missions cleanup "$(printf '%s' "$result" | ruby -rjson -e 'd=JSON.parse(STDIN.read); print d["run"]["run_id"]')" --json 2>&1)"
rc=$?
set -e
test "$rc" -ne 0
printf '%s' "$cleanup" | grep -q 'requires --confirm'
cleanup="$($KUJO run "$ROOT/main.kujo" -- missions cleanup "$(printf '%s' "$result" | ruby -rjson -e 'd=JSON.parse(STDIN.read); print d["run"]["run_id"]')" --confirm --json)"
printf '%s' "$cleanup" | grep -q '"cleaned":true'
test ! -e "$run_dir/workspace"
echo "PASS relay worktree smoke"
