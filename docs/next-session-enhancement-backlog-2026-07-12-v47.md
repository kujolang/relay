# Kujo Relay next-session enhancement backlog — v47

Review date: 2026-07-12. Relay remains a hardened local alpha/showcase, not
an enterprise-production platform or universally useful runtime. The v8
backlog remains the source of the unresolved enterprise requirements. This
review re-audited the v46 boundary and added explicit regression coverage for
safe sibling dependency paths versus strict state-store parent paths.

## Completed in this review

- [x] Re-read `docs/next-session-enhancement-backlog-2026-07-11-v8.md` and
  reconciled its P0/P1/P2 requirements with the current implementation.
- [x] Confirm root layout remains intentional: `main.kujo`, `kujo.toml`,
  README, launcher, `src/`, tests, examples, docs, and artifacts only.
- [x] Add a contract proving `./../ai-sdk` is inspectable without weakening
  the state-store `..` rejection policy.
- [x] Add a contract proving `store_root_safe` rejects parent traversal.
- [x] Preserve the v46 metadata-first evidence and ChangeBucket module-context
  fixes and their passing regression smokes.
- [x] Update this next-session backlog and current documentation pointers.

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
  durable run store supporting retention, crash recovery, multi-host
  concurrency, signed export, and deterministic migration.
- [ ] Prove a Watchdog-backed isolated repository mission against an external
  provider; the current real-server smoke uses a local stub upstream.

## P1 — ecosystem composition and correctness

- [ ] Load Spec task contracts and Dispatch workflows with schema/version
  negotiation; do not create a competing workflow format.
- [ ] Attach mission, run, workflow, step, agent, model, provider, packet
  revision, tool, artifact, evaluation, retry, and repair IDs to every event
  and RunLedger receipt.
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
- [ ] Add deterministic doctor checks for provider profiles, Watchdog
  reachability/auth mode, compatibility ranges, and release-policy posture.
- [ ] Add a stable-host lock/concurrent-writer stress gate to the full Loop
  workflow and preserve exact process-ownership evidence.
- [ ] Replace local JSONL polling with a bounded event sink when mission scale
  requires it, while retaining verified local export.

## P2 — presentation and adoption

- [ ] Add committed fixture transcripts, JSON Schemas for mission/run/event/
  report, doctor, probe, and tool-result contracts, plus a generated
  architecture diagram backed by real artifacts.
- [ ] Add pinned-runtime installation paths for macOS/Linux/CI and a
  reproducible dependency doctor command.
- [ ] Add Fence, Concord, ShipCheck, and Eval release gates with badges only
  for verified local gates.
- [ ] Add a truthful showcase gallery covering chat, probe, bounded task,
  pause/resume, budget denial, worktree cleanup, store recovery, event
  integrity, truncation rejection, verified export, Agents SDK tool approval,
  dangling-link rejection, ChangeBucket evidence, and Watchdog correlation.

## Definition of done for the next session

- [ ] All changed behavior has focused Kujo tests and the full local acceptance
  set remains green on a stable host.
- [ ] At least one external provider is exercised through the real Watchdog
  server with authenticated correlation evidence.
- [ ] Provider-generated Agents SDK tool planning is proven in an isolated
  mission with bounded approval and deterministic postconditions.
- [ ] Live, configured-live, fixture, and blocked evidence are separated in
  reports and docs.
- [ ] Concurrent index behavior has deterministic stress evidence or the store
  has moved to a stronger durable owner.
- [ ] Changes are committed in small meaningful commits, pushed, and left clean.
- [ ] Strata receives a deduplicated capture, decision, TODO, current-state
  handoff, and retrieval test.
