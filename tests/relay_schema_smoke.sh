#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELAY_TEST_TMP_ROOT="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
export RELAY_STATE_ROOT="${RELAY_STATE_ROOT:-$RELAY_TEST_TMP_ROOT/relay-test-state-${UID:-0}-$$}"

schemas=(
  mission
  run
  report
  event
  event-bundle
  run-bundle
  run-index-record
  receipt
  doctor
  probe
  tool-result
  tool-result-bundle
  run-verification
  run-sizes
  packet-manifest
)
for name in "${schemas[@]}"; do
  path="$ROOT/schemas/$name.schema.json"
  jq -e --arg id "https://kujo.dev/relay/schemas/$name.schema.json" \
    '."$schema" == "https://json-schema.org/draft/2020-12/schema" and ."$id" == $id and (.title | type == "string")' \
    "$path" >/dev/null
done

echo "PASS relay schema smoke (${#schemas[@]} schemas)"
