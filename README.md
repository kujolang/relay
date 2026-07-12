# Kujo Relay

Kujo Relay is a Kujo-native composition and execution layer for bounded agent missions. The CLI is a thin wrapper over reusable runtime modules. It composes existing AI SDK, Agents SDK, PackWrite, RunLedger, ChangeBucket, Eval, Capsule, and Chain of Command contracts instead of replacing them.

Status: `0.1.0` hardened local alpha. Offline execution, bounded repository work, resumable checkpoints, packet integrity metadata, sealed typed evidence receipts, live bounded `runs watch` event observation, bounded adapter duration metrics, redacted subprocess evidence, explicit environment isolation, fixed executable search paths, shell-free command execution with exact read-only Git argv profiles, bounded lock backoff with contention evidence, budgets, deterministic evaluation, detached worktree missions, locked/self-healing run-index rebuilds, complete event-sequence verification, integrity-verified event export, real local Watchdog correlation, and one isolated fixture mission using the Agents SDK Tool Registry are verified locally. Relay is not yet enterprise-production-ready or universally useful: external live-provider proof, authenticated multi-tenant operation, full workcell isolation/recovery, provider-driven tool execution, durable concurrent storage, and release gates remain open.

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
./bin/relay runs rebuild --json
```

The run writes a PackWrite agent pack, AgentEvent-compatible JSONL, sealed `RelayReceipt` index, RunLedger receipt, ChangeBucket result, Eval result, resumable state, and Markdown/JSON reports under `.relay/runs/<run-id>/`.

## Provider configuration

Relay uses the AI SDK provider boundary through `src/ai_bridge.kujo`. Fixture mode is default for safe local operation. A live call requires a configured OpenAI-compatible endpoint and key:

```bash
export RELAY_OFFLINE_FIXTURE=false
export RELAY_WATCHDOG_URL=http://127.0.0.1:7700/proxy/v1
export RELAY_WATCHDOG_PROXY_TOKEN=... # when Watchdog proxy auth is enabled
export RELAY_WATCHDOG_API_TOKEN=... # when Watchdog API auth is enabled
export RELAY_WATCHDOG_VERIFY=true
export OPENAI_API_KEY=...
./bin/relay chat "hello" --model gpt-4.1-mini --provider openai-compatible --json
```

For Ollama Cloud or another compatible service, keep the provider-specific details in the AI SDK-compatible endpoint configuration. Relay does not interpret vendor response formats. `RELAY_WATCHDOG_URL` is mandatory for live calls; Relay fails closed instead of silently bypassing Watchdog. Set `RELAY_WATCHDOG_VERIFY=true` when authenticated health/config/request correlation is required. Fixture mode explicitly records `direct_ai_sdk` as a deterministic no-network bypass.

## CLI surface

Implemented and truthful in this slice:

- `chat`, including normalized stream events and JSON output
- `models list|inspect|probe`
- `agents list|inspect|validate`
- `doctor`, including dependency, agent-registry, live-route, and credential posture checks
- `missions create|run|inspect|pause|resume|cleanup|report`; mission specs may opt into the bounded `agent_tools` bridge
- `runs list|rebuild|inspect|events|changes|evaluations|export`; event reads and exports verify the integrity chain and typed receipt index
- `benchmark run` for the Capsule discovery slice

`missions run` accepts explicit step, repair, token, output, and write budgets. A mission can set `agent_tools` to bounded `relay.write_file` or `relay.run_command` calls; the Agents SDK registry and approval provider execute them through Relay's policy worker, and the run records the result. The default Agents SDK aggregate smoke can be skipped for a deliberately configured run with `--skip-agent-smoke`; the run records that it was skipped. Not yet implemented: provider-driven model tool planning, adaptive routing, full multi-step Dispatch workflow loading, interactive approval UI, live Ollama Cloud proof, authenticated service mode, full workcell recovery, durable concurrent storage, and the complete Capsule A/B benchmark rubric. Those remain explicit follow-up work rather than placeholder commands.

## Safety boundary

Mission actions are declarative and policy checked. Write-enabled missions require `allow_writes: true` plus `approval.approved: true`; paths must remain inside the real workspace and cannot traverse `.git`, `.env`, or symlinked parents. Commands must match an explicit allowlist, reject shell syntax, and execute as direct argv without `/bin/sh`; destructive Git operations, credential paths, force-push, and traversal patterns are denied. Subprocesses run with an explicit bounded environment instead of inheriting the host environment wholesale; stdout/stderr and command receipts are redacted before evidence persistence. Relay does not expose unrestricted shell, root, credential files, publishing, or production access.

## Repository map

- `main.kujo`: thin CLI entrypoint
- `src/runtime.kujo`: mission state machine, actions, evidence, resume
- `src/adapters.kujo`: subprocess adapters to existing Kujo tools and AI SDK
- `src/agent_bridge.kujo`: Agents SDK Tool Registry and approval-provider bridge
- `src/contracts.kujo`: Relay run and AgentEvent-compatible contracts
- `src/policy.kujo`: authority and failure classification
- `src/store.kujo`: locked, validated/rebuildable run-index cache
- `src/registry.kujo`: Chain of Command role registry
- `docs/`: discovery report, integration matrix, ADRs, plan, final report
- `tests/relay_contract_tests.kujo`: deterministic contract tests
- `tests/relay_cli_smoke.sh`: CLI, doctor, probe, and approval-boundary smoke test
- `tests/relay_mission_smoke.sh`: real write, pause/resume, ChangeBucket, Eval, and RunLedger smoke test
- `tests/relay_budget_smoke.sh`: bounded step-budget failure smoke test
- `tests/relay_worktree_smoke.sh`: isolated worktree creation, source protection, and confirmed cleanup smoke test
- `tests/relay_store_smoke.sh`: tampered-index rejection and authoritative run-state rebuild smoke test
- `tests/relay_lock_stress_smoke.sh`: bounded index-lock backoff and concurrent rebuild smoke test
- `tests/relay_watch_smoke.sh`: bounded live event observation with terminal evidence verification
- `tests/relay_metrics_smoke.sh`: bounded AI/adapter duration telemetry evidence
- `tests/relay_output_budget_smoke.sh`: bounded command evidence and explicit truncation smoke test
- `tests/relay_watchdog_smoke.sh`: configured Watchdog health/config/request-correlation contract smoke test
- `tests/relay_watchdog_real_smoke.sh`: actual local Watchdog server, token auth, stub upstream, and correlation smoke test
- `tests/relay_agents_tool_smoke.sh`: isolated mission through the Agents SDK Tool Registry plus denied-write approval proof

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
bash tests/relay_store_smoke.sh
bash tests/relay_lock_stress_smoke.sh
bash tests/relay_watch_smoke.sh
bash tests/relay_metrics_smoke.sh
bash tests/relay_output_budget_smoke.sh
bash tests/relay_watchdog_smoke.sh
bash tests/relay_watchdog_real_smoke.sh
bash tests/relay_agents_tool_smoke.sh
git diff --check
```

For the full integration evidence boundary and deferred enterprise work, see [`docs/enterprise-readiness-review-2026-07-11.md`](docs/enterprise-readiness-review-2026-07-11.md), [`docs/command-reference.md`](docs/command-reference.md), and the current [`docs/next-session-enhancement-backlog-2026-07-11-v13.md`](docs/next-session-enhancement-backlog-2026-07-11-v13.md).
