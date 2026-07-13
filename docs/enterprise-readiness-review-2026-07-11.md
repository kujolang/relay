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
| Artifact size evidence | Read-only `runs sizes` inventories persisted run artifacts, excludes workspace, and rejects symlinks/oversized entry sets | `src/cli.kujo`, `tests/relay_sizes_smoke.sh` |
| Mission cancellation | Cooperative `missions cancel` request checks around actions, terminal event, and RunLedger finish evidence | `src/runtime.kujo`, `src/cli.kujo`, `tests/relay_cancel_smoke.sh` |
| Evidence path safety | JSON reads/appends and event inspection reject symbolic-linked or non-regular evidence files | `src/common.kujo`, `src/cli.kujo`, `tests/relay_store_smoke.sh` |
| Mission input safety | Regular-file, non-symlink, 1 MiB mission-spec bound before JSON parsing | `src/runtime.kujo`, `tests/relay_spec_safety_smoke.sh` |
| Persisted JSON safety | Index/lock-owner/state/receipt/export JSON is size-bounded before parsing | `src/common.kujo`, `src/store.kujo`, `src/cli.kujo`, contract and store smokes |
| Fallback safety | Primary model fallback is limited to explicit transient/capability classes and skipped reasons are recorded | `src/adapters.kujo`, contract tests |
| Worker executable authority | Agents SDK worker root and binary must match trusted environment values before spawn | `src/agent_bridge.kujo`, `tests/relay_agents_tool_smoke.sh` |
| Bridge payload safety | AI, Agents SDK, and tool-worker environment JSON is bounded and malformed input is structured before use | `src/ai_bridge.kujo`, `src/agent_bridge.kujo`, `src/cli.kujo`, `tests/relay_input_boundary_smoke.sh` |
| Live route safety | Watchdog URL scheme, userinfo, malformed hosts, query/fragment values, and remote cleartext HTTP are rejected before provider invocation; remote HTTPS and loopback HTTP remain supported | `src/adapters.kujo`, `src/watchdog.kujo`, `tests/relay_cli_smoke.sh`, contract tests |
| Secret-safe route diagnostics | `doctor --json` reuses route policy, fails live readiness for unsafe routes, and never echoes raw Watchdog URLs | `src/watchdog.kujo`, `src/doctor.kujo`, contract and CLI smokes |
| Resume checkpoint authority | Paused runs verify policy digest, workspace/Git identity, budgets, event chain, and receipts before resumed execution | `src/runtime.kujo`, `tests/relay_resume_integrity_smoke.sh`, contract tests |
| Cleanup state authority | Confirmed worktree cleanup revalidates policy, source/worktree identity, Git metadata, events, and receipts before destructive Git removal | `src/runtime.kujo`, `tests/relay_worktree_smoke.sh`, contract tests |
| Control-plane state authority | Operator pause and cancel revalidate checkpoint integrity before mutating non-terminal state | `src/runtime.kujo`, `tests/relay_contract_tests.kujo`, cancellation/resume smokes |
| Evidence persistence authority | State, receipt, and event write failures force `evidence_failure` and failed terminal status; failed atomic temps are removed | `src/common.kujo`, `src/runtime.kujo`, contract failure injection |
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
5. Process-group cancellation, retry classes, provider fallback, and repair receipts; cooperative action-boundary cancellation, basic timeouts, and output/write bounds are now local proof only.
6. CI gates using Fence, Concord, ShipCheck, and deterministic release manifests.

### P2 — Performance and product maturity

1. Avoid running Agents SDK aggregate smoke on every production mission; make it a startup or release gate.
2. Add bounded parallel read-only verification with serialized writes.
3. Add streaming event sinks rather than only file-backed post-run JSONL.
4. Add structured aggregate metrics for latency, tokens, retries, queue time, tool duration, artifact sizes, and provider availability; local duration and size inventories remain raw evidence.
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

## Fourteenth review slice — bounded artifact size evidence

Relay now exposes `runs sizes <run-id>` as a read-only inventory of persisted
run artifacts. It reports per-file bytes and aggregate counts, always reports
the repository workspace as excluded, rejects symbolic links and unsupported
paths, and caps inventory traversal at 4096 files. The focused size smoke proves
both a normal inventory and fail-closed symlink handling. This is local disk
evidence only; retention, compaction, transfer cost, and durable multi-host
artifact storage remain open.

## Fifteenth review slice — cooperative mission cancellation

