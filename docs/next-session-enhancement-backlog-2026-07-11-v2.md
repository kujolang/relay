# Kujo Relay next-session enhancement backlog — review 2

This is the follow-on list from the second enterprise-readiness review. It records the remaining work required to move Relay from a polished local alpha toward a broadly useful, enterprise-capable Kujo showcase. Every checked item must have implementation, focused tests, documentation, and executable evidence; interfaces and fixtures alone do not close an item.

## Completed in this review

- [x] Fail closed when live AI is requested without `RELAY_WATCHDOG_URL`.
- [x] Disable wholesale subprocess environment inheritance and pass only explicit variables.
- [x] Redact runtime command receipts and expand common provider-key redaction coverage.
- [x] Quote repository paths before generating Eval shell checks.
- [x] Use atomic text writes for state, prompts, reports, and repository file actions.
- [x] Enforce mission `max_steps`, `max_repairs`, and `max_tokens` budget fields.
- [x] Add `doctor --json`, `models probe`, explicit `--skip-agent-smoke`, and budget smoke coverage.
- [x] Document the intentional Kujo root layout and stable command/JSON surface.
- [x] Add detached worktree provisioning from an immutable commit with explicit confirmed cleanup.

## P0 — authority, isolation, and live proof

- [ ] Add a Watchdog health/proxy adapter that validates `/healthz`, `/api/proxy-config`, and correlated `/api/requests` rows for a Relay run; fail live preflight when telemetry correlation is absent.
- [ ] Add opt-in live smoke profiles for Ollama Cloud and one other OpenAI-compatible provider, with credentials supplied only through the bounded process environment and redacted receipts.
- [ ] Replace declarative action execution with Agents SDK Tool Registry contracts, approval providers, guardrails, cancellation, and tool-result artifacts while preserving the current policy boundary during migration.
- [ ] Extend worktree mode into a full workcell with rollback-on-failure, stronger isolation, and cleanup/recovery after crashes.
- [ ] Add authenticated machine mode through the existing guarded MCP boundary with identity, tenant, role, approval, and audit mappings.
- [ ] Add a locked or database-backed run store with concurrent-run tests, crash recovery, retention, tamper-evident export, and deterministic index rebuild.

## P1 — ecosystem composition and recovery

- [ ] Load Spec task contracts and Dispatch workflow files with schema/version negotiation rather than introducing a competing workflow format.
- [ ] Attach mission, run, workflow, step, agent, model, provider, packet revision, tool, artifact, evaluation, retry, and repair IDs to every RunLedger receipt and event.
- [ ] Integrate CaseFile for failed-run bundles and Redact for prompt, tool, report, packet, and handoff sanitization.
- [ ] Implement typed failure classes with bounded retry, provider fallback, repair, escalation, and regression-evaluation receipts.
- [ ] Finish Capsule A/B execution: Model A context generation, fresh Model B comprehension/implementation, repeatable comparison, and JSON/Markdown Eval reports.
- [ ] Add Paperclip and Hermes adapters over the JSON runtime contract without moving organizational ownership into Relay.

## P2 — performance, operations, and scale

- [ ] Add command output budgets and explicit truncation policy tests; preserve incomplete-evidence markers in all reports.
- [ ] Add streaming event sinks, rotation/compaction, retention, and artifact-size metrics for large missions.
- [ ] Add bounded parallel read-only discovery/evaluation while serializing writes and Git mutations.
- [ ] Record latency, token/cost, retry, queue, tool-duration, artifact-size, and provider-availability metrics through Watchdog/RunLedger contracts.
- [ ] Add model capability discovery and visible policy-aware routing explanations.
- [ ] Add deterministic doctor checks for upstream version compatibility, Watchdog reachability, provider profiles, and release-policy posture.

## P2 — presentation and adoption

- [ ] Add committed fixture transcripts and a generated architecture diagram backed by actual artifacts.
- [ ] Add JSON Schemas for mission, run, event, report, doctor, and probe responses; test them in CI.
- [ ] Add pinned-runtime installation paths for macOS/Linux/CI and a reproducible dependency doctor command.
- [ ] Add Fence, Concord, ShipCheck, and Eval release gates with badges only for verified local gates.
- [ ] Add a small showcase gallery of truthful workflows: chat, probe, bounded task, pause/resume, budget denial, and Capsule blocker reporting.

## Next-session definition of done

- [ ] All changed behavior has focused Kujo tests and no regression in the local acceptance set.
- [ ] README, command reference, integration matrix, ADRs, enterprise review, and final report agree with executable evidence.
- [ ] At least one real isolated repository mission uses Agents SDK tools and Watchdog telemetry.
- [ ] Live evidence is clearly separated from fixture and configured-live evidence.
- [ ] Changes are committed in small meaningful commits, pushed, and left clean.
