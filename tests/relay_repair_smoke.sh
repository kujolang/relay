#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELAY_TEST_TMP_ROOT="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
export RELAY_STATE_ROOT="${RELAY_STATE_ROOT:-$RELAY_TEST_TMP_ROOT/relay-test-state-${UID:-0}-$$}"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
SOURCE="/tmp/relay-repair-source"
SPEC="/tmp/relay-repair-mission.json"
ZERO_SPEC="/tmp/relay-repair-zero-budget.json"

rm -rf "$SOURCE" "$RELAY_STATE_ROOT" "$SPEC" "$ZERO_SPEC"
mkdir -p "$SOURCE/scripts"
git init -q "$SOURCE"
git -C "$SOURCE" config user.email relay@example.invalid
git -C "$SOURCE" config user.name Relay
printf 'repair baseline\n' > "$SOURCE/README.md"
printf '%s\n' '#!/bin/sh' 'if [ ! -f .relay-repair-seen ]; then printf seen > .relay-repair-seen; exit 17; fi' 'printf repaired > RELAY_REPAIR_OUTPUT.txt' > "$SOURCE/scripts/repair-once.sh"
chmod +x "$SOURCE/scripts/repair-once.sh"
git -C "$SOURCE" add README.md scripts/repair-once.sh
git -C "$SOURCE" commit -qm baseline
script_sha="$(shasum -a 256 "$SOURCE/scripts/repair-once.sh" | awk '{print $1}')"

ruby -rjson -e 'source=ARGV.fetch(0); sha=ARGV.fetch(1); output=ARGV.fetch(2); spec={"version"=>"1.0.0","id"=>"relay-repair-mission","name"=>"relay-repair-mission","goal"=>"Replay one bounded transient tool failure and verify the repair evidence.","workflow"=>"verified-feature","repository"=>source,"workspace_mode"=>"worktree","provider"=>"fixture","model"=>"fixture-model","allow_writes"=>true,"approval"=>{"approved"=>true,"actor"=>"repair-smoke"},"allowed_commands"=>["bash"],"allowed_script_hashes"=>{"scripts/repair-once.sh"=>sha},"budgets"=>{"max_steps"=>2,"max_repairs"=>1,"max_tokens"=>4000},"actions"=>[{"type"=>"run_command","command"=>"bash scripts/repair-once.sh"}]}; File.write(output, JSON.generate(spec))' "$SOURCE" "$script_sha" "$SPEC"
ruby -rjson -e 'spec=JSON.parse(File.read(ARGV.fetch(0))); spec["id"]="relay-repair-zero-budget"; spec["name"]="relay-repair-zero-budget"; spec["budgets"]["max_repairs"]=0; File.write(ARGV.fetch(1), JSON.generate(spec))' "$SPEC" "$ZERO_SPEC"

export RELAY_ROOT="$ROOT"
set +e
first="$($KUJO run "$ROOT/main.kujo" -- missions run "$SPEC" --fixture --skip-agent-smoke --json 2>&1)"
first_rc=$?
set -e
test "$first_rc" -ne 0
run_id="$(printf '%s' "$first" | ruby -rjson -e 'print JSON.parse(STDIN.read)["run"]["run_id"]')"
run_dir="$RELAY_STATE_ROOT/runs/$run_id"
printf '%s' "$first" | jq -e '.ok == false and .run.status == "failed" and .run.failure.class == "tool_failure" and .run.failure.repair_attempts == 0' >/dev/null

repaired="$($KUJO run "$ROOT/main.kujo" -- missions repair "$run_id" --json)"
printf '%s' "$repaired" | jq -e '.ok == true and .run.status == "completed" and .run.repair_attempts == 1 and .run.completion_candidate.repaired == true and any(.run.events[]; .kind == "repair_started") and any(.run.events[]; .kind == "repair_completed")' >/dev/null
test -f "$run_dir/workspace/RELAY_REPAIR_OUTPUT.txt"
for receipt in "$run_dir/state.json"; do
  jq -e 'any(.receipts[]; .kind == "repair" and .status == "completed")' "$receipt" >/dev/null
done

set +e
zero_first="$($KUJO run "$ROOT/main.kujo" -- missions run "$ZERO_SPEC" --fixture --skip-agent-smoke --json 2>&1)"
zero_first_rc=$?
set -e
test "$zero_first_rc" -ne 0
zero_id="$(printf '%s' "$zero_first" | ruby -rjson -e 'print JSON.parse(STDIN.read)["run"]["run_id"]')"
set +e
zero_repair="$($KUJO run "$ROOT/main.kujo" -- missions repair "$zero_id" --json 2>&1)"
zero_rc=$?
set -e
test "$zero_rc" -ne 0
printf '%s' "$zero_repair" | jq -e '.ok == false and .failure_class == "repair_budget_exceeded" and .max_repairs == 0' >/dev/null

cleanup="$($KUJO run "$ROOT/main.kujo" -- missions cleanup "$run_id" --confirm --json)"
printf '%s' "$cleanup" | jq -e '.ok == true and .cleaned == true' >/dev/null
zero_cleanup="$($KUJO run "$ROOT/main.kujo" -- missions cleanup "$zero_id" --confirm --json)"
printf '%s' "$zero_cleanup" | jq -e '.ok == true and .cleaned == true' >/dev/null

echo "PASS relay bounded repair smoke"
