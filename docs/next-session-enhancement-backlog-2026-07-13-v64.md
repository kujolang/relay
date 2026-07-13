# Kujo Relay next-session enhancement backlog — v64

Date: 2026-07-13

This backlog is the handoff from the sixty-fourth enterprise-readiness review.
Relay remains a hardened local alpha/showcase, not a universally useful,
enterprise-production platform. This review closes several local authority and
machine-observability gaps without claiming authenticated remote operation,
durable storage, live-provider completion, or full workcell isolation.

## Delivered in v64

- [x] Bind Agents SDK worker capabilities to a runtime-generated short-lived
  nonce; reject legacy deterministic capabilities.
- [x] Keep child-process `PATH` fixed and drop unsafe loader, interpreter, Git
  override, and trust-store environment overrides in common and Agents SDK
  process builders.
- [x] Reject mission repository and tool-workspace parent symlink components,
  while allowing the macOS system `/tmp` alias and still rejecting child links.
- [x] Preserve subprocess `exit_code` in repository command action evidence.
- [x] Expand and order canonical failure classification for policy,
  workflow-definition, permission, malformed-tool, invalid-model-response,
  missing-context, implementation, evaluation, repository, tool, and provider
  failures.
- [x] Add bounded `runs list --limit` and `--after` windows for machine callers
  and make the store smoke self-contained with two runs.
- [x] Add focused process-environment, capability, taxonomy, timeout, and
  repository-symlink regression coverage.

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
- [ ] Add signed state/export provenance and authenticated ownership; local
  state, cancellation, and worker seals are tamper evidence only.
- [ ] Add nonce expiry/replay protection and authenticated caller binding at a
  service or MCP boundary; the current nonce protects only the local
  parent/child worker handoff.
- [ ] Integrate CaseFile and structured Redact artifacts where supported.
- [ ] Map provider error taxonomies to the canonical Relay failure classes and
  add typed retry, repair, escalation, cancellation, and regression receipts.
- [ ] Finish Capsule A/B execution with fresh Model B sessions, repeated runs,
  comparable Eval scoring, and JSON/Markdown reports.
- [ ] Add Paperclip/Hermes adapters without moving organizational ownership
  into Relay; preserve the schemas as compatibility boundaries.
- [ ] Add semantic compatibility ranges and pinned/signed provenance for the
  in-tree bridge and external Kujo dependency roots.

## P2 — performance and operations

- [ ] Add true streaming event sinks and bounded backpressure for long-running
  missions; local response paging is not a remote event subscription.
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

## P2 — presentation and adoption

- [ ] Add committed fixture transcripts, a generated architecture diagram backed
  by real artifacts, and a truthful showcase gallery for chat, probe, bounded
  task, pause/resume, budget denial, worktree cleanup, store recovery, event
  integrity, verified export, tool approval, and Watchdog correlation.
- [ ] Add pinned-runtime installation paths for macOS/Linux/CI and a
  reproducible dependency doctor command.
- [ ] Add Fence, Concord, ShipCheck, and Eval release gates with badges only for
  verified local gates.
- [ ] Keep root layout conventional: `main.kujo`, `kujo.toml`, `README.md`, and
  `bin/relay` are intentional; runtime behavior remains under `src/`.

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
