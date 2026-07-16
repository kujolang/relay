#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELAY_TEST_TMP_ROOT="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
export RELAY_STATE_ROOT="${RELAY_STATE_ROOT:-$RELAY_TEST_TMP_ROOT/relay-test-state-${UID:-0}-$$}"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WORK="/tmp/relay-lock-stress-workspace"

rm -rf "$WORK" "$RELAY_STATE_ROOT"
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

for pid in $(jobs -p); do
  if ! wait "$pid"; then :; fi
done
for output in "${outputs[@]}"; do
  jq -e --arg run_id "$run_id" '(.runs[$run_id] != null) and (.index_source == "rebuild") and ((.ok == true and .persisted == true) or (.ok == false and .failure_class == "state_store_failure" and (.error | test("bounded lock|persisted|verification"))))' "$output" >/dev/null
done
jq -e --arg run_id "$run_id" 'has($run_id)' "$RELAY_STATE_ROOT/index.json" >/dev/null

echo "PASS relay lock stress smoke"
