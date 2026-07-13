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
