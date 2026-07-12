# Kujo Relay next-session enhancement backlog — review 30

This is the handoff from the thirtieth enterprise-readiness review. Relay
remains a local-first hardened alpha/showcase, not an enterprise-production
platform. This review closes the remaining Watchdog diagnostic disclosure
path: unreachable health/configuration requests now return bounded,
endpoint-independent errors.

## Completed in this review

- [x] Normalize Watchdog HTTP transport failures before they reach doctor,
  live verification, or persisted run telemetry.
- [x] Preserve logical endpoint paths and status while removing raw URL/error
  material from failure output.
- [x] Add an unreachable-route doctor smoke proving configured endpoints are
  not disclosed on connection failure.
- [x] Document ADR-048, the diagnostic contract, review evidence, and this
  next-session backlog.

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

- [ ] Load Spec task contracts and Dispatch workflows with schema/version
  negotiation; do not create a competing workflow format.
- [ ] Extend receipts to explicit retry, repair, escalation, approval,
  guardrail, cancellation, and regression-evaluation IDs.
- [ ] Integrate CaseFile for failed-run bundles and Redact for prompts, tools,
  packets, reports, and handoffs.
- [ ] Finish Capsule A/B execution with fresh Model B sessions, repeated runs,
  comparable Eval scoring, and JSON/Markdown reports.
- [ ] Add Paperclip and Hermes adapters over the stable JSON runtime boundary.
- [ ] Add authenticated file/socket transport for payloads larger than the
  128 KiB environment bridge limit.
- [ ] Add authenticated Watchdog route discovery, certificate policy, and mTLS.
- [ ] Add authenticated durable event sinks only after selecting an upstream
  ownership contract.

## P2 — performance and operations

- [ ] Add process-group cancellation and rollback-aware workcell semantics.
- [ ] Add artifact rotation/compaction, retention, and resumable export.
- [ ] Add bounded parallel read-only discovery/evaluation while serializing
  writes and Git mutations.
- [ ] Add aggregate latency, token/cost, retry, queue, tool-duration,
  artifact-size, and provider-availability metrics.
- [ ] Add model capability discovery and visible policy-aware routing reasons.
- [ ] Add doctor checks for upstream versions, auth, migration, TLS,
  checkpoint/control/store posture, and release policy.
- [ ] Promote local state-root, evidence, telemetry, correlation, and
  diagnostic non-disclosure checks into authenticated service, workcell, and
  no-follow durable-store contracts.

## P2 — presentation and adoption

- [ ] Add committed fixture transcripts, JSON Schemas for mission/run/event/
  receipt/report/doctor/probe/tool-result/store/telemetry/diagnostic
  contracts, and a generated architecture diagram backed by artifacts.
- [ ] Add pinned-runtime installation paths for macOS/Linux/CI.
- [ ] Add Fence, Concord, ShipCheck, and Eval release gates with badges only
  for verified local gates.
- [ ] Add a truthful showcase gallery covering Watchdog diagnostic
  non-disclosure, route telemetry non-disclosure, correlation replacement,
  store-lock race safety, state-store symlink rejection, evidence persistence
  failure, resume/control/cleanup integrity, PackWrite atomic generation,
  Watchdog correlation, and the remaining proven smokes.

## Definition of done for the next session

- [ ] Changed behavior has focused Kujo tests and the full local acceptance set
  remains green.
- [ ] PackWrite remains green in its own offline unit and CLI suites.
- [ ] At least one external provider is exercised through real Watchdog with
  authenticated correlation evidence.
- [ ] Provider-generated Agents SDK tool planning is proven in an isolated
  mission with bounded approval and deterministic postconditions.
- [ ] Fixture, configured-live, live, and blocked evidence are separated.
- [ ] State-store, evidence, route, telemetry, diagnostic, input, resume,
  control, cleanup, bridge, fallback, PackWrite, and Watchdog evidence remains
  deterministic or has moved to a stronger owner contract.
- [ ] Changes are committed in small meaningful commits, pushed, and clean.

## Repository layout decision

The small root remains intentional: `main.kujo` is the executable entrypoint,
`kujo.toml` is package metadata, `bin/relay` is a thin launcher, runtime code
is under `src/`, tests under `tests/`, examples under `examples/`, and operator
documentation under `docs/`. No root runtime files need relocation.

## Verification

```bash
export KUJO_BIN=/Users/robertdevore/2026/Kujolang/kujo-repos/kujo/target/release/kujo
"$KUJO_BIN" run tests/relay_contract_tests.kujo --interpreter
bash tests/relay_cli_smoke.sh
bash tests/relay_state_store_safety_smoke.sh
git diff --check
```

The full configured Relay acceptance set remains the Loop Engineering gate
source of truth. External provider proof, provider-generated tool planning,
workcell recovery, authenticated machine mode, durable multi-host storage,
certificate validation, mTLS, migration, and release gates remain unproven.
