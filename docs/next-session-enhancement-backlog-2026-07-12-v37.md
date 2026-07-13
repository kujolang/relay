# Kujo Relay next-session enhancement backlog — review 37

This review hardens the local live-event observer. `runs watch` now treats an
event-log disappearance after observation as evidence loss, and it avoids
re-running the full chain hash walk when the bounded raw stream has not
changed. Relay remains a local-first hardened alpha/showcase, not an
enterprise-production platform.

## Completed in this review

- [x] Reject a watched `events.jsonl` file disappearing after first observation.
- [x] Keep full event-chain validation on every changed stream while avoiding
  duplicate validation during idle polls.
- [x] Add a paused-run disappearance smoke with a non-zero exit and explicit
  fail-closed error.
- [x] Update the README, integration matrix, implementation plan, and ADRs.

## Contract-first caution discovered

The Redact repository was exercised locally during this review. Its current
CLI MVP accepts Markdown/text fixtures, but rejects `.json` input and does not
yet provide a proven structured JSON-preserving API. Relay must not pipe
machine-readable mission, receipt, event, or report artifacts through a text
sanitizer until Redact defines and tests that contract. The local Relay
redactor remains the fail-closed boundary for persisted evidence; full Redact
integration stays deferred rather than being represented by an unsafe adapter.

## P0 — production authority and external integrations

- [ ] Add credential-gated Ollama Cloud and one independent OpenAI-compatible
  provider smoke profile through the real Watchdog server, with redacted usage,
  latency, provider failures, fallback decisions, and correlation proof.
- [ ] Extend the Agents SDK bridge to provider-generated tool planning with
  typed tool-result artifacts, bounded cancellation, guardrail receipts, and
  explicit retry/fallback semantics.
- [ ] Extend detached worktrees into a workcell contract with rollback-on-
  failure, crash recovery, retention, and stronger process/filesystem/network
  isolation.
- [ ] Add authenticated machine mode through the guarded MCP boundary.
- [ ] Replace the rebuildable JSON cache with an authenticated durable store.

## P1 — ecosystem composition and correctness

- [ ] Define a Redact structured JSON/envelope contract, then integrate it
  across prompts, PackWrite packets, handoffs, reports, exports, and tenant-
  aware secret custody with Relay's local redactor as a fail-closed fallback.
- [ ] Add signed dependency manifests, executable hashes, provenance checks,
  and deployment-owned trust policy.
- [ ] Normalize provider/tool/repository/evaluation failure taxonomies and
  typed retry, repair, escalation, approval, guardrail, timeout, and regression
  receipts.
- [ ] Load Spec task contracts and Dispatch workflows with schema/version
  negotiation; do not create a competing workflow format.
- [ ] Finish Capsule A/B execution, Paperclip/Hermes adapters, authenticated
  Watchdog route discovery, certificate policy, and durable event sinks.

## P2 — performance and operations

- [ ] Add true streaming event sinks, retaining the bounded watcher fallback.
- [ ] Add artifact rotation/compaction, retention, resumable export, bounded
  parallel read-only discovery/evaluation, and aggregate metrics.
- [ ] Add model capability discovery, visible routing reasons, and doctor
  checks for upstream versions, auth, migration, TLS, and release readiness.
- [ ] Promote local watcher, redaction, evidence, route, telemetry, and
  process-lifecycle checks into authenticated service/workcell contracts.

## Definition of done for the next session

- [ ] Focused Kujo tests and the full local acceptance set remain green.
- [ ] PackWrite remains green in its offline unit and CLI suites.
- [ ] At least one external provider is exercised through real Watchdog, or
  the blocked credential/network evidence is preserved separately.
- [ ] Provider-generated Agents SDK tool planning is proven in an isolated
  mission with bounded approval and deterministic postconditions.
- [ ] Fixture, configured-live, live, and blocked evidence remain distinct.
- [ ] Changes are committed in small meaningful commits, pushed, and clean.

## Verification

```bash
export KUJO_BIN=/Users/robertdevore/2026/Kujolang/kujo-repos/kujo/target/release/kujo
"$KUJO_BIN" run tests/relay_contract_tests.kujo --interpreter
bash tests/relay_watch_smoke.sh
bash tests/relay_watch_integrity_smoke.sh
git diff --check
```

The full configured Relay acceptance set is the Loop Engineering gate source
of truth. External provider proof, provider-generated tool planning, workcell
recovery, authenticated machine mode, durable multi-host storage, structured
Redact integration, signed dependency provenance, remote event sinks,
certificate validation, mTLS, migration, and release gates remain unproven.
