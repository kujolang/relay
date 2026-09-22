#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/relay-sqlite-boundaries.XXXXXX")"
TMP_ROOT="$(cd "$TMP_ROOT" && pwd -P)"
locker_pid=""
trap 'if [[ -n "$locker_pid" ]]; then kill "$locker_pid" 2>/dev/null || true; wait "$locker_pid" 2>/dev/null || true; fi; rm -rf "$TMP_ROOT"' EXIT
probe() {
  RELAY_SQLITE_FIXTURE_ROOT="$1" RELAY_SQLITE_FIXTURE_ACTION="${2:-read}" "$KUJO" run "$ROOT/tests/relay_sqlite_boundary_fixture.kujo" --interpreter
}
reject() {
  if probe "$1" "${2:-read}" > "$TMP_ROOT/rejected.json"; then echo "unsafe SQLite case accepted: $1" >&2; exit 1; fi
  jq -e '.ok == false' "$TMP_ROOT/rejected.json" >/dev/null
}
python3 - "$TMP_ROOT" <<'PY'
import pathlib, sqlite3, sys
root=pathlib.Path(sys.argv[1])
for name in ['valid','missing','no-tables','unknown','extra','bad-columns','locked','wal-locked','uri ?#% directory']:
 p=root/name;p.mkdir();db=sqlite3.connect(p/'run-index.sqlite3')
 if name=='no-tables':db.execute('VACUUM');db.close();continue
 db.execute('CREATE TABLE schema_migrations(version INTEGER PRIMARY KEY,contract_version TEXT,applied_at_ms INTEGER)')
 if name!='missing':db.execute('INSERT INTO schema_migrations VALUES(?,?,0)',(2 if name=='unknown' else 1,'relay-run-index-sqlite-v1'))
 if name=='extra':db.execute("INSERT INTO schema_migrations VALUES(2,'future',0)")
 if name=='bad-columns':db.execute('CREATE TABLE run_index(unexpected TEXT)')
 else:db.execute('CREATE TABLE run_index(run_id TEXT PRIMARY KEY,run_dir TEXT,mission_id TEXT,status TEXT,updated_at TEXT,integrity_valid INTEGER)')
 db.commit();db.close()
PY
for name in valid missing no-tables unknown extra bad-columns 'uri ?#% directory'; do
  path="$TMP_ROOT/$name/run-index.sqlite3"
  before="$(shasum -a 256 "$path")"
  if [[ "$name" == valid || "$name" == 'uri ?#% directory' ]]; then
    probe "$TMP_ROOT/$name" | jq -e '.ok and .records == 0' >/dev/null
  else
    reject "$TMP_ROOT/$name"
    reject "$TMP_ROOT/$name" write
  fi
  test "$before" = "$(shasum -a 256 "$path")"
  test ! -e "$path-wal"
  test ! -e "$path-shm"
done
mkdir "$TMP_ROOT/absent"
reject "$TMP_ROOT/absent"
test ! -e "$TMP_ROOT/absent/run-index.sqlite3"
probe "$TMP_ROOT/absent" write | jq -e '.ok' >/dev/null
probe "$TMP_ROOT/absent" | jq -e '.ok' >/dev/null
for suffix in -wal -shm -journal; do
  ln -s "$TMP_ROOT/nonexistent" "$TMP_ROOT/valid/run-index.sqlite3$suffix"
  reject "$TMP_ROOT/valid"
  reject "$TMP_ROOT/valid" write
  test ! -e "$TMP_ROOT/nonexistent"
  rm "$TMP_ROOT/valid/run-index.sqlite3$suffix"
  mkdir "$TMP_ROOT/valid/run-index.sqlite3$suffix"
  reject "$TMP_ROOT/valid"
  rmdir "$TMP_ROOT/valid/run-index.sqlite3$suffix"
done
for lock_case in locked wal-locked; do
rm -f "$TMP_ROOT/lock-ready" "$TMP_ROOT/unlock"
python3 - "$TMP_ROOT" "$lock_case" <<'PY' &
import pathlib, sqlite3, sys, time
root=pathlib.Path(sys.argv[1]);name=sys.argv[2];db=sqlite3.connect(root/name/'run-index.sqlite3')
if name=='wal-locked':db.execute('PRAGMA journal_mode=WAL')
db.execute('BEGIN IMMEDIATE' if name=='wal-locked' else 'BEGIN EXCLUSIVE');(root/'lock-ready').touch()
for _ in range(200):
 if (root/'unlock').exists(): break
 time.sleep(.1)
db.rollback();db.close()
PY
locker_pid=$!
for attempt in {1..100}; do test -f "$TMP_ROOT/lock-ready" && break; sleep .1; done
test -f "$TMP_ROOT/lock-ready"
if [[ "$lock_case" == locked ]]; then reject "$TMP_ROOT/$lock_case"; else probe "$TMP_ROOT/$lock_case" | jq -e ".ok" >/dev/null; fi
reject "$TMP_ROOT/$lock_case" write
touch "$TMP_ROOT/unlock"
wait "$locker_pid"
locker_pid=""
probe "$TMP_ROOT/$lock_case" | jq -e '.ok' >/dev/null
done
echo 'PASS SQLite read-only validation, schema versions, URI paths, sidecars, and lock recovery'
