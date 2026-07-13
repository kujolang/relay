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
printf '%s' "$resumed" | grep -q '"ok":true'
printf '%s' "$resumed" | grep -q '"status":"completed"'
printf '%s' "$resumed" | grep -q '"runledger_finish"'
printf '%s' "$resumed" | grep -q '"packet_revision":1'
printf '%s' "$resumed" | grep -q '"runledger_id"'
printf '%s' "$resumed" | grep -q '"provider":"fixture"'
printf '%s' "$resumed" | grep -q '"receipts"'

run_dir="$(printf '%s' "$resumed" | ruby -rjson -e 'print JSON.parse(STDIN.read)["run_dir"]')"
jq -e '.receipts | length >= 7 and (map(.receipt_id) as $ids | (($ids | unique | length) == ($ids | length))) and (all(.[]; (.metadata.workflow == "verified-feature" and .metadata.model == "fixture-model" and .metadata.provider == "fixture" and (.metadata.packet_revision == 0 or .metadata.packet_revision == 1) and (.metadata.runledger_id != null))))' "$run_dir/state.json" >/dev/null
test -f "$run_dir/receipts.json"

test -f "$WORK/RELAY_OUTPUT.txt"
echo "PASS relay mission smoke"
