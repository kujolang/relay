# Implementation Plan

## Delivered MVP

- Kujo CLI and reusable `src/runtime.kujo`.
- Fixture-backed AI SDK chat, normalized stream events, explicit model/provider metadata.
- Chain of Command role registry for Planner, Core Developer, Code Reviewer, Release Verifier.
- PackWrite packet generation and validation.
- One isolated Git workspace with policy-checked file and command actions.
- RunLedger start/finish receipt, ChangeBucket JSON, Eval JSON, AgentEvent JSONL, resumable state, Markdown/JSON report.
- Contract tests, security tests, CLI smoke tests, and fixture end-to-end evidence.
- Explicit write approvals, realpath workspace checks, command injection deny rules, redacted subprocess evidence, packet digest metadata, bounded preflight, and real pause-after-plan/resume.
- Fail-closed live Watchdog routing, explicit subprocess environments, configurable budgets, operator diagnostics/probes, detached worktree creation with confirmed cleanup, opt-in authenticated Watchdog health/config/request-correlation verification through a narrow Kujo HTTP adapter, shell-free command execution, a locked rebuildable index, and AgentEvent integrity hashes.
- A bounded Agents SDK Tool Registry bridge with approval-provider enforcement, direct Relay policy-worker execution, and one isolated fixture mission that creates a real repository artifact.
- Fixed subprocess executable paths, workspace-bound worker capabilities, validated Agent SDK tool-call budgets, integrity-chain verification for `runs events`, and versioned `runs export` bundles.
- Added authoritative event-sequence matching and an 8 MiB event-inspection bound so truncated, malformed, or oversized evidence cannot be exported as complete.
- Enriched every emitted event with workflow, model, provider, packet revision, and RunLedger correlation metadata before resealing its integrity hash.
- Added the sealed `RelayReceipt` index for typed cross-references to PackWrite, Agents SDK, model, tool, ChangeBucket, Eval, and RunLedger evidence; event inspection/export verifies receipt integrity and state consistency.
- Narrowed mission Git execution to exact read-only argv profiles and added bounded index-lock backoff with a concurrent rebuild stress smoke.
- Added bounded `runs watch` live AgentEvent observation with per-poll chain verification and terminal state/file reconciliation.
- Added non-negative adapter/action `duration_ms` measurements to AI telemetry and fixture mission evidence.
- Added read-only `runs sizes` artifact inventory with workspace exclusion, per-file sizes, and fail-closed symlink/entry bounds.
- Added cooperative `missions cancel` requests with action-boundary checks, terminal cancellation evidence, and RunLedger finish recording.
- Hardened JSON/JSONL evidence reads, appends, watch, and export against symbolic-linked and non-regular artifact files.
- Added a regular-file, non-symlink, 1 MiB mission-spec bound before JSON parsing and persistence.
- Added bounded pre-parse JSON readers for persisted index/state/evidence files and restricted model fallback to explicit retryable/capability failures with visible skip reasons.
- Bound Agents SDK worker executable and Relay-root selection to trusted environment values and added tampered-root rejection coverage.
- Added 128 KiB pre-parse limits and structured malformed-payload errors to the AI, Agents SDK, and tool-worker environment bridges.
- Added pre-provider Watchdog URL validation that rejects unsupported schemes and embedded credentials with a structured failure.
- Required HTTPS for non-loopback Watchdog hosts while preserving HTTP loopback support for local development and fixture evidence.
- Added structured Watchdog route posture for `doctor --json`; unsafe URLs now fail readiness checks and raw route values are never echoed, including rejected credential-bearing values.
- Bound paused-run resume to the persisted mission-policy digest, workspace identity, Git metadata, event/receipt integrity, and effective budgets; tampered state now fails before resumed actions.

## Deferred

Live Ollama Cloud proof, a live Watchdog-backed mission against a real external provider, provider-driven model tool planning, richer Agents SDK runner/tool-result artifact integration, Dispatch workflow import, dynamic agent discovery, full workcell isolation/rollback/recovery, CaseFile failure bundles, Redact integration, MCP adapter, adaptive routing, Capsule A/B scoring, durable concurrent storage, signed export, richer retry/repair/cancellation receipts, remote event sinks, aggregate metrics, artifact retention/compaction, and ShipCheck/Concord release gates. Local real-Watchdog/stub-provider correlation, one fixture mission through the Agents SDK Tool Registry, complete event-sequence and receipt verification, exact Git argv policy, bounded lock backoff, bounded live event watch, bounded duration evidence, bounded artifact size inventory, cooperative cancellation, symlink-safe evidence access, bounded mission-spec input, bounded persisted JSON parsing, failure-aware fallback, trusted worker-root binding, bounded bridge payloads, validated live Watchdog routes, HTTPS enforcement for non-loopback routes, secret-safe doctor route posture, integrity-bound resume checkpoints, and core execution-context correlation are proven. See `docs/next-session-enhancement-backlog-2026-07-12-v24.md`.

## Dependency order

1. Stabilize cross-repository package/import and process contracts.
2. Run the Watchdog adapter against real configured providers, beginning with Ollama Cloud and one independent OpenAI-compatible provider.
3. Extend the proven Agents SDK Tool Registry bridge to provider-driven tool planning, typed tool-result artifacts, cancellation, and richer approval/guardrail receipts.
4. Add Dispatch/Spec workflow loader and bounded checkpoint transitions.
5. Extend detached worktree mode into full workcell creation, cleanup, rollback, and crash recovery.
6. Implement CaseFile/Redact and complete Capsule benchmark comparison.
7. Wire Paperclip/Hermes through JSON or MCP adapters.

## Main risks

Process path resolution, live credentials, Watchdog availability, provider capability differences, cross-repo version drift, worktree cleanup, and accidental authority expansion. Every deferred item has an explicit boundary rather than a placeholder command.
