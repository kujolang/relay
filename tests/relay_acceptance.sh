#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"

if command -v rg >/dev/null 2>&1; then
  unsafe_cleanup="$(rg -n 'rm -rf .*\$ROOT/\.relay' "$ROOT"/tests/relay_*_smoke.sh || true)"
else
  unsafe_cleanup="$(grep -En 'rm -rf .*\$ROOT/\.relay' "$ROOT"/tests/relay_*_smoke.sh || true)"
fi
if [[ -n "$unsafe_cleanup" ]]; then
  printf '%s\n' "$unsafe_cleanup" >&2
  echo "FAIL Relay smoke test may delete the repository evidence store" >&2
  exit 1
fi

export KUJO
"$KUJO" run "$ROOT/tests/relay_contract_tests.kujo" --interpreter
bash "$ROOT/tests/markdown_links.sh"
bash "$ROOT/tests/release_metadata.sh"

smoke_count=0
for smoke in "$ROOT"/tests/*_smoke.sh; do
  echo "RUN ${smoke#"$ROOT/"}"
  set +e
  bash "$smoke"
  smoke_status=$?
  set -e
  if [[ "$smoke_status" -ne 0 ]]; then
    echo "FAIL ${smoke#"$ROOT/"}" >&2
    exit "$smoke_status"
  fi
  smoke_count=$((smoke_count + 1))
done

git -C "$ROOT" diff --check
echo "PASS relay acceptance ($smoke_count smoke scripts)"
