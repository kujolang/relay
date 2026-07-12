# Kujo Relay next-session enhancement backlog — review 27

This is the handoff from the twenty-seventh enterprise-readiness review. Relay
remains a local-first hardened alpha/showcase, not a universally useful,
enterprise-production platform. This review makes state, receipt, and event
persistence failures fail closed instead of allowing incomplete evidence to
appear successful.

## Completed in this review

- [x] Mark state, receipt, and event persistence failures as
  `evidence_failure`.
- [x] Force failed status before terminal success reporting when evidence
  persistence has failed.
- [x] Propagate receipt persistence failures through the runtime.
- [x] Clean temporary files after failed atomic state writes.
- [x] Add contract failure injection for evidence and state persistence.
- [x] Preserve mission, resume, and cancellation smoke coverage.
- [x] Update ADR-043, README, command reference, integration matrix,
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
  and authenticated ownership.

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
- [ ] Add authenticated file or socket transport for prompts and tool plans
  larger than the 128 KiB environment bridge limit.
- [ ] Add authenticated route discovery, certificate policy, and mTLS policy
  for Watchdog endpoints while retaining fail-closed route, diagnostics,
  checkpoint, cleanup, pause, cancel, and evidence-persistence integrity as
  local baselines.
- [ ] Add remote/event-sink adapters only after selecting an authenticated,
  durable upstream ownership contract; keep runs watch as the local fallback.

## P2 — performance and operations

- [ ] Add process-group cancellation and rollback-aware workcell semantics;
  keep cooperative missions cancel as the safe local fallback.
- [ ] Add artifact rotation/compaction, retention policy, and resumable export
  for .relay evidence; keep runs sizes read-only until an owner and approval
  contract exist.
- [ ] Add bounded parallel read-only discovery/evaluation while serializing
  writes and Git mutations.
- [ ] Add aggregate latency, token/cost, retry, queue, tool-duration,
  artifact-size, and provider-availability metrics through Watchdog/RunLedger
  contracts, preserving local duration and size evidence as raw measurements.
- [ ] Add model capability discovery and visible policy-aware routing
  explanations, including provider-specific retry taxonomy.
- [ ] Add deterministic doctor checks for upstream versions, Watchdog
  reachability, auth mode, provider profiles, worker-root integrity, bridge
  payload transport, route TLS posture, route certificate posture, checkpoint,
  cleanup, control, evidence-persistence migration posture, and release policy.
- [ ] Promote route, checkpoint, control, cleanup, and evidence validation into
  authenticated service and workcell contracts with tenant-scoped egress policy
  and durable receipts.

## P2 — presentation and adoption

- [ ] Add committed fixture transcripts, JSON Schemas for mission/run/event/
  receipt/report/doctor/probe/tool-result/sizes/cancellation/resume/cleanup/
  control/evidence contracts, plus a generated architecture diagram backed by
  artifacts.
- [ ] Add pinned-runtime installation paths for macOS/Linux/CI and a
  reproducible dependency doctor command.
- [ ] Add Fence, Concord, ShipCheck, and Eval release gates with badges only
  for verified local gates.
- [ ] Add a truthful showcase gallery covering chat, probe, bounded task,
  pause/resume/cancel, budget denial, worktree cleanup, store recovery,
  event/receipt integrity, symlink rejection, oversized-input rejection,
  oversized-index recovery, non-retryable fallback suppression, tampered
  worker-root rejection, oversized and malformed bridge payload rejection,
  invalid Watchdog-route rejection, loopback HTTP acceptance, remote HTTPS
  acceptance, remote HTTP rejection, doctor route failure, doctor secret
  non-disclosure, tampered resume/cleanup/control rejection, evidence write
  failure, temp-file cleanup, truncation rejection, verified export, correlated
  event context, exact Git policy rejection, lock stress, live event watch,
  duration metrics, artifact size inventory, Agents SDK tool approval, PackWrite
  atomic generation, and Watchdog correlation.

## Definition of done for the next session

- [ ] All changed behavior has focused Kujo tests and the full local acceptance
  set remains green.
- [ ] PackWrite remains green in its own offline unit and CLI suites, and Relay
  records truthful generated-pack evidence.
- [ ] At least one external provider is exercised through the real Watchdog
  server with authenticated correlation evidence.
- [ ] Provider-generated Agents SDK tool planning is proven in an isolated
  mission, with bounded approval and deterministic postconditions.
- [ ] Live, configured-live, fixture, and blocked evidence are separated in
  reports and docs.
- [ ] Concurrent index, live event, duration, size, cancellation, symlink,
  mission-input, bounded-JSON, fallback, worker-root, bridge-payload, route,
  doctor-redaction, resume, cleanup, pause/cancel, PackWrite, evidence-write,
  and temp-cleanup evidence have deterministic coverage or their owners have
  moved to stronger contracts.
- [ ] Changes are committed in small meaningful commits, pushed, and left
  clean.

## Repository layout decision

The small root remains intentional and follows mature Kujo conventions:
main.kujo is the executable entrypoint, kujo.toml is package metadata,
bin/relay is a thin launcher, and README.md is the package landing page.
Runtime implementation remains under src/, tests under tests/, examples under
examples/, and operator documentation under docs/.

## Verification

Relay focused evidence:

```bash
export KUJO_BIN=/Users/robertdevore/2026/Kujolang/kujo-repos/kujo/target/release/kujo
"$KUJO_BIN" run tests/relay_contract_tests.kujo --interpreter
bash tests/relay_mission_smoke.sh
bash tests/relay_resume_integrity_smoke.sh
git diff --check
```

PackWrite evidence:

```bash
cd ../packwrite
make test KUJO=/Users/robertdevore/2026/Kujolang/kujo-repos/kujo/target/release/kujo
```

The full configured Relay acceptance set remains the Loop Engineering gate
source of truth. External provider proof, provider-generated tool planning,
workcell recovery, authenticated machine mode, durable multi-host storage,
certificate validation, mTLS, authenticated route discovery, migration, and
release gates remain unproven.
