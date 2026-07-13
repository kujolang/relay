# Kujo Relay next-session enhancement backlog — review 38

This review improves the evidence contract. Every newly emitted
`RelayReceipt` now carries sealed execution context for workflow, model,
provider, packet revision, attempt, repair attempt, RunLedger, and AI
correlation identifiers. Relay remains a local-first hardened alpha/showcase,
not an enterprise-production or universally useful platform.

## Completed in this review

- [x] Add context metadata to every runtime receipt.
- [x] Include receipt metadata in the integrity hash input.
- [x] Add contract coverage for the metadata field and mission-smoke coverage
  for workflow/model/provider/packet/RunLedger context.
- [x] Update README, command reference, integration matrix, ADRs,
  implementation plan, enterprise review, final report, and this backlog.

## P0 — production authority and external integrations

- [ ] Add credential-gated Ollama Cloud and one independent OpenAI-compatible
  provider smoke profile through real Watchdog, with redacted usage, latency,
  provider failures, fallback decisions, and authenticated correlation proof.
- [ ] Extend Agents SDK integration to provider-generated tool planning with
  typed tool-result artifacts, bounded cancellation, guardrail receipts, and
  explicit retry/fallback semantics.
- [ ] Extend detached worktrees into workcells with rollback-on-failure,
  crash recovery, retention, and stronger process/filesystem/network isolation.
- [ ] Add authenticated machine mode through MCP with identity, tenant, role,
  approval, and audit mappings.
- [ ] Replace the rebuildable JSON cache with an authenticated durable store
  supporting retention, crash recovery, multi-host concurrency, migration, and
  signed export.

## P1 — ecosystem composition and correctness

- [ ] Load Spec task contracts and Dispatch workflows with schema/version
  negotiation; do not create a competing workflow format.
- [ ] Add typed retry, fallback, repair, escalation, cancellation, approval,
  and regression-evaluation receipts with stable upstream-compatible IDs.
- [ ] Integrate CaseFile and a structured Redact JSON/envelope contract across
  prompts, tools, packets, reports, exports, and handoffs. Do not pass JSON
  artifacts through the current text-oriented Redact CLI without proof.
- [ ] Finish Capsule A/B execution with fresh Model B sessions, repeated runs,
  comparable Eval scoring, and JSON/Markdown reports.
- [ ] Add Paperclip and Hermes adapters over the stable JSON runtime boundary.

## P2 — performance and operations

- [ ] Add true streaming event sinks for long-running missions while retaining
  the bounded local watcher fallback.
- [ ] Add artifact rotation/compaction, retention, resumable export, bounded
  parallel read-only discovery/evaluation, and aggregate cost/latency metrics.
- [ ] Add model capability discovery and visible policy-aware routing reasons.
- [ ] Add deterministic doctor checks for upstream versions, Watchdog reachability,
  auth mode, provider profiles, migration state, and release-policy posture.
- [ ] Promote local receipt, event, redaction, and process-lifecycle checks into
  authenticated service/workcell contracts.

## Presentation and adoption

- [ ] Add committed fixture transcripts, JSON Schemas for mission/run/event/
  receipt/report/doctor/probe/tool-result contracts, and a generated architecture
  diagram backed by real artifacts.
- [ ] Add pinned-runtime installation paths for macOS/Linux/CI and reproducible
  dependency verification.
- [ ] Add Fence, Concord, ShipCheck, and Eval release gates with badges only
  for verified local gates.
- [ ] Add a truthful showcase gallery covering receipts with context metadata,
  chat/probe, bounded missions, pause/resume, budget denial, worktree cleanup,
  store recovery, event integrity, Agents SDK approval, and Watchdog correlation.

## Definition of done for the next session

- [ ] Changed behavior has focused Kujo tests and the full local acceptance set
  remains green.
- [ ] At least one external provider is exercised through real Watchdog with
  authenticated correlation, redaction, latency, and failure evidence.
- [ ] Provider-generated Agents SDK tool planning is proven in an isolated
  mission with bounded approval and deterministic postconditions.
- [ ] Live, configured-live, fixture, and blocked evidence remain distinct.
- [ ] Concurrent storage behavior has deterministic stress evidence or a
  stronger durable owner has replaced the local cache.
- [ ] Changes are committed in small meaningful commits, pushed, and clean.

## Verification

```bash
export KUJO_BIN=/Users/robertdevore/2026/Kujolang/kujo-repos/kujo/target/release/kujo
"$KUJO_BIN" run tests/relay_contract_tests.kujo --interpreter
bash tests/relay_mission_smoke.sh
git diff --check
```

Full Loop Engineering, external provider proof, provider-generated tool
planning, workcells, authenticated machine mode, durable storage, structured
Redact integration, release gates, and universal enterprise readiness remain
unproven until their stronger owner contracts and executable evidence exist.
