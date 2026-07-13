#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

schemas=(
  mission
  run
  report
  event
  receipt
  doctor
  probe
  tool-result
)
for name in "${schemas[@]}"; do
  path="$ROOT/schemas/$name.schema.json"
  jq -e --arg id "https://kujo.dev/relay/schemas/$name.schema.json" \
    '."$schema" == "https://json-schema.org/draft/2020-12/schema" and ."$id" == $id and (.title | type == "string")' \
    "$path" >/dev/null
done

echo "PASS relay schema smoke (${#schemas[@]} schemas)"
