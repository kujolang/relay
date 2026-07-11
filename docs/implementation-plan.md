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
- Fail-closed live Watchdog routing, explicit subprocess environments, configurable budgets, operator diagnostics/probes, detached worktree creation with confirmed cleanup, and opt-in authenticated Watchdog health/config/request-correlation verification through a narrow Kujo HTTP adapter.

## Deferred

Live Ollama Cloud proof, a live Watchdog-backed mission against a real external provider, full Agents SDK runner/tool registry integration, Dispatch workflow import, dynamic agent discovery, full workcell isolation/rollback/recovery, CaseFile failure bundles, Redact integration, MCP adapter, adaptive routing, model-generated tool calls, Capsule A/B scoring, durable concurrent storage, and ShipCheck/Concord release gates. Local real-Watchdog and stub-provider correlation proof is now present. See `docs/next-session-enhancement-backlog-2026-07-11-v4.md`.

## Dependency order

1. Stabilize cross-repository package/import and process contracts.
2. Run the Watchdog adapter against real configured providers, beginning with Ollama Cloud and one independent OpenAI-compatible provider.
3. Replace explicit action lists with Agents SDK Tool contracts and approvals.
4. Add Dispatch/Spec workflow loader and bounded checkpoint transitions.
5. Extend detached worktree mode into full workcell creation, cleanup, rollback, and crash recovery.
6. Implement CaseFile/Redact and complete Capsule benchmark comparison.
7. Wire Paperclip/Hermes through JSON or MCP adapters.

## Main risks

Process path resolution, live credentials, Watchdog availability, provider capability differences, cross-repo version drift, worktree cleanup, and accidental authority expansion. Every deferred item has an explicit boundary rather than a placeholder command.
