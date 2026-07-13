# Kujo Relay next-session enhancement backlog — v62

Date: 2026-07-13

This backlog is the handoff from the sixty-second enterprise-readiness review.
Relay remains a hardened local alpha/showcase, not a universally useful,
enterprise-production platform. This review makes fallback policy outcomes
first-class mission evidence and adds a complete byte bound to artifact-size
inspection without claiming external integration completion.

## Delivered in v62

- [x] Centralize fallback classification for transient/capability failures and
  preserve non-retryable skip reasons.
- [x] Persist `model_fallback_selected` and `model_fallback_skipped` events
  with typed `fallback` receipts and bounded retry IDs during mission planning.
- [x] Bound `runs sizes` by 4096 entries, 16 directory levels, and 8 MiB of
  total artifact bytes; add a regression smoke for the total-byte denial.
- [x] Update the command reference, architecture decisions, integration
  matrix, implementation plan, enterprise review, final report, and this
  handoff.

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
  current state seal and receipt hashes are tamper evidence only.
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
  missions; current chat JSONL remains normalized after the AI SDK bridge
  returns.
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
