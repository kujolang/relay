# Kujo Relay next-session enhancement backlog — review 6

This is the handoff from the sixth enterprise-readiness review. Relay remains a
local-first hardened alpha/showcase, not a universal enterprise-production
platform. This review proves one real isolated mission path through the
existing Agents SDK Tool Registry and approval provider while keeping Relay's
workspace and command policy authoritative.

## Completed in this review

- [x] Register bounded `relay.write_file` and `relay.run_command` tools through
  the existing Agents SDK Tool Registry.
- [x] Apply the existing Agents SDK approval-provider contract to write tools.
- [x] Delegate tool execution through a capability-bound Relay worker process.
- [x] Keep direct-argv, workspace, write, command, and budget checks in Relay.
- [x] Record the summarized tool result in the mission's integrity-sealed event
  stream and RunLedger-backed report.
- [x] Prove an isolated fixture mission creates a real repository artifact via
  `relay.write_file`.
- [x] Prove an unapproved write is denied and creates no file.
- [x] Keep the root layout conventional: `main.kujo`, `kujo.toml`, and
  `bin/relay` remain necessary; runtime stays under `src/`.
- [x] Add a focused smoke gate and update the integration matrix, ADRs,
  implementation plan, enterprise review, README, and final report.

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
- [ ] Attach mission, run, workflow, step, agent, model, provider, packet
  revision, tool, artifact, evaluation, retry, and repair IDs to every event and
  RunLedger receipt.
- [ ] Integrate CaseFile for failed-run bundles and Redact for prompts, tools,
  packets, reports, and handoffs.
- [ ] Implement typed retry, fallback, repair, escalation, cancellation, and
  regression-evaluation receipts.
- [ ] Finish Capsule A/B execution with fresh Model B sessions, repeated runs,
  comparable Eval scoring, and JSON/Markdown reports.
- [ ] Add Paperclip and Hermes adapters over the stable JSON runtime boundary
  without moving organizational ownership into Relay.

## P2 — performance and operations

- [ ] Add true streaming event sinks for long-running missions; current chat
  JSONL is normalized after the AI SDK bridge returns.
- [ ] Add artifact rotation/compaction, retention policy, size metrics, and
  resumable export for `.relay` evidence.
- [ ] Add bounded parallel read-only discovery/evaluation while serializing
  writes and Git mutations.
- [ ] Record latency, token/cost, retry, queue, tool-duration, artifact-size,
  and provider-availability metrics through Watchdog/RunLedger contracts.
- [ ] Add model capability discovery and visible policy-aware routing
  explanations.
- [ ] Add deterministic doctor checks for upstream versions, Watchdog
  reachability, auth mode, provider profiles, and release-policy posture.
- [ ] Add a lock-contention and concurrent-writer stress harness before claiming
  the local cache is sufficient for multi-process workloads.

## P2 — presentation and adoption

- [ ] Add committed fixture transcripts, JSON Schemas for mission/run/event/report,
  doctor, probe, and tool-result contracts, plus a generated architecture
  diagram backed by real artifacts.
- [ ] Add pinned-runtime installation paths for macOS/Linux/CI and a reproducible
  dependency doctor command.
- [ ] Add Fence, Concord, ShipCheck, and Eval release gates with badges only for
  verified local gates.
- [ ] Add a truthful showcase gallery covering chat, probe, bounded task,
  pause/resume, budget denial, worktree cleanup, store recovery, event integrity,
  Agents SDK tool approval, and Watchdog correlation.

## Definition of done for the next session

- [ ] All changed behavior has focused Kujo tests and the full local acceptance
  set remains green.
- [ ] At least one external provider is exercised through the real Watchdog
  server with authenticated correlation evidence.
- [ ] Provider-generated Agents SDK tool planning is proven in an isolated
  mission, with bounded approval and deterministic postconditions.
- [ ] Live, configured-live, fixture, and blocked evidence are separated in
  reports and docs.
- [ ] Concurrent index behavior has deterministic stress evidence or the store
  has moved to a stronger durable owner.
- [ ] Changes are committed in small meaningful commits, pushed, and left clean.
