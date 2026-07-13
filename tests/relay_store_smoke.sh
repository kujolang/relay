#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WORK="/tmp/relay-store-workspace"

rm -rf "$WORK" "$ROOT/.relay"
mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline

export RELAY_ROOT="$ROOT"
result="$($KUJO run "$ROOT/main.kujo" -- missions run "$ROOT/examples/fixture-mission.json" --fixture --skip-agent-smoke --json)"
printf '%s' "$result" | grep -q '"status":"completed"'
run_id="$(printf '%s' "$result" | ruby -rjson -e 'print JSON.parse(STDIN.read)["run"]["run_id"]')"
test -n "$run_id"

# A corrupt or tampered cache must not become an arbitrary filesystem read.
printf '%s' '{"attacker":{"run_dir":"/etc","status":"completed"}}' > "$ROOT/.relay/index.json"
listed="$($KUJO run "$ROOT/main.kujo" -- runs list --json)"
printf '%s' "$listed" | grep -q "\"$run_id\""
printf '%s' "$listed" | grep -q '"index_source":"validated_cache_or_rebuild"'
printf '%s' "$listed" | jq -e --arg run_id "$run_id" '.runs[$run_id].updated_at != null and .runs[$run_id].updated_at != ""' >/dev/null
if printf '%s' "$listed" | grep -q 'attacker'; then
  echo "tampered index entry was trusted" >&2
  exit 1
fi

# The cache must be size-bounded before JSON parsing, not only after a large
# attacker-controlled document has already been loaded.
ruby -e 'path=ARGV.fetch(0); File.write(path, "{\"oversized\":\"" + ("x" * 8388609) + "\"}")' "$ROOT/.relay/index.json"
oversized_listed="$($KUJO run "$ROOT/main.kujo" -- runs list --json)"
printf '%s' "$oversized_listed" | grep -q "\"$run_id\""
if printf '%s' "$oversized_listed" | grep -q 'oversized'; then
  echo "oversized index entry was trusted" >&2
  exit 1
fi

rebuilt="$($KUJO run "$ROOT/main.kujo" -- runs rebuild --json)"
printf '%s' "$rebuilt" | grep -q '"index_source":"rebuild"'
printf '%s' "$rebuilt" | grep -q "\"$run_id\""

export_path="/tmp/relay-run-export-$run_id.json"
rm -f "$export_path"
exported="$($KUJO run "$ROOT/main.kujo" -- runs export "$run_id" --output "$export_path" --json)"
printf '%s' "$exported" | grep -q '"integrity_valid":true'
test -f "$export_path"
jq -e --arg run_id "$run_id" '.format == "relay-run-export-v1" and .run_id == $run_id and .integrity_valid == true and .receipts_valid == true and .receipts_consistent == true and (.events | length) > 0 and (.receipts | length) >= 7 and (.receipts | map(.receipt_id) as $ids | (($ids | unique | length) == ($ids | length)))' "$export_path" >/dev/null
jq -e --arg run_id "$run_id" '.events | all(.metadata.mission_id == "relay-fixture-mission" and .metadata.run_id == $run_id and (.metadata | has("tool")) and (.metadata | has("artifact")) and (.metadata | has("retry_id")) and (.metadata | has("repair_id")))' "$export_path" >/dev/null

run_dir="$ROOT/.relay/runs/$run_id"
events_path="$run_dir/events.jsonl"
mv "$events_path" "$events_path.regular"
ln -s /etc/passwd "$events_path"
set +e
symlink_events="$($KUJO run "$ROOT/main.kujo" -- runs events "$run_id" --json 2>&1)"
symlink_rc=$?
set -e
test "$symlink_rc" -ne 0
printf '%s' "$symlink_events" | grep -q 'symbolic-linked'
rm "$events_path"
mv "$events_path.regular" "$events_path"

receipts_path="$ROOT/.relay/runs/$run_id/receipts.json"
cp "$receipts_path" "$receipts_path.backup"
ruby -rjson -e 'path=ARGV.fetch(0); receipts=JSON.parse(File.read(path)); receipts[0]["status"]="tampered"; File.write(path, JSON.generate(receipts))' "$receipts_path"
set +e
tampered_receipts="$($KUJO run "$ROOT/main.kujo" -- runs events "$run_id" --json 2>&1)"
receipts_rc=$?
set -e
test "$receipts_rc" -ne 0
printf '%s' "$tampered_receipts" | grep -q '"receipts_valid":false'
mv "$receipts_path.backup" "$receipts_path"

