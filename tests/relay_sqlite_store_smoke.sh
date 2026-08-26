#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
TMP_CREATED="$(mktemp -d "${TMPDIR:-/tmp}/relay-sqlite-store.XXXXXX")"
TMP_ROOT="$(cd "$TMP_CREATED" && pwd -P)"
WORK="$TMP_ROOT/work"
SPEC="$TMP_ROOT/mission.json"
export RELAY_ROOT="$ROOT"
export RELAY_STATE_ROOT="$TMP_ROOT/state"
export KUJO_BIN="$KUJO"
trap 'rm -rf "$TMP_ROOT"' EXIT

mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline
ruby -rjson -e 'spec=JSON.parse(File.read(ARGV.fetch(0))); spec["repository"]=ARGV.fetch(1); File.write(ARGV.fetch(2), JSON.generate(spec))' "$ROOT/examples/fixture-mission.json" "$WORK" "$SPEC"

result="$($KUJO run "$ROOT/main.kujo" -- missions run "$SPEC" --fixture --skip-agent-smoke --json)"
run_id="$(printf '%s' "$result" | jq -r '.run.run_id')"
test -n "$run_id"
migrated="$($KUJO run "$ROOT/main.kujo" -- runs migrate-store --backend sqlite --confirm --json)"
printf '%s' "$migrated" | jq -e --arg run_id "$run_id" '.ok == true and .format == "relay-store-migration-v1" and .to == "sqlite" and .contract_version == "relay-run-index-sqlite-v1" and .records == 1' >/dev/null
test -f "$RELAY_STATE_ROOT/run-index.sqlite3"

listed="$(RELAY_STORE_BACKEND=sqlite $KUJO run "$ROOT/main.kujo" -- runs list --json)"
printf '%s' "$listed" | jq -e --arg run_id "$run_id" '.ok == true and .runs[$run_id].status == "completed"' >/dev/null
printf '%s' '{"corrupt":true}' > "$RELAY_STATE_ROOT/index.json"
listed_again="$(RELAY_STORE_BACKEND=sqlite $KUJO run "$ROOT/main.kujo" -- runs list --json)"
printf '%s' "$listed_again" | jq -e --arg run_id "$run_id" '.ok == true and .runs[$run_id].status == "completed" and .runs.corrupt == null' >/dev/null

rm "$RELAY_STATE_ROOT/run-index.sqlite3"
rm -f "$RELAY_STATE_ROOT/run-index.sqlite3-wal" "$RELAY_STATE_ROOT/run-index.sqlite3-shm"
printf '%s' 'not-a-sqlite-database' > "$RELAY_STATE_ROOT/run-index.sqlite3"
set +e
failed_rebuild="$(RELAY_STORE_BACKEND=sqlite $KUJO run "$ROOT/main.kujo" -- runs list --json 2>&1)"
failed_rebuild_rc=$?
set -e
test "$failed_rebuild_rc" -ne 0
printf '%s' "$failed_rebuild" | jq -e '.ok == false and .failure_class == "state_store_failure" and (.error | contains("SQLite"))' >/dev/null
rm "$RELAY_STATE_ROOT/run-index.sqlite3"
rm -f "$RELAY_STATE_ROOT/run-index.sqlite3-wal" "$RELAY_STATE_ROOT/run-index.sqlite3-shm"
recovered="$(RELAY_STORE_BACKEND=sqlite $KUJO run "$ROOT/main.kujo" -- runs list --json)"
printf '%s' "$recovered" | jq -e --arg run_id "$run_id" '.ok == true and .runs[$run_id].status == "completed"' >/dev/null
test -f "$RELAY_STATE_ROOT/run-index.sqlite3"
doctor="$(RELAY_STORE_BACKEND=sqlite $KUJO run "$ROOT/main.kujo" -- doctor --json)"
printf '%s' "$doctor" | jq -e '(.checks | map(select(.name == "Relay transactional store"))[0]) | .ok == true and .required == true and .backend == "sqlite" and .configured == true and .contract_version == "relay-run-index-sqlite-v1"' >/dev/null

echo "PASS relay SQLite store migration and recovery smoke"
