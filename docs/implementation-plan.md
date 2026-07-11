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

## Deferred

Live Ollama Cloud proof, a live Watchdog-backed mission against a real external provider, provider-driven model tool planning, richer Agents SDK runner/tool-result artifact integration, Dispatch workflow import, dynamic agent discovery, full workcell isolation/rollback/recovery, CaseFile failure bundles, Redact integration, MCP adapter, adaptive routing, Capsule A/B scoring, durable concurrent storage, signed export, and ShipCheck/Concord release gates. Local real-Watchdog/stub-provider correlation, one fixture mission through the Agents SDK Tool Registry, and complete event-sequence verification are proven. See `docs/next-session-enhancement-backlog-2026-07-11-v8.md`.

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
