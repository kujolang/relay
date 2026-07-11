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

## Deferred

Live Ollama Cloud proof, Watchdog server health/telemetry assertion, full Agents SDK runner/tool registry integration, Dispatch workflow import, dynamic agent discovery, automated worktree creation, CaseFile failure bundles, Redact integration, MCP adapter, adaptive routing, model-generated tool calls, Capsule A/B scoring, durable concurrent storage, and ShipCheck/Concord release gates. See `docs/next-session-enhancement-backlog.md`.

## Dependency order

1. Stabilize cross-repository package/import and process contracts.
2. Add a Watchdog health/proxy adapter and live provider smoke test.
3. Replace explicit action lists with Agents SDK Tool contracts and approvals.
4. Add Dispatch/Spec workflow loader and bounded checkpoint transitions.
5. Add worktree/workcell creation and cleanup policy.
6. Implement CaseFile/Redact and complete Capsule benchmark comparison.
7. Wire Paperclip/Hermes through JSON or MCP adapters.

## Main risks

Process path resolution, live credentials, Watchdog availability, provider capability differences, cross-repo version drift, worktree cleanup, and accidental authority expansion. Every deferred item has an explicit boundary rather than a placeholder command.
