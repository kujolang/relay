#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/relay-restore-evidence.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT
KUJO_BIN="$KUJO" python3 "$ROOT/scripts/backup_restore_drill.py" --output "$TMP_ROOT/receipt.json"
jq -e '.ok and .fixture_only and .observed_rpo_completed_runs == 0 and .original_location_unavailable_during_recovery and .source_unchanged and (.recovery | keys == ["json","sqlite"]) and (.negative_cases | keys == ["corrupt","interrupted","partial"])' "$TMP_ROOT/receipt.json" >/dev/null
