# Kujo Relay next-session enhancement backlog — v42

Review date: 2026-07-12. Relay remains a hardened local alpha/showcase, not
an enterprise-production platform or universally useful runtime. This review
closes a fail-open filesystem inspection path and records the next evidence-
backed work without overstating readiness.

## Completed in this review

- [x] Treat symlink-probe exceptions and invalid probe inputs as unsafe.
- [x] Reuse the fail-closed helper across runtime, CLI, doctor, dependency,
  workspace, control, evidence, and Agents SDK worker checks.
- [x] Preserve absent-path behavior for missing files and directories.
- [x] Add contract coverage for an invalid probe input and retain missing-path
  coverage.
- [x] Pass Kujo source checks, Relay contracts, Agents SDK tool smoke, and CLI
  smoke.
- [x] Update README, command reference, ADR-060, enterprise review, final
  report, integration matrix, implementation plan, and this backlog.

## P0 — prove external composition and authority

- [ ] Execute a credential-gated Ollama Cloud request through the real Watchdog
  server and AI SDK, with redacted usage, latency, provider failure, fallback,
  and correlation evidence.
- [ ] Execute one live bounded repository mission through Watchdog, Agents SDK,
  PackWrite, RunLedger, ChangeBucket, and Eval against an immutable starting
  commit.
- [ ] Extend Agents SDK integration from fixture-specified calls to provider-
  generated tool planning, typed tool-result artifacts, bounded cancellation,
  approvals, retries, and deterministic postconditions.
- [ ] Define authenticated machine-mode ownership: identity, tenant, role,
  approval, network egress, secret custody, and audit mappings.
- [ ] Extend detached worktrees into workcells with process/filesystem/network
  isolation, rollback-on-failure, crash recovery, ownership proofs, and
  retention/cleanup receipts.
- [ ] Replace or formally bound the rebuildable JSON cache with a durable
  append-only/database owner supporting migration, retention, crash recovery,
  multi-host concurrency, and signed export.

## P1 — ecosystem composition and correctness

- [ ] Load Spec task contracts and Dispatch workflows with schema/version
  negotiation, without creating a competing workflow language.
- [ ] Attach mission, run, workflow, step, agent, model, provider, packet,
  tool, artifact, evaluation, retry, repair, and approval IDs to every event
  and RunLedger receipt.
- [ ] Integrate CaseFile for failed-run bundles and Redact for prompts, tools,
  packets, reports, and handoffs once a structured artifact contract exists.
- [ ] Add typed retry, fallback, repair, escalation, cancellation, and
  regression-evaluation receipts.
- [ ] Finish Capsule A/B execution with fresh Model B sessions, repeated runs,
  comparable Eval scoring, and JSON/Markdown reports.
- [ ] Add Paperclip and Hermes adapters over the stable JSON boundary without
  moving organizational ownership into Relay.

## P2 — performance and operations

- [ ] Add true streaming event sinks and bounded backpressure for long-running
  missions; preserve canonical local AgentEvent evidence.
- [ ] Add artifact rotation/compaction, retention policy, size metrics, and
  resumable export for `.relay` evidence.
- [ ] Add bounded parallel read-only discovery/evaluation while serializing
  writes and Git mutations with deterministic evidence ordering.
- [ ] Record latency, token/cost, retry, queue, tool-duration, artifact-size,
  and provider-availability metrics through Watchdog/RunLedger contracts.
- [ ] Add model capability discovery and visible policy-aware routing reasons.
- [ ] Add doctor checks for provider profiles, Watchdog reachability/auth mode,
  dependency compatibility ranges, and release-policy posture.
- [ ] Make cancellation/timeout Loop gates deterministic under a clean host;
  current reruns have been interrupted by local process/resource instability.

## P2 — presentation and adoption

- [ ] Add committed fixture transcripts, JSON Schemas for mission/run/event/
  report/doctor/tool-result contracts, and an architecture diagram backed by
  real artifacts.
- [ ] Add pinned-runtime installation paths for macOS, Linux, and CI with
  reproducible dependency verification.
- [ ] Add Fence, Concord, ShipCheck, and Eval release gates with badges only
  for verified local or externally reproduced evidence.
- [ ] Add a truthful showcase gallery for chat, probe, bounded task,
  pause/resume, budget denial, worktree cleanup, store recovery, event
  integrity, export, approval, and Watchdog correlation.

## Definition of done for the next session

- [ ] All changed behavior has focused Kujo tests and the full local acceptance
  set is green on a stable host.
- [ ] At least one external provider is exercised through real Watchdog with
  authenticated correlation evidence.
- [ ] Provider-generated Agents SDK tool planning is proven in an isolated
  mission with deterministic postconditions.
- [ ] Fixture, configured-live, live, and blocked evidence remain distinct.
- [ ] Concurrent index behavior has deterministic evidence or a stronger store
  owner is adopted.
- [ ] Changes are committed in small meaningful commits, pushed, and clean.
- [ ] Strata receives a deduplicated capture, decision, TODO, current-state
  handoff, and retrieval test.
