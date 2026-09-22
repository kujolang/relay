#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
TMP_CREATED="$(mktemp -d "${TMPDIR:-/tmp}/relay-watch.XXXXXX")"
TMP_ROOT="$(cd "$TMP_CREATED" && pwd -P)"
export RELAY_STATE_ROOT="$TMP_ROOT/state"
WORK="$TMP_ROOT/workspace"
MISSION_OUTPUT="$TMP_ROOT/mission-output.json"
WATCH_OUTPUT="$TMP_ROOT/events.jsonl"
mission_pid=""
cleanup() {
  if [[ -n "$mission_pid" ]] && kill -0 "$mission_pid" 2>/dev/null; then
    kill "$mission_pid" 2>/dev/null || true
    wait "$mission_pid" 2>/dev/null || true
  fi
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline

export RELAY_ROOT="$ROOT"
jq --arg repository "$WORK" '.repository=$repository' "$ROOT/examples/fixture-mission.json" > "$TMP_ROOT/mission.json"
"$KUJO" run "$ROOT/main.kujo" -- missions run "$TMP_ROOT/mission.json" --fixture --skip-agent-smoke --json >"$MISSION_OUTPUT" &
mission_pid=$!

run_dir=""
for attempt in $(seq 1 1000); do
  candidates=("$RELAY_STATE_ROOT"/runs/*)
  # Directory creation precedes the first atomic state publication. Watch
  # requires a readable run, not merely a directory observed during startup.
  if [[ -f "${candidates[0]}/state.json" ]] && jq -e '.contract_version == "relay-run-v1"' "${candidates[0]}/state.json" >/dev/null 2>&1; then
    run_dir="${candidates[0]}"
    break
  fi
  if ! kill -0 "$mission_pid" 2>/dev/null; then break; fi
  sleep 0.01
done
[[ -n "$run_dir" ]] || { cat "$MISSION_OUTPUT" >&2; echo "run state was not published" >&2; exit 1; }
run_id="$(basename "$run_dir")"

"$KUJO" run "$ROOT/main.kujo" -- runs watch "$run_id" --poll-ms 10 --timeout-ms 120000 --json >"$WATCH_OUTPUT"
wait "$mission_pid"
mission_pid=""

jq -s -e 'length > 0 and (map(select(.type == "AgentEvent")) | length) > 0 and .[-1].kind == "run_completed"' "$WATCH_OUTPUT" >/dev/null
if grep -q 'relay_watch_error' "$WATCH_OUTPUT"; then
  echo "watch emitted an error" >&2
  exit 1
fi

echo "PASS relay watch smoke"
