#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WORK="/tmp/relay-spec-safety-workspace"
LARGE="/tmp/relay-large-mission.json"
SYMLINK="/tmp/relay-symlink-mission.json"

rm -rf "$WORK" "$ROOT/.relay" "$LARGE" "$SYMLINK"
mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline

ruby -rjson -e 'path=ARGV.fetch(0); File.write(path, JSON.generate({name:"oversized",goal:"x" * 1100000,repository:ARGV.fetch(1),actions:[]}))' "$LARGE" "$WORK"
export RELAY_ROOT="$ROOT"
set +e
large_output="$($KUJO run "$ROOT/main.kujo" -- missions run "$LARGE" --fixture --skip-agent-smoke --json 2>&1)"
large_status=$?
set -e
test "$large_status" -ne 0
printf '%s' "$large_output" | grep -q '1 MiB safety limit'

cp "$ROOT/examples/fixture-mission.json" "$SYMLINK.target"
ln -s "$SYMLINK.target" "$SYMLINK"
set +e
symlink_output="$($KUJO run "$ROOT/main.kujo" -- missions run "$SYMLINK" --fixture --skip-agent-smoke --json 2>&1)"
symlink_status=$?
set -e
test "$symlink_status" -ne 0
printf '%s' "$symlink_output" | grep -q 'must not be a symbolic link'

echo "PASS relay spec safety smoke"
