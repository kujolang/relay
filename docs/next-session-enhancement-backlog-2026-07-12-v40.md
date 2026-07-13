# Kujo Relay next-session enhancement backlog — review 40

This review strengthens dependency integrity. `doctor --json` now supports
optional SHA-256 pins for the Kujo, PackWrite, RunLedger, and ChangeBucket
executables, with malformed, mismatched, missing, or symlinked pinned targets
failing readiness. Relay remains a local-first hardened alpha/showcase, not an
enterprise-production or universally useful platform.

## Completed in this review

- [x] Add optional SHA-256 pin checks to `doctor --json`.
- [x] Reject malformed digests, mismatches, missing files, and symlinked
  targets when a pin is configured.
- [x] Add CLI smoke coverage for matching and wrong-hash readiness behavior.
- [x] Keep hash pinning separate from version probes, signed provenance, and
  deployment ownership.
- [x] Update README, command reference, integration matrix, ADR-058,
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

- [ ] Add semantic compatibility ranges and signed provenance for version and
  hash checks; keep deployment trust policy outside Relay's local doctor.
- [ ] Load Spec task contracts and Dispatch workflows with schema/version
  negotiation; do not create a competing workflow format.
- [ ] Add typed retry, fallback, repair, escalation, cancellation, approval,
  and regression-evaluation receipts with stable upstream-compatible IDs.
- [ ] Integrate CaseFile and a structured Redact JSON/envelope contract across
  prompts, tools, packets, reports, exports, and handoffs.
- [ ] Finish Capsule A/B execution and add Paperclip/Hermes adapters over the
  stable JSON runtime boundary.

## P2 — performance and operations

- [ ] Add true streaming event sinks while retaining the bounded watcher
  fallback.
- [ ] Add artifact rotation/compaction, retention, resumable export, bounded
  parallel read-only discovery/evaluation, and aggregate cost/latency metrics.
- [ ] Add model capability discovery and visible policy-aware routing reasons.
- [ ] Promote doctor, receipt, event, redaction, and process-lifecycle checks
  into authenticated service/workcell contracts.

## Presentation and adoption

- [ ] Add committed fixture transcripts, JSON Schemas for mission/run/event/
  receipt/report/doctor/probe/tool-result contracts, and a generated architecture
  diagram backed by real artifacts.
- [ ] Add pinned-runtime installation paths for macOS/Linux/CI and reproducible
  dependency verification.
- [ ] Add Fence, Concord, ShipCheck, and Eval release gates with badges only
  for verified local gates.
- [ ] Add a truthful showcase gallery covering version/hash readiness, receipt
  context, chat/probe, bounded missions, pause/resume, budget denial, worktree
  cleanup, store recovery, event integrity, Agents SDK approval, and Watchdog
  correlation.

## Definition of done for the next session

- [ ] Changed behavior has focused Kujo tests and the full local acceptance set
  remains green.
- [ ] At least one external provider is exercised through real Watchdog with
  authenticated correlation, redaction, latency, and failure evidence.
- [ ] Provider-generated Agents SDK tool planning is proven in an isolated
  mission with bounded approval and deterministic postconditions.
- [ ] Live, configured-live, fixture, and blocked evidence remain distinct.
- [ ] Version, path, hash, provenance, and live evidence are clearly separated.
- [ ] Changes are committed in small meaningful commits, pushed, and clean.

## Verification

```bash
export KUJO_BIN=/Users/robertdevore/2026/Kujolang/kujo-repos/kujo/target/release/kujo
"$KUJO_BIN" run tests/relay_contract_tests.kujo --interpreter
bash tests/relay_cli_smoke.sh
git diff --check
```

Full Loop Engineering, external provider proof, provider-generated tool
planning, workcells, authenticated machine mode, durable storage, structured
Redact integration, signed provenance, release gates, and universal enterprise
readiness remain unproven.
