# Kujo Relay next-session enhancement backlog — v63

Date: 2026-07-13

This backlog is the handoff from the sixty-third enterprise-readiness review.
Relay remains a hardened local alpha/showcase, not a universally useful,
enterprise-production platform. This review improves machine-readable event
inspection and cooperative control evidence without claiming distributed
authentication, durable storage, or live-provider completion.

## Delivered in v63

- [x] Add bounded `runs events --limit 1..4096` windows with `--after` event
  cursors; validate the complete event chain and authoritative state sequence
  before slicing.
- [x] Publish `schemas/event-bundle.schema.json` for unpaged and paged event
  inspection responses, including integrity and cursor metadata.
- [x] Bind cancellation requests to the target run ID and a SHA-256 seal;
  reject malformed, copied, stale-format, or tampered requests at action
  boundaries.
- [x] Add focused store, cancellation, contract, schema, command-reference,
  integration-matrix, ADR, and readiness-report evidence.

## P0 — production authority and external integrations

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

## P1 — ecosystem composition and correctness

- [ ] Import Spec and Dispatch contracts with schema/version negotiation.
- [ ] Add signed state/export provenance and authenticated ownership; the
  current state and cancellation seals are tamper evidence only.
- [ ] Integrate CaseFile and structured Redact artifacts where supported.
- [ ] Extend typed retry evidence to repair, escalation, cancellation, and
  regression-evaluation receipts owned by their corresponding policies.
- [ ] Finish Capsule A/B execution with fresh Model B sessions, repeated runs,
  comparable Eval scoring, and JSON/Markdown reports.
- [ ] Add Paperclip/Hermes adapters without moving organizational ownership
  into Relay; preserve the schemas as compatibility boundaries.
- [ ] Add semantic compatibility ranges and pinned/signed provenance for the
  in-tree bridge and external Kujo dependency roots.

## P2 — performance and operations

- [ ] Add true streaming event sinks and bounded backpressure for long-running
  missions; paged inspection is not a remote event subscription.
- [ ] Add artifact rotation/compaction, retention policy, and resumable export
  for `.relay` evidence; keep `runs sizes` read-only.
- [ ] Add bounded parallel read-only discovery/evaluation while serializing
  writes and Git mutations.
- [ ] Record latency, token/cost, retry, queue, tool-duration, artifact-size,
  and provider-availability metrics through Watchdog/RunLedger contracts.
- [ ] Add provider capability discovery and evaluated policy-aware routing
  explanations without overstating model features.
- [ ] Add deterministic doctor checks for upstream compatibility ranges,
  Watchdog reachability, auth mode, provider profiles, schema versions, and
  release policy posture.
- [ ] Add a lock-contention and concurrent-writer stress harness before
  claiming the local cache is sufficient for multi-process workloads.

## Definition of done for the next session

- [ ] Keep the implementation Kujo-native and the CLI thin over reusable
  runtime contracts.
- [ ] Prove every claimed integration with executable evidence, not placeholders.
- [ ] Pass `bash tests/relay_acceptance.sh`, the full Loop Engineering workflow,
  and documentation/schema checks without regressions.
- [ ] Separate live, configured-live, fixture, and blocked evidence in reports.
- [ ] Commit small meaningful changes, push `origin/main`, leave the tree
  clean, and consolidate/retrieval-test Strata with exact evidence and this
  backlog.
