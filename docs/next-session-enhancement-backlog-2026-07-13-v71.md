# Kujo Relay Next-Session Enhancement Backlog — 2026-07-13 v71

This backlog records the next enterprise-readiness boundary after the v71
bounded-repair review. Relay is a hardened local alpha/showcase, not an
enterprise production runtime or universally useful platform. Repair is an
explicit replay primitive, not adaptive self-healing.

## Delivered in v71

- Added `missions repair <run-id>` with failed-state, failure-class, and budget checks.
- Added repair IDs, attempt counts, typed RunLedger receipts, and lifecycle events.
- Enforced `budgets.max_repairs` in the range 0–4 at schema and runtime boundaries.
- Added a flaky isolated-worktree repair smoke and zero-budget rejection coverage.
- Updated command, architecture, integration, implementation, README, and readiness documentation.

## P0 — external proof and durable authority

- Prove real Ollama Cloud and one independent OpenAI-compatible provider through authenticated Watchdog paths, including streaming, usage, provider errors, tool dialects, and visible fallback records.
- Add provider dialect negotiation and a complete provider-driven tool loop while preserving policy-controlled tool execution and bounded continuation budgets.
- Replace disposable worktree assumptions with recoverable workcells: durable identity, crash recovery, cleanup, lease/ownership checks, and safe interrupted-step resume.
- Add authenticated Paperclip, Hermes, CI, and MCP adapters with explicit tenant/task identity and no implicit trust in caller-supplied paths or credentials.
- Add a transactional durable run store with concurrency, locking, crash consistency, retention, migration, and multi-process evidence.
- Complete one external-provider mission that performs isolated repository work, resumes or repairs after interruption, records ChangeBucket/Eval/RunLedger evidence, and emits stable JSON and Markdown reports.

## P1 — composition and evaluation depth

- Integrate Spec and Dispatch contracts where they are authoritative, with one ownership map for mission state and workflow state.
- Standardize stable causal IDs across mission, run, workflow, step, agent, model, provider, packet revision, tool call, artifact, repair, evaluation, and approval records.
- Integrate CaseFile and Redact for failure bundles, secret/output sanitization, and export-safe evidence.
- Extend explicit repair into typed adaptive recovery only after evidence supports it: failure classifier, approved repair strategies, per-class budgets, regression evaluation, and escalation.
- Run a Capsule A/B benchmark with Model A/Model B swaps, repeated immutable commits, deterministic scoring, and comparable JSON/Markdown reports.
- Add signed or externally verifiable packet and artifact provenance, capability-based model/tool routing, and manifest validation.

## P2 — operations and scale

- Add bounded streaming event sinks, retention/compaction, replay-safe export, and aggregate latency/token/cost/failure metrics.
- Add parallel read-only discovery and evaluation only with deterministic merge rules and isolated write authority.
- Add `doctor` checks for repair posture, workcell health, store migrations, provider auth, packet integrity, and tool-policy drift.
- Add stress/fuzz/concurrency tests for provider loops, repair races, store corruption, packet traversal, and large evidence bundles.
- Add ShipCheck/Concord/install/gallery/compatibility-matrix coverage before calling Relay release-ready.

## Definition of done for the next session

- Every P0 acceptance claim has executable evidence, including a real external provider and a live recoverable workcell.
- Interrupted, cancelled, fallback, and repaired paths have causal receipts and deterministic terminal semantics.
- Repairable and terminal failure classes are tested separately; no policy or authentication failure is replayable.
- Packet integrity, secret redaction, concurrent store behavior, and export boundaries are tested.
- Full Kujo checks, contract/schema smokes, aggregate acceptance, and Loop Engineering pass.
- Changes are committed in small meaningful commits, pushed, and the worktree is clean.
- Strata memory is consolidated, deduplicated, and retrieval-tested with the final handoff.