# The state copy is not a substitute for the persisted receipt evidence file.
# Removing the file must fail inspection instead of silently passing through
# the state.json fallback.
mv "$receipts_path" "$receipts_path.missing"
set +e
missing_receipts="$($KUJO run "$ROOT/main.kujo" -- runs events "$run_id" --json 2>&1)"
missing_receipts_rc=$?
set -e
test "$missing_receipts_rc" -ne 0
printf '%s' "$missing_receipts" | grep -q '"receipts_valid":false'
mv "$receipts_path.missing" "$receipts_path"

# Run inspection must fail closed when authoritative state is absent; the
# rebuildable index is not a substitute for the per-run state record.
state_path="$run_dir/state.json"
mv "$state_path" "$state_path.missing"
set +e
missing_state="$($KUJO run "$ROOT/main.kujo" -- runs inspect "$run_id" --json 2>&1)"
missing_state_rc=$?
set -e
test "$missing_state_rc" -ne 0
printf '%s' "$missing_state" | grep -Eq 'unknown run|run state evidence is missing'
mv "$state_path.missing" "$state_path"

# An index entry with placeholder metadata must not make a run with missing
# authoritative state appear listable. This guards the cache validation path
# against accepting its own fallback values as proof of a real state record.
printf '{"%s":{"run_dir":"%s","mission_id":"","status":"unknown","updated_at":""}}' "$run_id" "$run_dir" > "$ROOT/.relay/index.json"
mv "$state_path" "$state_path.missing"
set +e
missing_index_state="$($KUJO run "$ROOT/main.kujo" -- runs list --json 2>&1)"
missing_index_state_rc=$?
set -e
test "$missing_index_state_rc" -eq 0
if printf '%s' "$missing_index_state" | jq -e --arg run_id "$run_id" '.runs[$run_id] != null' >/dev/null; then
  echo "index placeholder entry was accepted without state evidence" >&2
  exit 1
fi
mv "$state_path.missing" "$state_path"

inspected="$($KUJO run "$ROOT/main.kujo" -- runs inspect "$run_id" --json)"
printf '%s' "$inspected" | jq -e --arg run_id "$run_id" '.ok == true and .run.run_id == $run_id' >/dev/null

verified="$($KUJO run "$ROOT/main.kujo" -- runs verify "$run_id" --json)"
printf '%s' "$verified" | jq -e --arg run_id "$run_id" '.ok == true and .format == "relay-run-verification-v1" and .run_id == $run_id and .integrity_valid == true and .state_valid == true and .events_valid == true and .receipts_valid == true and .receipts_consistent == true and .changes_valid == true and .evaluations_valid == true' >/dev/null
printf '%s' "$verified" | jq -e '.report_valid == true' >/dev/null

# Machine callers can page a verified event stream without requesting the full
# JSONL payload. Integrity is still checked against the complete authoritative
# chain before the window is returned.
window="$($KUJO run "$ROOT/main.kujo" -- runs events "$run_id" --limit 2 --json)"
printf '%s' "$window" | jq -e '.ok == true and .integrity_valid == true and .event_count > 2 and (.events | length) == 2 and .has_more == true and (.next_after | length) > 0 and .events_jsonl == ""' >/dev/null
cursor="$(printf '%s' "$window" | jq -r '.next_after')"
next_window="$($KUJO run "$ROOT/main.kujo" -- runs events "$run_id" --after "$cursor" --limit 2 --json)"
printf '%s' "$next_window" | jq -e '.ok == true and .integrity_valid == true and .offset == 2 and (.events | length) > 0' >/dev/null
set +e
bad_limit="$($KUJO run "$ROOT/main.kujo" -- runs events "$run_id" --limit 4097 --json 2>&1)"
bad_limit_status=$?
set -e
test "$bad_limit_status" -ne 0
printf '%s' "$bad_limit" | grep -q 'event limit must be between 1 and 4096'
set +e
zero_limit="$($KUJO run "$ROOT/main.kujo" -- runs events "$run_id" --limit 0 --json 2>&1)"
zero_limit_status=$?
set -e
test "$zero_limit_status" -ne 0
printf '%s' "$zero_limit" | grep -q 'event limit must be between 1 and 4096'

