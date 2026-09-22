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
| G4 | Quiescent-host five-sample performance measurements; diagnose breaches without loosening budgets | Completed at `ddf690f`: six dedicated Linux profiles, five samples per command/cache mode, all unchanged budgets passed. See [controlled measurements](controlled-store-performance.md). |
| G5 | Operator-owned identity/role/tenant/action/approval mappings; forged claims, replay, expiry and cross-tenant tests | Implemented in `5c5a909`; operator-owned v2 policy, per-identity credentials, registered resources, exact actions, bound approval and persistent replay tests pass. Full pinned gate: 37 smokes and 28 schemas. |
| G6 | Authoritative backup/restore drill, both cache rebuilds, partial/corrupt/interrupted restoration, measured recovery objectives | Implemented in `76b5e64`; isolated drill restores with original location unavailable, rebuilds both caches and rejects partial/corrupt/interrupted publication. Measured fixture receipt retained. |
| G7 | SQLite reader/init split with missing/future schemas, locks and unsafe sidecars covered | Implemented in `ef02ab0`; pinned-runtime boundary, migration/recovery and state-store safety tests verify the change. |
| G8 | Quoted credentials, whitespace, escaped quotes and chunk-boundary redaction fixtures | Implemented in `f324e90` with `2926cdb`/`838a05e` follow-ups; real buffered chat/stream fixtures, contracts and pinned-dependency integration gate passed. See redaction evidence below. |
| G9 | Cold/warm latency and memory comparison on both index backends, small/medium/large profiles, preserved tamper detection | Completed at `ddf690f`: JSON/SQLite, all three sizes, cold/warm latency and child peak RSS, phase timings and tamper/restore checks. [Report and raw receipts](controlled-store-performance.md). |
| G10 | Streaming discovery and chunked-evidence design beyond current limits, stable cursors, mutation, cancellation and bounded acceptance | Design delivered in [streaming/evidence design](streaming-evidence-design.md): pinned-runtime prerequisite, bounded snapshot/cursor and chunk contracts, mutation/cancellation state machine and acceptance matrix. The requested deliverable is a design; implementation is explicitly future work. |
| G11 | Isolated fixture installation-to-export walkthrough, generated screenshots, Kujo learning links, clean-host validation | Implemented in `757cd96`; archive installation into fresh HOME, full fixture mission and portable signed-export verification pass with exact pinned siblings. Screenshots visually reviewed; fresh-host platform CI remains part of G1. |

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

## Redaction evidence

[Component receipt](review-evidence/2026-09-22/redaction-verification.json).
The full release gate passed at `f324e90` with pinned Kujo and siblings:
36 smoke scripts, contracts, 25 schemas, source/link/metadata checks, Kennel,
ShipCheck 16/16, deterministic two-build archives and clean archive installation.
Follow-up commits `2926cdb` and `838a05e` retain multiline mixed-log context and
credential-name suffix compatibility; the expanded redaction smoke and contract
suite passed again. These are component receipts, not final candidate receipts.

Fixtures cover quoted whitespace, escaped quotes, multiline/truncated values,
JSON strings and malformed JSON continuation tails, nesting bounds, idempotence,
public/private PEM handling, preserved benign structure and diagnostics, and
actual buffered chat/stream subprocess output with split content/tool arguments.

## Machine authorization and recovery evidence

The [G5 remediation report](review-evidence/2026-09-22/machine-authorization-review.md)
records the original reproduced authority bypass, new operator-owned v2 boundary,
independent review and exact pinned release-gate evidence at `5c5a909`.
The full gate passed 37 smoke scripts, 28 schemas, contracts, source/link/metadata,
Kennel, ShipCheck 16/16 and reproducible archives/clean installation.

The [G6 recovery receipt](review-evidence/2026-09-22/backup-restore-verification.json)
records 34 authoritative files / 93,039 bytes from one completed fixture run,
zero lost completed runs and observed restore times of 4,152 ms (JSON) and
3,705 ms (SQLite). The original source location was unavailable throughout
recovery. Partial/corrupt copies were rejected by both inventory and Relay
verification; interrupted staging was not published and clean retry passed.
The script hash binds the receipt to the drill committed in `76b5e64`.
These measurements are not production SLOs; see [recovery guidance](backup-restore.md).
The added `tests/relay_backup_restore_smoke.sh` passed separately at `76b5e64`
in the same pinned environment. The final candidate gate must include it.

## Walkthrough evidence

[First verified run](first-verified-run.md) contains the pinned install procedure,
copyable offline runner, generated transcript screenshots and official Kujo
learning links. [Receipt](walkthrough/receipt.json) binds the full command
[transcript](walkthrough/transcript.json) to source `757cd96`, the generator hash,
the Kujo binary hash and immutable required dependency revisions.

`tests/relay_walkthrough_smoke.sh` passed in the isolated pinned tree. The runner
extracts a committed archive into an empty HOME, uses an explicit environment
allowlist, validates agents, runs the complete fixture mission, verifies evidence,
exports under an ephemeral random fixture signing key and verifies with an absent
origin store. The fixture key is never stored. Both PNG transcript views were
rendered with an isolated Chromium profile and visually checked. Platform clean-host
runs remain in the final G1 matrix; local clean installation is not evidence for
unrun platforms.
