# Kujo Relay next-session enhancement backlog — v56

Date: 2026-07-13

This backlog is the handoff from the fifty-sixth enterprise-readiness review.
Relay remains a hardened local alpha/showcase, not universal enterprise
production. The local worker and watcher boundaries are stronger, while the
external authority and provider-integration P0s remain open.

## Delivered in v56

- Rechecked `approval.approved` inside the direct Agents SDK worker before any
  write action can execute.
- Rejected direct worker command timeouts outside 1–600000 ms.
- Rejected direct worker output/write budgets outside 1–8 MiB.
- Made `runs watch` use the identity-checked authoritative state reader for
  terminal status and fail closed on unsafe state artifacts.
- Added direct-worker approval, timeout, and budget regression tests plus a
  watcher state-symlink regression test.
- Updated README, command reference, ADRs, implementation plan, final report,
  enterprise review, and this handoff.

## P0 — completion blockers

1. Prove a real Ollama Cloud run through the normal Watchdog → AI SDK path with
   credentials supplied outside persisted evidence, plus one independent
   OpenAI-compatible provider.
2. Replace explicit action-plan-only execution with provider-generated tool
   planning through the Agents SDK, typed tool-result artifacts, bounded
   approval/repair receipts, and a real multi-step repository task.
3. Provide true isolated workcell/worktree lifecycle ownership with rollback,
   cleanup, crash recovery, and tamper-resistant workspace identity.
4. Provide authenticated machine invocation for Paperclip/Hermes/CI/MCP with
   caller identity, authorization, replay protection, and bounded export.
5. Replace the rebuildable local index and file bundle with durable concurrent
   transactional storage and explicit crash-recovery semantics.

## P1 — high-value follow-ons

- Import Spec and Dispatch contracts without creating a competing workflow
  schema or state machine.
- Add stable identifiers, schema migration, and compatibility negotiation.
- Emit CaseFile failure bundles and use structured Redact APIs where supported.
- Add typed retry, fallback, repair, escalation, and approval receipts with
  deterministic failure-class policies and regression evaluations.
- Run the Capsule benchmark end to end with independently swappable Model A and
  Model B, repeated immutable-commit trials, and comparable Eval reports.
- Add Paperclip and Hermes adapters while preserving their task ownership and
  delegating execution evidence to Relay.
- Add signed authenticated export, retention/compaction, crash-injection tests,
  recovery, and idempotent report retry semantics.

## P2 — later improvements

- Adaptive model routing, remote event sinks, aggregate metrics, benchmark
  dashboards, and multi-host run observation.
- ShipCheck, Concord, Fence, Lens, Muzzle, and release-gate composition after
  their ownership boundaries are proven useful for Relay.

## Definition of done for the next session

- Keep the implementation Kujo-native and the CLI thin over reusable runtime
  contracts.
- Prove every claimed integration with executable evidence, not placeholders.
- Prove or explicitly block the P0 integrations with authentic external evidence.
- Pass focused tests, all existing smokes, the complete Loop Engineering
  workflow, and documentation checks without regressions.
- Commit in small meaningful commits, push `origin/main`, and leave the tree
  clean.
- Consolidate and retrieval-test Strata memory with exact commits, tests,
  blockers, and this backlog.
