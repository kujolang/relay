#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WORK="/tmp/relay-lock-stress-workspace"

rm -rf "$WORK" "$ROOT/.relay"
mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline

export RELAY_ROOT="$ROOT"
mission="$($KUJO run "$ROOT/main.kujo" -- missions run "$ROOT/examples/fixture-mission.json" --fixture --skip-agent-smoke --json)"
run_id="$(printf '%s' "$mission" | ruby -rjson -e 'print JSON.parse(STDIN.read)["run"]["run_id"]')"
test -n "$run_id"

outputs=()
for i in $(seq 1 12); do
  output="/tmp/relay-lock-stress-$i.json"
  outputs+=("$output")
  rm -f "$output"
  "$KUJO" run "$ROOT/main.kujo" -- runs rebuild --json >"$output" &
done

for pid in $(jobs -p); do wait "$pid"; done
for output in "${outputs[@]}"; do jq -e '.ok == true and .index_source == "rebuild"' "$output" >/dev/null; done
jq -e --arg run_id "$run_id" 'has($run_id)' "$ROOT/.relay/index.json" >/dev/null

echo "PASS relay lock stress smoke"
