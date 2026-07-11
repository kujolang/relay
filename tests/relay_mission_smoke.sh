#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WORK="/tmp/relay-fixture-workspace"

rm -rf "$WORK"
mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline

export RELAY_ROOT="$ROOT"
paused="$($KUJO run "$ROOT/main.kujo" -- missions run "$ROOT/examples/fixture-mission.json" --fixture --pause-after-plan --json)"
printf '%s' "$paused" | grep -q '"status":"paused"'
printf '%s' "$paused" | grep -q '"checkpoint"'

run_id="$(printf '%s' "$paused" | ruby -rjson -e 'd=JSON.parse(STDIN.read); print d["run"]["run_id"]')"
test -n "$run_id"
resumed="$($KUJO run "$ROOT/main.kujo" -- missions resume "$run_id" --json)"
case "$resumed" in
  *'"ok":true'*'"status":"completed"'*'"runledger_finish"'*) ;;
  *) echo "resume run did not complete with evidence" >&2; exit 1 ;;
esac

test -f "$WORK/RELAY_OUTPUT.txt"
echo "PASS relay mission smoke"
