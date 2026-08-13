# Relay local evidence retention policy

Relay retains run evidence by default. Operators can inspect the deterministic
local policy without deleting anything:

```bash
./bin/relay runs retention --keep-last 100 --json
```

The v1 policy considers only completed runs, orders them by the sortable run
identifier, retains the newest requested count, and proposes at most 256 older
runs per invocation. Failed, cancelled, paused, active, malformed, and
integrity-invalid runs are never candidates. Worktree runs must be cleaned with
`missions cleanup --confirm` before their evidence can be pruned.

Deletion requires the same command with `--confirm`. Relay revalidates run
identity, terminal status, state integrity, event-chain integrity, receipt
integrity, exact run ownership, and worktree cleanup immediately before using a
fixed `/bin/rm` argv. It then rebuilds the non-authoritative index. Pruning is
irreversible; export or back up evidence before confirmation when retention is
required.

This is a bounded single-host lifecycle policy, not regulatory retention,
legal hold, remote custody, disaster recovery, or multi-host garbage
collection.
