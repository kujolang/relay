#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELAY_TEST_TMP_ROOT="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
export RELAY_STATE_ROOT="${RELAY_STATE_ROOT:-$RELAY_TEST_TMP_ROOT/relay-test-state-${UID:-0}-$$}"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WORK="/tmp/relay-fixture-workspace"

rm -rf "$WORK"
mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline

export RELAY_ROOT="$ROOT"
paused="$($KUJO run "$ROOT/main.kujo" -- missions run "$ROOT/examples/fixture-mission.json" --fixture --pause-after-plan --json)"
grep -q '"status":"paused"' <<<"$paused"
grep -q '"checkpoint"' <<<"$paused"

run_id="$(printf '%s' "$paused" | ruby -rjson -e 'd=JSON.parse(STDIN.read); print d["run"]["run_id"]')"
test -n "$run_id"
resumed="$($KUJO run "$ROOT/main.kujo" -- missions resume "$run_id" --json)"
grep -q '"ok":true' <<<"$resumed"
grep -q '"status":"completed"' <<<"$resumed"
grep -q '"runledger_finish"' <<<"$resumed"
grep -q '"packet_revision":1' <<<"$resumed"
grep -q '"runledger_id"' <<<"$resumed"
grep -q '"provider":"fixture"' <<<"$resumed"
grep -q '"receipts"' <<<"$resumed"

run_dir="$(printf '%s' "$resumed" | ruby -rjson -e 'print JSON.parse(STDIN.read)["run_dir"]')"
python3 "$ROOT/scripts/validate_json.py" "$ROOT/schemas/run.schema.json" "$run_dir/state.json"
python3 "$ROOT/scripts/validate_json.py" "$ROOT/schemas/report.schema.json" "$run_dir/report.json"
python3 "$ROOT/scripts/validate_json.py" "$ROOT/schemas/packet-manifest.schema.json" "$run_dir/packet-manifest.json"
contract_item="/tmp/relay-mission-contract-item-$$.json"
jq -c '.[]' "$run_dir/receipts.json" | while IFS= read -r item; do
  printf '%s\n' "$item" > "$contract_item"
  python3 "$ROOT/scripts/validate_json.py" "$ROOT/schemas/receipt.schema.json" "$contract_item" >/dev/null
done
while IFS= read -r item; do
  printf '%s\n' "$item" > "$contract_item"
  python3 "$ROOT/scripts/validate_json.py" "$ROOT/schemas/event.schema.json" "$contract_item" >/dev/null
done < "$run_dir/events.jsonl"
rm -f "$contract_item"
jq -e '.receipts | length >= 7 and (map(.receipt_id) as $ids | (($ids | unique | length) == ($ids | length))) and (all(.[]; (.metadata.workflow == "verified-feature" and .metadata.model == "fixture-model" and .metadata.provider == "fixture" and (.metadata.packet_revision == 0 or .metadata.packet_revision == 1) and (.metadata.runledger_id != null))))' "$run_dir/state.json" >/dev/null
test -f "$run_dir/receipts.json"

# A configured fallback decision must be persisted as typed evidence even when
# the primary failure is non-retryable and the fallback is skipped.
set +e
fallback_run="$(RELAY_OFFLINE_FIXTURE=false RELAY_FALLBACK_MODEL=backup "$KUJO" run "$ROOT/main.kujo" -- missions run "$ROOT/examples/fixture-mission.json" --skip-agent-smoke --json 2>&1)"
fallback_status=$?
set -e
test "$fallback_status" -ne 0
printf '%s' "$fallback_run" | jq -e '.run.status == "failed" and (.run.events | map(.kind) | index("model_fallback_skipped")) != null and (.run.receipts | map(select(.kind == "fallback" and .status == "skipped")) | length) == 1' >/dev/null

test -f "$WORK/RELAY_OUTPUT.txt"
echo "PASS relay mission smoke"
