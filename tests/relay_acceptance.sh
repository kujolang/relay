#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"

export KUJO
"$KUJO" run "$ROOT/tests/relay_contract_tests.kujo" --interpreter

smoke_count=0
for smoke in "$ROOT"/tests/relay_*_smoke.sh; do
  bash "$smoke"
  smoke_count=$((smoke_count + 1))
done

git -C "$ROOT" diff --check
echo "PASS relay acceptance ($smoke_count smoke scripts)"
