#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"

if rg -n 'rm -rf .*\$ROOT/\.relay' "$ROOT"/tests/relay_*_smoke.sh; then
  echo "FAIL Relay smoke test may delete the repository evidence store" >&2
  exit 1
fi

export KUJO
"$KUJO" run "$ROOT/tests/relay_contract_tests.kujo" --interpreter
bash "$ROOT/tests/markdown_links.sh"
bash "$ROOT/tests/release_metadata.sh"

smoke_count=0
for smoke in "$ROOT"/tests/*_smoke.sh; do
  bash "$smoke"
  smoke_count=$((smoke_count + 1))
done

git -C "$ROOT" diff --check
echo "PASS relay acceptance ($smoke_count smoke scripts)"
