# Kujo Relay next-session enhancement backlog — v59

Date: 2026-07-13

This backlog is the handoff from the fifty-ninth enterprise-readiness review.
Relay remains a hardened local alpha/showcase, not universal enterprise
production. The AI bridge source boundary is now fail-closed; external
authority, provider, and durable-runtime P0s remain open.

## Delivered in v59

- Bound `RELAY_AI_BRIDGE` to a regular, non-symlinked `.kujo` file inside the
  configured Relay root before AI SDK bridge execution.
- Added the same AI bridge readiness check to `doctor` without disclosing
  rejected paths.
- Added CLI regression coverage for external bridge rejection in chat and
  doctor.
- Updated README, command reference, ADR-080, implementation plan, final
  report, enterprise review, and this handoff.

## P0 — completion blockers

1. Prove a real Ollama Cloud run and an independent provider through the normal
   Watchdog → AI SDK path with redacted usage, latency, failures, fallback, and
   correlation evidence.
2. Add provider-generated Agents SDK tool planning, typed tool-result artifacts,
   bounded repair/approval receipts, and a real multi-step repository task.
3. Provide true isolated workcell lifecycle ownership with rollback, cleanup,
   crash recovery, and tamper-resistant workspace identity.
4. Provide authenticated Paperclip/Hermes/CI/MCP invocation with identity,
   authorization, replay protection, and bounded export.
5. Replace the rebuildable local index/file bundle with durable concurrent
   transactional storage and crash recovery.

## P1 — high-value follow-ons

- Import Spec and Dispatch contracts with schema/version negotiation.
- Add complete stable correlation IDs and schema migrations.
- Integrate CaseFile and structured Redact artifacts where supported.
- Add typed retry, fallback, repair, escalation, cancellation, and approval
  receipts with deterministic policies and regression evaluations.
- Finish Capsule A/B execution and comparable JSON/Markdown scoring.
- Add Paperclip/Hermes adapters without moving organizational ownership into
  Relay; add signed authenticated export and retention/compaction.
- Add signed or pinned provenance for the in-tree bridge and external Kujo
  dependency roots before supporting arbitrary deployment overrides.

## P2 — later improvements

- Streaming event sinks, bounded parallel discovery/evaluation, aggregate
  metrics, model capability routing, benchmark dashboards, and multi-host
  observation.
- ShipCheck, Concord, Fence, Lens, Muzzle, and release-gate composition after
  ownership boundaries are proven useful.

## Definition of done for the next session

- Keep the implementation Kujo-native and the CLI thin over reusable runtime
  contracts.
- Prove every claimed integration with executable evidence, not placeholders.
- Pass focused tests, all existing smokes, the complete Loop Engineering
  workflow, and documentation checks without regressions.
- Commit small meaningful changes, push `origin/main`, leave the tree clean,
  and consolidate/retrieval-test Strata with exact evidence and this backlog.
