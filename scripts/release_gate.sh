#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
KUJO_SOURCE_ROOT="${KUJO_SOURCE_ROOT:-$ROOT/../kujo}"
KENNEL_ROOT="${KENNEL_ROOT:-$ROOT/../kennel}"
SHIPCHECK_ROOT="${SHIPCHECK_ROOT:-$ROOT/../shipcheck}"

test -x "$KUJO"
test -z "$(git -C "$ROOT" status --porcelain)"
test "$(git -C "$KUJO_SOURCE_ROOT" rev-parse HEAD)" = "$(cat "$ROOT/RUNTIME_VERSION")"
bash "$ROOT/tests/release_metadata.sh"

while IFS= read -r source; do
  "$KUJO" check "$source"
done < <(find "$ROOT" -type f -name '*.kujo' -not -path '*/.git/*' -not -path '*/.relay/*' -not -path '*/.workcell/*' | sort)

KUJO_BIN="$KUJO" bash "$ROOT/tests/relay_acceptance.sh"

"$KUJO" run "$KENNEL_ROOT/kennel.kujo" --interpreter -- validate --project-dir "$ROOT"

shipcheck_output="$(mktemp "${TMPDIR:-/tmp}/relay-shipcheck.XXXXXX")"
trap 'rm -f "$shipcheck_output"' EXIT
"$KUJO" run "$SHIPCHECK_ROOT/shipcheck.kujo" gate --dir "$ROOT" --format json > "$shipcheck_output"
jq -e '.summary.gate_passed == 1 and .summary.passed == 16 and .summary.total_checks == 16 and .summary.failed_errors == 0 and .summary.warnings == 0' "$shipcheck_output" >/dev/null

git -C "$ROOT" diff --check
echo "PASS Relay release gate"
