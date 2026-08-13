#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
TMP_CREATED="$(mktemp -d "${TMPDIR:-/tmp}/relay-retention.XXXXXX")"
TMP_ROOT="$(cd "$TMP_CREATED" && pwd -P)"
WORK="$TMP_ROOT/work"
SPEC="$TMP_ROOT/mission.json"
export RELAY_ROOT="$ROOT"
export RELAY_STATE_ROOT="$TMP_ROOT/state"
export KUJO_BIN="$KUJO"
trap 'rm -rf "$TMP_ROOT"' EXIT

mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline
ruby -rjson -e 'spec=JSON.parse(File.read(ARGV.fetch(0))); spec["repository"]=ARGV.fetch(1); File.write(ARGV.fetch(2), JSON.generate(spec))' "$ROOT/examples/fixture-mission.json" "$WORK" "$SPEC"

for _ in 1 2 3; do
  "$KUJO" run "$ROOT/main.kujo" -- missions run "$SPEC" --fixture --skip-agent-smoke --json >/dev/null
done

plan="$($KUJO run "$ROOT/main.kujo" -- runs retention --keep-last 1 --json)"
printf '%s' "$plan" | jq -e '.ok == true and .dry_run == true and .completed_runs == 3 and .candidate_count == 2 and .policy.keep_last == 1' >/dev/null
pruned="$($KUJO run "$ROOT/main.kujo" -- runs retention --keep-last 1 --confirm --json)"
printf '%s' "$pruned" | jq -e '.ok == true and .dry_run == false and .removed_count == 2 and (.removed | length) == 2' >/dev/null
listed="$($KUJO run "$ROOT/main.kujo" -- runs list --json)"
printf '%s' "$listed" | jq -e '.ok == true and (.runs | length) == 1' >/dev/null

echo "PASS relay retention smoke"
