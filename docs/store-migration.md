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
the authoritative run directories. If the database is missing, malformed, or
stale while SQLite mode is selected, Relay rebuilds it from run evidence.

The legacy `index.json` cache remains as a rollback-compatible sidecar. Set
`RELAY_STORE_BACKEND=json` to return to it; no evidence conversion is needed.
Do not copy a live WAL database between hosts. This migration provides local
transactions and crash recovery from authoritative evidence, not replicated
storage, remote locking, backup policy, or multi-host concurrency.
