# Kujo Relay next-session enhancement backlog — review 4

This is the handoff from the fourth enterprise-readiness review. It records the
new Watchdog evidence slice and keeps external-provider, isolation, authority,
and persistence claims explicit. Each item closes only with implementation,
focused tests, documentation, and executable evidence.

Implementation baseline before this review: `602ce3e` (`main`, pushed to
`origin/main`). This review adds a narrow Watchdog adapter, correlation-header
propagation, a local contract smoke, and a real local Watchdog plus stub-provider
smoke.

## Completed in this review

- [x] Add `src/watchdog.kujo` as a provider-independent HTTP adapter for health,
  proxy configuration, and correlated request verification.
- [x] Keep Watchdog API/proxy credentials in bounded headers/environment seams;
  sanitize response bodies so prompt/response summaries and raw telemetry do not
  enter Relay output.
- [x] Propagate the Relay run correlation ID through the AI SDK bridge as
  `X-Observe-Correlation-Id` and `X-Observe-Session-Id`.
- [x] Add opt-in `RELAY_WATCHDOG_VERIFY=true` fail-closed verification for live
  calls and doctor checks.
- [x] Add the Kujo Watchdog contract stub smoke, including secret non-leakage and
  missing-correlation failure coverage.
- [x] Add the real local Watchdog smoke with API/proxy token auth, a Kujo
  OpenAI-compatible stub upstream, persisted request correlation, and secret
  non-leakage assertions.
- [x] Add focused contract checks, README/operator documentation, ADR-016, and
  integration/readiness-report updates.

## P0 — external authority, tools, and isolation

- [ ] Add opt-in Ollama Cloud and one independent OpenAI-compatible provider live
  smoke profile. Keep credentials in bounded environment variables and record
  redacted usage, latency, provider errors, and fallback evidence.
- [ ] Replace declarative action lists with the Agents SDK Tool Registry,
  approval providers, guardrails, cancellation, and tool-result artifacts while
  preserving Relay's policy boundary.
- [ ] Extend detached worktrees into a workcell contract with rollback-on-failure,
  crash recovery, retention, and stronger process/filesystem/network isolation.
- [ ] Add authenticated machine mode through the guarded MCP boundary with
  identity, tenant, role, approval, and audit mappings.
- [ ] Replace the rebuildable index cache with a locked or database-backed run
  store supporting concurrent writers, crash recovery, retention, integrity
  verification, and deterministic export.
- [ ] Prove a Watchdog-backed isolated repository mission against an external
  configured provider; the current real-server smoke uses a local stub upstream.

## P1 — ecosystem composition and correctness

- [ ] Load Spec task contracts and Dispatch workflows with schema/version
  negotiation; do not create a competing workflow format.
- [ ] Attach mission, run, workflow, step, agent, model, provider, packet revision,
  tool, artifact, evaluation, retry, and repair IDs to every event and RunLedger
  receipt.
- [ ] Integrate CaseFile for failed-run bundles and Redact for prompts, tools,
  packets, reports, and handoffs.
- [ ] Implement typed retry, fallback, repair, escalation, cancellation, and
  regression-evaluation receipts.
- [ ] Finish Capsule A/B execution with fresh Model B sessions, repeated runs,
  comparable Eval scoring, and JSON/Markdown reports.
- [ ] Add Paperclip and Hermes adapters over the stable JSON runtime boundary
  without moving organizational ownership into Relay.

## P2 — performance and operations

- [ ] Add true streaming event sinks for long-running missions; current chat JSONL
  is normalized after the AI SDK bridge returns.
- [ ] Add artifact rotation/compaction, retention policy, size metrics, and
  resumable export for `.relay` evidence.
- [ ] Add bounded parallel read-only discovery/evaluation while serializing writes
  and Git mutations.
- [ ] Record latency, token/cost, retry, queue, tool-duration, artifact-size, and
  provider-availability metrics through Watchdog/RunLedger contracts.
- [ ] Add model capability discovery and visible policy-aware routing explanations.
- [ ] Add deterministic doctor checks for upstream versions, Watchdog reachability,
  auth mode, provider profiles, and release-policy posture.

## P2 — presentation and adoption

- [ ] Add committed fixture transcripts, JSON Schemas for mission/run/event/report/
  doctor/probe contracts, and a generated architecture diagram backed by real
  artifacts.
- [ ] Add pinned-runtime installation paths for macOS/Linux/CI and a reproducible
  dependency doctor command.
- [ ] Add Fence, Concord, ShipCheck, and Eval release gates with badges only for
  verified local gates.
- [ ] Add a truthful showcase gallery covering chat, probe, bounded task,
  pause/resume, budget denial, worktree cleanup, store recovery, and Watchdog
  correlation.

## Definition of done for the next session

- [ ] All changed behavior has focused Kujo tests and the full local acceptance
  set remains green.
- [ ] At least one external provider is exercised through the real Watchdog
  server with authenticated correlation evidence.
- [ ] At least one isolated mission uses Agents SDK tools rather than only
  declarative Relay actions.
- [ ] Live, configured-live, fixture, and blocked evidence are separated in
  reports and docs.
- [ ] Changes are committed in small meaningful commits, pushed, and left clean.
