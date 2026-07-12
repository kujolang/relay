# Kujo Relay Next-Session Enhancement Backlog

This backlog is the next bounded work list after the 2026-07-11 enterprise-readiness review. Each item must add implementation, tests, documentation, and executable evidence. Do not mark an integration complete from an interface or fixture alone.

The follow-up reviews created the more specific current list at [`next-session-enhancement-backlog-2026-07-11-v13.md`](next-session-enhancement-backlog-2026-07-11-v13.md); keep this document as the original P0/P1/P2 baseline.

## P0 — Production proof and authority

- [ ] Add a Watchdog health/proxy adapter that validates `/healthz`, `/api/proxy-config`, and correlated `/api/requests` rows for a Relay run.
- [ ] Add live-provider smoke profiles for Ollama Cloud and one non-Ollama OpenAI-compatible provider, with opt-in credentials and redacted receipts.
- [ ] Replace declarative action execution with Agents SDK Tool Registry contracts, approval providers, guardrails, cancellation, and tool-result artifacts.
- [ ] Add automated Git worktree/workcell creation from an immutable starting commit, safe cleanup, rollback, and repository snapshot evidence.
- [ ] Add authenticated machine mode through the existing guarded MCP boundary; define identity, tenant, role, approval, and audit mappings.
- [ ] Add a durable run backend or locked file-store contract that supports concurrent runs, crash recovery, retention, and signed export.

## P1 — Ecosystem composition

- [ ] Load Spec task contracts and Dispatch workflow files without creating a competing schema.
- [ ] Attach mission, run, workflow, step, agent, model, provider, packet revision, tool, artifact, evaluation, retry, and repair IDs to every receipt.
- [ ] Integrate CaseFile for failed runs and Redact for prompt, tool, report, and handoff sanitization.
- [ ] Implement typed failure classes with bounded retry, fallback, repair, escalation, and regression evaluation receipts.
- [ ] Finish Capsule A/B benchmark execution for Model A context generation and Model B implementation, with comparable JSON/Markdown Eval reports.
- [ ] Add Paperclip and Hermes adapters that use the JSON runtime contract and preserve organizational versus execution ownership boundaries.

## P2 — Performance and operations

- [ ] Move the Agents SDK smoke check to configurable startup/release validation rather than every mission run.
- [ ] Add bounded parallel read-only discovery/evaluation while serializing writes and Git mutations.
- [ ] Add a streaming event sink/API and event rotation/compaction for large runs.
- [ ] Add token, cost, latency, retry, queue, tool-duration, artifact-size, and provider-availability metrics.
- [ ] Add configurable output-size limits, retention policies, and deterministic cleanup reports.
- [ ] Add model capability discovery, policy-aware routing, and visible fallback explanations.

## P2 — Presentation and adoption

- [ ] Add an installation guide for pinned Kujo runtime builds and dependency path configuration.
- [ ] Add a command reference with JSON schemas and exit-code contracts.
- [ ] Add a `doctor` command that checks runtime paths, upstream versions, Watchdog reachability, provider configuration, and policy posture.
- [ ] Add a generated architecture diagram and one end-to-end transcript backed entirely by committed fixture artifacts.
- [ ] Add release badges only for verified local gates; do not imply universal enterprise certification.

## Definition of done for the next session

- All changed behavior has focused Kujo tests.
- The full local verification matrix passes.
- Live tests are clearly separated from fixture tests and preserve redacted evidence.
- At least one real isolated repository mission uses Agents SDK tools and Watchdog telemetry.
- README, integration matrix, architecture decisions, and final engineering report agree with the evidence.
- Changes are committed in small meaningful commits, pushed to the configured remote, and the working tree is clean.
