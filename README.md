# Kujo Relay

Kujo Relay is a Kujo-native composition and execution layer for bounded agent missions. The CLI is a thin wrapper over reusable runtime modules. It composes existing AI SDK, Agents SDK, PackWrite, RunLedger, ChangeBucket, Eval, Capsule, and Chain of Command contracts instead of replacing them.

Status: `0.1.0` hardened local alpha. Offline execution, bounded repository work, bounded mission-spec inputs, bounded JSON evidence parsing, bounded AI/Agents SDK/tool bridge payloads, bounded provider request/response sizes, bounded provider tool arguments and unique tool-call IDs, hash-pinned repository script execution, validated and secret-safe live Watchdog route posture with HTTPS required for non-loopback hosts, non-disclosing Watchdog route posture in diagnostics and AI telemetry, bounded safe correlation IDs, dependency-integrity doctor checks that reject unsafe required files and symlinked executables, deterministic upstream version probes and optional SHA-256 dependency pinning in `doctor --json`, dangerous dynamic-loader/interpreter/Git/proxy override credential environment names rejected before bridge spawn, explicit cancellation/timeout failure classes in action evidence, bounded JSONL event/receipt evidence, race-safe concurrent store probes, descendant-safe cancellation through the Kujo process-group runtime, trusted Agents SDK worker-root binding, trusted in-tree AI bridge source enforcement, integrity-bound run state, resume, pause, cancel, and worktree cleanup controls, fail-closed evidence persistence, required ChangeBucket/Eval/report artifact verification, RunLedger finish authority before completion, state-store symlink rejection across parent path components, identity-bound sealed cancellation requests, cooperative mission cancellation, symlink-safe evidence reads that fail closed on probe errors and preserve dangling-symlink detection, structured credential/token/private-key redaction in persisted evidence, incremental bounded `runs watch` event parsing with append-prefix and disappearance integrity checks, change-triggered chain validation, context-rich sealed RunLedger receipts, bounded adapter duration metrics, read-only run artifact size inventory with a directory-depth bound, redacted subprocess evidence, explicit environment isolation, fixed executable search paths, shell-free command execution with exact read-only Git argv profiles, bounded lock backoff with contention evidence, cache-consistent run-index metadata with single-scan registration, failure-aware model fallback, budgets, deterministic evaluation, detached worktree missions, locked/self-healing run-index rebuilds, complete event-sequence verification, verified paged event inspection with cursor metadata, integrity-verified event export, required persisted receipt/state evidence for inspection and export, machine-readable JSON Schemas including `event-bundle` and `tool-result-bundle`, opt-in provider-generated tool planning through the existing Watchdog/AI SDK/Agents SDK path, bounded multi-turn provider tool execution with persisted typed results, and one aggregate acceptance runner covering all local smokes are verified locally. Relay is not yet enterprise-production-ready or universally useful: external live-provider proof, authenticated multi-tenant operation, full workcell isolation/recovery, durable concurrent storage, and release gates remain open.

The current review also makes JSON/JSONL reads and appends, cancellation
requests, and live event watching metadata-first for symlink safety. `runs watch`
reuses the event-file existence result within each poll, while dangling event
links fail immediately instead of being treated as missing files.

The current review adds verified `runs events --limit ... --after ...` windows
for machine callers. Relay validates the complete event chain and authoritative
state sequence before slicing a response; paged output is described by the
versioned [`event-bundle` schema](schemas/event-bundle.schema.json). Cancellation
requests now carry the target run ID and a tamper-evident seal, so copied,
stale-format, or modified request files fail closed.

The v67 review adds a hard provider request boundary below the bridge transport
ceiling, a 1 MiB provider-response bound, duplicate/oversized provider-tool
argument rejection, proxy-environment denial at child-process boundaries, and
8 MiB caps on persisted event and receipt evidence. PackWrite completion now
requires a safe generated `agent/MASTER.md` artifact before mission preflight
can pass. These are local resource and authority safeguards; they do not
replace durable storage, authenticated tenancy, or live-provider compatibility
proof.

The v64 review hardens the Agents SDK worker capability with a short-lived
nonce that is not derivable from public run and workspace identifiers, keeps
child-process `PATH` fixed while dropping unsafe environment overrides, rejects
repository and tool-workspace parent symlink components, exposes subprocess
`exit_code` in action evidence, and expands failure classification for policy,
workflow, permission, malformed-tool, invalid-model, missing-context,
implementation, and evaluation failures. These are locally tested safeguards;
they do not replace authenticated remote authorization or a durable workcell.

