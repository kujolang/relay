# v88 execution status

Objective: complete every checkbox in the
[v88 next-session list](next-session-enhancement-backlog-2026-09-22-v88.md).
The goal remains active. Component completion is not final release approval.
Historical receipts must not be promoted to the eventual final candidate.

| ID | Required outcome | Current evidence / remaining work |
| --- | --- | --- |
| G1 | Final candidate acceptance and reproducibility on Linux, macOS Intel, macOS ARM with immutable dependencies | Pending final candidate. Existing release-preparation workflow calls the three-platform CI matrix without requiring publication. |
| G2 | Explicitly approved bounded external provider/model proof through Watchdog | Configuration and approval requested; no live credentials used. |
| G3 | Final-candidate Workcell success/failure proof, or permitted host blocker plus closest proof | Earlier host blocker retained as historical evidence only; rerun on final candidate. |
| G4 | Quiescent-host five-sample performance measurements; diagnose breaches without loosening budgets | Pending. Historical contended-host comparison is not sufficient. |
| G5 | Operator-owned identity/role/tenant/action/approval mappings; forged claims, replay, expiry and cross-tenant tests | Pending implementation. Disabled-by-default primitive remains trusted-caller only until replaced. |
| G6 | Authoritative backup/restore drill, both cache rebuilds, partial/corrupt/interrupted restoration, measured recovery objectives | Pending implementation and drill. |
| G7 | SQLite reader/init split with missing/future schemas, locks and unsafe sidecars covered | Implemented in `ef02ab0`; pinned-runtime boundary, migration/recovery and state-store safety tests verify the change. |
| G8 | Quoted credentials, whitespace, escaped quotes and chunk-boundary redaction fixtures | Pending. Include actual buffered stream handling, not only concatenated test strings. |
| G9 | Cold/warm latency and memory comparison on both index backends, small/medium/large profiles, preserved tamper detection | Pending profiling and controlled measurements. |
| G10 | Streaming discovery and chunked-evidence design beyond current limits, stable cursors, mutation, cancellation and bounded acceptance | Pending design and acceptance evidence. |
| G11 | Isolated fixture installation-to-export walkthrough, generated screenshots, Kujo learning links, clean-host validation | Pending implementation and evidence. |

## SQLite evidence

Pinned Kujo: `9b77dce592047121cb71066629836ad89252f3ce` (1.0.0).
Source: `ef02ab081764a113c1f31d8a775e000f006d5b89`.
The existing integration tests run with the pinned sibling dependency worktrees.

- `kujo check src/store_sqlite.kujo`: passed.
- `tests/relay_sqlite_boundaries_smoke.sh`: passed. Reads preserve database bytes;
  absent files are not created; missing/extra/future migrations and missing
  columns fail closed; URI path metacharacters are escaped; symlink/directory
  sidecars are rejected; exclusive locks fail within the configured wait;
  WAL readers see committed data while competing writers fail, then recover.
- `tests/relay_sqlite_store_smoke.sh`: passed migration, corrupt-cache failure,
  absent-cache reconstruction, run listing and doctor posture.
- `tests/relay_state_store_safety_smoke.sh`: passed existing state boundaries.
- Markdown links and `git diff --check`: passed.

The final full release gate will include the newly discovered smoke script.
No final-candidate platform, provider, performance or Workcell claim is made here.
