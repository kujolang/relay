# Kujo Relay next-session enhancement backlog — review 9

This is the handoff from the ninth enterprise-readiness review. Relay remains
a local-first hardened alpha/showcase, not a universally useful,
enterprise-production platform. This review closes a read-boundary evidence
gap: missing persisted receipt or run-state files can no longer be replaced by
embedded/indexed fallback data during inspection, watch, or export.

## Completed in this review

- [x] Require a bounded, regular, non-symlinked `receipts.json` at `runs
  events`, `runs watch`, and `runs export` read boundaries.
- [x] Reject missing or malformed persisted receipts instead of falling back
  to `state.json`.
- [x] Require a bounded, regular, identity-matching `state.json` for mission
  and run inspection and event export.
- [x] Add store-smoke coverage for missing receipt and missing state evidence.
- [x] Normalize relative `KUJO_BIN` and sibling adapter paths before cwd
  changes; prove the full fixture mission under the Loop Engineering path form.
- [x] Preserve v48 complete state/event canonical comparison and prior path
  safety hardening.
- [x] Update README, command reference, ADRs, enterprise review, final report,
  integration matrix, implementation plan, and this backlog.

## P0 — production authority and external integrations

- [ ] Add credential-gated Ollama Cloud and one independent OpenAI-compatible
  provider smoke profile through the real Watchdog server. Record redacted
  usage, latency, provider failures, fallback decisions, and correlation proof.
- [ ] Extend the Agents SDK bridge from fixture-specified calls to
  provider-generated tool planning with typed tool-result artifacts, bounded
  cancellation, guardrail receipts, and explicit retry/fallback semantics.
- [ ] Extend detached worktrees into a workcell contract with rollback-on-
  failure, crash recovery, retention, and stronger process/filesystem/network
  isolation.
- [ ] Add authenticated machine mode through the guarded MCP boundary with
  identity, tenant, role, approval, and audit mappings.
- [ ] Replace the rebuildable JSON cache with a database-backed or append-only
  durable run store supporting retention, crash recovery, multi-host
  concurrency, signed export, and deterministic migration.
- [ ] Prove a Watchdog-backed isolated repository mission against an external
  provider; the current real-server smoke uses a local stub upstream.

## P1 — ecosystem composition and correctness

- [ ] Load Spec task contracts and Dispatch workflows with schema/version
  negotiation; do not create a competing workflow format.
- [ ] Attach mission, run, workflow, step, agent, model, provider, packet
  revision, tool, artifact, evaluation, retry, and repair IDs to every event
  and RunLedger receipt.
- [ ] Integrate CaseFile for failed-run bundles and Redact for prompts, tools,
  packets, reports, and handoffs.
- [ ] Implement typed retry, fallback, repair, escalation, cancellation, and
  regression-evaluation receipts.
- [ ] Finish Capsule A/B execution with fresh Model B sessions, repeated runs,
  comparable Eval scoring, and JSON/Markdown reports.
- [ ] Add Paperclip and Hermes adapters over the stable JSON runtime boundary
  without moving organizational ownership into Relay.

## P2 — performance and operations

- [ ] Add true streaming event sinks for long-running missions; current chat
  JSONL is normalized after the AI SDK bridge returns.
- [ ] Add artifact rotation/compaction, retention policy, size metrics, and
  resumable export for `.relay` evidence.
- [ ] Add bounded parallel read-only discovery/evaluation while serializing
  writes and Git mutations.
- [ ] Record latency, token/cost, retry, queue, tool-duration, artifact-size,
  and provider-availability metrics through Watchdog/RunLedger contracts.
- [ ] Add model capability discovery and visible policy-aware routing
  explanations.
- [ ] Add deterministic doctor checks for upstream versions, Watchdog
  reachability, auth mode, provider profiles, and release-policy posture.
- [ ] Add a lock-contention and concurrent-writer stress harness before
  claiming the local cache is sufficient for multi-process workloads.

## P2 — presentation and adoption

- [ ] Add committed fixture transcripts, JSON Schemas for mission/run/event/
  report, doctor, probe, and tool-result contracts, plus a generated
  architecture diagram backed by real artifacts.
- [ ] Add pinned-runtime installation paths for macOS/Linux/CI and a
  reproducible dependency doctor command.
- [ ] Add Fence, Concord, ShipCheck, and Eval release gates with badges only
  for verified local gates.
- [ ] Add a truthful showcase gallery covering chat, probe, bounded task,
  pause/resume, budget denial, worktree cleanup, store recovery, event
  integrity, receipt/state disappearance rejection, verified export, Agents
  SDK tool approval, and Watchdog correlation.

## Definition of done for the next session

- [ ] All changed behavior has focused Kujo tests and the full local acceptance
  set remains green.
- [ ] At least one external provider is exercised through the real Watchdog
  server with authenticated correlation evidence.
- [ ] Provider-generated Agents SDK tool planning is proven in an isolated
  mission, with bounded approval and deterministic postconditions.
- [ ] Live, configured-live, fixture, and blocked evidence are separated in
  reports and docs.
- [ ] Concurrent index behavior has deterministic stress evidence or the store
  has moved to a stronger durable owner.
- [ ] Changes are committed in small meaningful commits, pushed, and left
  clean.
