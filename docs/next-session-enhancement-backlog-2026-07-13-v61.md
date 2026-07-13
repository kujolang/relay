# Kujo Relay next-session enhancement backlog — v61

Date: 2026-07-13

This backlog is the handoff from the sixty-first enterprise-readiness review.
Relay remains a hardened local alpha/showcase, not a universally useful,
enterprise-production platform. This review improves local state authority,
input hardening, machine contracts, and verification presentation without
claiming that external integrations are complete.

## Delivered in v61

- [x] Seal persisted `state.json` with `integrity_sha256` and verify it at
  read, resume, cleanup, and report boundaries.
- [x] Bound mission IDs to a 96-character filesystem-safe alphabet and reject
  oversized names/goals, unsupported action types, malformed write actions,
  oversized writes, and policy-invalid command actions before execution.
- [x] Publish forward-compatible JSON Schemas for mission, run/report,
  AgentEvent, receipt, doctor, model probe, and tool-result boundaries.
- [x] Normalize mission/run/workflow/step/agent/model/provider/packet/tool,
  artifact/evaluation/retry/repair, RunLedger, and AI correlation metadata on
  every runtime event and receipt.
- [x] Add `tests/relay_acceptance.sh` as the aggregate local gate that runs the
  Kujo contract suite, all committed smoke tests, schema checks, and
  `git diff --check`.
- [x] Update README, command reference, integration matrix, ADRs,
  implementation plan, enterprise review, final report, and this handoff.

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

- Import Spec and Dispatch contracts with schema/version negotiation.
- Add signed state/export provenance and authenticated ownership; the current
  state seal is tamper evidence only.
- Integrate CaseFile and structured Redact artifacts where supported.
- Implement typed retry, fallback, repair, escalation, cancellation, and
  regression-evaluation receipts.
- Finish Capsule A/B execution with fresh Model B sessions, repeated runs,
  comparable Eval scoring, and JSON/Markdown reports.
- Add Paperclip/Hermes adapters without moving organizational ownership into
  Relay; preserve the schemas as compatibility boundaries.
- Add semantic compatibility ranges and pinned/signed provenance for the
  in-tree bridge and external Kujo dependency roots.

## P2 — performance and operations

- Add true streaming event sinks for long-running missions; current chat JSONL
  remains normalized after the AI SDK bridge returns.
- Add artifact rotation/compaction, retention policy, size metrics, and
  resumable export for `.relay` evidence.
- Add bounded parallel read-only discovery/evaluation while serializing writes
  and Git mutations.
- Record latency, token/cost, retry, queue, tool-duration, artifact-size, and
  provider-availability metrics through Watchdog/RunLedger contracts.
- Add provider capability discovery and evaluated policy-aware routing
  explanations without overstating model features.
- Add deterministic doctor checks for upstream compatibility ranges, Watchdog
  reachability, auth mode, provider profiles, schema versions, and release
  policy posture.
- Add a lock-contention and concurrent-writer stress harness before claiming
  the local cache is sufficient for multi-process workloads.

## P2 — presentation and adoption

- Add pinned-runtime installation paths for macOS/Linux/CI and a reproducible
  dependency doctor command.
- Add Fence, Concord, ShipCheck, and Eval release gates with badges only for
  verified local gates.
- Add a truthful showcase gallery covering chat, probe, bounded task,
  pause/resume, budget denial, worktree cleanup, store recovery, state/event
  integrity, verified export, Agents SDK tool approval, and Watchdog
  correlation.
- Generate schema-derived examples and architecture diagrams from real
  artifacts while keeping examples offline and deterministic.

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
