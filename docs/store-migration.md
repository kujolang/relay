# Transactional local run-index migration

Per-run `state.json` remains Relay's authoritative evidence. Relay 1.x can
migrate its rebuildable index cache to a versioned SQLite transaction store
without changing run evidence or the JSON machine contracts.

From a clean, backed-up state root, create and verify the SQLite cache:

```bash
./bin/relay runs migrate-store --backend sqlite --confirm --json
export RELAY_STORE_BACKEND=sqlite
./bin/relay doctor --json
./bin/relay runs list --json
```

The migration rebuilds from integrity-checked run state, writes all index rows
inside `BEGIN IMMEDIATE`/`COMMIT`, uses full SQLite synchronization and WAL,
records `relay-run-index-sqlite-v1`, reads the rows back, and compares them to
the authoritative run directories. A missing cache is initialized and a stale valid cache is rebuilt from run
evidence. Existing malformed databases, missing migration records, extra/future
schema versions, or missing columns fail closed; reads never initialize them.
After backing up evidence, an operator can remove only the invalid cache and
rebuild it. Do not replace authoritative run directories to repair an index.

Reads use a SQLite `mode=ro` connection and query-only validation, with a bounded
one-second lock wait. They do not create schema, insert migration records, or
change journal mode. SQLite may still use WAL coordination sidecars for an
existing WAL database. Main files and `-wal`, `-shm`, and `-journal` companions
must be regular non-symlink files when present. URI metacharacters in state
paths are escaped, so filenames cannot inject SQLite connection options.

The legacy `index.json` cache remains as a rollback-compatible sidecar. Set
`RELAY_STORE_BACKEND=json` to return to it; no evidence conversion is needed.
Do not copy a live WAL database between hosts. This migration provides local
transactions and crash recovery from authoritative evidence, not replicated
storage, remote locking, backup policy, or multi-host concurrency.

Use the [backup/restore drill](backup-restore.md) to verify authoritative recovery
and reconstruction of both cache backends before adopting a recovery procedure.
