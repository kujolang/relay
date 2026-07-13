# Kujo Relay Next-Session Enhancement Backlog — 2026-07-13 v66

This backlog records the next review after the bounded multi-turn provider-tool
enhancement. Relay remains a hardened local alpha/showcase, not an enterprise
production platform or universally useful runtime. The v66 local proof uses an
authenticated Watchdog and deterministic OpenAI-compatible stub; it does not
substitute for live provider or distributed authority evidence.

## Delivered in v66

- Added a bounded provider-tool continuation loop using the existing AI SDK
  message contract and Watchdog route.
- Preserved assistant tool calls and returned typed `role: tool` messages for
  follow-up model requests.
- Added `max_tool_turns`, aggregate token accounting, cancellation checks, and
  fail-closed call/turn/result persistence boundaries.
- Added the `relay-tool-result-bundle-v1` artifact and
  `tool-result-bundle.schema.json` contract.
- Proved a two-turn authenticated local Watchdog/stub-provider mission through
  Agents SDK execution, repository mutation, ChangeBucket, Eval, RunLedger,
  receipt/event evidence, and typed result persistence.
- Updated source contracts, command reference, README, ADRs, integration matrix,
  implementation plan, readiness review, final report, schema inventory, and
  regression coverage.

## P0 — live provider and authority proof

1. Run the provider-tool loop against real Ollama Cloud and one independent
   OpenAI-compatible provider through real Watchdog. Record capability
   negotiation, redacted usage/latency, provider dialect behavior, fallback,
   cancellation, and correlation evidence separately from fixture/stub/live-
   configured results.
2. Add provider dialect negotiation and normalization for tool-call IDs,
   argument encoding, tool-result content, finish reasons, and streaming tool
   deltas. Keep unsupported dialects explicit capability failures.
3. Extend detached worktrees into a workcell contract with create/bind/inspect,
   rollback-on-failure, cleanup, retention, crash recovery, and stronger
   process/filesystem/network isolation. Prove workspace identity through
   interruption and resume.
4. Add authenticated Paperclip, Hermes, CI, and MCP adapters with caller
   identity, tenant scope, replay protection, approval mapping, and audit
   receipts. Keep organizational ownership in Paperclip when present.
5. Replace the rebuildable JSON index/cache with a durable transactional owner
   supporting crash recovery, retention, multi-host concurrency, deterministic
   migrations, and integrity-checked/signed export.
6. Complete one externally configured repository mission combining live
   provider tool loops, Watchdog verification, isolated recoverable workcell,
   resume, ChangeBucket, Eval, RunLedger, and machine-readable reporting.

## P1 — evidence and ecosystem composition

- Negotiate mission/workflow contracts with Spec and Dispatch rather than
  expanding Relay's private workflow vocabulary.
- Add stable causal, parent, receipt, artifact, retry, repair, approval, and
  escalation IDs to every event and persisted result.
- Integrate CaseFile and Redact across prompts, packets, tool results,
  reports, handoffs, exports, and failure bundles with adversarial fixtures.
- Add typed retry/fallback/repair/cancellation receipts and regression Eval for
  each recovery branch.
- Complete Capsule A/B with independent fresh sessions, immutable commits,
  context-efficiency scoring, repeated runs, and comparable reports.
- Add Paperclip/Hermes adapter contract tests plus pinned provenance for every
  reused Kujo dependency.
- Add capability discovery and visible policy-aware routing explanations for
  provider, model, agent, tool, privacy, modality, budget, and tenant limits.

## P2 — performance, operations, and presentation

- Add streaming event sinks with bounded queues, backpressure, reconnection,
  and terminal-seal verification for long missions.
- Add artifact retention, compaction, resumable export, storage metrics, and
  bounded memory/file descriptors for large evidence histories.
- Add bounded parallel read-only discovery/Eval after write serialization and
  cancellation semantics are durable.
- Add aggregate Watchdog/RunLedger metrics and provider/model comparisons
  without exposing prompts, secrets, or repository content.
- Expand doctor with capability negotiation, workcell health, durable-store
  recovery, adapter authentication, provider profile, and release provenance
  checks.
- Run crash, replay, cancellation, lock, and concurrent-reader/writer stress
  suites.
- Add ShipCheck/Concord release gates, pinned install paths, generated-artifact
  verification, and a truthful showcase gallery.

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
- Changes are committed in small meaningful commits, pushed, and clean.
- Strata memory is consolidated, deduplicated, and retrieval-tested.
