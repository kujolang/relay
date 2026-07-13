#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WORK="/tmp/relay-spec-safety-workspace"
LARGE="/tmp/relay-large-mission.json"
SYMLINK="/tmp/relay-symlink-mission.json"
REPO_LINK="/tmp/relay-symlink-repository-$$"
INVALID_ACTION="/tmp/relay-invalid-action-mission.json"
INVALID_PROVIDER="/tmp/relay-invalid-provider-tool-mission.json"
INVALID_TURNS="/tmp/relay-invalid-tool-turns-mission.json"
OVERSIZED_COMMAND="/tmp/relay-oversized-command-mission.json"
INVALID_REPAIRS="/tmp/relay-invalid-repairs-mission.json"

rm -rf "$WORK" "$ROOT/.relay" "$LARGE" "$SYMLINK" "$REPO_LINK" "$INVALID_ACTION" "$INVALID_PROVIDER" "$INVALID_TURNS" "$OVERSIZED_COMMAND" "$INVALID_REPAIRS"
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

ln -s "$WORK" "$REPO_LINK"
ruby -rjson -e 'path=ARGV.fetch(0); repo=ARGV.fetch(1); File.write(path, JSON.generate({name:"symlink-repository",goal:"must fail closed",repository:repo,actions:[]}))' "$INVALID_ACTION" "$REPO_LINK"
set +e
symlink_repository_output="$($KUJO run "$ROOT/main.kujo" -- missions run "$INVALID_ACTION" --fixture --skip-agent-smoke --json 2>&1)"
symlink_repository_status=$?
set -e
test "$symlink_repository_status" -ne 0
printf '%s' "$symlink_repository_output" | grep -q 'non-symlink directory'
rm -f "$REPO_LINK"

ruby -rjson -e 'path=ARGV.fetch(0); File.write(path, JSON.generate({name:"invalid-action",goal:"must fail during validation",repository:ARGV.fetch(1),actions:[{type:"unknown"}]}))' "$INVALID_ACTION" "$WORK"
set +e
invalid_action_output="$($KUJO run "$ROOT/main.kujo" -- missions run "$INVALID_ACTION" --fixture --skip-agent-smoke --json 2>&1)"
invalid_action_status=$?
set -e
test "$invalid_action_status" -ne 0
printf '%s' "$invalid_action_output" | grep -q 'action type is not supported'

ruby -rjson -e 'path=ARGV.fetch(0); repo=ARGV.fetch(1); File.write(path, JSON.generate({name:"oversized-command",goal:"must fail during bounded input validation",repository:repo,actions:[{type:"run_command",command:"git status " + ("x" * 17000)}]}))' "$OVERSIZED_COMMAND" "$WORK"
set +e
oversized_command_output="$($KUJO run "$ROOT/main.kujo" -- missions run "$OVERSIZED_COMMAND" --fixture --skip-agent-smoke --json 2>&1)"
oversized_command_status=$?
set -e
test "$oversized_command_status" -ne 0
printf '%s' "$oversized_command_output" | grep -q '16 KiB safety limit'

ruby -rjson -e 'path=ARGV.fetch(0); repo=ARGV.fetch(1); File.write(path, JSON.generate({name:"invalid-provider-tools",goal:"must require an allowlist",repository:repo,agent_tool_mode:"provider",actions:[]}))' "$INVALID_PROVIDER" "$WORK"
set +e
invalid_provider_output="$($KUJO run "$ROOT/main.kujo" -- missions run "$INVALID_PROVIDER" --fixture --skip-agent-smoke --json 2>&1)"
invalid_provider_status=$?
set -e
test "$invalid_provider_status" -ne 0
printf '%s' "$invalid_provider_output" | grep -q 'agent_tool_allowlist'

ruby -rjson -e 'path=ARGV.fetch(0); repo=ARGV.fetch(1); File.write(path, JSON.generate({name:"invalid-tool-turns",goal:"must reject unbounded turns",repository:repo,budgets:{max_tool_turns:5},actions:[]}))' "$INVALID_TURNS" "$WORK"
set +e
invalid_turns_output="$($KUJO run "$ROOT/main.kujo" -- missions run "$INVALID_TURNS" --fixture --skip-agent-smoke --json 2>&1)"
invalid_turns_status=$?
set -e
test "$invalid_turns_status" -ne 0
printf '%s' "$invalid_turns_output" | grep -q 'max_tool_turns'

ruby -rjson -e 'path=ARGV.fetch(0); repo=ARGV.fetch(1); File.write(path, JSON.generate({name:"invalid-repairs",goal:"must reject unbounded repair replay",repository:repo,budgets:{max_repairs:5},actions:[]}))' "$INVALID_REPAIRS" "$WORK"
set +e
invalid_repairs_output="$($KUJO run "$ROOT/main.kujo" -- missions run "$INVALID_REPAIRS" --fixture --skip-agent-smoke --json 2>&1)"
invalid_repairs_status=$?
set -e
test "$invalid_repairs_status" -ne 0
printf '%s' "$invalid_repairs_output" | grep -q 'max_repairs'

echo "PASS relay spec safety smoke"
