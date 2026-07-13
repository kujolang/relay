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
- Added sealed receipt context metadata for workflow, model, provider, packet revision, attempt, repair attempt, RunLedger, and AI correlation identifiers so machine consumers do not reconstruct execution context from neighboring files.
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
- Applied the same state-integrity boundary to confirmed worktree cleanup so tampered terminal state cannot redirect Git removal.
- Reused the checkpoint integrity boundary for operator pause and cancel mutations; non-terminal control actions now fail closed on tampered state.
- Added fail-closed evidence persistence: state, receipt, and event write failures mark `evidence_failure`, force failed status before success reporting, and clean temporary files after failed atomic writes.
- Added state-store path validation: `.relay` and `.relay/runs` symbolic links are rejected before mission creation, execution, inspection, or operator controls, with a required doctor check and focused redirection smoke.
- Removed raw Watchdog URLs from AI telemetry; `relay_telemetry.watchdog_route` now carries only non-secret route posture, with credential-bearing and remote-host redaction regression coverage.
- Constrained correlation IDs to a bounded transport-safe alphabet before AI headers, telemetry, or Watchdog query construction, with delimiter and replacement coverage.
- Made store symlink probes tolerant of concurrent lock removal so index rebuilds retry bounded contention instead of crashing on a disappearing `.index.lock` path.
- Added Kujo `spawn_process` process-group cancellation and wired mission commands to `cancel_file`; the cancellation smoke now proves a 30-second descendant task returns within eight seconds.
- Expanded the local evidence redaction boundary to structured credential fields, common provider token formats, and private-key markers, with deterministic contract coverage.
- Hardened `doctor --json` dependency checks to reject required path type mismatches and symbolic-linked runtime/entrypoint dependencies, with machine-readable safety posture and a symlinked-Kujo regression smoke.
- Added bounded `doctor --json` version probes for the Kujo runtime, PackWrite, RunLedger, and ChangeBucket launchers, with explicit tool environments, configurable sibling roots, and fail-closed required readiness.
- Added optional SHA-256 dependency pins for the Kujo, PackWrite, RunLedger, and ChangeBucket executables; malformed, mismatched, missing, or symlinked pinned targets fail doctor readiness.
- Hardened provider credential environment selection against dynamic-loader, interpreter-injection, Git override, and trust-store override variables before the AI bridge receives them.
- Preserved `cancelled` and `timeout` as distinct action failure classes in runtime evidence and policy classification, with contract and cancellation-smoke coverage.
- Added a 30-second descendant timeout smoke proving Kujo process-group termination returns within 12 seconds without an orphan and persists typed timeout evidence.
- Optimized `runs watch` to retain parsed events and process only newly appended complete lines or a pending partial line, while rejecting replacement/truncation/disappearance and revalidating the full chain only after stream changes.
- Unified Relay symlink inspection behind a fail-closed helper: missing paths remain absent, dangling symlinks are detected through metadata before existence checks, existing parent path components are checked for store roots, and runtime probe errors are unsafe across evidence, workspace, dependency, control, and Agents SDK worker boundaries.

## Deferred

 Live Ollama Cloud proof, a live Watchdog-backed mission against a real external provider, provider-driven model tool planning, richer Agents SDK runner/tool-result artifact integration, Dispatch workflow import, dynamic agent discovery, full workcell isolation/rollback/recovery, CaseFile failure bundles, full Redact integration, MCP adapter, adaptive routing, Capsule A/B scoring, durable concurrent storage, signed export, richer retry/repair/cancellation receipts, remote event sinks, aggregate metrics, artifact retention/compaction, and ShipCheck/Concord release gates. Local real-Watchdog/stub-provider correlation, one fixture mission through the Agents SDK Tool Registry, complete event-sequence and receipt verification, exact Git argv policy, bounded lock backoff, incremental bounded live event watch, bounded duration evidence, bounded artifact size inventory, cooperative cancellation, symlink-safe evidence access including parent-component store checks, bounded mission-spec input, bounded persisted JSON parsing, failure-aware fallback, trusted worker-root binding, bounded bridge payloads, validated live Watchdog routes, HTTPS enforcement for non-loopback routes, secret-safe doctor route posture, route telemetry non-disclosure, endpoint-independent Watchdog diagnostics, integrity-bound resume checkpoints, integrity-bound worktree cleanup, integrity-bound pause/cancel controls, structured local credential/token/private-key redaction, dependency-integrity doctor checks, deterministic upstream version probes, optional SHA-256 dependency pinning, credential-environment injection deny rules, fail-closed symlink probe errors and dangling-symlink detection, explicit cancellation/timeout action classes, descendant-safe timeout termination evidence, PackWrite atomic pack writes, fail-closed evidence persistence, state-store symlink rejection, and sealed receipt execution context are proven. See `docs/next-session-enhancement-backlog-2026-07-12-v47.md`.

Current follow-on backlog: `docs/next-session-enhancement-backlog-2026-07-12-v47.md`.

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

## Current review delta

Extend the existing fail-closed filesystem policy to all local trust roots:
state-store parents, doctor dependency targets, the Agents SDK worker
root/source, bounded JSON/JSONL artifacts, cancellation requests, and live
event observation. Keep this as a shared boundary helper with focused probes;
do not introduce a separate path-policy implementation. Cache repeated watcher
existence checks per poll. The next implementation priority remains live
Watchdog/provider evidence and a real bounded mission, followed by stronger
workcell and durable-store ownership.

The adapter boundary also now canonicalizes subprocess module context for
sibling Kujo tools. This closes a cross-repository launch-context failure that
could make ChangeBucket import Relay's modules or return no change evidence.
