# Kujo Relay Next-Session Enhancement Backlog — 2026-07-13 v70

This backlog records the next enterprise-readiness boundary after the v70
packet-integrity and delegated-authority review. Relay remains a hardened
local alpha/showcase, not an enterprise-production platform or universally
useful runtime. Local evidence proves bounded behavior, but it does not replace
live providers, authenticated ownership, recoverable workcells, durable
storage, or release gates.

## Delivered in v70

- Added bounded recursive `relay-packwrite-manifest-v1` generation for every
  regular PackWrite packet file under `agent/`.
- Persisted `packet-manifest.json` outside the packet tree and bound its digest
  to authoritative run state.
- Made `runs verify` and valid `runs export` fail closed on changed, missing,
  extra, symbolic-linked, or digest-mismatched packet files.
- Added `packet-manifest.schema.json`; schema smoke now covers 15 contracts.
- Preserved exact `allowed_script_hashes` through Agents SDK delegated worker
  calls, with a focused pinned-script execution smoke.
- Added packet-tamper verification to the store smoke and updated README,
  ADRs, integration matrix, implementation plan, reports, and this backlog.

## P0 — external authority and production proof

1. Exercise the bounded provider-tool loop against real Ollama Cloud and one
   independent OpenAI-compatible provider through the real Watchdog server.
   Preserve redacted request correlation, capability/dialect observations,
   usage, latency, fallback, cancellation, and provider failure evidence.
2. Implement provider dialect negotiation for tool-call IDs, argument
   encoding, result content, finish reasons, and streaming tool deltas.
   Unsupported dialects must be explicit capability failures.
3. Extend detached worktrees into a recoverable workcell contract with
   create/bind/inspect, rollback-on-failure, cleanup, retention, crash
   recovery, and stronger process/filesystem/network isolation. Bind packet and
   script provenance to the workcell starting commit and caller identity.
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
  every recovery branch; enforce the currently declared `max_repairs` budget.
- Complete Capsule A/B with independent fresh sessions, immutable commits,
  context-efficiency scoring, repeated runs, and comparable JSON/Markdown
  reports.
- Add Paperclip/Hermes adapter contract tests plus pinned provenance for every
  reused Kujo dependency.
- Add capability discovery and visible policy-aware routing explanations for
  provider, model, agent, tool, privacy, modality, budget, and tenant limits.
- Negotiate provider tool dialects before enabling provider-generated tools and
  persist the selected dialect and capability evidence.
- Promote the unsigned local packet manifest to a signed durable artifact
  manifest only when a canonical storage owner and export signature contract
  exist.

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
  durable-store recovery, adapter authentication, provider profile, packet and
  script provenance, and release provenance checks.
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
  typed tool-result, packet-manifest, ChangeBucket, Eval, RunLedger, and report
  evidence.
- Interrupted, cancelled, fallback, and repaired runs preserve causal receipts
  and do not bypass policy, approval, Watchdog, or budgets.
- Live, configured-live, local-stub, fixture, and blocked evidence remain
  visibly distinct in JSON and Markdown reports.
- PackWrite packet provenance and recursive artifact integrity are verified.
- Concurrent index behavior has deterministic stress evidence or the store has
  moved to a stronger durable owner.
- Changes are committed in small meaningful commits, pushed, and clean.
- Strata memory is consolidated, deduplicated, and retrieval-tested.
