#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
probe="/tmp/relay-dangling-symlink-$$"
rm -f "$probe"
trap 'rm -f "$probe"' EXIT
ln -s "/tmp/relay-target-that-does-not-exist-$$" "$probe"

output="$(RELAY_SYMLINK_PROBE_PATH="$probe" RELAY_EXPECT_SYMLINK_PROBE=true "$KUJO" run "$ROOT/tests/relay_contract_tests.kujo" --interpreter)"
printf '%s\n' "$output" | grep -q 'PASS configured symlink probe boundary'
printf 'PASS relay symlink probe smoke\n'
