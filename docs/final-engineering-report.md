# Final Engineering Report

## What was discovered

Kujo already has nearly all important primitives: AI SDK provider normalization, Agents SDK contracts for agents/tools/approvals/budgets/events, Watchdog proxy telemetry, PackWrite packet compilation, RunLedger receipts, ChangeBucket diff analysis, Eval deterministic checks, Dispatch workflow state, Capsule discovery, Chain of Command roles, and Loop Engineering stop rules. The missing piece was a small composition runtime with a stable machine-facing boundary.

## What was reused and newly built

Reused directly: AI SDK normalized responses and fixture behavior, PackWrite CLI/validator, RunLedger CLI/records, ChangeBucket JSON, Eval config/checks, Capsule CLI shape, Chain of Command role locations, and AgentEvent-compatible field names. Newly built: Relay mission/run state, adapter boundary, policy-checked declarative actions, evidence aggregation, report surface, and CLI routing.

Deliberately not built: another provider client, another general workflow engine, another telemetry database, another packet schema, unrestricted shell access, adaptive model router, or a fake claim of live Ollama/Watchdog success.

## Verification

Passed locally with the pinned Kujo release runtime:

- `kujo run tests/relay_contract_tests.kujo --interpreter`
- fixture `relay chat` JSON and normalized stream output
- fixture mission with real write to `/tmp/relay-fixture-workspace`
- Agents SDK offline aggregate smoke executed as part of the mission and recorded in run state
- PackWrite generated and validated 13 artifacts
- RunLedger recorded a pass with starting commit and changed-file count
- ChangeBucket recorded the added file
- Eval passed `git diff --check`
- generated Eval config also checks that each declared `write_file` action produced a file
- six AgentEvent-compatible lifecycle/artifact/tool/evaluation events were persisted
- pause/resume path persisted a resumable checkpoint and completion report

Not proven in this local session: live Ollama Cloud, live Watchdog proxy telemetry, multi-model Capsule A/B implementation scoring, Paperclip/Hermes invocation, and container/microVM-grade workcell isolation. Detached Git worktree provisioning and explicit cleanup are now proven locally, but rollback-on-failure and crash recovery remain open. These are known limitations, not successful integrations.

## Ecosystem recommendations

1. Publish a supported cross-repository Kujo package/dependency mechanism so composition layers do not need subprocess adapters.
2. Add a single Agents SDK mission/workflow loader that can consume Chain of Command role metadata without product-specific prompt flattening.
3. Add a Watchdog client library or health/telemetry correlation contract for local Kujo runtimes.
4. Add RunLedger correlation fields for mission, workflow, step, packet revision, tool call, artifact, and evaluation IDs.
5. Add PackWrite packet revision/hash fields and an offline compiler mode with a first-class fixture flag.
6. Add ChangeBucket and Eval library APIs in addition to their CLIs for composition runtimes.

## Known limitations

The current run engine accepts explicit action plans instead of allowing an Agents SDK model to request tools. Agent roles are loaded as a small registry, not dynamically resolved from all Chain of Command definitions. Resume currently supports the explicit post-plan checkpoint only; arbitrary interrupted-step replay and failure-repair flows require follow-up integration work. Live Watchdog/Ollama remains unverified.

## 2026-07-11 enterprise-readiness review

The current posture is local-first hardened alpha/showcase, not universal enterprise production. This review added realpath workspace checks, shell/Git command deny rules, explicit write approvals, subprocess redaction, packet digest metadata, unique run suffixes, preflight failure handling, ChangeBucket/Eval completion authority, atomic JSON persistence, efficient JSONL append, generated file-existence acceptance checks, shared Capsule process handling, and a real pause-after-plan/resume checkpoint. See `docs/enterprise-readiness-review-2026-07-11.md` and `docs/next-session-enhancement-backlog.md` for the evidence boundary and prioritized remaining work.

## Second 2026-07-11 review

The follow-up review preserved the alpha boundary and added fail-closed live Watchdog routing, explicit subprocess environment allowlists, provider-key environment validation, atomic mission writes, output-truncation evidence fields, configurable mission budgets, an explicit Agents SDK smoke skip with receipt, detached worktree provisioning with confirmed cleanup, `doctor --json`, `models probe`, budget and worktree regression smokes, a command reference, and a versioned next-session backlog. The root layout was re-audited and remains intentionally conventional: `main.kujo`, `kujo.toml`, and `bin/relay` are necessary entry/package/launcher files; runtime behavior remains under `src/`. This review is committed as `7dd7cea`, `b0d1712`, and `f2c414e`, pushed to `origin/main`. See `docs/enterprise-readiness-review-2026-07-11.md`, `docs/command-reference.md`, and `docs/next-session-enhancement-backlog-2026-07-11-v2.md`.

## Repository handoff

The review hardening is committed as `b21ef02` (`Loop engineering: Build and verify the Kujo Relay composition runtime vertical slice`) and is pushed to the configured `origin/main`. The working tree is clean. The next session should preserve this evidence boundary rather than widening claims.
