#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/relay-walkthrough.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT
KUJO_BIN="$KUJO" python3 "$ROOT/scripts/fixture_walkthrough.py" --output "$TMP_ROOT/result"
jq -e '.ok and .archive_install and .fresh_home and .fixture_only and .run_verified and .signature_valid_without_origin_store and .mission_status == "completed"' "$TMP_ROOT/result/receipt.json" >/dev/null
test -s "$TMP_ROOT/result/01-install.html"
test -s "$TMP_ROOT/result/02-evidence.html"
