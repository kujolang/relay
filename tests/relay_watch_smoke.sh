#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELAY_TEST_TMP_ROOT="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
export RELAY_STATE_ROOT="${RELAY_STATE_ROOT:-$RELAY_TEST_TMP_ROOT/relay-test-state-${UID:-0}-$$}"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WORK="/tmp/relay-watch-workspace"
MISSION_OUTPUT="/tmp/relay-watch-mission.json"
WATCH_OUTPUT="/tmp/relay-watch-events.jsonl"

rm -rf "$WORK" "$RELAY_STATE_ROOT" "$MISSION_OUTPUT" "$WATCH_OUTPUT"
mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline

export RELAY_ROOT="$ROOT"
"$KUJO" run "$ROOT/main.kujo" -- missions run "$ROOT/examples/fixture-mission.json" --fixture --skip-agent-smoke --json >"$MISSION_OUTPUT" &
mission_pid=$!

run_dir=""
for attempt in $(seq 1 1000); do
  candidates=("$RELAY_STATE_ROOT"/runs/*)
  if [ -d "${candidates[0]}" ]; then run_dir="${candidates[0]}"; break; fi
  sleep 0.01
done
test -n "$run_dir"
run_id="$(basename "$run_dir")"

"$KUJO" run "$ROOT/main.kujo" -- runs watch "$run_id" --poll-ms 10 --timeout-ms 120000 --json >"$WATCH_OUTPUT"
wait "$mission_pid"

jq -s -e 'length > 0 and (map(select(.type == "AgentEvent")) | length) > 0 and .[-1].kind == "run_completed"' "$WATCH_OUTPUT" >/dev/null
if grep -q 'relay_watch_error' "$WATCH_OUTPUT"; then
  echo "watch emitted an error" >&2
  exit 1
fi

echo "PASS relay watch smoke"
