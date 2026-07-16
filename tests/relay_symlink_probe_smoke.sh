#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELAY_TEST_TMP_ROOT="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
export RELAY_STATE_ROOT="${RELAY_STATE_ROOT:-$RELAY_TEST_TMP_ROOT/relay-test-state-${UID:-0}-$$}"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
probe="/tmp/relay-dangling-symlink-$$"
parent_target="$ROOT/.relay-parent-target-$$"
parent_link="$ROOT/.relay-parent-link-$$"
dependency_target="$ROOT/.relay-dependency-target-$$"
dependency_link="$ROOT/.relay-dependency-link-$$"
dangling_append_target="/tmp/relay-dangling-append-target-$$"
dangling_append_link="$ROOT/.relay-dangling-append-link-$$"
dangling_cancel_target="/tmp/relay-dangling-cancel-target-$$"
dangling_cancel_dir="$ROOT/.relay-dangling-cancel-dir-$$"
atomic_target="/tmp/relay-atomic-target-$$"
atomic_link="$ROOT/.relay-atomic-link-$$"
rm -f "$probe"
rm -f "$dangling_append_target" "$dangling_append_link" "$dangling_cancel_target" "$atomic_target" "$atomic_link"
rm -rf "$parent_target" "$parent_link" "$dependency_target" "$dependency_link" "$dangling_cancel_dir"
trap 'rm -f "$probe" "$dangling_append_target" "$dangling_append_link" "$dangling_cancel_target" "$atomic_target" "$atomic_link"; rm -rf "$parent_target" "$parent_link" "$dependency_target" "$dependency_link" "$dangling_cancel_dir"' EXIT
ln -s "/tmp/relay-target-that-does-not-exist-$$" "$probe"
mkdir -p "$parent_target"
ln -s "$parent_target" "$parent_link"
mkdir -p "$dependency_target"
ln -s "$dependency_target" "$dependency_link"
ln -s "$dangling_append_target" "$dangling_append_link"
mkdir -p "$dangling_cancel_dir"
ln -s "$dangling_cancel_target" "$dangling_cancel_dir/cancel.request.json"
printf 'relay-atomic-target' > "$atomic_target"
ln -s "$atomic_target" "$atomic_link"

output="$(RELAY_SYMLINK_PROBE_PATH="$probe" RELAY_EXPECT_SYMLINK_PROBE=true RELAY_STORE_PROBE_PATH="$parent_link/.relay" RELAY_DEPENDENCY_PROBE_PATH="$dependency_link/kujo" RELAY_DANGLING_APPEND_PATH="$dangling_append_link" RELAY_DANGLING_CANCEL_RUN_DIR="$dangling_cancel_dir" RELAY_ATOMIC_PROBE_PATH="$atomic_link" RELAY_ATOMIC_TARGET_PATH="$atomic_target" "$KUJO" run "$ROOT/tests/relay_contract_tests.kujo" --interpreter)"
printf '%s\n' "$output" | grep -q 'PASS configured symlink probe boundary'
printf '%s\n' "$output" | grep -q 'PASS parent symlink store rejected'
printf '%s\n' "$output" | grep -q 'PASS parent symlink dependency rejected'
printf '%s\n' "$output" | grep -q 'PASS dangling JSONL append rejected'
printf '%s\n' "$output" | grep -q 'PASS dangling cancellation request rejected'
printf '%s\n' "$output" | grep -q 'PASS atomic write replaces link safely'
test ! -e "$dangling_append_target"
test -f "$atomic_link" && test ! -L "$atomic_link"
test "$(cat "$atomic_target")" = 'relay-atomic-target'
printf 'PASS relay symlink probe smoke\n'