# The authoritative state seal must also protect read-side status and
# workspace authority, not only resume and event-sequence checks.
cp "$run_dir/state.json" "$run_dir/state.json.sealed-backup"
ruby -rjson -e 'path=ARGV.fetch(0); state=JSON.parse(File.read(path)); state["status"]="failed"; File.write(path, JSON.generate(state))' "$run_dir/state.json"
set +e
tampered_state_inspect="$($KUJO run "$ROOT/main.kujo" -- runs inspect "$run_id" --json 2>&1)"
tampered_state_rc=$?
set -e
test "$tampered_state_rc" -ne 0
printf '%s' "$tampered_state_inspect" | grep -q 'integrity verification failed'
mv "$run_dir/state.json.sealed-backup" "$run_dir/state.json"

# A shape-valid report with the wrong run identity is not valid evidence.
cp "$run_dir/report.json" "$run_dir/report.json.backup"
ruby -rjson -e 'path=ARGV.fetch(0); report=JSON.parse(File.read(path)); report["run_id"]="other-run"; File.write(path, JSON.generate(report))' "$run_dir/report.json"
set +e
tampered_report_verify="$($KUJO run "$ROOT/main.kujo" -- runs verify "$run_id" --json 2>&1)"
tampered_report_rc=$?
set -e
test "$tampered_report_rc" -ne 0
printf '%s' "$tampered_report_verify" | jq -e '.ok == false and .report_valid == false and .integrity_valid == false' >/dev/null
set +e
tampered_report_command="$($KUJO run "$ROOT/main.kujo" -- missions report "$run_id" --json 2>&1)"
tampered_report_command_rc=$?
set -e
test "$tampered_report_command_rc" -ne 0
printf '%s' "$tampered_report_command" | grep -q 'does not match authoritative state'
mv "$run_dir/report.json.backup" "$run_dir/report.json"

# The Markdown report is also required evidence for inspection and export.
mv "$run_dir/report.md" "$run_dir/report.md.missing"
set +e
missing_markdown_verify="$($KUJO run "$ROOT/main.kujo" -- runs verify "$run_id" --json 2>&1)"
missing_markdown_rc=$?
set -e
test "$missing_markdown_rc" -ne 0
printf '%s' "$missing_markdown_verify" | jq -e '.ok == false and .report_valid == false' >/dev/null
mv "$run_dir/report.md.missing" "$run_dir/report.md"

# Paused/failed runs may intentionally lack post-verification artifacts. A
# caller must opt into the explicit partial contract; it never claims valid
# evidence and is unavailable for a completed run.
paused="$($KUJO run "$ROOT/main.kujo" -- missions run "$ROOT/examples/fixture-mission.json" --fixture --pause-after-plan --skip-agent-smoke --json)"
printf '%s' "$paused" | jq -e '.ok == true and .run.status == "paused"' >/dev/null
paused_id="$(printf '%s' "$paused" | ruby -rjson -e 'print JSON.parse(STDIN.read)["run"]["run_id"]')"
test -n "$paused_id"
set +e
complete_export="$($KUJO run "$ROOT/main.kujo" -- runs export "$paused_id" --json 2>&1)"
complete_export_rc=$?
set -e
test "$complete_export_rc" -ne 0
printf '%s' "$complete_export" | grep -q 'run export evidence is incomplete'
printf '%s' "$complete_export" | grep -q '"partial_export_available":true'
partial_export="$($KUJO run "$ROOT/main.kujo" -- runs export "$paused_id" --partial --json)"
printf '%s' "$partial_export" | jq -e --arg run_id "$paused_id" '.ok == true and .format == "relay-run-export-partial-v1" and .run_id == $run_id and .partial == true and .completeness == "partial" and .integrity_valid == false and .artifact_presence.changes == false and .artifact_presence.evaluations == false and .artifact_presence.report == true and .changes == null and .evaluations == null' >/dev/null

