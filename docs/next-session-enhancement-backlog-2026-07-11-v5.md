# Kujo Relay next-session enhancement backlog — review 5

This is the handoff from the fifth enterprise-readiness review. Relay is still
not universally enterprise-production-ready, but this review closes several
local security and evidence gaps without widening the product claim.

Implementation baseline before this review: 614113d. This review adds shell-free
mission command execution, locked index refreshes, event integrity hashes, Git
argument hardening, and tamper-resistant worktree cleanup.

## Completed in this review

- [x] Replace mission /bin/sh -lc execution with direct argv execution through
  the bounded process environment.
- [x] Reject tabs and shell syntax at the command policy boundary.
- [x] Add atomic run-index lock directories with stale-lock recovery.
- [x] Validate cached run status and timestamps against authoritative state.
- [x] Reject symlinked or oversized index files.
- [x] Add deterministic SHA-256 integrity fields and validation for
  AgentEvent-compatible records.
- [x] Protect worktree cleanup from tampered state paths and source-repository
  mismatches.
- [x] Pass Git revision arguments through end-of-options handling.
- [x] Add focused contract, store, mission, and worktree regression coverage.
- [x] Re-audit the root layout: main.kujo, kujo.toml, and bin/relay remain
  necessary idiomatic entry/package/launcher files; no redundant root runtime
  files were found.
- [x] Update README, ADRs, integration matrix, implementation plan, enterprise
  review, final report, and this new backlog.

## P0 — production authority and external integrations

- [ ] Add credential-gated Ollama Cloud and one independent OpenAI-compatible
  provider smoke profile through the real Watchdog server. Record redacted
  usage, latency, provider failures, fallback decisions, and correlation proof.
- [ ] Replace explicit Relay action lists with the Agents SDK Tool Registry,
  approval providers, guardrails, cancellation, and tool-result artifacts.
  Preserve Relay policy checks as the authority boundary.
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
  resumable export for .relay evidence.
- [ ] Add bounded parallel read-only discovery/evaluation while serializing writes
  and Git mutations.
- [ ] Record latency, token/cost, retry, queue, tool-duration, artifact-size, and
  provider-availability metrics through Watchdog/RunLedger contracts.
- [ ] Add model capability discovery and visible policy-aware routing explanations.
- [ ] Add deterministic doctor checks for upstream versions, Watchdog reachability,
  auth mode, provider profiles, and release-policy posture.
- [ ] Add a lock-contention and concurrent-writer stress harness before claiming
  the local cache is sufficient for multi-process workloads.

## P2 — presentation and adoption

- [ ] Add committed fixture transcripts, JSON Schemas for mission/run/event/report,
  doctor, and probe contracts, plus a generated architecture diagram backed by
  real artifacts.
- [ ] Add pinned-runtime installation paths for macOS/Linux/CI and a reproducible
  dependency doctor command.
- [ ] Add Fence, Concord, ShipCheck, and Eval release gates with badges only for
  verified local gates.
- [ ] Add a truthful showcase gallery covering chat, probe, bounded task,
  pause/resume, budget denial, worktree cleanup, store recovery, event integrity,
  and Watchdog correlation.

## Definition of done for the next session

- [ ] All changed behavior has focused Kujo tests and the full local acceptance
  set remains green.
- [ ] At least one external provider is exercised through the real Watchdog
  server with authenticated correlation evidence.
- [ ] At least one isolated mission uses Agents SDK tools rather than only
  declarative Relay actions.
- [ ] Live, configured-live, fixture, and blocked evidence are separated in
  reports and docs.
- [ ] Concurrent index behavior has deterministic stress evidence or the store
  has moved to a stronger durable owner.
- [ ] Changes are committed in small meaningful commits, pushed, and left clean.
