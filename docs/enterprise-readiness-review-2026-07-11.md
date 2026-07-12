# Kujo Relay Enterprise-Readiness Review — 2026-07-11

## Executive conclusion

Relay is not production-ready in a universal enterprise-grade sense today. It is a credible, well-presented Kujo-native local foundation and a useful showcase of Kujo composition, but its current proof is fixture-first and single-workspace. Calling it universally production-ready would overstate the evidence.

The correct posture is: **local-first hardened alpha / ecosystem showcase**. The prior reviews landed in commits `7dd7cea`, `b0d1712`, `f2c414e`, `d7bd3f6`, and `862aff9`, pushed to `origin/main`; the previous audit is implemented in `0e030ed`, and this review extends local Watchdog proof without changing that release posture.

## Evidence reviewed

- Existing Relay history on `main`, clean working tree at the start of this review, configured `origin/main`.
- Kujo release runtime contract test.
- Fixture chat and stream output through the AI SDK bridge.
- Real bounded write to `/tmp/relay-fixture-workspace`.
- PackWrite validation, Agents SDK offline smoke, RunLedger receipt, ChangeBucket report, Eval result, AgentEvent JSONL, packet hash, and pause-after-plan/resume.
- Capsule adapter failure reproduced: `Symbol 'run_cli' not found in module 'src.cli'`.
- Existing ecosystem READMEs, source modules, tests, and workflow contracts.
- Second-review evidence: `doctor --json`, fixture `models probe`, fail-closed live-route check, budget failure smoke, all Relay `kujo check` targets, and expanded Loop Engineering gates.
- Additional audit evidence: stream option forwarding, Watchdog proxy-token header isolation, hardened `kujo run` path policy, tampered-index recovery, bounded output/write budgets, timeout validation, and new store/output-budget smokes.
- A Kujo Watchdog HTTP adapter with sanitized health/config/correlation verification, plus a real local Watchdog server and stub-provider smoke with token authentication.

## Enhancements made in this review

| Area | Change | Evidence |
|---|---|---|
| Path security | Canonical lexical containment, realpath parent checks, traversal/secret-directory rejection | `src/policy.kujo`, contract tests |
| Command security | Reject shell metacharacters, destructive Git, credential, force, and config/remote operations | `src/policy.kujo`, contract tests |
| Approval boundary | Write-enabled mission specs require explicit approval metadata | `src/runtime.kujo`, fixture mission |
| Evidence safety | Redact common bearer/API-key material from subprocess output | `src/common.kujo`, `src/adapters.kujo` |
| Packet integrity | Record revision and SHA-256 digest for `agent/MASTER.md` | mission `artifacts` state |
| Run uniqueness | Add random suffix to mission run IDs | `src/runtime.kujo` |
| Preflight correctness | Fail before repository actions when PackWrite, Agents SDK, AI, RunLedger, or token budget checks fail | `src/runtime.kujo` |
| Evaluation authority | Failed ChangeBucket or Eval evidence now fails the run | `src/runtime.kujo` |
| Resume correctness | `--pause-after-plan` creates a real checkpoint; resume executes pending actions and re-verifies evidence | mission run events/state |
| Event performance | JSONL uses `append_file` instead of rereading/rebuilding the whole file | `src/common.kujo` |
| State durability | JSON state writes use sibling temp files and rename into place | `src/common.kujo` |
| Acceptance coverage | Generated Eval config checks each declared file-write output in addition to `git diff --check` | `src/runtime.kujo`, mission smoke |
| Capsule adapter | Uses the shared process adapter and preserves truthful failure output | `src/adapters.kujo`, `src/cli.kujo` |
| Live-route safety | Live AI calls fail closed when Watchdog is not configured; provider-key environment names are validated | `src/adapters.kujo`, `src/doctor.kujo`, blocked-live smoke |
| Process isolation | Adapter subprocesses use explicit bounded environment allowlists instead of wholesale inheritance | `src/common.kujo`, contract tests |
| Atomic tool writes | Mission file actions and Markdown artifacts use sibling temp files plus rename | `src/common.kujo`, mission smoke |
| Budget enforcement | Mission specs can override step, repair, and token limits; action loops stop at `max_steps` | `src/runtime.kujo`, budget smoke |
| Operator onboarding | `doctor --json` and `models probe` expose truthful environment and model checks | `src/doctor.kujo`, CLI smoke |
| Presentation contract | README, command reference, root-layout explanation, and a versioned follow-up backlog document the evidence boundary | README, `docs/command-reference.md`, backlog v3 |
| Workspace isolation | `workspace_mode: worktree` provisions a detached worktree from an immutable commit; cleanup is explicit and confirmed | `src/runtime.kujo`, worktree smoke |
| Stream correctness | `chat --stream` forwards the stream option through the AI SDK bridge and emits normalized JSONL delta/done events | `src/ai_bridge.kujo`, `src/cli.kujo`, CLI smoke |
| Machine credential boundary | Watchdog proxy authorization is passed as a bounded header environment value and omitted from the model payload | `src/adapters.kujo`, `src/ai_bridge.kujo` |
| Run-index resilience | Per-run `state.json` is authoritative; malformed or incomplete index caches rebuild deterministically | `src/store.kujo`, store smoke |
| Resource bounds | Mission output/write budgets and command timeout bounds fail closed; truncation remains explicit | `src/runtime.kujo`, output-budget smoke |
| Watchdog evidence | Correlation is propagated through the AI SDK bridge; optional verification checks authenticated health, proxy config, and the matching request row without returning telemetry payloads | `src/watchdog.kujo`, `tests/relay_watchdog_smoke.sh`, `tests/relay_watchdog_real_smoke.sh` |
| Shell boundary | Allowlisted mission commands execute as direct argv without a shell; tabs, shell syntax, Git pathspecs, unknown options, and script arguments are rejected | `src/common.kujo`, `src/policy.kujo`, `src/runtime.kujo`, contract and mission smokes |
| Index concurrency | Atomic lock directory, bounded four-attempt backoff, stale-lock recovery, cache-size/symlink checks, and state/status freshness validation protect the rebuildable index | `src/store.kujo`, contract, store, and lock-stress smokes |
| Live observation | Bounded `runs watch` emits verified event records while a run is active and reconciles terminal state with the event file | `src/cli.kujo`, `tests/relay_watch_smoke.sh` |
| Performance evidence | Bounded AI bridge, tool, and evidence adapter calls expose non-negative duration measurements | `src/adapters.kujo`, `src/runtime.kujo`, `tests/relay_metrics_smoke.sh` |
| Event integrity | AgentEvent-compatible JSONL records carry deterministic SHA-256 integrity fields and tamper validation | `src/contracts.kujo`, contract smoke |
| Worktree cleanup authority | Cleanup rejects tampered paths and requires the run-owned workspace target | `src/runtime.kujo`, `tests/relay_worktree_smoke.sh` |
| Agents SDK tools | A Kujo bridge registers `relay.write_file` and `relay.run_command`, applies Agents SDK approval providers, and delegates to Relay's capability-bound policy worker | `src/agent_bridge.kujo`, `src/runtime.kujo`, `tests/relay_agents_tool_smoke.sh` |
| Process and evidence boundary | Fixed subprocess PATH, workspace-bound worker capabilities, bounded tool-call budgets, event-chain verification, and versioned run export | `src/common.kujo`, `src/agent_bridge.kujo`, `src/contracts.kujo`, `src/cli.kujo`, store/tool smokes |
| Evidence completeness | Event reads/exports compare the verified log sequence with authoritative state and enforce an 8 MiB inspection bound | `src/contracts.kujo`, `src/cli.kujo`, `tests/relay_store_smoke.sh` |

