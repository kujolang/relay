#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WORK="/tmp/relay-watch-integrity-workspace"
MISSION_OUTPUT="/tmp/relay-watch-integrity-mission.json"
WATCH_OUTPUT="/tmp/relay-watch-integrity-events.jsonl"
WATCH_STATUS="/tmp/relay-watch-integrity-status"

rm -rf "$WORK" "$ROOT/.relay" "$MISSION_OUTPUT" "$WATCH_OUTPUT" "$WATCH_STATUS"
mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline

export RELAY_ROOT="$ROOT"
"$KUJO" run "$ROOT/main.kujo" -- missions run "$ROOT/examples/fixture-mission.json" --fixture --skip-agent-smoke --pause-after-plan --json >"$MISSION_OUTPUT" &
mission_pid=$!
watch_pid=""
cleanup() {
  if [ -n "$watch_pid" ]; then kill "$watch_pid" 2>/dev/null || true; fi
  kill "$mission_pid" 2>/dev/null || true
  wait "$watch_pid" 2>/dev/null || true
  wait "$mission_pid" 2>/dev/null || true
}
trap cleanup EXIT

run_dir=""
for attempt in $(seq 1 1000); do
  candidates=("$ROOT"/.relay/runs/*)
  if [ -d "${candidates[0]}" ]; then run_dir="${candidates[0]}"; break; fi
  sleep 0.01
done
test -n "$run_dir"
run_id="$(basename "$run_dir")"

"$KUJO" run "$ROOT/main.kujo" -- runs watch "$run_id" --poll-ms 10 --timeout-ms 120000 --json >"$WATCH_OUTPUT" 2>&1 &
watch_pid=$!

for attempt in $(seq 1 1000); do
  if [ -s "$WATCH_OUTPUT" ]; then break; fi
  sleep 0.01
done
test -s "$WATCH_OUTPUT"

# Watch must use the authoritative state reader and reject a symlinked state
# object instead of treating it as ordinary run status.
mv "$run_dir/state.json" "$run_dir/state-real.json"
ln -s "state-real.json" "$run_dir/state.json"
set +e
kill -0 "$watch_pid"
wait "$watch_pid"
state_link_status=$?
set -e
test "$state_link_status" -ne 0
grep -q 'symbolic-linked' "$WATCH_OUTPUT"
rm "$run_dir/state.json"
mv "$run_dir/state-real.json" "$run_dir/state.json"

"$KUJO" run "$ROOT/main.kujo" -- runs watch "$run_id" --poll-ms 10 --timeout-ms 120000 --json >"$WATCH_OUTPUT" 2>&1 &
watch_pid=$!
for attempt in $(seq 1 1000); do
  if [ -s "$WATCH_OUTPUT" ]; then break; fi
  sleep 0.01
done
test -s "$WATCH_OUTPUT"
rm "$run_dir/events.jsonl"

set +e
wait "$watch_pid"
watch_status=$?
set -e
printf '%s' "$watch_status" >"$WATCH_STATUS"
test "$watch_status" -ne 0
grep -q 'run event log disappeared' "$WATCH_OUTPUT"

# A dangling event link is still an unsafe evidence object. The watcher must
# reject it immediately instead of treating it as a missing file and waiting
# for a timeout.
ln -s "/tmp/relay-watch-dangling-target-$$" "$run_dir/events.jsonl"
set +e
dangling_watch_output="$($KUJO run "$ROOT/main.kujo" -- runs watch "$run_id" --poll-ms 10 --timeout-ms 1000 --json 2>&1)"
dangling_watch_status=$?
set -e
test "$dangling_watch_status" -ne 0
printf '%s' "$dangling_watch_output" | grep -q 'symbolic link'

echo "PASS relay watch event disappearance smoke"
