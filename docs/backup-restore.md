# Quiesced run-evidence backup and restore

Relay's run directories are authoritative. `index.json` and `run-index.sqlite3`
are rebuildable caches. A backup is not evidence of recovery until the restored
runs pass `runs verify` with the original store unavailable and each chosen cache
has been rebuilt from the restored bytes.

This procedure covers completed, quiesced local runs. It does not restore a
running process, an external repository/worktree, provider state, or distributed
storage. Preserve source repositories separately if future work needs them.
Do not roll back machine authorization audit state or restore worker capabilities:
retire affected identities/credentials and invalidate sessions first. See
[machine authorization recovery](machine-authorization.md).

## Backup procedure

1. Stop mission writers and all wrappers that can mutate the state root. Confirm
   they have stopped; copying a live directory is not a consistent snapshot.
2. Run `relay runs verify <run-id> --json` for every run being backed up. Retain
   the successful verification receipts and exact Relay/runtime/dependency pins.
3. Copy the complete `runs/` subtree to a fresh backup directory, preserving file
   bytes and relative layout. Include state, receipts, events, reports, packets
   and all referenced run artifacts. Reject symlinks and non-regular files.
4. Build a relative-path manifest containing every file's byte length and SHA-256.
   Compare the source inventory before and after copying with the backup's full
   inventory. Any change, omission or additional file invalidates the snapshot.
   Publish the manifest only after the full copy matches. Store the backup and
   manifest on operator-protected storage; an unsigned hash manifest does not
   authenticate a maliciously replaced backup.
5. Resume writers only after snapshot validation. Record the snapshot time and
   last completed run. Backup cadence determines how much later work can be lost.

Do not copy the live SQLite database or WAL as the recovery source. Preserve old
caches separately for diagnosis if necessary; they must not overwrite restored
authoritative evidence.

## Restore procedure

Keep consumers stopped throughout verification and publication. Restore into a
new staging state root on the same filesystem as its final, **absent** destination.
Never merge a partial backup into an existing store.

1. Copy `runs/` into staging and compare its complete inventory against the
   trusted backup manifest. Reject missing, extra, altered and unsafe entries.
2. With `RELAY_STATE_ROOT` set to staging, verify every restored run. Reject the
   whole restore if any check fails; do not infer completeness from a run list.
3. With caches absent, run `relay runs list --json` using
   `RELAY_STORE_BACKEND=json`, or use `RELAY_STORE_BACKEND=sqlite` for the SQLite
   cache. Compare run membership/status to the snapshot, and verify authoritative
   file bytes remain unchanged. The [migration guide](store-migration.md) describes
   cache format validation and recovery.
4. Atomically rename the staging directory to the absent final destination.
   Verify the runs again there before enabling consumers. A failed or interrupted
   staging copy is never published; discard only that unpublished staging
   directory and retry from the verified snapshot.

The operator must retain the old store until the new one is accepted. Switching
`RELAY_STATE_ROOT` is an explicit operator action. Do not delete evidence to make
an index rebuild succeed.

## Executable drill and recovery objectives

Run the offline drill with pinned Kujo and sibling dependencies:

```bash
KUJO_BIN=/absolute/path/to/pinned/kujo \
  python3 scripts/backup_restore_drill.py --output /tmp/relay-recovery.json
```

It creates its own temporary Git repository, completed fixture mission, backup
and restore directories. It never backs up or replaces an operator's state root.
It makes the original run location unavailable, restores to new roots, rebuilds
both caches and verifies after publication. Partial/corrupt copies must fail both
inventory validation and Relay verification. An interrupted staging restore must
remain unpublished and succeed only after a clean retry. The smoke suite runs
the same drill so these behaviors remain regression-tested.

The recovery point objective for a **quiesced snapshot** is zero missing completed
runs and zero altered snapshot bytes. This is checked, not inferred from a cache.
The recovery time measurement starts before staging copy and ends after cache
rebuild, publication and final verification, separately for each backend. The
[measured receipt](review-evidence/2026-09-22/backup-restore-verification.json)
records the actual durations and dataset size. Those observations establish a
fixture baseline, not an enterprise SLA. Production RTO targets require this
procedure to be measured with representative volume and the operator's storage;
production RPO also includes time since the last validated backup. Neither
multi-host durability nor a universal recovery-time promise follows from this drill.