# Run artifact readers must fail closed instead of turning a missing result
# into a successful empty object or array.
changes_path="$run_dir/changes.json"
mv "$changes_path" "$changes_path.missing"
set +e
missing_changes="$($KUJO run "$ROOT/main.kujo" -- runs changes "$run_id" --json 2>&1)"
missing_changes_rc=$?
set -e
test "$missing_changes_rc" -ne 0
printf '%s' "$missing_changes" | grep -q 'run artifact evidence is missing'
mv "$changes_path.missing" "$changes_path"

mv "$changes_path" "$changes_path.missing"
set +e
missing_export_changes="$($KUJO run "$ROOT/main.kujo" -- runs export "$run_id" --json 2>&1)"
missing_export_changes_rc=$?
set -e
test "$missing_export_changes_rc" -ne 0
printf '%s' "$missing_export_changes" | grep -q 'run export evidence is incomplete'
printf '%s' "$missing_export_changes" | grep -q '"changes_valid":false'
mv "$changes_path.missing" "$changes_path"

evaluations_path="$run_dir/evaluations.json"
mv "$evaluations_path" "$evaluations_path.missing"
set +e
missing_evaluations="$($KUJO run "$ROOT/main.kujo" -- runs evaluations "$run_id" --json 2>&1)"
missing_evaluations_rc=$?
set -e
test "$missing_evaluations_rc" -ne 0
printf '%s' "$missing_evaluations" | grep -q 'run artifact evidence is missing'
mv "$evaluations_path.missing" "$evaluations_path"

report_path="$run_dir/report.json"
mv "$report_path" "$report_path.missing"
set +e
missing_export_report="$($KUJO run "$ROOT/main.kujo" -- runs export "$run_id" --json 2>&1)"
missing_export_report_rc=$?
set -e
test "$missing_export_report_rc" -ne 0
printf '%s' "$missing_export_report" | grep -q 'run export evidence is incomplete'
printf '%s' "$missing_export_report" | grep -q '"report_valid":false'
mv "$report_path.missing" "$report_path"

# The authoritative state event list must match the verified JSONL payloads,
# not merely carry the same event IDs. A state-only payload edit is evidence
# divergence and must fail inspection/export.
state_path="$run_dir/state.json"
cp "$state_path" "$state_path.backup"
ruby -rjson -e 'path=ARGV.fetch(0); state=JSON.parse(File.read(path)); state.fetch("events").fetch(0).fetch("payload")["state_only_tampered"]=true; File.write(path, JSON.generate(state))' "$state_path"
set +e
state_divergence="$($KUJO run "$ROOT/main.kujo" -- runs events "$run_id" --json 2>&1)"
state_divergence_rc=$?
set -e
test "$state_divergence_rc" -ne 0
printf '%s' "$state_divergence" | grep -q '"state_consistent":false'
mv "$state_path.backup" "$state_path"

cp "$events_path" "$events_path.backup"
# A truncated log must fail closed even when the remaining prefix is internally
# hash-valid, because authoritative state records the expected event sequence.
ruby -e 'path=ARGV.fetch(0); lines=File.readlines(path); lines.pop; File.write(path, lines.join)' "$events_path"
set +e
truncated_events="$($KUJO run "$ROOT/main.kujo" -- runs events "$run_id" --json 2>&1)"
truncated_rc=$?
set -e
test "$truncated_rc" -ne 0
printf '%s' "$truncated_events" | grep -q '"state_consistent":false'
mv "$events_path.backup" "$events_path"

# Integrity-sealed event records must fail closed when an on-disk payload is
# modified without recomputing its digest.
ruby -rjson -e 'path=ARGV.fetch(0); lines=File.readlines(path); event=JSON.parse(lines.fetch(0)); event["payload"]["tampered"]=true; lines[0]=JSON.generate(event)+"\n"; File.write(path, lines.join)' "$events_path"
set +e
tampered_events="$($KUJO run "$ROOT/main.kujo" -- runs events "$run_id" --json 2>&1)"
events_rc=$?
set -e
test "$events_rc" -ne 0
printf '%s' "$tampered_events" | grep -q '"integrity_valid":false'

set +e
unknown="$($KUJO run "$ROOT/main.kujo" -- runs inspect attacker --json 2>&1)"
rc=$?
set -e
test "$rc" -ne 0
printf '%s' "$unknown" | grep -q 'unknown run'

echo "PASS relay store smoke"