Relay now exposes `missions cancel <run-id>`. It records a cancellation request
as run evidence, checks it before and after each declared action, transitions
the run to `cancelled`, emits a sealed `run_cancelled` event, and finishes the
RunLedger record. Paused runs can be cancelled immediately. The focused smoke
proves cancellation during a slow repository action and rejects a false
completion event. This is cooperative local cancellation only; process-group
termination, rollback, distributed identity/authorization, and workcell
recovery remain open.

## Seventeenth review slice — bounded mission-spec input

Relay now requires a mission input to be an existing regular, non-symbolic file
no larger than 1 MiB before JSON parsing or run-state persistence. The focused
spec-safety smoke proves both oversized and symlinked mission documents fail
closed. This bounds local parse/prompt/state amplification; authenticated
input identity, schema negotiation, and larger durable workflow packets remain
future work.

## Sixteenth review slice — symlink-safe evidence access

Relay now rejects symbolic-linked or non-regular JSON/JSONL evidence files at
the common read/append boundary and at `runs watch`/`runs events`/`runs export`
inspection boundaries. The store smoke replaces `events.jsonl` with a symlink
to `/etc/passwd` and verifies that inspection fails closed before restoring the
real artifact. This reduces local evidence redirection risk; kernel-level
no-follow primitives, multi-user ownership, and durable storage isolation
remain open.

## Eighth review slice — complete evidence verification

The machine evidence boundary now rejects not only mutated or reordered event
records, but also truncated logs, malformed records, oversized logs, and logs
whose sequence differs from authoritative run state. This keeps a valid prefix
from being presented as a complete run and gives CI/Paperclip callers a clear
failure signal for repair or recovery. The implementation remains local-first;
durable append-only storage, signed exports, and crash recovery are still open.

## Eighteenth 2026-07-11 review

This review closes two pre-parse and retry-policy gaps. Persisted JSON reads now
check size before parsing: index files are capped at 8 MiB, lock owners at
64 KiB, and run state at 64 MiB, with bounded receipt/export reads at the CLI
boundary. The store smoke proves an oversized index is rebuilt rather than
trusted. Model fallback now runs only for explicit timeout, rate-limit,
provider-availability, connection, overload, or missing-model classes; auth,
policy, route, and malformed-bridge failures remain single-attempt and expose
the skip reason. Relay remains local-first hardened alpha/showcase.

## Twentieth 2026-07-11 review

This review hardens the machine-callable bridge boundary. AI, Agents SDK, and
tool-worker JSON received through environment variables is capped at 128 KiB
before parsing; malformed and non-object payloads return structured errors
instead of raw interpreter failures. The focused input-boundary smoke proves
oversized and malformed payload rejection across all three bridges. Larger
future prompts or tool plans require an authenticated file or socket transport.
Relay remains local-first hardened alpha/showcase.

## Twenty-first 2026-07-11 review

This review validates the live Watchdog route before the AI SDK subprocess is
started. Relay now rejects unsupported schemes and embedded credentials with an
`invalid_watchdog_route` failure, while the CLI and contract smokes prove the
boundary. This is route-input hardening, not TLS policy, authenticated route
discovery, or external-provider proof.

## Twenty-second 2026-07-11 review

This review tightens live route policy. HTTP is now accepted only for
localhost, 127.0.0.1, or [::1]; non-loopback Watchdog hosts must use HTTPS.
Contract coverage proves local loopback HTTP, external HTTPS, and external HTTP
rejection. This is transport policy hardening, not TLS certificate validation,
mTLS, route discovery, or external-provider proof.

## Nineteenth 2026-07-11 review

This review closes a worker-path authority gap. The Agents SDK bridge now rejects
payload-selected Relay roots or Kujo binaries unless they exactly match trusted
process environment values, and rejects missing or symbolic-linked trusted roots
before spawning the policy worker. The Agents SDK smoke proves a tampered root
cannot redirect the worker or create the requested file. This is local launch
integrity hardening, not authenticated service identity, signed binary
verification, or full workcell isolation.

## Twenty-eighth 2026-07-12 review

This review closed a state-store redirection gap. Relay now rejects symbolic
links at both `.relay` and `.relay/runs` before mission creation, execution,
index access, or operator control; unsafe access returns `state_store_failure`.
`doctor --json` reports the required store posture, and the focused smoke proves
that neither symlink shape can redirect evidence into an external target. This
is local path hardening, not kernel-level no-follow durability, authenticated
ownership, or full workcell isolation.

## Twenty-ninth 2026-07-12 review

