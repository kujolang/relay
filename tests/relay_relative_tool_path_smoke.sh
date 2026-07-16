#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELAY_TEST_TMP_ROOT="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
export RELAY_STATE_ROOT="${RELAY_STATE_ROOT:-$RELAY_TEST_TMP_ROOT/relay-test-state-${UID:-0}-$$}"
WORK="/tmp/relay-relative-tool-path-workspace"
KUJO_REL="../kujo/target/release/kujo"

rm -rf "$WORK" "$RELAY_STATE_ROOT"
mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline

export RELAY_ROOT="$ROOT"
export KUJO_BIN="$KUJO_REL"
result="$($KUJO_REL run "$ROOT/main.kujo" -- missions run "$ROOT/examples/fixture-mission.json" --fixture --skip-agent-smoke --json)"
printf '%s' "$result" | jq -e '.ok == true and .run.status == "completed" and (.run.changes.files | length) > 0 and .run.evaluations[0].ok == true' >/dev/null

echo "PASS relay relative tool path smoke"
