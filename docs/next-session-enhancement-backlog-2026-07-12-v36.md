# Kujo Relay next-session enhancement backlog — review 36

This is the handoff from the thirty-sixth enterprise-readiness review. Relay
remains a local-first hardened alpha/showcase, not an enterprise-production
platform. This review improves `runs watch` scaling by parsing only appended
event data while retaining append-prefix and full chain integrity checks.

## Completed in this review

- [x] Retain parsed watcher events across polls instead of reparsing the full
  JSONL history each time.
- [x] Parse only newly appended complete lines and a pending partial line.
- [x] Reject event-log replacement or truncation before incremental parsing.
- [x] Continue full event-chain validation on every poll.
- [x] Update the README, ADRs, integration matrix, implementation plan,
  enterprise review, final report, and this backlog.

## P0 — production authority and external integrations

- [ ] Add credential-gated Ollama Cloud and one independent OpenAI-compatible
  provider smoke profile through the real Watchdog server. Record redacted
  usage, latency, provider failures, fallback decisions, and correlation proof.
- [ ] Extend the Agents SDK bridge from fixture-specified calls to
  provider-generated tool planning with typed tool-result artifacts, bounded
  cancellation, guardrail receipts, and explicit retry/fallback semantics.
- [ ] Extend detached worktrees into a workcell contract with rollback-on-
  failure, crash recovery, retention, and stronger process/filesystem/network
  isolation.
- [ ] Add authenticated machine mode through the guarded MCP boundary with
  identity, tenant, role, approval, and audit mappings.
- [ ] Replace the rebuildable JSON cache with a database-backed or append-only
  durable run store supporting retention, crash recovery, multi-host
  concurrency, and authenticated ownership.

## P1 — ecosystem composition and correctness

- [ ] Integrate the Redact contract across prompts, PackWrite packets,
  handoffs, reports, exports, and tenant-aware secret custody; preserve the
  local redactor as a fail-closed last line of defense.
- [ ] Add signed dependency manifests, executable hashes, provenance checks,
  and deployment-owned trust policy on top of doctor path posture.
- [ ] Normalize provider/tool/repository/evaluation failure taxonomies across
  adapters and emit typed retry, repair, escalation, approval, guardrail,
  cancellation, timeout, and regression-evaluation receipts.
- [ ] Load Spec task contracts and Dispatch workflows with schema/version
  negotiation; do not create a competing workflow format.
- [ ] Finish Capsule A/B execution with fresh Model B sessions, repeated runs,
  comparable Eval scoring, and JSON/Markdown reports.
- [ ] Add Paperclip and Hermes adapters over the stable JSON runtime boundary.
- [ ] Add authenticated Watchdog route discovery, certificate policy, and mTLS.
- [ ] Add authenticated durable event sinks only after selecting an upstream
  ownership contract.

## P2 — performance and operations

- [ ] Add true streaming event sinks for long-running missions; preserve the
  bounded local watcher as the safe fallback.
- [ ] Add artifact rotation/compaction, retention, and resumable export.
- [ ] Add bounded parallel read-only discovery/evaluation while serializing
  writes and Git mutations.
- [ ] Add aggregate latency, token/cost, retry, queue, tool-duration,
  artifact-size, and provider-availability metrics.
- [ ] Add model capability discovery and visible policy-aware routing reasons.
- [ ] Add doctor checks for upstream versions, auth, migration, TLS,
  checkpoint/control/store posture, redaction policy, and release readiness.
- [ ] Promote local redaction, dependency, evidence, route, telemetry,
  correlation, diagnostic, failure-class, cancellation, timeout, and watcher
  integrity checks into authenticated service and workcell contracts.

## P2 — presentation and adoption

- [ ] Add committed fixture transcripts, JSON Schemas for mission/run/event/
  receipt/report/doctor/probe/tool-result/store/telemetry/diagnostic
  contracts, and a generated architecture diagram backed by artifacts.
- [ ] Add pinned-runtime installation paths for macOS/Linux/CI.
- [ ] Add Fence, Concord, ShipCheck, and Eval release gates with badges only
  for verified local gates.
- [ ] Add a truthful showcase gallery covering incremental watcher parsing,
  dependency-integrity doctor posture, structured evidence redaction, typed
  cancellation/timeout evidence, independent descendant timeout proof,
  process groups, Watchdog diagnostic and telemetry non-disclosure,
  correlation replacement, store-lock race safety, state-store symlink
  rejection, evidence persistence failure, resume/control/cleanup integrity,
  PackWrite generation, Watchdog correlation, and remaining proven smokes.

## Definition of done for the next session

- [ ] Changed behavior has focused Kujo tests and the full local acceptance set
  remains green.
- [ ] PackWrite remains green in its own offline unit and CLI suites.
- [ ] At least one external provider is exercised through real Watchdog with
  authenticated correlation evidence, redaction proof, dependency posture,
  typed failure evidence, and timeout/cancellation lifecycle evidence.
- [ ] Provider-generated Agents SDK tool planning is proven in an isolated
  mission with bounded approval and deterministic postconditions.
- [ ] Fixture, configured-live, live, and blocked evidence are separated.
- [ ] Redaction, dependency, state-store, evidence, route, telemetry,
  diagnostic, failure-class, input, resume, control, cleanup, bridge,
  fallback, PackWrite, Watchdog, cancellation, timeout, and watcher evidence
  remains deterministic or has moved to a stronger owner contract.
- [ ] Changes are committed in small meaningful commits, pushed, and clean.

## Repository layout decision

The small root remains intentional: `main.kujo` is the executable entrypoint,
`kujo.toml` is package metadata, `bin/relay` is a thin launcher, runtime code
is under `src/`, tests under `tests/`, examples under `examples/`, and operator
documentation under `docs/`. No root runtime files need relocation.

## Verification

```bash
export KUJO_BIN=/tmp/kujo-process-group/target/debug/kujo
"$KUJO_BIN" run tests/relay_contract_tests.kujo --interpreter
bash tests/relay_watch_smoke.sh
git diff --check
```

The full configured Relay acceptance set remains the Loop Engineering gate
source of truth. External provider proof, provider-generated tool planning,
workcell recovery, authenticated machine mode, durable multi-host storage,
full Redact integration, signed dependency provenance, remote event sinks,
certificate validation, mTLS, migration, and release gates remain unproven.
