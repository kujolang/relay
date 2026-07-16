#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELAY_TEST_TMP_ROOT="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
export RELAY_STATE_ROOT="${RELAY_STATE_ROOT:-$RELAY_TEST_TMP_ROOT/relay-test-state-${UID:-0}-$$}"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
TARGET="/tmp/relay-state-store-target"
WORK="/tmp/relay-state-store-workspace"
PARENT_TARGET="$RELAY_STATE_ROOT-state-store-parent-target"
PARENT_LINK="$RELAY_STATE_ROOT-state-store-parent-link"

rm -rf "$RELAY_STATE_ROOT" "$TARGET" "$WORK" "$PARENT_TARGET" "$PARENT_LINK"
mkdir -p "$TARGET" "$WORK" "$PARENT_TARGET"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline

export RELAY_ROOT="$ROOT"
capability_fixture="$(jq -cn --arg root "$ROOT" --arg work "$WORK" '{root:$root,run_id:"relay-state-capability",session_id:"relay-state-capability-session",workspace:$work,nonce:"relay-state-capability-nonce",max_calls:1,ttl_ms:180000}')"
capability_output="$(RELAY_CAPABILITY_FIXTURE="$capability_fixture" "$KUJO" run "$ROOT/tests/relay_capability_fixture.kujo" --interpreter)"
printf '%s' "$capability_output" | jq -e '.ok == true' >/dev/null
test -d "$RELAY_STATE_ROOT/capabilities"
set +e
duplicate_capability="$(RELAY_CAPABILITY_FIXTURE="$capability_fixture" "$KUJO" run "$ROOT/tests/relay_capability_fixture.kujo" --interpreter 2>&1)"
duplicate_status=$?
set -e
test "$duplicate_status" -ne 0
printf '%s' "$duplicate_capability" | grep -q 'capability_already_registered'
rm -rf "$RELAY_STATE_ROOT"

ln -s "$TARGET" "$RELAY_STATE_ROOT"
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
parent_probe_output="$(env -u RELAY_STATE_ROOT RELAY_STORE_PROBE_PATH="$PARENT_LINK/.relay" "$KUJO" run "$ROOT/tests/relay_contract_tests.kujo" --interpreter)"
printf '%s' "$parent_probe_output" | grep -q 'PASS parent symlink store rejected'

rm "$RELAY_STATE_ROOT"
mkdir -p "$RELAY_STATE_ROOT"
ln -s "$TARGET" "$RELAY_STATE_ROOT/runs"
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

rm -rf "$RELAY_STATE_ROOT" "$TARGET" "$WORK" "$PARENT_TARGET" "$PARENT_LINK"
echo "PASS relay state store safety smoke"