## Remaining enterprise gaps

### P0 — Must close before production claims

1. Live Watchdog proxy correlation and telemetry export against external configured providers; the local real-server/stub-provider proof is now complete.
2. Live Ollama Cloud and at least one other OpenAI-compatible provider smoke test.
3. Authenticated service/MCP boundary with identity, tenant, role, and approval mapping.
4. Full workcell isolation, rollback, and crash recovery beyond the now-proven detached Git worktree mode and confirmed cleanup.
5. Provider-driven Agents SDK tool planning and richer tool-result/artifact integration; a bounded Tool Registry and approval-provider bridge plus one isolated fixture mission are now proven.
6. Durable run store with database-backed retention/recovery, multi-host concurrency, and signed export; local tamper-evident event verification and unsigned versioned export are now proven.

### P1 — Required for broad enterprise usefulness

1. Dispatch/Spec workflow import with schema version negotiation.
2. CaseFile and Redact failure evidence integration.
3. Watchdog rate limits, budget accounting, and correlation IDs attached to every event.
4. Capsule A/B benchmark execution and comparable Eval reports.
5. Bounded cancellation, retry classes, provider fallback, and repair receipts; basic timeouts and output/write bounds are now local proof only.
6. CI gates using Fence, Concord, ShipCheck, and deterministic release manifests.

### P2 — Performance and product maturity

1. Avoid running Agents SDK aggregate smoke on every production mission; make it a startup or release gate.
2. Add bounded parallel read-only verification with serialized writes.
3. Add streaming event sinks rather than only file-backed post-run JSONL.
4. Add structured metrics for latency, tokens, retries, queue time, tool duration, and artifact sizes.
5. Add retention/compaction for `.relay` artifacts and streaming artifact sinks.
6. Add model capability discovery and explicit fallback-selection explanations.

## Root-layout review

The root files are still justified by established Kujo conventions: `main.kujo` is the executable entrypoint, `kujo.toml` is package metadata, `bin/relay` is a thin launcher, and `README.md` is the package landing page. Runtime logic is correctly under `src/`; no root implementation file should be moved into `src/` without breaking the conventional entrypoint.

