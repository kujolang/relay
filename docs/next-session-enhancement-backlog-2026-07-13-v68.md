# Kujo Relay Next-Session Enhancement Backlog — 2026-07-13 v68

This backlog records the next enterprise-readiness boundary after the v68
local evidence-integrity improvement. Relay remains a hardened local
alpha/showcase, not an enterprise-production platform or universally useful
runtime. Local tests prove bounded behavior, but they do not substitute for
live provider, authenticated ownership, workcell, durable-storage, or
release-gate evidence.

## Delivered in v68

- Made provider-generated Agents SDK tool execution a required read-side
  artifact when authoritative state says provider tools ran.
- Added contract and run-identity validation for `tool-results.json`.
- Recomputed its SHA-256 and compared it with the authoritative state record
  before `runs verify` or valid `runs export` can succeed.
- Included verified provider tool results in machine-readable exports and
  exposed their presence/errors in explicit partial exports.
- Added a provider-tool smoke proving both valid verification and tampered
  bundle rejection.
- Updated the README, command reference, ADRs, integration matrix,
  implementation plan, final engineering report, and this backlog.

## P0 — external authority and production proof

1. Exercise the bounded provider-tool loop against real Ollama Cloud and one
   independent OpenAI-compatible provider through the real Watchdog server.
   Preserve redacted request correlation, capability/dialect observations,
   usage, latency, fallback, cancellation, and provider failure evidence.
2. Implement provider dialect negotiation for tool-call IDs, argument encoding,
   result content, finish reasons, and streaming tool deltas. Unsupported
   dialects must be explicit capability failures, not silent normalization.
3. Extend detached worktrees into a recoverable workcell contract with
   create/bind/inspect, rollback-on-failure, cleanup, retention, crash
   recovery, and stronger process/filesystem/network isolation.
4. Add authenticated Paperclip, Hermes, CI, and MCP adapters with caller
   identity, tenant scope, replay protection, approval mapping, and audit
   receipts. Preserve Paperclip organizational ownership when present.
5. Replace the rebuildable JSON index/cache with a durable transactional owner
   supporting crash recovery, retention, multi-host concurrency, deterministic
   migrations, and integrity-checked/signed export.
6. Complete one externally configured repository mission combining live provider
   tool loops, Watchdog verification, an isolated recoverable workcell, resume,
   ChangeBucket, Eval, RunLedger, and machine-readable reporting.

## P1 — ecosystem composition and correctness

- Negotiate mission/workflow contracts with Spec and Dispatch instead of
  expanding Relay's private workflow vocabulary.
- Attach stable causal, parent, receipt, artifact, retry, repair, approval,
  and escalation IDs to every event and persisted result.
- Integrate CaseFile and Redact across prompts, packets, tool results, reports,
  handoffs, exports, and failure bundles with adversarial fixtures.
- Add typed retry/fallback/repair/cancellation receipts and regression Eval for
  every recovery branch.
- Complete Capsule A/B with independent fresh sessions, immutable commits,
  context-efficiency scoring, repeated runs, and comparable JSON/Markdown
  reports.
- Add Paperclip/Hermes adapter contract tests plus pinned provenance for every
  reused Kujo dependency.
- Add capability discovery and visible policy-aware routing explanations for
  provider, model, agent, tool, privacy, modality, budget, and tenant limits.
- Verify PackWrite packet manifests and revision digests recursively without
  following links, then bind packet provenance to the mission/run identity.
- Extend read-side artifact verification to signed manifests and all future
  CaseFile, packet, handoff, and export bundles without duplicating owners.

## P2 — performance, operations, and presentation

- Add streaming event sinks with bounded queues, backpressure, reconnection,
  and terminal-seal verification for long missions.
- Add artifact retention, compaction, resumable export, storage metrics, and
  bounded memory/file-descriptor behavior for large evidence histories.
- Add bounded parallel read-only discovery/Eval after write serialization and
  cancellation semantics are durable.
- Add aggregate Watchdog/RunLedger metrics and provider/model comparisons
  without exposing prompts, secrets, or repository content.
- Expand doctor with provider capability negotiation, workcell health,
  durable-store recovery, adapter authentication, provider profile, and release
  provenance checks.
- Run crash, replay, cancellation, lock, concurrent-reader/writer, and
  provider-response-size stress suites.
- Add ShipCheck/Concord release gates, pinned install paths, generated-artifact
  verification, platform matrix evidence, and a truthful showcase gallery.
- Add a compatibility matrix for Kujo, AI SDK, Agents SDK, Watchdog, PackWrite,
  RunLedger, ChangeBucket, Eval, Spec, Dispatch, and Capsule versions.

## Definition of done for the next session

- All Kujo checks, focused tests, `relay_acceptance`, and Loop Engineering pass.
- At least one real external provider completes the bounded tool loop through
  authenticated Watchdog with redacted correlation evidence.
- A live provider mission completes in an isolated recoverable workcell with
  typed tool-result, ChangeBucket, Eval, RunLedger, and report evidence.
- Interrupted, cancelled, fallback, and repaired runs preserve causal receipts
  and do not bypass policy, approval, Watchdog, or budgets.
- Live, configured-live, local-stub, fixture, and blocked evidence remain
  visibly distinct in JSON and Markdown reports.
- PackWrite packet provenance and recursive artifact integrity are verified.
- Concurrent index behavior has deterministic stress evidence or the store has
  moved to a stronger durable owner.
- Changes are committed in small meaningful commits, pushed, and clean.
- Strata memory is consolidated, deduplicated, and retrieval-tested.
