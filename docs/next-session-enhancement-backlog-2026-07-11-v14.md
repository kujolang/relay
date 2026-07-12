# Kujo Relay next-session enhancement backlog — review 14

This is the handoff from the fourteenth enterprise-readiness review. Relay
remains a local-first hardened alpha/showcase, not a universally useful,
enterprise-production platform. This review adds safe, read-only artifact size
evidence without inventing retention or storage ownership.

## Completed in this review

- [x] Add `runs sizes <run-id>` with versioned JSON output and per-file bytes.
- [x] Always report the repository workspace as excluded from Relay artifact
  accounting; do not scan an unbounded checkout by default.
- [x] Reject symbolic links and unsupported paths and cap inventory at 4096
  artifact files.
- [x] Add a fixture size-inventory smoke and Loop Engineering gate.
- [x] Update ADR-029, README, command reference, integration matrix,
  implementation plan, enterprise review, final report, and this backlog.

## P0 — production authority and external integrations

- [ ] Add credential-gated Ollama Cloud and one independent OpenAI-compatible
  provider smoke profile through the real Watchdog server. Record redacted
  usage, latency, provider failures, fallback decisions, and correlation proof.
- [ ] Extend the Agents SDK bridge from fixture-specified calls to
  provider-generated tool planning with typed tool-result artifacts, bounded
  cancellation, guardrail receipts, and explicit retry/fallback semantics.
- [ ] Extend detached worktrees into a workcell contract with rollback-on-failure,
  crash recovery, retention, and stronger process/filesystem/network isolation.
- [ ] Add authenticated machine mode through the guarded MCP boundary with
  identity, tenant, role, approval, and audit mappings.
- [ ] Replace the rebuildable JSON cache with a database-backed or append-only
  durable run store supporting retention, crash recovery, multi-host concurrency,
  signed export, and deterministic migration.
- [ ] Prove a Watchdog-backed isolated repository mission against an external
  provider; the current real-server smoke uses a local stub upstream.

## P1 — ecosystem composition and correctness

- [ ] Load Spec task contracts and Dispatch workflows with schema/version
  negotiation; do not create a competing workflow format.
- [ ] Extend receipt coverage to explicit retry, repair, escalation, approval,
  guardrail, cancellation, and regression-evaluation IDs, and map those IDs to
  upstream RunLedger records when the upstream contracts support them.
- [ ] Integrate CaseFile for failed-run bundles and Redact for prompts, tools,
  packets, reports, and handoffs.
- [ ] Finish Capsule A/B execution with fresh Model B sessions, repeated runs,
  comparable Eval scoring, and JSON/Markdown reports.
- [ ] Add Paperclip and Hermes adapters over the stable JSON runtime boundary
  without moving organizational ownership into Relay.
- [ ] Add remote/event-sink adapters only after selecting an authenticated,
  durable upstream ownership contract; keep `runs watch` as the local fallback.

## P2 — performance and operations

- [ ] Add artifact rotation/compaction, retention policy, and resumable export
  for `.relay` evidence; keep `runs sizes` read-only until an owner and approval
  contract exist.
- [ ] Add bounded parallel read-only discovery/evaluation while serializing
  writes and Git mutations.
- [ ] Add aggregate latency, token/cost, retry, queue, tool-duration,
  artifact-size, and provider-availability metrics through Watchdog/RunLedger
  contracts, preserving local duration and size evidence as raw measurements.
- [ ] Add model capability discovery and visible policy-aware routing
  explanations.
- [ ] Add deterministic doctor checks for upstream versions, Watchdog
  reachability, auth mode, provider profiles, and release-policy posture.
- [ ] Promote local watch, duration, size, and lock stress evidence into durable
  event/store concurrency gates when stronger persistence and sink owners are
  selected.

## P2 — presentation and adoption

- [ ] Add committed fixture transcripts, JSON Schemas for mission/run/event/
  receipt/report/doctor/probe/tool-result/sizes contracts, plus a generated
  architecture diagram backed by real artifacts.
- [ ] Add pinned-runtime installation paths for macOS/Linux/CI and a
  reproducible dependency doctor command.
- [ ] Add Fence, Concord, ShipCheck, and Eval release gates with badges only
  for verified local gates.
- [ ] Add a truthful showcase gallery covering chat, probe, bounded task,
  pause/resume, budget denial, worktree cleanup, store recovery,
  event/receipt integrity, truncation rejection, verified export, correlated
  event context, exact Git policy rejection, lock stress, live event watch,
  duration metrics, artifact size inventory, Agents SDK tool approval, and
  Watchdog correlation.

## Definition of done for the next session

- [ ] All changed behavior has focused Kujo tests and the full local acceptance
  set remains green.
- [ ] At least one external provider is exercised through the real Watchdog
  server with authenticated correlation evidence.
- [ ] Provider-generated Agents SDK tool planning is proven in an isolated
  mission, with bounded approval and deterministic postconditions.
- [ ] Live, configured-live, fixture, and blocked evidence are separated in
  reports and docs.
- [ ] Concurrent index, live event, duration, and size evidence have
  deterministic coverage or the store/metrics sinks have moved to stronger
  durable owners.
- [ ] Changes are committed in small meaningful commits, pushed, and left clean.
