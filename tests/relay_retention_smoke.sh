#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
TMP_CREATED="$(mktemp -d "${TMPDIR:-/tmp}/relay-retention.XXXXXX")"
TMP_ROOT="$(cd "$TMP_CREATED" && pwd -P)"
WORK="$TMP_ROOT/work"
OLD_SPEC="$TMP_ROOT/old-mission.json"
NEW_SPEC="$TMP_ROOT/new-mission.json"
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
ruby -rjson -e 'spec=JSON.parse(File.read(ARGV.fetch(0))); spec["repository"]=ARGV.fetch(1); spec["id"]="z-old"; File.write(ARGV.fetch(2), JSON.generate(spec))' "$ROOT/examples/fixture-mission.json" "$WORK" "$OLD_SPEC"
ruby -rjson -e 'spec=JSON.parse(File.read(ARGV.fetch(0))); spec["repository"]=ARGV.fetch(1); spec["id"]="a-new"; File.write(ARGV.fetch(2), JSON.generate(spec))' "$ROOT/examples/fixture-mission.json" "$WORK" "$NEW_SPEC"

old_run="$($KUJO run "$ROOT/main.kujo" -- missions run "$OLD_SPEC" --fixture --skip-agent-smoke --json)"
old_id="$(printf '%s' "$old_run" | jq -r '.run.run_id')"
new_run="$($KUJO run "$ROOT/main.kujo" -- missions run "$NEW_SPEC" --fixture --skip-agent-smoke --json)"
new_id="$(printf '%s' "$new_run" | jq -r '.run.run_id')"

plan="$($KUJO run "$ROOT/main.kujo" -- runs retention --keep-last 1 --json)"
printf '%s' "$plan" | jq -e --arg old_id "$old_id" '.ok == true and .dry_run == true and .completed_runs == 2 and .candidate_count == 1 and .policy.keep_last == 1 and .policy.order == "updated_at_then_created_at_ascending" and .candidates[0].run_id == $old_id' >/dev/null
pruned="$($KUJO run "$ROOT/main.kujo" -- runs retention --keep-last 1 --confirm --json)"
printf '%s' "$pruned" | jq -e --arg old_id "$old_id" '.ok == true and .dry_run == false and .removed_count == 1 and .removed == [$old_id]' >/dev/null
listed="$($KUJO run "$ROOT/main.kujo" -- runs list --json)"
printf '%s' "$listed" | jq -e --arg new_id "$new_id" '.ok == true and (.runs | length) == 1 and .runs[$new_id].status == "completed"' >/dev/null

echo "PASS relay retention smoke"