Sibling Kujo-tool subprocesses also receive an aligned `PWD` and module-path
context. Relative `KUJO_BIN` and sibling-tool overrides are rooted at the
Relay checkout before a subprocess changes cwd, so the same mission works from
the Loop Engineering harness and direct shell launch. This keeps PackWrite,
RunLedger, ChangeBucket, and doctor probes from resolving Relay's modules or
losing their executable merely because the caller launched Relay from a
different working directory.

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
- `models list|inspect|probe`; model profiles expose chat/streaming capabilities and the environment profile advertises opt-in provider tool planning through the AI SDK
- `agents list|inspect|validate`
- `doctor`, including dependency identity/version, agent-registry, secret-safe live-route posture, and credential checks
- `missions create|run|inspect|pause|resume|cancel|cleanup|report`; cancellation is cooperative and recorded as run evidence
- `runs list|rebuild|inspect|verify|events|watch|sizes|changes|evaluations|export`; `list` and `events` support bounded validated cursor windows, `verify` provides a compact machine-readable evidence verdict, while event reads and exports verify the integrity chain, typed receipt index, and required result/report artifacts; provider-generated runs also require the sealed `tool-results.json` bundle; `runs export --partial` is an explicit non-valid bundle for paused/failed runs
- `benchmark run` for the Capsule discovery slice

`missions run` accepts explicit step, repair, token, output, write, tool-call, and tool-turn budgets. A mission can set `agent_tools` to bounded `relay.write_file` or `relay.run_command` calls; the Agents SDK registry and approval provider execute them through Relay's policy worker, and the run records the result. For provider-generated planning, set `agent_tool_mode` to `provider` and explicitly list the allowed tools in `agent_tool_allowlist`; the AI SDK request carries only those schemas, each provider response is normalized, and Agents SDK still executes every call through the same policy worker. Bounded follow-up turns send typed `role: tool` results back through Watchdog and persist `tool-results.json` under the run directory. `bash`/`sh` repository actions additionally require exact `allowed_script_hashes` entries. Cancellation, malformed responses, approval denial, tool-call limits, and tool-turn limits fail closed. The default Agents SDK aggregate smoke can be skipped for a deliberately configured run with `--skip-agent-smoke`; the run records that it was skipped. Not yet implemented: adaptive routing, full multi-step Dispatch workflow loading, interactive approval UI, live Ollama Cloud proof, authenticated service mode, full workcell recovery, durable concurrent storage, and the complete Capsule A/B benchmark rubric. Those remain explicit follow-up work rather than placeholder commands.

## Safety boundary

Mission actions are declarative and policy checked. Write-enabled missions require `allow_writes: true` plus `approval.approved: true`; paths must remain inside the real workspace and cannot traverse `.git`, `.env`, or symlinked parents. Commands must match an explicit allowlist, reject shell syntax, and execute as direct argv without `/bin/sh`; destructive Git operations, credential paths, force-push, and traversal patterns are denied. Subprocesses run with an explicit bounded environment instead of inheriting the host environment wholesale; provider credential selectors also reject dynamic-loader, interpreter-injection, Git override, and trust-store override names before the AI bridge is spawned. stdout/stderr and command receipts are redacted before evidence persistence. Relay does not expose unrestricted shell, root, credential files, publishing, or production access.

