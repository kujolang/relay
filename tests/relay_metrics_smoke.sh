#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELAY_TEST_TMP_ROOT="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
export RELAY_STATE_ROOT="${RELAY_STATE_ROOT:-$RELAY_TEST_TMP_ROOT/relay-test-state-${UID:-0}-$$}"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WORK="/tmp/relay-metrics-workspace"

rm -rf "$WORK" "$RELAY_STATE_ROOT"
mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline

export RELAY_ROOT="$ROOT"
chat="$($KUJO run "$ROOT/main.kujo" -- chat "relay metrics" --fixture --json)"
jq -e '.ok == true and (.relay_telemetry.duration_ms | type == "number") and .relay_telemetry.duration_ms >= 0' <<<"$chat" >/dev/null

mission="$($KUJO run "$ROOT/main.kujo" -- missions run "$ROOT/examples/fixture-mission.json" --fixture --skip-agent-smoke --json)"
jq -e '.ok == true and (.run.telemetry.duration_ms | type == "number") and .run.telemetry.duration_ms >= 0 and (.run.runledger.duration_ms | type == "number")' <<<"$mission" >/dev/null

echo "PASS relay metrics smoke"
