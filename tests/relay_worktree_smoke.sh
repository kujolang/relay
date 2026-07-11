#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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
