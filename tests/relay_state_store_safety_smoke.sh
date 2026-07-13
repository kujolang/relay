#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
TARGET="/tmp/relay-state-store-target"
WORK="/tmp/relay-state-store-workspace"
PARENT_TARGET="/tmp/relay-state-store-parent-target"
PARENT_LINK="/tmp/relay-state-store-parent-link"

rm -rf "$ROOT/.relay" "$TARGET" "$WORK" "$PARENT_TARGET" "$PARENT_LINK"
mkdir -p "$TARGET" "$WORK" "$PARENT_TARGET"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline

export RELAY_ROOT="$ROOT"
ln -s "$TARGET" "$ROOT/.relay"
set +e
root_output="$($KUJO run "$ROOT/main.kujo" -- runs list --json 2>&1)"
root_status=$?
set -e
test "$root_status" -ne 0
printf '%s' "$root_output" | grep -q 'state_store_failure'
printf '%s' "$root_output" | grep -q 'unsafe'

set +e
root_mission_output="$($KUJO run "$ROOT/main.kujo" -- missions run "$ROOT/examples/fixture-mission.json" --fixture --skip-agent-smoke --json 2>&1)"
root_mission_status=$?
set -e
test "$root_mission_status" -ne 0
printf '%s' "$root_mission_output" | grep -q 'state_store_failure'
test ! -e "$TARGET/runs"

ln -s "$PARENT_TARGET" "$PARENT_LINK"
parent_probe_output="$(RELAY_STORE_PROBE_PATH="$PARENT_LINK/.relay" "$KUJO" run "$ROOT/tests/relay_contract_tests.kujo" --interpreter)"
printf '%s' "$parent_probe_output" | grep -q 'PASS parent symlink store rejected'

rm "$ROOT/.relay"
mkdir -p "$ROOT/.relay"
ln -s "$TARGET" "$ROOT/.relay/runs"
set +e
runs_output="$($KUJO run "$ROOT/main.kujo" -- runs list --json 2>&1)"
runs_status=$?
set -e
test "$runs_status" -ne 0
printf '%s' "$runs_output" | grep -q 'state_store_failure'

set +e
runs_mission_output="$($KUJO run "$ROOT/main.kujo" -- missions run "$ROOT/examples/fixture-mission.json" --fixture --skip-agent-smoke --json 2>&1)"
runs_mission_status=$?
set -e
test "$runs_mission_status" -ne 0
printf '%s' "$runs_mission_output" | grep -q 'state_store_failure'
test ! -e "$TARGET/runs"

rm -rf "$ROOT/.relay" "$TARGET" "$WORK" "$PARENT_TARGET" "$PARENT_LINK"
echo "PASS relay state store safety smoke"