Read-side evidence is also fail closed: report JSON must match the authoritative
run and status, report Markdown must exist as a bounded regular file, the run
index cannot substitute placeholder metadata for missing state, and artifact
inventory rejects oversized directories before recursive flattening.

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
- `schemas/`: machine-readable mission, run, event, receipt, doctor, probe, tool-result, run-verification, and run-sizes contracts
- `tests/relay_contract_tests.kujo`: deterministic contract tests
- `tests/relay_acceptance.sh`: contract suite plus every committed smoke test and `git diff --check`
- `tests/relay_cli_smoke.sh`: CLI, doctor, probe, normalized boolean-environment, AI-bridge source-boundary, approval-boundary, and Watchdog-route telemetry non-disclosure smoke test
- `tests/relay_mission_smoke.sh`: real write, pause/resume, required ChangeBucket/Eval/report persistence, and RunLedger smoke test
- `tests/relay_budget_smoke.sh`: bounded step-budget failure smoke test
- `tests/relay_worktree_smoke.sh`: isolated worktree creation, source protection, and confirmed cleanup smoke test
- `tests/relay_store_smoke.sh`: bounded-index/run-list paging, missing-state cache rejection, report identity/Markdown validation, event-symlink, receipt-tamper, truncation, and authoritative run-state rebuild smoke test
- `tests/relay_lock_stress_smoke.sh`: bounded index-lock backoff and concurrent rebuild smoke test
- `tests/relay_watch_smoke.sh`: bounded live event observation with terminal evidence verification
- `tests/relay_watch_integrity_smoke.sh`: fail-closed event-log disappearance observation
- `tests/relay_metrics_smoke.sh`: bounded AI/adapter duration telemetry evidence
- `tests/relay_sizes_smoke.sh`: bounded artifact size inventory, optional SHA-256 digests, symlink rejection, and directory-depth denial
- `tests/relay_cancel_smoke.sh`: process-group cancellation, bounded return time, and terminal evidence
- `tests/relay_timeout_smoke.sh`: process-group timeout termination, bounded return time, and typed timeout evidence
- `tests/relay_spec_safety_smoke.sh`: mission-spec size, input symlink, and repository parent-symlink rejection
- `tests/relay_schema_smoke.sh`: committed JSON Schema parse, identity, and title checks
- `tests/relay_output_budget_smoke.sh`: bounded command evidence and explicit truncation smoke test
- `tests/relay_watchdog_smoke.sh`: configured Watchdog health/config/request-correlation contract smoke test
- `tests/relay_watchdog_real_smoke.sh`: actual local Watchdog server, token auth, stub upstream, and correlation smoke test
- `tests/relay_agents_tool_smoke.sh`: isolated mission, nonce-bound capability and legacy rejection, denied-write approval, direct-worker approval/budget/timeout rejection, worker-output redaction, and tampered worker-root rejection
- `tests/relay_provider_tool_smoke.sh`: authenticated local Watchdog, bounded multi-turn provider-generated tool planning, typed result persistence, Agents SDK execution, and evidence-backed repository mutation
- `tests/relay_resume_integrity_smoke.sh`: tampered paused-run workspace and mission-policy rejection before resume
- `tests/relay_state_store_safety_smoke.sh`: state-root and runs-directory symlink redirection rejection
- `tests/relay_symlink_probe_smoke.sh`: dangling-symlink and probe-error rejection at the shared filesystem boundary
- `tests/relay_relative_tool_path_smoke.sh`: relative `KUJO_BIN` normalization through PackWrite, RunLedger, ChangeBucket, and Eval
- `tests/relay_input_boundary_smoke.sh`: bounded and malformed AI, Agents SDK, and tool-worker payload rejection
- `tests/relay_contract_tests.kujo`: contract coverage for bounded JSON/JSONL evidence, hash-pinned scripts, provider payload/tool-ID limits, proxy-environment denial, and retryable versus non-retryable fallback classes

## Repository layout decision

The small root is intentional and follows mature Kujo conventions: `main.kujo` is the executable entrypoint, `kujo.toml` is package metadata, and `bin/relay` is a thin launcher. Runtime implementation belongs under `src/`; moving the entrypoint or package manifest there would make the repository less idiomatic and break the documented CLI shape.

## Verification

The local acceptance set is:

```bash
export KUJO_BIN=/Users/robertdevore/2026/Kujolang/kujo-repos/kujo/target/release/kujo
bash tests/relay_acceptance.sh
```

The aggregate runner executes the contract suite, all committed `*_smoke.sh`
tests, the schema smoke, and `git diff --check`, so new smoke coverage is
automatically included without maintaining a second hand-written test list.

For the full integration evidence boundary and deferred enterprise work, see [`docs/enterprise-readiness-review-2026-07-11.md`](docs/enterprise-readiness-review-2026-07-11.md), [`docs/command-reference.md`](docs/command-reference.md), the machine contracts in [`schemas/`](schemas/), and the current [`docs/next-session-enhancement-backlog-2026-07-13-v69.md`](docs/next-session-enhancement-backlog-2026-07-13-v69.md).
