# Kujo Relay next-session enhancement backlog — v77

Date: 2026-07-13

## Current position

Relay is a hardened local alpha and Kujo showcase, not an enterprise-ready or
universally useful platform. The v77 review closes a local capability-lifecycle
race: explicit doctor repair now uses the same per-record lock as Agents SDK
tool consumption, re-reads records while holding that lock, and skips active
records instead of deleting them. Invalid lock objects fail closed.

## Delivered in v77

- [x] Serialize `doctor --repair` with the existing capability consumption lock.
- [x] Re-read capability records under lock before stale deletion.
- [x] Report active records as `locked` and retain them.
- [x] Reject symbolic-linked and non-directory lock objects as invalid posture.
- [x] Add CLI smoke coverage for locked-record retention and post-unlock repair.
- [x] Update README, command reference, ADR-107, integration matrix,
  implementation plan, engineering reports, and this backlog.

## P0 — prove the real execution boundary

- [ ] Run Ollama Cloud and one independent OpenAI-compatible provider through
  the real Watchdog server; preserve redacted usage, latency, failures,
  fallback decisions, and request-correlation proof.
- [ ] Execute a provider-generated Agents SDK tool-planning mission in an
  isolated repository workcell with typed tool-result artifacts, approval,
  cancellation, postconditions, and bounded repair evidence.
- [ ] Extend detached worktrees into a workcell contract with rollback-on-
  failure, crash recovery, retention, and stronger process/filesystem/network
  isolation.
- [ ] Add authenticated machine mode over the guarded MCP/JSON boundary with
  identity, tenant, role, approval, and audit mappings.
- [ ] Replace the rebuildable JSON cache with a durable concurrent run store
  supporting retention, migration, crash recovery, multi-host concurrency, and
  signed export.
- [ ] Add conservative crash-lock reconciliation with authenticated ownership;
  never force-remove an unknown active capability lock.

## P1 — ecosystem composition and correctness

- [ ] Load canonical Spec task contracts and Dispatch workflows with explicit
  schema/version negotiation; keep Relay as execution/evidence composition.
- [ ] Attach causal mission/run/workflow/step/agent/model/provider/packet/tool/
  artifact/evaluation/retry/repair IDs to every event and receipt.
- [ ] Reuse CaseFile for failed-run bundles and Redact for prompts, tools,
  packets, reports, and handoffs.
- [ ] Implement typed retry, fallback, repair, escalation, cancellation, and
  regression-evaluation receipts with per-class budgets.
- [ ] Complete Capsule A/B execution with fresh Model B sessions, repeated
  immutable-commit runs, comparable Eval scoring, and JSON/Markdown reports.
- [ ] Add Paperclip and Hermes adapters over the stable machine boundary without
  moving organizational ownership into Relay.

## P2 — performance and operations

- [ ] Add true streaming event sinks for long-running missions and bounded
  remote watch/export adapters.
- [ ] Add artifact rotation, compaction, retention policy, size metrics, and
  resumable export with RunLedger/PackWrite ownership clearly separated.
- [ ] Add bounded parallel read-only discovery/evaluation while serializing
  writes and Git mutations.
- [ ] Record latency, token/cost, retry, queue, tool-duration, artifact-size,
  and provider-availability metrics through Watchdog/RunLedger contracts.
- [ ] Add model capability discovery and visible policy-aware routing reasons.
- [ ] Add deterministic doctor checks for upstream versions, Watchdog
  reachability/auth mode, provider profiles, storage posture, and release
  policy posture.
- [ ] Stress-test capability locks, stale cleanup, malformed lock objects, and
  concurrent writers before claiming multi-process or multi-host readiness.

## P2 — presentation and adoption

- [ ] Add committed fixture transcripts, generated architecture diagrams backed
  by real artifacts, and a truthful showcase gallery.
- [ ] Add pinned-runtime installation paths for macOS, Linux, and CI plus a
  reproducible dependency doctor command.
- [ ] Add Fence, Concord, ShipCheck, and Eval release gates with badges only
  for verified local gates.
- [ ] Keep the README explicit about fixture, configured-live, blocked-live,
  and externally verified evidence classes.

## Explicitly deferred

No adaptive router, background cleanup daemon, force-removal of unknown locks,
unrestricted shell/filesystem authority, remote capability service,
authenticated tenancy, package publish, production deployment, or vendor-only
provider path belongs in this slice.

## Definition of done for the next session

- [ ] Focused Kujo checks, capability-lock smokes, full acceptance, and Loop
  Engineering pass.
- [ ] At least one external provider is exercised through the real Watchdog
  server with authenticated correlation evidence.
- [ ] Provider-generated Agents SDK tool planning is proven in an isolated
  mission with deterministic postconditions.
- [ ] Live, configured-live, fixture, and blocked evidence are separate in
  reports and docs.
- [ ] Concurrent storage and lock behavior have deterministic stress evidence
  or ownership has moved to a stronger durable store.
- [ ] Changes are committed in small meaningful commits, pushed, and clean.
