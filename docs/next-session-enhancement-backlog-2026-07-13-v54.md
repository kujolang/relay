# Kujo Relay next-session enhancement backlog — v54

Date: 2026-07-13

This backlog is the handoff from the fifty-fourth enterprise-readiness review.
Relay remains a hardened local alpha/showcase. The completion boundary now
requires persisted acceptance artifacts; it is not a claim of enterprise
production readiness.

## Delivered in v54

- Added a shared `persist_required_json` Kujo runtime contract for bounded,
  regular, non-symlinked, expected-shape JSON artifacts.
- Made ChangeBucket and Eval artifact persistence part of completion authority.
- Made JSON and Markdown report persistence fail closed.
- Made a failed pass-status RunLedger finish transition the run to
  `evidence_failure` before the final result is returned.
- Added injected artifact-write and report-write contract coverage.
- Updated the command reference, integration matrix, implementation plan,
  architecture decisions, enterprise review, final report, README, and this
  versioned handoff.
- Focused mission, store, sizes, resume-integrity, and Agents SDK tool smokes
  pass; the full configured Loop Engineering gate remains required at handoff.

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

- Import Spec and Dispatch workflow contracts without creating a competing
  workflow schema or state machine.
- Add stable mission/run identifiers, schema migrations, and compatibility
  negotiation across upstream tool versions.
- Emit CaseFile failure bundles and use structured Redact APIs when the
  upstream contract supports machine-readable artifacts.
- Add typed retry, fallback, repair, escalation, and approval receipts with
  deterministic failure-class policies and regression evaluations.
- Run the Capsule benchmark end to end with independently swappable Model A
  and Model B, repeated immutable-commit trials, and comparable JSON/Markdown
  Eval reports.
- Add Paperclip and Hermes adapters that preserve their organizational/task
  ownership boundaries while delegating execution evidence to Relay.
- Add signed, authenticated export and retention/compaction policies.
- Add crash-injection tests around state, report, receipt, and RunLedger finish
  writes, including recovery and idempotent report retry semantics.

## P2 — later improvements

- Adaptive model routing based on role, context, budget, provider availability,
  Watchdog telemetry, and Eval history.
- Remote event sinks, aggregate cost/latency metrics, benchmark dashboards, and
  multi-host run observation.
- ShipCheck, Concord, Fence, Lens, Muzzle, and full release-gate composition
  after their ownership boundaries are proven useful for Relay.

## Definition of done for the next session

- The implementation remains Kujo-native and the CLI remains a thin wrapper
  over reusable runtime contracts.
- Every claimed upstream integration has executable evidence, not only a
  compile check or placeholder command.
- Required artifact and RunLedger finish failures have injected tests and
  cannot result in a successful terminal run.
- The real-provider, provider-tool, workcell, authenticated-machine, and
  durable-storage P0s are either proven with captured evidence or explicitly
  blocked by missing external authority/credentials.
- Unit/contract tests, focused smokes, the full Loop Engineering workflow, and
  documentation checks pass.
- Changes are committed in small meaningful commits, pushed to `origin/main`,
  and the working tree is clean.
- Strata memory is consolidated, deduplicated, retrievable, and the next
  session handoff names exact commits, tests, blockers, and this backlog.
