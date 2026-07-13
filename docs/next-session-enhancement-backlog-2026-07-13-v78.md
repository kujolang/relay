# Kujo Relay next-session enhancement backlog — v78

Date: 2026-07-13

## Current position

Relay is a hardened local alpha and Kujo showcase, not an enterprise-ready or
universally useful platform. The v78 review found that Kujo's `create_dir` is
idempotent and therefore unsuitable as an authority lock primitive. Relay now
uses an exclusive fixed-path native `mkdir` operation for capability consumption,
capability repair, and the rebuildable run-index lock. Contract coverage proves
that a second acquisition fails; the full local acceptance gate must remain the
source of truth for regressions.

## Delivered in v78

- [x] Added `create_exclusive_dir` using a fixed native executable and argv,
  without shell interpretation or caller-controlled PATH lookup.
- [x] Updated Agents SDK capability consumption to reject active locks and
  malformed lock objects before verification.
- [x] Updated `doctor --repair` and run-index locking to use exclusive creation.
- [x] Added contract coverage proving exclusive lock creation is one-shot.
- [x] Corrected the v77 locked-record smoke to exercise the real lock behavior.
- [x] Updated README, command reference, ADR-107, integration matrix,
  implementation plan, engineering reports, and this backlog.

## P0 — prove the real execution boundary

- [ ] Run Ollama Cloud and one independent OpenAI-compatible provider through
  the real Watchdog server with redacted usage, latency, failures, fallback
  decisions, and request-correlation evidence.
- [ ] Prove provider-generated Agents SDK tool planning in an isolated
  repository workcell with typed tool results, approvals, cancellation,
  deterministic postconditions, and bounded repair evidence.
- [ ] Extend detached worktrees into a workcell contract with rollback,
  crash recovery, retention, and stronger process/filesystem/network isolation.
- [ ] Add authenticated machine mode over MCP/JSON with identity, tenant, role,
  approval, and audit mappings.
- [ ] Replace the rebuildable JSON cache with a durable concurrent run store
  supporting retention, migration, crash recovery, multi-host concurrency, and
  signed export.
- [ ] Design conservative crash-lock reconciliation with authenticated
  ownership; never force-remove an unknown active lock.

## P1 — ecosystem composition and correctness

- [ ] Load canonical Spec task contracts and Dispatch workflows with explicit
  schema/version negotiation.
- [ ] Attach causal IDs for mission, run, workflow, step, agent, model,
  provider, packet, tool, artifact, evaluation, retry, and repair events.
- [ ] Reuse CaseFile for failed-run bundles and Redact for all persisted
  prompts, tools, packets, reports, and handoffs.
- [ ] Implement typed retry, fallback, repair, escalation, cancellation, and
  regression-evaluation receipts with per-class budgets.
- [ ] Complete Capsule A/B runs with fresh Model B sessions, immutable commits,
  comparable Eval scoring, and JSON/Markdown reports.
- [ ] Add Paperclip and Hermes adapters over the stable machine boundary.

## P2 — performance and operations

- [ ] Add true streaming event sinks and bounded remote watch/export adapters.
- [ ] Add artifact rotation, compaction, retention, size metrics, and
  resumable export with RunLedger/PackWrite ownership boundaries.
- [ ] Add bounded parallel read-only discovery/evaluation while serializing
  writes and Git mutations.
- [ ] Record latency, token/cost, retry, queue, tool-duration, artifact-size,
  and provider-availability metrics.
- [ ] Add model capability discovery and visible policy-aware routing reasons.
- [ ] Add deterministic doctor checks for Watchdog reachability/auth mode,
  provider profiles, storage posture, and release-policy posture.
- [ ] Stress-test exclusive locks, stale cleanup, malformed locks, and
  concurrent writers before claiming multi-process or multi-host readiness.

## P2 — presentation and adoption

- [ ] Add committed fixture transcripts, generated artifact-backed diagrams,
  and a truthful showcase gallery.
- [ ] Add pinned-runtime installation paths for macOS, Linux, and CI.
- [ ] Add Fence, Concord, ShipCheck, and Eval release gates with verified-only
  badges.
- [ ] Keep fixture, configured-live, blocked-live, and externally verified
  evidence classes separate in reports and docs.

## Explicitly deferred

No adaptive router, background cleanup daemon, force-removal of unknown locks,
unrestricted shell/filesystem authority, remote capability service,
authenticated tenancy, package publish, production deployment, or vendor-only
provider path belongs in this slice.

## Definition of done for the next session

- [ ] Focused checks, lock contract/smokes, full acceptance, and Loop
  Engineering pass.
- [ ] At least one external provider runs through the real Watchdog server with
  authenticated correlation evidence.
- [ ] Provider-generated Agents SDK planning is proven in an isolated mission
  with deterministic postconditions.
- [ ] Live, configured-live, fixture, and blocked evidence are separated.
- [ ] Concurrent storage and lock behavior have deterministic stress evidence or
  ownership has moved to a stronger durable store.
- [ ] Small meaningful commits are pushed and the worktree is clean.
