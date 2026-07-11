# Kujo Relay next-session enhancement backlog — review 3

This backlog is the handoff from the third enterprise-readiness review. It keeps Relay honest about what is locally proven, what is only configured-live, and what still needs ecosystem or deployment evidence. Each item closes only with implementation, focused tests, documentation, and executable evidence.

Implementation baseline: `0e030ed` (`main`, pushed to `origin/main`).

## Completed in this review

- [x] Forward `chat --stream` through the AI SDK bridge and emit normalized JSONL `delta`/`done` events.
- [x] Forward an optional Watchdog proxy authorization header through a bounded environment seam without placing the token in the model payload or reports.
- [x] Restrict `kujo run` and targeted `kujo test` actions to workspace-local `.kujo` files; retain explicit read-only command policy.
- [x] Add mission-level positive `max_output_bytes` and `max_write_bytes` budgets capped at 8 MiB.
- [x] Bound `run_command` timeouts to 1 ms–10 minutes and preserve truncation markers in action evidence.
- [x] Treat per-run `state.json` as authoritative and rebuild malformed, unsafe, or incomplete `.relay/index.json` caches.
- [x] Add `runs rebuild`, store recovery coverage, stream/token isolation coverage, and output-budget/timeout coverage.
- [x] Reconcile README, command reference, ADRs, integration matrix, enterprise review, final report, and repository layout claims.

## P0 — live authority and isolation

- [x] Add a Watchdog health/proxy adapter that can verify `/healthz`, `/api/proxy-config`, and authenticated correlated `/api/requests` records for a Relay correlation ID; live proof remains environment-dependent.
- [x] Add a deterministic local Watchdog contract smoke with a Kujo HTTP stub, secret non-leakage assertions, and correlated live-route verification.
  - Evidence required: a local Watchdog server plus stub provider, authenticated request headers, matching request row, and failure when correlation is absent.
- [ ] Add opt-in Ollama Cloud and second-provider live smoke profiles.
  - Evidence required: credentials injected only through bounded environment variables, redacted receipts, usage telemetry, and provider-specific failure classification.
- [ ] Replace declarative action lists with the Agents SDK Tool Registry, approval providers, guardrails, cancellation, and tool-result artifacts while preserving the current Relay policy boundary.
- [ ] Extend detached worktrees into a workcell contract with rollback-on-failure, crash recovery, retention, and stronger process/filesystem/network isolation.
- [ ] Add authenticated machine mode through the guarded MCP boundary with identity, tenant, role, approval, and audit mappings.
- [ ] Replace the rebuildable index cache with a locked or database-backed run store supporting concurrent writers, crash recovery, retention, integrity verification, and deterministic export.

## P1 — ecosystem composition and correctness

- [ ] Load Spec task contracts and Dispatch workflows with schema/version negotiation; do not create a competing workflow format.
- [ ] Attach mission, run, workflow, step, agent, model, provider, packet revision, tool, artifact, evaluation, retry, and repair IDs to every event and RunLedger receipt.
- [ ] Integrate CaseFile for failed-run bundles and Redact for prompts, tools, packets, reports, and handoffs.
- [ ] Implement typed retry, fallback, repair, escalation, cancellation, and regression-evaluation receipts.
- [ ] Finish Capsule A/B execution with fresh Model B sessions, repeated runs, comparable Eval scoring, and JSON/Markdown reports.
- [ ] Add Paperclip and Hermes adapters over the stable JSON runtime boundary without moving organizational ownership into Relay.

## P2 — performance and operations

- [ ] Add true streaming event sinks for long-running missions; current chat JSONL is normalized after the AI SDK bridge returns.
- [ ] Add artifact rotation/compaction, retention policy, size metrics, and resumable export for `.relay` evidence.
- [ ] Add bounded parallel read-only discovery/evaluation while serializing writes and Git mutations.
- [ ] Record latency, token/cost, retry, queue, tool-duration, artifact-size, and provider-availability metrics through Watchdog/RunLedger contracts.
- [ ] Add model capability discovery and visible policy-aware routing explanations.
- [ ] Add deterministic doctor checks for upstream versions, Watchdog reachability/auth mode, provider profiles, and release-policy posture.

## P2 — presentation and adoption

- [ ] Add committed fixture transcripts, JSON Schemas for mission/run/event/report/doctor/probe contracts, and a generated architecture diagram backed by real artifacts.
- [ ] Add pinned-runtime installation paths for macOS/Linux/CI and a reproducible dependency doctor command.
- [ ] Add Fence, Concord, ShipCheck, and Eval release gates with badges only for verified local gates.
- [ ] Add a truthful showcase gallery covering chat, probe, bounded task, pause/resume, budget denial, worktree cleanup, store recovery, and Capsule blocker reporting.

## Definition of done for the next session

- [ ] All changed behavior has focused Kujo tests and the full local acceptance set remains green.
- [ ] A Watchdog-backed isolated mission has authenticated telemetry correlation evidence.
- [ ] At least one isolated mission uses Agents SDK tools rather than only declarative Relay actions.
- [ ] Live, configured-live, fixture, and blocked evidence are separated in reports and docs.
- [ ] Changes are committed in small meaningful commits, pushed, and left clean.
