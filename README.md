# Kujo Relay

Kujo Relay is a Kujo-native composition and execution layer for bounded agent missions. The CLI is a thin wrapper over reusable runtime modules. It composes existing AI SDK, Agents SDK, PackWrite, RunLedger, ChangeBucket, Eval, Capsule, and Chain of Command contracts instead of replacing them.

Status: `0.1.0` hardened local alpha. Offline execution, bounded repository work, resumable checkpoints, packet integrity metadata, redacted subprocess evidence, explicit environment isolation, budgets, and deterministic evaluation are verified locally. Relay is not yet enterprise-production-ready or universally useful: live provider/Watchdog proof, authenticated multi-tenant operation, worktree provisioning, full Agents SDK tool execution, durable concurrent storage, and release gates remain open.

## Enterprise-readiness position

Relay is a strong Kujo showcase and a safe local foundation, not a universal enterprise platform. Enterprise adoption requires environment-specific validation for identity, tenancy, network egress, secret custody, retention, concurrency, disaster recovery, provider SLAs, and approval governance. The current implementation intentionally fails closed for unsafe paths, shell metacharacters, destructive Git operations, unapproved writes, invalid workspaces, missing PackWrite/Agents SDK/AI evidence, and failed ChangeBucket/Eval evidence.

## Quick start

```bash
export KUJO_BIN=/Users/robertdevore/2026/Kujolang/kujo-repos/kujo/target/release/kujo
./bin/relay doctor --json
./bin/relay agents validate --json
./bin/relay chat "Summarize the mission boundary" --fixture --json
./bin/relay models probe fixture-model --fixture --json
./bin/relay chat "Stream a short answer" --fixture --stream
```

Run a real bounded repository mutation in a disposable isolated Git workspace:

```bash
git init /tmp/relay-fixture-workspace
git -C /tmp/relay-fixture-workspace config user.email relay@example.invalid
git -C /tmp/relay-fixture-workspace config user.name Relay
touch /tmp/relay-fixture-workspace/README.md
git -C /tmp/relay-fixture-workspace add README.md
git -C /tmp/relay-fixture-workspace commit -m baseline
./bin/relay missions run examples/fixture-mission.json --fixture --json
./bin/relay runs list --json
```

The run writes a PackWrite agent pack, AgentEvent-compatible JSONL, RunLedger receipt, ChangeBucket result, Eval result, resumable state, and Markdown/JSON reports under `.relay/runs/<run-id>/`.

## Provider configuration

Relay uses the AI SDK provider boundary through `src/ai_bridge.kujo`. Fixture mode is default for safe local operation. A live call requires a configured OpenAI-compatible endpoint and key:

```bash
export RELAY_OFFLINE_FIXTURE=false
export RELAY_WATCHDOG_URL=http://127.0.0.1:7700/proxy/v1
export OPENAI_API_KEY=...
./bin/relay chat "hello" --model gpt-4.1-mini --provider openai-compatible --json
```

For Ollama Cloud or another compatible service, keep the provider-specific details in the AI SDK-compatible endpoint configuration. Relay does not interpret vendor response formats. `RELAY_WATCHDOG_URL` is mandatory for live calls; Relay fails closed instead of silently bypassing Watchdog. Fixture mode explicitly records `direct_ai_sdk` as a deterministic no-network bypass.

## CLI surface

Implemented and truthful in this slice:

- `chat`, including normalized stream events and JSON output
- `models list|inspect|probe`
- `agents list|inspect|validate`
- `doctor`, including dependency, agent-registry, live-route, and credential posture checks
- `missions create|run|inspect|pause|resume|cleanup|report`
- `runs list|inspect|events|changes|evaluations`
- `benchmark run` for the Capsule discovery slice

`missions run` accepts explicit `budgets.max_steps`, `budgets.max_repairs`, and `budgets.max_tokens`. The default Agents SDK aggregate smoke can be skipped for a deliberately configured run with `--skip-agent-smoke`; the run records that it was skipped. Not yet implemented: adaptive routing, model-generated tool plans, full multi-step Dispatch workflow loading, interactive approval UI, live Ollama Cloud proof, authenticated service mode, automated worktree provisioning, durable concurrent storage, and the complete Capsule A/B benchmark rubric. Those remain explicit follow-up work rather than placeholder commands.

## Safety boundary

Mission actions are declarative and policy checked. Write-enabled missions require `allow_writes: true` plus `approval.approved: true`; paths must remain inside the real workspace and cannot traverse `.git`, `.env`, or symlinked parents. Commands must match an explicit allowlist and deny shell expansion, metacharacters, destructive Git operations, credential paths, force-push, and traversal patterns. Subprocesses run with an explicit bounded environment instead of inheriting the host environment wholesale; stdout/stderr and command receipts are redacted before evidence persistence. Relay does not expose unrestricted shell, root, credential files, publishing, or production access.

## Repository map

- `main.kujo`: thin CLI entrypoint
- `src/runtime.kujo`: mission state machine, actions, evidence, resume
- `src/adapters.kujo`: subprocess adapters to existing Kujo tools and AI SDK
- `src/contracts.kujo`: Relay run and AgentEvent-compatible contracts
- `src/policy.kujo`: authority and failure classification
- `src/registry.kujo`: Chain of Command role registry
- `docs/`: discovery report, integration matrix, ADRs, plan, final report
- `tests/relay_contract_tests.kujo`: deterministic contract tests
- `tests/relay_cli_smoke.sh`: CLI, doctor, probe, and approval-boundary smoke test
- `tests/relay_mission_smoke.sh`: real write, pause/resume, ChangeBucket, Eval, and RunLedger smoke test
- `tests/relay_budget_smoke.sh`: bounded step-budget failure smoke test
- `tests/relay_worktree_smoke.sh`: isolated worktree creation, source protection, and confirmed cleanup smoke test

## Repository layout decision

The small root is intentional and follows mature Kujo conventions: `main.kujo` is the executable entrypoint, `kujo.toml` is package metadata, and `bin/relay` is a thin launcher. Runtime implementation belongs under `src/`; moving the entrypoint or package manifest there would make the repository less idiomatic and break the documented CLI shape.

## Verification

The local acceptance set is:

```bash
export KUJO_BIN=/Users/robertdevore/2026/Kujolang/kujo-repos/kujo/target/release/kujo
"$KUJO_BIN" run tests/relay_contract_tests.kujo --interpreter
bash tests/relay_cli_smoke.sh
bash tests/relay_mission_smoke.sh
bash tests/relay_budget_smoke.sh
bash tests/relay_worktree_smoke.sh
git diff --check
```

For the full integration evidence boundary and deferred enterprise work, see [`docs/enterprise-readiness-review-2026-07-11.md`](docs/enterprise-readiness-review-2026-07-11.md), [`docs/command-reference.md`](docs/command-reference.md), and [`docs/next-session-enhancement-backlog-2026-07-11-v2.md`](docs/next-session-enhancement-backlog-2026-07-11-v2.md).
