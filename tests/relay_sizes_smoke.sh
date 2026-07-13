#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WORK="/tmp/relay-sizes-workspace"
MISSION_OUTPUT="/tmp/relay-sizes-mission.json"

rm -rf "$WORK" "$ROOT/.relay" "$MISSION_OUTPUT"
mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline

export RELAY_ROOT="$ROOT"
"$KUJO" run "$ROOT/main.kujo" -- missions run "$ROOT/examples/fixture-mission.json" --fixture --skip-agent-smoke --json >"$MISSION_OUTPUT"
run_id="$(jq -r '.run.run_id // .run_id' "$MISSION_OUTPUT")"
test -n "$run_id" && test "$run_id" != "null"

sizes="$($KUJO run "$ROOT/main.kujo" -- runs sizes "$run_id" --json)"
printf '%s\n' "$sizes" | jq -e '.ok == true and .summary.files > 0 and .summary.bytes > 0 and ((.excluded | map(.path)) | index("workspace")) != null and ((.entries | map(.path) | map(startswith("workspace/")) | any) == false)' >/dev/null
hashed_sizes="$($KUJO run "$ROOT/main.kujo" -- runs sizes "$run_id" --hashes --json)"
printf '%s\n' "$hashed_sizes" | jq -e '.ok == true and .hashes_included == true and all(.entries[]; (.integrity_sha256 | type == "string" and length == 64))' >/dev/null

run_dir="$ROOT/.relay/runs/$run_id"
ln -s /etc "$run_dir/unsafe-link"
set +e
unsafe_output="$($KUJO run "$ROOT/main.kujo" -- runs sizes "$run_id" --json 2>&1)"
unsafe_status=$?
set -e
test "$unsafe_status" -ne 0
printf '%s\n' "$unsafe_output" | grep -q "symbolic link"
rm "$run_dir/unsafe-link"

# A single directory with more entries than the inventory budget is rejected
# before recursive flattening allocates an unbounded result array.
overflow="$run_dir/entry-overflow"
mkdir -p "$overflow"
for entry in $(seq 1 4097); do
  : > "$overflow/file-$entry"
done
set +e
overflow_output="$($KUJO run "$ROOT/main.kujo" -- runs sizes "$run_id" --json 2>&1)"
overflow_status=$?
set -e
test "$overflow_status" -ne 0
printf '%s\n' "$overflow_output" | grep -q 'entry limit'
rm -rf "$overflow"

# A byte budget is required in addition to entry/depth budgets: thousands of
# small files can otherwise create an oversized JSON inventory while staying
# below the entry bound.
byte_overflow="$run_dir/byte-overflow"
mkdir -p "$byte_overflow"
dd if=/dev/zero of="$byte_overflow/payload.bin" bs=1048576 count=9 status=none
set +e
byte_output="$($KUJO run "$ROOT/main.kujo" -- runs sizes "$run_id" --json 2>&1)"
byte_status=$?
set -e
test "$byte_status" -ne 0
printf '%s\n' "$byte_output" | grep -q 'total byte limit'
rm -rf "$byte_overflow"

# Artifact inventory is bounded by both entry count and directory depth so a
# hostile run artifact tree cannot consume unbounded recursive work.
deep="$run_dir/deep"
mkdir -p "$deep"
for depth in $(seq 1 17); do
  deep="$deep/level-$depth"
  mkdir "$deep"
done
set +e
deep_output="$($KUJO run "$ROOT/main.kujo" -- runs sizes "$run_id" --json 2>&1)"
deep_status=$?
set -e
test "$deep_status" -ne 0
printf '%s\n' "$deep_output" | grep -q '16-level directory depth limit'

echo "PASS relay sizes smoke"
