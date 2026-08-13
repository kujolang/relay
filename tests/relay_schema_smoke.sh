#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELAY_TEST_TMP_ROOT="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
export RELAY_STATE_ROOT="${RELAY_STATE_ROOT:-$RELAY_TEST_TMP_ROOT/relay-test-state-${UID:-0}-$$}"

schemas=(
  chat
  models
  agents
  benchmark
  mission
  run
  report
  run-export
  run-export-partial
  signed-export
  aggregate-metrics
  failure-handoff
  machine-access
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

python3 "$ROOT/scripts/validate_json.py" "$ROOT/schemas/chat.schema.json" "$ROOT/tests/fixtures/cli/chat-v1.json"
python3 "$ROOT/scripts/validate_json.py" "$ROOT/schemas/models.schema.json" "$ROOT/tests/fixtures/cli/models-v1.json"
python3 "$ROOT/scripts/validate_json.py" "$ROOT/schemas/agents.schema.json" "$ROOT/tests/fixtures/cli/agents-v1.json"
python3 "$ROOT/scripts/validate_json.py" "$ROOT/schemas/benchmark.schema.json" "$ROOT/tests/fixtures/cli/benchmark-v1.json"
python3 "$ROOT/scripts/validate_json.py" "$ROOT/schemas/mission.schema.json" "$ROOT/tests/fixtures/mission-v0.1.0.json"
for mission in "$ROOT"/examples/*-mission.json; do
  python3 "$ROOT/scripts/validate_json.py" "$ROOT/schemas/mission.schema.json" "$mission"
done

echo "PASS relay schema smoke (${#schemas[@]} schemas)"
