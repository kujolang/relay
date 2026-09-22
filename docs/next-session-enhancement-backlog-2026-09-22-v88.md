# Relay review and next-session backlog — v88

Reviewed 2026-09-22. Relay remains a bounded local/operator-controlled mission
runner, not a universally enterprise-ready service. This review covers the
CLI, redaction and process helpers, mission policy/lifecycle, signed exports,
run-index validation, SQLite integration, test/release tooling, and public
documentation. It is a targeted engineering review, not an exhaustive security
certification or proof of every deployment environment.

## Changes from this review

- Complete and truncated PEM private-key bodies are removed from redacted
  output, including JSON-escaped blocks; public-key text is preserved.
- Invalid configured signing keyrings cannot silently select the legacy secret.
  Signed-export verification validates wrapper metadata and works without the
  originating local state store. Existing HMAC payload inputs are unchanged.
- Bounded JSON reads reuse one file-size probe, and signed exports reuse their
  canonical payload serialization for the size check and digest.
- Benchmark p95 now uses nearest rank rather than rounding down. Five-sample
  CI evidence replaces single-sample representative runs. This improves
  measurement integrity; it does not establish a throughput improvement.
- The lifecycle projection assertion now handles Kujo's integer `contains`
  result instead of aborting the contract suite on unary negation.
- README and security guidance distinguish optional local SQLite transactions,
  retention, and HMAC authentication from hosted tenancy and key custody.

## Repository layout decision

All tracked runtime modules already live in `src/`. Keep root `main.kujo`:
launchers, package manifests, release archives, and tests require that small
entrypoint. Keep package manifests, version pins, license, changelog, and
contributor/security guidance at the root. No obsolete tracked root runtime
copies were found. Ignored historical test/state directories are operator-local
artifacts and were not deleted as part of source cleanup.

## P0 — Release evidence before production claims

- [ ] Run the final candidate on Linux and both supported macOS architectures,
  retain full acceptance and artifact reproducibility evidence, and confirm
  all immutable ecosystem revisions match `release/dependencies.json`.
- [ ] Obtain explicit owner approval for credentials/provider/model and run
  `scripts/live_provider_verification.sh` through Watchdog. Fixture and local
  stub results cannot establish external provider compatibility.
- [ ] Rerun Workcell success/failure proof on the final candidate. If Docker or
  the host is unavailable, retain a blocker receipt and closest local proof;
  never carry an old commit's receipt forward as current evidence.

Acceptance: candidate-specific receipts and CI results, no unresolved required
release gate, and explicit deployment scope. These continue the v87 P0 gates.

## P1 — Strengthen boundaries before extending the product

- [ ] Recheck performance budgets on a quiescent host with the same pinned
  runtime and five samples. The [small-profile comparison](review-evidence/2026-09-22/performance-comparison.json)
  shows both pre-session `01c44da` and candidate `5867ddd` exceeding export,
  verify, and watch limits. Candidate p95 values were 6790/7044/5282 ms against
  allowance-inclusive limits of 3000/6000/3000 ms; baseline values were
  7659/6849/6843 ms. These were contended-host measurements, not proof of a
  regression or speedup. Complete medium/large profiles on a quiet host,
  isolate bottlenecks, and preserve the existing budgets until evidence
  justifies a reviewed change.

- [x] Define operator-owned machine identity/role/tenant mappings before adding
  socket or MCP transport. `src/enterprise.kujo::authorize_machine_request`
  currently trusts caller-supplied claims after shared-secret authentication;
  it accepts action prefixes and approved operator actions rather than a fixed
  action dictionary. The CLI primitive is not a service authorization layer.
  Add exact action mappings, deny unknown actions, derive approval server-side,
  and test forged role/tenant/approval, replay, expiry, and cross-tenant access.
  Resolved by [operator policy v2](machine-authorization.md) in `5c5a909`;
  the preceding text records the reviewed v1 behavior, not current authority.
- [x] Add a documented backup/restore drill for authoritative run directories;
  rebuild both index backends from restored evidence and test partial copies,
  corruption, and interrupted restore. Define recovery objectives from measured
  results instead of implying multi-host durability. Implemented in `76b5e64`;
  see the [drill and measured receipt](backup-restore.md).
- [x] Review SQLite open behavior: `sqlite_read_index` calls `sqlite_open`, which
  performs schema creation, migration insertion, and WAL configuration even on
  read paths. Separate initialization from read-only validation and add fixtures
  for missing/unknown schema versions, locked databases, and unsafe sidecars.
  Implemented and verified in `ef02ab0`; see the
  [execution status](v88-execution-status.md) for pinned-runtime evidence.
- [x] Expand redaction fixtures for quoted credentials containing whitespace,
  escaped quotes, and chunk boundaries. Preserve useful diagnostics without
  treating pattern matching as a general secret-classification guarantee.
  Implemented with real buffered-stream fixtures; see the
  [component verification](review-evidence/2026-09-22/redaction-verification.json).

## P2 — Measure scale and improve adoption

- [ ] Collect fresh five-sample small/medium/large results after the percentile
  correction. `run_directories_match_index` reparses all authoritative states
  on a cache hit; aggregate metrics reads them again. Profile this cost before
  designing an invalidation strategy. Preserve tamper detection and bounded
  reads; compare cold/warm latency and memory on both backends.
- [x] Design streaming tracked-file discovery beyond the current 16 MiB envelope
  and versioned chunked evidence beyond the 1 MiB JSON ceiling. Acceptance must
  cover stable cursors, concurrent repository changes, cancellation, and bounds.
  The [design](streaming-evidence-design.md) records the pinned-runtime
  prerequisite, bounded contracts, state transitions and acceptance matrix.
  Implementation remains a separate follow-up; current limits are unchanged.
- [x] Add an isolated fixture walkthrough from installation to verified export,
  with generated screenshots and clear links to Kujo learning material. Confirm
  it works with pinned sibling dependencies on a clean host. The
  [walkthrough](first-verified-run.md) passes an isolated fresh-home archive
  installation with exact pins; full clean-host platform proof remains in P0.

Asymmetric custody and full Spec/Dispatch execution remain deferred v87 items;
implementing them requires explicit contracts and compatibility fixtures.

## Verification record

The [local verification receipt](review-evidence/2026-09-22/verification.json)
records a passed release gate at source commit `5867ddd` on macOS x86_64,
using Kujo `9b77dce` (1.0.0) and isolated pinned sibling dependencies. All 34
smoke scripts, contracts, 25 schemas, source checks, links, metadata, Kennel,
ShipCheck 16/16, two-build reproducibility, and clean archive installation passed.
The required doctor, agent validation, and fixture-chat commands passed too.
The separate representative performance experiment did **not** pass: small
budgets failed on both revisions; broader sampling was stopped after that
comparison. The functional release gate checks performance contracts and a
historical budget fixture, so its success must not be read as fresh performance
certification.

Workcell stopped during preparation with exit 4: the Docker daemon did not
report AppArmor required by the pinned rootful-Docker policy. Cleanup completed;
container execution and verification did not occur. The sanitized
[blocker receipt](review-evidence/2026-09-22/workcell-blocker.json) records the
exact candidate, run ID, error, and source receipt digest. Fixture/worktree tests
are the closest local proof and do not replace container execution.

External live-provider proof was not run without owner-approved credentials.
Linux/macOS-arm64 CI was not run in this session. Final documentation/evidence
commits do not change the tested runtime implementation; release-owner gates
still require results for the eventual exact release candidate.