The second review found no redundant root implementation files. New behavior remains under `src/`, tests under `tests/`, examples under `examples/`, and operator-facing material under `docs/`.

## Security posture

The local runtime now fails closed for the highest-risk MVP paths and removes shell interpretation from mission commands, but it is not a complete security boundary. External direct-argv commands remain local process authority, the new worktree mode is repository-local rather than a container/microVM boundary, and there is no identity-aware remote service. Never expose the CLI or future MCP adapter to untrusted callers until auth, tenancy, secret policy, network egress, and stronger workcell isolation are implemented and tested.

## Sixth review slice — Agents SDK tool boundary

The runtime now has a bounded `agent_tools` mission seam. `src/agent_bridge.kujo`
uses the existing Agents SDK Tool Registry and approval provider, while a
capability-bound worker calls Relay's existing workspace, command, write, and
budget policy. `tests/relay_agents_tool_smoke.sh` proves a real isolated mission
creates a repository file through `relay.write_file`, records the Tool Registry
event in the RunLedger-backed run, and rejects an unapproved write without
creating the file. This is fixture-model execution evidence, not proof of
provider-driven model tool planning or universal enterprise isolation.

## Seventh review slice — executable and export boundaries

Relay now resolves bounded subprocesses through a fixed system PATH rather than
the caller's arbitrary PATH. Agents SDK worker capabilities bind the run,
session, workspace, and worker purpose, while tool calls are limited by both a
mission ceiling and a 16-call hard ceiling. Agent-created files are now part of
the deterministic Eval suite. Machine callers can use `runs events` and
`runs export`; both verify event hashes, parent ordering, and duplicate IDs,
and export refuses tampered logs. These are local hardening improvements, not
proof of external-provider availability, signed exports, durable multi-host
storage, or universal enterprise readiness.

## Ninth review slice — execution-context correlation

Every newly emitted event now carries workflow, model, provider, packet
revision, and RunLedger run ID metadata before its integrity hash is sealed.
This reduces downstream reconstruction work for CI, Paperclip, and future
machine adapters. Typed tool, artifact, evaluation, retry, repair, and
cancellation IDs remain open, so this is correlation hardening rather than a
claim of complete enterprise evidence.

## Tenth review slice — typed evidence references

Relay now emits a versioned `RelayReceipt` index for the PackWrite packet,
Agents SDK smoke/tool result, model call, ChangeBucket result, Eval result, and
RunLedger start/finish artifacts. Receipts carry mission, run, step, agent,
artifact reference, status, and a SHA-256 integrity field. Lifecycle events
include the relevant receipt IDs, and `runs events`/`runs export` verify both
receipt integrity and exact agreement with authoritative state. The store smoke
proves a tampered receipt fails closed. Upstream tools remain canonical; this
index is a Relay correlation layer, not a second artifact store.

## Eleventh review slice — argv least privilege and lock contention

Mission command policy now validates tokenized argv profiles instead of relying
on broad Git string prefixes. Only explicit read-only Git subcommands and
options are accepted; positional pathspecs, unknown options, arbitrary
subcommands, and script arguments fail closed. The contract suite proves these
rejections. The rebuildable index now uses a bounded four-attempt, 20 ms
linear lock backoff, and `tests/relay_lock_stress_smoke.sh` exercises twelve
concurrent `runs rebuild` callers without corrupting the cache. These are local
security/performance improvements, not proof of durable multi-host storage or
an identity-aware security boundary.

## Twelfth review slice — bounded live event observation

Relay now exposes `runs watch <run-id>` as a machine-readable JSONL watcher over
the existing AgentEvent-compatible file stream. It emits each complete event
once, verifies the chain on every poll, bounds polling and total wait time, and
waits through the final state/file persistence race before validating terminal
receipts and state consistency. `tests/relay_watch_smoke.sh` proves a watcher
can observe a concurrently executing fixture mission through `run_completed`.
This is a local CLI observation surface, not a remote subscription service or a
durable multi-host event bus.

## Thirteenth review slice — bounded duration evidence

Relay now records non-negative `duration_ms` values at the bounded subprocess
adapter boundary and propagates the AI bridge duration into telemetry and
mission action/evidence results. The metrics smoke verifies fixture chat and a
fixture mission expose these measurements. These values improve local
performance debugging and regression detection; they are not billing, queue,
provider-SLA, or globally comparable latency metrics.

## Eighth review slice — complete evidence verification

The machine evidence boundary now rejects not only mutated or reordered event
records, but also truncated logs, malformed records, oversized logs, and logs
whose sequence differs from authoritative run state. This keeps a valid prefix
from being presented as a complete run and gives CI/Paperclip callers a clear
failure signal for repair or recovery. The implementation remains local-first;
durable append-only storage, signed exports, and crash recovery are still open.

## Release recommendation

Publish Relay only as a local-first alpha/showcase until all P0 items have executable evidence. The review hardening is pushed to `origin/main`; keep the README's enterprise-readiness disclaimer and require a release report that distinguishes fixture, configured-live, and production-environment evidence.
