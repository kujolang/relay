#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
export KUJO_BIN="$KUJO"
RELAY_TEST_TMP_CREATED="$(mktemp -d "${TMPDIR:-/tmp}/relay-cli-contract.XXXXXX")"
RELAY_TEST_TMP_ROOT="$(cd "$RELAY_TEST_TMP_CREATED" && pwd -P)"
export RELAY_STATE_ROOT="$RELAY_TEST_TMP_ROOT/state"
trap 'rm -rf "$RELAY_TEST_TMP_ROOT"' EXIT

version="$($ROOT/bin/relay --version)"
test "$version" = "relay 1.1.0"
help="$($ROOT/bin/relay --help)"
grep -q 'Relay 1.1.0' <<<"$help"
grep -q 'chat <prompt>' <<<"$help"
grep -q 'missions create' <<<"$help"
grep -q 'runs list' <<<"$help"

set +e
unknown="$($ROOT/bin/relay unknown-command 2>&1)"
unknown_status=$?
missing_chat="$($ROOT/bin/relay chat --json 2>&1)"
missing_chat_status=$?
unknown_option="$($ROOT/bin/relay models list --modle typo --json 2>&1)"
unknown_option_status=$?
missing_option_value="$($ROOT/bin/relay models probe fixture-model --provider --json 2>&1)"
missing_option_value_status=$?
extra_argument="$($ROOT/bin/relay agents validate unexpected --json 2>&1)"
extra_argument_status=$?
duplicate_option="$($ROOT/bin/relay models list --json --json 2>&1)"
duplicate_option_status=$?
set -e
test "$unknown_status" -eq 2
test "$missing_chat_status" -eq 1
test "$unknown_option_status" -eq 1
test "$missing_option_value_status" -eq 1
test "$extra_argument_status" -eq 1
test "$duplicate_option_status" -eq 1
grep -q 'Usage: relay' <<<"$unknown"
printf '%s' "$missing_chat" | jq -e '.ok == false and (.error | contains("prompt"))' >/dev/null
printf '%s' "$unknown_option" | jq -e '.ok == false and .error == "unknown option --modle"' >/dev/null
printf '%s' "$missing_option_value" | jq -e '.ok == false and (.error | contains("requires a value"))' >/dev/null
printf '%s' "$extra_argument" | jq -e '.ok == false and (.error | contains("unexpected arguments"))' >/dev/null
printf '%s' "$duplicate_option" | jq -e '.ok == false and (.error | contains("duplicate option"))' >/dev/null

"$ROOT/bin/relay" chat "Summarize the mission boundary" --fixture --json > "$RELAY_TEST_TMP_ROOT/chat.json"
"$ROOT/bin/relay" models list --json > "$RELAY_TEST_TMP_ROOT/models.json"
"$ROOT/bin/relay" agents validate --json > "$RELAY_TEST_TMP_ROOT/agents.json"
"$ROOT/bin/relay" doctor --json > "$RELAY_TEST_TMP_ROOT/doctor.json"
"$ROOT/bin/relay" models probe fixture-model --fixture --json > "$RELAY_TEST_TMP_ROOT/probe.json"
literal_prompt="$($ROOT/bin/relay chat -- --literal-prompt)"
grep -q 'ok: true' <<<"$literal_prompt"

python3 "$ROOT/scripts/validate_json.py" "$ROOT/schemas/chat.schema.json" "$RELAY_TEST_TMP_ROOT/chat.json"
python3 "$ROOT/scripts/validate_json.py" "$ROOT/schemas/models.schema.json" "$RELAY_TEST_TMP_ROOT/models.json"
python3 "$ROOT/scripts/validate_json.py" "$ROOT/schemas/agents.schema.json" "$RELAY_TEST_TMP_ROOT/agents.json"
python3 "$ROOT/scripts/validate_json.py" "$ROOT/schemas/doctor.schema.json" "$RELAY_TEST_TMP_ROOT/doctor.json"
python3 "$ROOT/scripts/validate_json.py" "$ROOT/schemas/probe.schema.json" "$RELAY_TEST_TMP_ROOT/probe.json"

set +e
"$KUJO" run "$ROOT/main.kujo" -- benchmark run "$ROOT" --json > "$RELAY_TEST_TMP_ROOT/benchmark.json"
benchmark_status=$?
set -e
test "$benchmark_status" -eq 0 || test "$benchmark_status" -eq 1
python3 "$ROOT/scripts/validate_json.py" "$ROOT/schemas/benchmark.schema.json" "$RELAY_TEST_TMP_ROOT/benchmark.json"

echo "PASS relay CLI contract smoke"
