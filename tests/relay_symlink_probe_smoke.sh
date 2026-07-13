#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
probe="/tmp/relay-dangling-symlink-$$"
parent_target="$ROOT/.relay-parent-target-$$"
parent_link="$ROOT/.relay-parent-link-$$"
dependency_target="$ROOT/.relay-dependency-target-$$"
dependency_link="$ROOT/.relay-dependency-link-$$"
rm -f "$probe"
rm -rf "$parent_target" "$parent_link" "$dependency_target" "$dependency_link"
trap 'rm -f "$probe"; rm -rf "$parent_target" "$parent_link" "$dependency_target" "$dependency_link"' EXIT
ln -s "/tmp/relay-target-that-does-not-exist-$$" "$probe"
mkdir -p "$parent_target"
ln -s "$parent_target" "$parent_link"
mkdir -p "$dependency_target"
ln -s "$dependency_target" "$dependency_link"

output="$(RELAY_SYMLINK_PROBE_PATH="$probe" RELAY_EXPECT_SYMLINK_PROBE=true RELAY_STORE_PROBE_PATH="$parent_link/.relay" RELAY_DEPENDENCY_PROBE_PATH="$dependency_link/kujo" "$KUJO" run "$ROOT/tests/relay_contract_tests.kujo" --interpreter)"
printf '%s\n' "$output" | grep -q 'PASS configured symlink probe boundary'
printf '%s\n' "$output" | grep -q 'PASS parent symlink store rejected'
printf '%s\n' "$output" | grep -q 'PASS parent symlink dependency rejected'
printf 'PASS relay symlink probe smoke\n'
