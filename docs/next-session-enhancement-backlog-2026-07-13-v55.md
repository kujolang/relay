# Kujo Relay next-session enhancement backlog — v55

Date: 2026-07-13

This backlog is the handoff from the fifty-fifth enterprise-readiness review.
Relay remains a hardened local alpha/showcase, not universal enterprise
production. Read-side evidence now requires semantic report identity and
bounded Markdown presence, but the major external-integration P0s remain open.

## Delivered in v55

- Required `report.json` run ID, mission ID, and status to match authoritative
  state for report lookup, verification, and export.
- Required a bounded regular `report.md` companion at those read boundaries.
- Rejected run-index records whose authoritative `state.json` is missing or
  does not contain the indexed run ID.
- Rejected oversized artifact directories before recursive inventory flattening.
- Checked mission-spec persistence and delayed final completion emission until
  the RunLedger finish and evidence-failure boundary were known to succeed.
- Added store and sizes regression coverage for these failure cases.
- Updated the README, command reference, integration matrix, ADRs, final report,
  and enterprise-readiness review.

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
- Add stable identifiers, schema migration, and compatibility negotiation
  across upstream tool versions.
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

- Adaptive model routing based on role, context, budget, availability, Watchdog
  telemetry, and Eval history.
- Remote event sinks, aggregate cost/latency metrics, benchmark dashboards, and
  multi-host run observation.
- ShipCheck, Concord, Fence, Lens, Muzzle, and release-gate composition after
  their ownership boundaries are proven useful for Relay.

## Definition of done for the next session

- The implementation remains Kujo-native and the CLI remains a thin wrapper over
  reusable runtime contracts.
- Every claimed integration has executable evidence, not only a compile check or
  placeholder command.
- P0 integrations are proven with captured evidence or explicitly blocked by
  missing external authority/credentials.
- Focused tests, the complete Loop Engineering workflow, and documentation
  checks pass without regressions.
- Changes are committed in small meaningful commits, pushed to `origin/main`,
  and the working tree is clean.
- Strata memory is consolidated, deduplicated, retrievable, and the next-session
  handoff names exact commits, tests, blockers, and this backlog.