This review closed telemetry and correlation-input gaps. Successful AI calls
previously copied the raw `RELAY_WATCHDOG_URL` into `relay_telemetry`, even
though doctor already exposed only route posture. Relay now emits only
configured, valid, scheme, and reason fields in `watchdog_route`, and accepts
only transport-safe correlation IDs before headers, telemetry, or Watchdog
queries. CLI and contract coverage prove both boundaries, including fixture
execution. This is local telemetry hardening, not authenticated route
discovery, certificate validation, or mTLS.

The same review also hardened the local index lock boundary: concurrent
rebuilds now tolerate a lock directory disappearing between filesystem probes,
and the lock stress gate passes without an interpreter race.

## Thirtieth 2026-07-12 review

This review closed a Watchdog diagnostic disclosure path. When health or proxy
configuration requests fail, Relay now returns the bounded
`Watchdog HTTP request failed` class and logical endpoint path without exposing
the constructed URL or transport-library error. The unreachable-route doctor
smoke and full local gates pass. This is diagnostic hardening, not authenticated
route discovery, certificate validation, or mTLS.

## Release recommendation

Publish Relay only as a local-first alpha/showcase until all P0 items have executable evidence. The review hardening is pushed to `origin/main`; keep the README's enterprise-readiness disclaimer and require a release report that distinguishes fixture, configured-live, and production-environment evidence.

## Thirty-first 2026-07-12 review

This review closed an active-command cancellation gap. Relay now passes the
run-owned cancellation marker to Kujo's `spawn_process` runtime, and Kujo
commit `f24b3c3` starts Unix commands in their own process groups so cancelling
the direct child also terminates descendants that inherited output pipes. The
Relay smoke runs a 30-second descendant task and proves terminal cancellation
within eight seconds, with no orphaned slow process observed. Non-Unix
direct-child behavior, rollback-aware workcells, and distributed cancellation
remain deferred.

## Thirty-second 2026-07-12 review

This review closed a local evidence-redaction gap. Relay previously handled
bearer headers and environment-style assignments but could preserve structured
JSON credentials or common provider token formats in subprocess and adapter
evidence. The shared redactor now covers API/access/auth tokens, client
secrets, passwords, generic secret fields, OpenAI/AWS/GitHub/Slack token
patterns, and private-key markers. Contract tests prove the new cases. Full
Redact integration across prompts, packets, handoffs, tenant-aware custody,
and external-provider evidence remains deferred.

## Thirty-third 2026-07-12 review

This review closed a dependency-readiness gap. `doctor --json` previously
treated an existing path as healthy even when it was the wrong type or a
symbolic link. Required runtime, entrypoint, source, SDK, ecosystem-tool, and
agent-registry paths now report explicit `exists`, `expected_type`, `symlink`,
and `safe` posture and fail the doctor check when unsafe. The CLI smoke proves
a symlinked Kujo runtime is rejected. Signed dependency manifests, executable
hashes, provenance, and deployment ownership remain deferred.

## Thirty-fourth 2026-07-12 review

This review closed a failure-evidence precision gap. Active commands previously
persisted cancellation and timeout outcomes as generic `tool_failure` records.
Relay now maps Kujo cancellation to `cancelled`, timeout termination to
`timeout`, and explicit cancellation codes to the same classification. The
contract suite and cancellation smoke prove the distinction. Provider-specific
failure taxonomies, typed retry/repair receipts, and cross-system normalization
remain deferred.

## Thirty-fifth 2026-07-12 review

This review added independent timeout evidence. A 30-second descendant command
with a one-second timeout now returns within 12 seconds, records
`timed_out: true` and `failure_class: timeout`, and leaves no slow descendant
process. This proves the Unix Kujo process-group timeout boundary separately
from operator cancellation. Non-Unix process trees, rollback-aware workcells,
and distributed process ownership remain deferred.

## Thirty-sixth 2026-07-12 review

This review reduced local watcher parsing cost without weakening evidence
validation. `runs watch` now retains parsed events, parses only newly appended
complete lines plus any pending partial line, rejects replacement/truncation,
and still validates the full event chain on every changed stream. Remote event
sinks, durable subscriptions, and multi-host fan-out remain deferred.

## Thirty-seventh 2026-07-12 review

This review closes a watcher evidence-loss gap. After `runs watch` has seen an
event log, deletion now produces a non-zero `run event log disappeared` error
instead of allowing stale in-memory events to satisfy terminal reconciliation.
The focused disappearance smoke and full local acceptance gates pass.

The Redact repository was exercised as part of the integration audit. Its
current CLI MVP is text/Markdown-oriented and rejects `.json` input, so a safe
structured-artifact adapter cannot yet be claimed. Relay keeps its local
fail-closed redactor and records a contract-first Redact follow-up rather than
passing machine-readable evidence through an unproven text sanitizer.
