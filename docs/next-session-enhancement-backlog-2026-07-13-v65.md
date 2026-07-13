# Kujo Relay Next-Session Enhancement Backlog — 2026-07-13 v65

This backlog records the next bounded engineering work after the v65 review.
Relay remains a hardened local alpha. The new provider-generated tool-planning
path is locally proven through an authenticated Watchdog and deterministic stub
provider, but that is not evidence of live external-provider or enterprise
readiness.

## Delivered in v65

- Added opt-in `agent_tool_mode: "provider"` with a required explicit
  `agent_tool_allowlist` for the supported Relay tools.
- Added bounded OpenAI-compatible function schemas and fail-closed
  normalization of provider-generated tool calls.
- Routed normalized calls through the existing Agents SDK registry, approval
  provider, nonce-bound worker capability, and Relay policy worker.
- Added an authenticated local Watchdog/stub-provider end-to-end smoke proving
  provider response, tool planning, repository mutation, ChangeBucket, Eval,
  RunLedger, and `tool_plan_resolved` event evidence.
- Added mission-schema, contract, CLI, example, command-reference, architecture,
  integration-matrix, implementation-plan, and readiness-report coverage.

## P0 — external proof and authority foundations

1. Run the same provider-tool mission through real Ollama Cloud and one
   independent OpenAI-compatible provider via a real Watchdog instance. Capture
   redacted usage, latency, fallback, provider capability, and correlation
   evidence; keep fixture, local-stub, configured-live, and live results
   distinct.
2. Extend the single planning response into a bounded multi-turn tool loop with
   provider tool-result messages, typed persisted tool-result artifacts,
   cancellation receipts, approval receipts, and a hard maximum call/turn
   budget. Never let a provider response bypass the existing policy worker.
3. Replace detached-worktree-only execution with a real workcell lifecycle:
   create, bind, inspect, cleanup, rollback, crash recovery, and isolation
   verification. Prove that workcell identity and repository authority survive
   interruption without trusting mutable paths.
4. Add authenticated Paperclip, Hermes, CI, and MCP adapter boundaries with
   caller identity, tenant scope, replay protection, approval mapping, and
   audit evidence. Keep these integrations optional for the core runtime.
5. Add a durable transactional store with concurrent writers/readers,
   recovery after process loss, retention policy, and integrity-checked export.
   Preserve RunLedger as the evidence owner instead of creating a parallel run
   database.
6. Complete one externally configured Watchdog-backed repository mission using
   a live provider, isolated workcell, provider-generated tool planning, Eval,
   ChangeBucket, RunLedger, resume, and machine-readable final report.

## P1 — contract depth and reusable composition

- Negotiate the chosen mission/workflow boundary with Spec and Dispatch instead
  of maintaining a Relay-specific workflow vocabulary.
- Add stable event IDs, causal/parent IDs, receipt IDs, and cross-artifact
  references for every significant action, retry, repair, approval, handoff,
  fallback, and model/tool call.
- Integrate CaseFile for failure bundles and Redact for the full persisted and
  exported evidence surface, with adversarial secret-shaped fixtures.
- Add typed retry/repair/fallback receipts and regression evaluation for every
  repair path.
- Run Capsule A/B benchmark comparisons with independent receiving sessions,
  immutable starting commits, context-efficiency scoring, and comparable JSON
  and Markdown reports.
- Add Paperclip/Hermes adapter contract tests and pinned package/repository
  provenance for every reused Kujo dependency.
- Add capability discovery and explicit routing explanations for model, agent,
  tool, privacy, budget, and provider constraints.

## P2 — operations, scale, and release confidence

- Add bounded streaming event sinks with backpressure, reconnection, and
  terminal-seal verification.
- Add artifact retention, compaction, resumable export, and bounded storage
  accounting.
- Add bounded parallel discovery/evaluation only after durable ownership and
  cancellation semantics are proven.
- Add aggregate operational metrics and provider/model quality comparisons
  without leaking prompts, secrets, or repository content.
- Add doctor checks for live capability negotiation, workcell health, durable
  store recovery, adapter authentication, and release provenance.
- Run lock, crash, replay, cancellation, and concurrent-reader/writer stress
  suites.
- Add showcase/install/release gates through ShipCheck and Concord, including
  pinned dependency and generated-artifact verification.

## Definition of done for the next session

- The aggregate acceptance runner and Loop Engineering workflow pass.
- Live-provider evidence is separately labeled from fixture, stub, and
  configured-live evidence.
- At least one live provider-generated tool mission completes in an isolated
  recoverable workcell with RunLedger, ChangeBucket, Eval, and report evidence.
- A resumed or repaired run preserves causal receipts and does not bypass
  Watchdog, policy, approval, or budget boundaries.
- Changes are committed in small meaningful commits, pushed, and the worktree
  is clean.
- Durable session memory is consolidated in Strata, deduplicated, and retrieved
  successfully.
