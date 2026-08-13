#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
TMP_BASE="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
TMP_ROOT="$(mktemp -d "$TMP_BASE/relay-discovery.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT
WORK="$TMP_ROOT/work"
mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
for i in $(seq -w 1 320); do touch "$WORK/tracked-file-$i-with-a-long-name.txt"; done
git -C "$WORK" add .
git -C "$WORK" commit -qm baseline
MISSION="$TMP_ROOT/mission.json"
jq -n --arg repo "$WORK" '{version:"1.0.0",id:"relay-discovery-cursor",name:"relay-discovery-cursor",goal:"page a tracked index larger than the agent-visible output budget",workflow:"verified-feature",repository:$repo,model:"fixture-model",provider:"fixture",allow_writes:false,budgets:{max_steps:4,max_repairs:0,max_tokens:100,max_output_bytes:64,max_write_bytes:64},actions:[{type:"list_files",offset:0},{type:"list_files",offset:256}]}' > "$MISSION"
export RELAY_ROOT="$ROOT"
export RELAY_STATE_ROOT="$TMP_ROOT/state"
result="$($KUJO run "$ROOT/main.kujo" -- missions run "$MISSION" --fixture --skip-agent-smoke --json)"
jq -e '.ok and .run.status == "completed" and (.run.action_results | length) == 2 and .run.action_results[0].has_more == true and .run.action_results[0].next_offset == 256 and (.run.action_results[1].files | length) == 64 and .run.action_results[1].has_more == false' <<<"$result" >/dev/null
echo "PASS relay cursor-backed tracked-file discovery smoke"
