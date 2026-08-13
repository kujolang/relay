#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
TMP_BASE="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
TMP_ROOT="$(mktemp -d "$TMP_BASE/relay-benchmark-fixture.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT
fixture="$(jq -cn --arg root "$TMP_ROOT/state" '{state_root:$root,profile:"smoke",run_count:3,event_count:5,artifact_bytes:4096}')"
generated="$(RELAY_BENCHMARK_FIXTURE="$fixture" "$KUJO" run "$ROOT/scripts/benchmark_fixture.kujo" --interpreter)"
run_id="$(jq -er '.target_run_id' <<<"$generated")"
export RELAY_ROOT="$ROOT"
export RELAY_STATE_ROOT="$TMP_ROOT/state"
$KUJO run "$ROOT/main.kujo" -- runs rebuild --json | jq -e '.ok and (.runs | length) == 3' >/dev/null
$KUJO run "$ROOT/main.kujo" -- runs verify "$run_id" --json | jq -e '.ok and .integrity_valid' >/dev/null
$KUJO run "$ROOT/main.kujo" -- runs export "$run_id" --output "$TMP_ROOT/export.json" --json | jq -e '.ok and .integrity_valid' >/dev/null
jq -e '.format == "relay-run-export-v1" and (.events | length) == 5 and .changes.artifact_bytes == 4096' "$TMP_ROOT/export.json" >/dev/null
test "$(wc -c < "$TMP_ROOT/state/runs/$run_id/report.md" | tr -d ' ')" -gt 4096
echo "PASS Relay representative benchmark fixture smoke"
