# Kujo Relay Next-Session Enhancement Backlog — 2026-07-13 v72

This backlog records the next enterprise-readiness boundary after the v72
budget and environment review. Relay remains a hardened local alpha/showcase,
not an enterprise production runtime or universally useful platform.

## Delivered in v72

- [x] Require positive mission `max_tokens` and cap it at 16,384.
- [x] Pass the mission token budget to the AI SDK/Watchdog request and reduce provider-tool follow-ups to remaining budget.
- [x] Prevent negative provider usage from reducing budget accounting.
- [x] Reject caller-controlled `PWD` in generic child environment overrides while preserving trusted adapter cwd metadata.
- [x] Add contract and spec-safety coverage plus low-budget fixture evidence.
- [x] Update README, schemas documentation, command reference, integration matrix, ADRs, implementation plan, final report, enterprise review, and this backlog.

## P0 — external proof and durable authority

- [ ] Prove real Ollama Cloud and one independent OpenAI-compatible provider through authenticated Watchdog paths, including streaming, usage, billing/usage reconciliation, provider errors, tool dialects, and visible fallback records.
- [ ] Add provider dialect negotiation and a complete provider-driven tool loop while preserving policy-controlled execution, remaining token budgets, and bounded continuation budgets.
- [ ] Replace disposable worktree assumptions with recoverable workcells: durable identity, crash recovery, cleanup, lease/ownership checks, network policy, and safe interrupted-step resume.
- [ ] Add authenticated Paperclip, Hermes, CI, and MCP adapters with explicit tenant/task identity and no implicit trust in caller-supplied paths, environment, or credentials.
- [ ] Add a transactional durable run store with concurrency, locking, crash consistency, retention, migration, multi-process evidence, and signed/export-verifiable provenance.
- [ ] Complete one external-provider mission that performs isolated repository work, resumes or repairs after interruption, records ChangeBucket/Eval/RunLedger evidence, and emits stable JSON and Markdown reports.

## P1 — composition and evaluation depth

- [ ] Integrate Spec and Dispatch contracts where they are authoritative, with one ownership map for mission state and workflow state.
- [ ] Standardize stable causal IDs across mission, run, workflow, step, agent, model, provider, packet revision, tool call, artifact, repair, evaluation, approval, and token-usage records.
- [ ] Integrate CaseFile and Redact for failure bundles, prompt/tool/packet/report sanitization, and export-safe evidence.
- [ ] Reconcile provider-reported usage with Watchdog/AI SDK billing telemetry and make discrepancies terminal or explicitly degraded rather than silently budget-complete.
- [ ] Extend explicit repair into typed adaptive recovery only after evidence supports it: failure classifier, approved repair strategies, per-class budgets, regression evaluation, and escalation.
- [ ] Run a Capsule A/B benchmark with Model A/Model B swaps, repeated immutable commits, deterministic scoring, context efficiency, and comparable JSON/Markdown reports.
- [ ] Add signed or externally verifiable packet and artifact provenance, capability-based model/tool routing, and manifest validation.

## P2 — operations, performance, and adoption

- [ ] Add bounded streaming event sinks, retention/compaction, replay-safe export, and aggregate latency/token/cost/failure metrics.
- [ ] Add parallel read-only discovery and evaluation only with deterministic merge rules and isolated write authority.
- [ ] Add `doctor` checks for token-budget posture, provider billing/usage reconciliation, workcell health, store migrations, provider auth, packet integrity, and tool-policy drift.
- [ ] Add stress/fuzz/concurrency tests for provider loops, budget races, repair races, store corruption, packet traversal, environment boundaries, and large evidence bundles.
- [ ] Add ShipCheck/Concord/install/gallery/compatibility-matrix coverage before calling Relay release-ready.

## Definition of done for the next session

- [ ] Every P0 acceptance claim has executable evidence, including a real external provider and a live recoverable workcell.
- [ ] Interrupted, cancelled, fallback, budget-exhausted, and repaired paths have causal receipts and deterministic terminal semantics.
- [ ] Provider request budgets, reported usage, Watchdog telemetry, and final accounting agree or surface a typed discrepancy.
- [ ] Packet integrity, secret redaction, environment authority, concurrent store behavior, and export boundaries are tested.
- [ ] Full Kujo checks, contract/schema smokes, aggregate acceptance, and Loop Engineering pass.
- [ ] Changes are committed in small meaningful commits, pushed, and the worktree is clean.
- [ ] Strata memory is consolidated, deduplicated, and retrieval-tested with the final handoff.
