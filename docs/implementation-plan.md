# Implementation Plan

## Delivered MVP

- Kujo CLI and reusable `src/runtime.kujo`.
- Fixture-backed AI SDK chat, normalized stream events, explicit model/provider metadata.
- Chain of Command role registry for Planner, Core Developer, Code Reviewer, Release Verifier.
- PackWrite packet generation and validation.
- One isolated Git workspace with policy-checked file and command actions.
- RunLedger start/finish receipt, ChangeBucket JSON, Eval JSON, AgentEvent JSONL, resumable state, Markdown/JSON report.
- Contract tests, security tests, CLI smoke tests, and fixture end-to-end evidence.
- Explicit write approvals, realpath workspace checks, command injection deny rules, redacted subprocess evidence, packet digest metadata, bounded preflight, and real pause-after-plan/resume.
- Fail-closed live Watchdog routing, explicit subprocess environments, configurable budgets, operator diagnostics/probes, detached worktree creation with confirmed cleanup, opt-in authenticated Watchdog health/config/request-correlation verification through a narrow Kujo HTTP adapter, shell-free command execution, a locked rebuildable index, and AgentEvent integrity hashes.
- A bounded Agents SDK Tool Registry bridge with approval-provider enforcement, direct Relay policy-worker execution, and one isolated fixture mission that creates a real repository artifact.
- Fixed subprocess executable paths, workspace-bound worker capabilities, validated Agent SDK tool-call budgets, integrity-chain verification for `runs events`, and versioned `runs export` bundles.
- Added authoritative event-sequence matching and an 8 MiB event-inspection bound so truncated, malformed, or oversized evidence cannot be exported as complete.
- Enriched every emitted event with workflow, model, provider, packet revision, and RunLedger correlation metadata before resealing its integrity hash.
- Added the sealed `RelayReceipt` index for typed cross-references to PackWrite, Agents SDK, model, tool, ChangeBucket, Eval, and RunLedger evidence; event inspection/export verifies receipt integrity and state consistency.
- Added sealed receipt context metadata for workflow, model, provider, packet revision, attempt, repair attempt, RunLedger, and AI correlation identifiers so machine consumers do not reconstruct execution context from neighboring files.
- Narrowed mission Git execution to exact read-only argv profiles and added bounded index-lock backoff with a concurrent rebuild stress smoke.
- Added bounded `runs watch` live AgentEvent observation with per-poll chain verification and terminal state/file reconciliation.
- Added non-negative adapter/action `duration_ms` measurements to AI telemetry and fixture mission evidence.
- Added read-only `runs sizes` artifact inventory with workspace exclusion, per-file sizes, and fail-closed symlink/entry bounds.
- Added cooperative `missions cancel` requests with action-boundary checks, terminal cancellation evidence, and RunLedger finish recording.
- Hardened JSON/JSONL evidence reads, appends, watch, and export against symbolic-linked and non-regular artifact files.
- Added a regular-file, non-symlink, 1 MiB mission-spec bound before JSON parsing and persistence.
- Added bounded pre-parse JSON readers for persisted index/state/evidence files, restricted model fallback to explicit retryable/capability failures with visible skip reasons, and added explicit bounded repair replay with typed repair receipts/events and a four-attempt safety ceiling.
- Bound Agents SDK worker executable and Relay-root selection to trusted environment values and added tampered-root rejection coverage.
- Added 128 KiB pre-parse limits and structured malformed-payload errors to the AI, Agents SDK, and tool-worker environment bridges.
- Added pre-provider Watchdog URL validation that rejects unsupported schemes and embedded credentials with a structured failure.
- Required HTTPS for non-loopback Watchdog hosts while preserving HTTP loopback support for local development and fixture evidence.
- Added structured Watchdog route posture for `doctor --json`; unsafe URLs now fail readiness checks and raw route values are never echoed, including rejected credential-bearing values.
- Bound paused-run resume to the persisted mission-policy digest, workspace identity, Git metadata, event/receipt integrity, and effective budgets; tampered state now fails before resumed actions.
- Applied the same state-integrity boundary to confirmed worktree cleanup so tampered terminal state cannot redirect Git removal.
- Reused the checkpoint integrity boundary for operator pause and cancel mutations; non-terminal control actions now fail closed on tampered state.
- Added fail-closed evidence persistence: state, receipt, and event write failures mark `evidence_failure`, force failed status before success reporting, and clean temporary files after failed atomic writes.
- Added state-store path validation: `.relay` and `.relay/runs` symbolic links are rejected before mission creation, execution, inspection, or operator controls, with a required doctor check and focused redirection smoke.
- Removed raw Watchdog URLs from AI telemetry; `relay_telemetry.watchdog_route` now carries only non-secret route posture, with credential-bearing and remote-host redaction regression coverage.
- Constrained correlation IDs to a bounded transport-safe alphabet before AI headers, telemetry, or Watchdog query construction, with delimiter and replacement coverage.
- Made store symlink probes tolerant of concurrent lock removal so index rebuilds retry bounded contention instead of crashing on a disappearing `.index.lock` path.
- Added Kujo `spawn_process` process-group cancellation and wired mission commands to `cancel_file`; the cancellation smoke now proves a 30-second descendant task returns within eight seconds.
- Expanded the local evidence redaction boundary to structured credential fields, common provider token formats, and private-key markers, with deterministic contract coverage.
- Hardened `doctor --json` dependency checks to reject required path type mismatches and symbolic-linked runtime/entrypoint dependencies, with machine-readable safety posture and a symlinked-Kujo regression smoke.
- Added bounded `doctor --json` version probes for the Kujo runtime, PackWrite, RunLedger, and ChangeBucket launchers, with explicit tool environments, configurable sibling roots, and fail-closed required readiness.
- Added optional SHA-256 dependency pins for the Kujo, PackWrite, RunLedger, and ChangeBucket executables; malformed, mismatched, missing, or symlinked pinned targets fail doctor readiness.
- Hardened provider credential environment selection against dynamic-loader, interpreter-injection, Git override, and trust-store override variables before the AI bridge receives them.
- Preserved `cancelled` and `timeout` as distinct action failure classes in runtime evidence and policy classification, with contract and cancellation-smoke coverage.
- Added a 30-second descendant timeout smoke proving Kujo process-group termination returns within 12 seconds without an orphan and persists typed timeout evidence.
- Optimized `runs watch` to retain parsed events and process only newly appended complete lines or a pending partial line, while rejecting replacement/truncation/disappearance and revalidating the full chain only after stream changes.
- Unified Relay symlink inspection behind a fail-closed helper: missing paths remain absent, dangling symlinks are detected through metadata before existence checks, existing parent path components are checked for store roots, and runtime probe errors are unsafe across evidence, workspace, dependency, control, and Agents SDK worker boundaries.
- Required persisted `receipts.json` and identity-matching `state.json` at CLI read boundaries so inspection, watch, event reads, and export cannot substitute embedded or indexed copies for missing authoritative evidence.
- Normalized relative `KUJO_BIN` and sibling adapter paths against the Relay root before cwd changes, preserving truthful PackWrite, RunLedger, ChangeBucket, and Eval evidence under Loop Engineering and alternate launch directories.
- Added fail-closed `runs verify` evidence aggregation and shape-checked `runs changes`/`runs evaluations` readers so machine callers receive one stable integrity verdict and missing artifacts cannot become successful empty results.
- Hardened `runs export` to require persisted ChangeBucket, Eval, and report artifacts with expected JSON shapes; incomplete bundles now fail closed instead of exporting empty fallbacks as valid evidence, while explicit `--partial` exports preserve paused/failed evidence with `integrity_valid: false`.
- Bounded `runs sizes` recursion to 16 directory levels and removed a redundant run-tree scan during index registration; cache records now preserve `updated_at`, avoiding needless rebuilds on subsequent reads.
- Required mission completion to verify persisted ChangeBucket, Eval, Markdown/JSON report, and RunLedger finish artifacts; injected artifact-write failures now fail closed with typed evidence failures and focused contract coverage.
- Hardened read-side evidence authority: `runs verify`, `runs export`, and `missions report` now require report identity/status agreement and a bounded regular Markdown report; the run index rejects placeholder records when authoritative state is absent; artifact inventory rejects oversized single directories before recursive flattening.
- Revalidated the internal Agents SDK worker boundary for write approval, command timeout, and output/write byte budgets; `runs watch` now reads terminal state through the identity-checked authoritative evidence reader and fails closed on unsafe state links.
- Added recursive redaction of Agents SDK worker model output, tool output, and error text before the summary crosses the bridge; the worker smoke proves credential-shaped output is not exposed.
- Centralized boolean environment parsing for fixture mode and Watchdog verification; `true`/`false`, `1`/`0`, and `yes`/`no` now share one case-insensitive, fail-safe contract with CLI smoke coverage.
- Bound the environment-selected AI bridge to a regular, non-symlinked `.kujo` file inside Relay; `chat`, `models probe`, and `doctor` fail closed with a non-disclosing error and CLI coverage.
- Made model profiles truthful: `models list` and `models probe` expose chat/streaming capability, explicit selection rationale, and `tool_planning: false` with declared-mission-only tool execution.
- Added an integrity seal over persisted run state and verify it at read, resume, cleanup, and report boundaries; state mutation now fails closed before status or workspace authority is trusted.
- Published forward-compatible JSON Schemas for mission, run/report, AgentEvent, receipt, doctor, model probe, and tool-result boundaries under `schemas/`.
- Added `tests/relay_acceptance.sh`, which discovers every committed smoke test, runs the contract suite and schema smoke, and performs `git diff --check`.
- Added verified event-inspection windows with bounded `--limit` and `--after` cursors; the complete event chain and authoritative state sequence are validated before any page is returned.
- Published the `event-bundle` JSON Schema for unpaged and paged `runs events` responses, including cursor and integrity metadata.
- Bound cooperative cancellation requests to the target run ID and a SHA-256 request seal; malformed, copied, stale-format, and tampered requests fail closed at action boundaries.
- Hardened Agents SDK tool capabilities with a short-lived nonce, fixed child-process `PATH`, and unsafe environment override filtering; legacy deterministic capabilities fail closed.
- Rejected mission repository and tool-workspace parent symlink components, exposed subprocess `exit_code` in command evidence, and expanded canonical failure taxonomy for policy, workflow, permission, malformed-tool, invalid-model, missing-context, implementation, and evaluation failures.
- Added validated `runs list --limit` and `--after` windows with deterministic run-ID ordering, cursor metadata, invalid-window rejection, and versioned `run-bundle`/`run-index-record` schemas.
- Required provider-generated tool runs to carry a persisted `relay-tool-result-bundle-v1` whose run identity and SHA-256 are verified by `runs verify` and valid `runs export`; exports now include the verified bundle.
- Required exact SHA-256 declarations for repository `bash`/`sh` scripts, preserved that policy through Agents SDK delegation, added opt-in `runs sizes --hashes` artifact digests while keeping the default inventory fast, and added recursive PackWrite packet manifests; published run-verification, run-sizes, and packet-manifest schemas.
- Bounded model output requests to the positive mission `max_tokens` budget (capped at 16,384), passed remaining tokens to provider follow-ups, normalized negative usage to zero, and removed caller-controlled `PWD` from child environment overrides.
- Hardened mission, run-root, and per-run state-directory creation with fail-closed symlink-component checks and the shared exclusive native `mkdir` primitive; unsafe or unavailable state paths now return `state_store_failure` before mission evidence work begins.
- Reused Kujo's native `write_file_atomic` for Relay evidence writes and unified Agents SDK capability-registry directory creation with the shared safe-directory helper; added symlink replacement and capability-creation regression coverage.
- Serialized Agents SDK capability issuance with the existing per-record exclusive lock and rejected duplicate run/session records instead of silently replacing a worker secret; added deterministic duplicate-issuance coverage.

## Deferred

 Live Ollama Cloud proof, a live Watchdog-backed mission against a real external provider, provider dialect negotiation, richer Agents SDK runner/tool-result artifact integration, Dispatch workflow import, dynamic agent discovery, full workcell isolation/rollback/recovery, CaseFile failure bundles, full Redact integration, MCP adapter, adaptive routing, Capsule A/B scoring, durable concurrent storage, signed export, richer retry/repair/cancellation receipts, remote event sinks, aggregate metrics, artifact retention/compaction, crash recovery, and ShipCheck/Concord release gates. Local real-Watchdog/stub-provider correlation, one fixture mission through the Agents SDK Tool Registry, bounded multi-turn provider-generated planning with typed tool-result persistence and read-side tool-result verification, exact hash-pinned script execution including delegated worker calls, recursive PackWrite packet manifests, opt-in artifact digests, complete event-sequence and receipt verification, exact Git argv policy, bounded lock backoff, incremental bounded live event watch, bounded duration evidence, bounded artifact size inventory with depth denial, cooperative cancellation, symlink-safe evidence access including parent-component store checks, bounded mission-spec input, bounded persisted JSON parsing, required persisted receipt/state read boundaries, failure-aware fallback, trusted worker-root binding, bounded bridge payloads, validated live Watchdog routes, HTTPS enforcement for non-loopback routes, secret-safe doctor route posture, route telemetry non-disclosure, endpoint-independent Watchdog diagnostics, integrity-bound resume checkpoints, integrity-bound worktree cleanup, integrity-bound pause/cancel controls, structured local credential/token/private-key redaction, dependency-integrity doctor checks, deterministic upstream version probes, optional SHA-256 dependency pinning, credential-environment injection deny rules, fail-closed symlink probe errors and dangling-symlink detection, explicit cancellation/timeout action classes, descendant-safe timeout termination evidence, PackWrite atomic pack writes, fail-closed evidence persistence including required ChangeBucket/Eval/report artifacts and RunLedger finish, state-store symlink rejection, sealed receipt execution context, the read-only `runs verify` contract, complete export artifact checks, explicit non-valid partial export checks, cache-consistent index metadata, single-scan registration, provider request/response and tool-argument size bounds, duplicate tool-ID rejection, proxy-environment denial, bounded JSONL event/receipt writes, and safe PackWrite artifact verification are proven. See `docs/next-session-enhancement-backlog-2026-07-13-v70.md`.

The latest review adds exact Watchdog request-ID matching and normalized
per-request usage reconciliation to opt-in verification. Missing or mismatched
observed usage fails closed, while only sanitized telemetry fields are returned.
Focused contract and local Watchdog smokes pass.

Current follow-on backlog: `docs/next-session-enhancement-backlog-2026-07-13-v73.md`.

The v61 handoff supersedes the earlier v60 review backlog after persisted
state-seal, machine-schema, aggregate-acceptance, and bounded mission-ID
hardening delivered in this session.

The v62 local hardening also centralizes fallback classification and persists
mission-level selected/skipped fallback evidence, and bounds `runs sizes` by
total artifact bytes in addition to entry count and directory depth.

The v63 local hardening adds machine-callable event windows without weakening
integrity verification and seals cancellation requests to a run identity. These
are local evidence and control-plane safeguards, not authenticated distributed
operation or a durable event service.

The v64 local hardening adds nonce-bound Agents SDK worker capabilities, fixed
child-process executable paths, parent-component repository/workspace symlink
rejection, exit-code evidence, and a more discriminating failure taxonomy.
These remain local defense-in-depth and evidence improvements; remote identity,
authenticated caller binding, workcell isolation, and durable storage are deferred.

## Dependency order

1. Stabilize cross-repository package/import and process contracts.
2. Run the Watchdog adapter against real configured providers, beginning with Ollama Cloud and one independent OpenAI-compatible provider.
3. Extend the proven provider-generated Agents SDK Tool Registry bridge to multi-turn tool loops, typed tool-result artifacts, cancellation, and richer approval/guardrail receipts.
4. Add Dispatch/Spec workflow loader and bounded checkpoint transitions.
5. Extend detached worktree mode into full workcell creation, cleanup, rollback, and crash recovery.
6. Implement CaseFile/Redact and complete Capsule benchmark comparison.
7. Wire Paperclip/Hermes through JSON or MCP adapters.

## Main risks

Process path resolution, live credentials, Watchdog availability, provider capability differences, cross-repo version drift, worktree cleanup, and accidental authority expansion. Every deferred item has an explicit boundary rather than a placeholder command.

## Current review delta

Extend the existing fail-closed filesystem policy to all local trust roots:
state-store parents, doctor dependency targets, the Agents SDK worker
root/source, bounded JSON/JSONL artifacts, cancellation requests, and live
event observation. Keep this as a shared boundary helper with focused probes;
do not introduce a separate path-policy implementation. Cache repeated watcher
existence checks per poll. The next implementation priority remains live
Watchdog/provider evidence and a real bounded mission, followed by stronger
workcell and durable-store ownership.

The adapter boundary also now canonicalizes subprocess module context for
sibling Kujo tools. This closes a cross-repository launch-context failure that
could make ChangeBucket import Relay's modules or return no change evidence.

The v49 review also requires persisted `receipts.json` and identity-matching
`state.json` at read boundaries. Missing receipt evidence can no longer fall
back to the embedded state copy, and missing run state can no longer produce a
successful empty inspection. This is evidence completeness hardening, not
durable storage, signed provenance, or enterprise tenancy.

The same review normalized relative adapter paths before subprocess cwd
changes. The dedicated relative-tool-path smoke proves a real fixture mission
still reaches PackWrite, RunLedger, ChangeBucket, and Eval when `KUJO_BIN` is
provided in the relative form used by the Loop Engineering configuration.

The v50 review adds one non-mutating `runs verify` contract over authoritative
state, event, receipt, ChangeBucket, and Eval evidence. Individual changes and
evaluations reads now fail closed on missing or wrong-shaped persisted files;
the store smoke proves both the positive verdict and the negative cases.

The v51 review extends the same evidence-completeness rule to `runs export` and
the JSON report. Missing ChangeBucket, Eval, or report artifacts now produce an
incomplete-export failure rather than a valid bundle with empty fallback data.

The v52 review adds an explicit opt-in partial export for paused and failed
runs. It is versioned separately, always reports `integrity_valid: false`, and
is refused for completed runs.

The v53 review bounds artifact inventory recursion at 16 directory levels and
adds a deep-tree regression. Run registration now delegates to the locked
authoritative index rebuild once instead of scanning the run tree twice, and
the resulting cache record retains `updated_at`, preventing avoidable stale
cache rebuilds. The focused store and sizes smokes pass; durable multi-host
storage and retention remain open.

The v54 review makes required result persistence part of completion authority.
ChangeBucket, Eval, report JSON/Markdown, and RunLedger finish artifacts are
verified after writing; injected write failures produce `evidence_failure`
instead of a successful run. Contract, mission, store, size, resume, and Agent
SDK tool smokes pass; crash recovery, live external-provider proof, and durable
storage remain open.

The v55 review closes read-side evidence gaps: report identity/status and
Markdown presence are required for verification, export, and report lookup;
the run-index validator rejects placeholder entries when state is absent; and
artifact inventory rejects a directory larger than its entry budget before
recursive flattening. Focused store, sizes, mission, and watch smokes pass;
live external providers, crash recovery, and durable storage remain open.

The v65 review adds an opt-in provider-generated tool-planning path. Relay
passes only an explicit `agent_tool_allowlist` through Watchdog and the AI SDK,
normalizes OpenAI-compatible function arguments, and sends the resulting calls
through the existing Agents SDK registry and Relay policy worker. A local
Watchdog/stub-provider smoke proves provider response, normalized planning,
Agents SDK approval, repository mutation, ChangeBucket, Eval, and RunLedger
completion. Live Ollama Cloud and independent-provider evidence remain open.

The v66 review extends that path to a bounded multi-turn loop. Assistant tool
calls and typed `role: tool` results remain inside the existing AI SDK bridge,
each result is persisted in a redacted `relay-tool-result-bundle-v1` artifact,
and cancellation, call, turn, and aggregate token budgets are checked before
continuation. The local authenticated Watchdog/stub-provider mission proves
the tool result round trip and completion. Provider dialect negotiation, live
external providers, workcells, durable storage, and authenticated adapters
remain open. See `docs/next-session-enhancement-backlog-2026-07-13-v67.md`.

The v67 review adds resource ceilings below downstream transport and inspection
limits: 112 KiB serialized AI requests, 1 MiB provider responses, 64 KiB
provider tool arguments, and 8 MiB persisted event/receipt evidence. Duplicate
provider call IDs and unsafe proxy environment overrides fail closed, and
PackWrite preflight now verifies a safe generated `agent/MASTER.md`. These
local protections improve failure behavior and reduce authority ambiguity; they
do not claim live provider, durable store, or enterprise tenancy readiness.

The v74 review adds a shared trusted-path boundary for dependency invocation.
The launcher resolves Kujo from an explicit override, `PATH`, or the sibling
release tree and exports the resolved binary. PackWrite, RunLedger, ChangeBucket,
Eval, and Capsule adapters reject configured symlinked or non-regular targets
before spawning them; doctor retains raw path and symlink diagnostics. The CLI
smoke proves a symlinked PackWrite target fails readiness without execution.
Executable mode/signature provenance, authenticated deployment ownership, live
external-provider proof, durable workcells, and release gates remain open.

Current follow-on backlog: `docs/next-session-enhancement-backlog-2026-07-13-v74.md`.

The v75 review adds short-lived Agents SDK capability issuance and consumption.
Relay persists a digest-only registry record bound to run/session/workspace/
nonce identity, expiry, and a bounded call allowance; each authority call
consumes one allowance under a lock, and the parent revokes the record after the
worker exits. Direct legacy or replayed requests fail closed. The Agents SDK
tool smoke proves issued use, policy denial, and one-time replay rejection.
Remote authenticated authorization, multi-host storage, and crash-recovery
reconciliation remain open.

Current follow-on backlog: `docs/next-session-enhancement-backlog-2026-07-13-v75.md`.

The v76 review adds bounded capability-registry posture and explicit repair.
Doctor now reports stale and invalid Agents SDK records, while
`doctor --repair` removes only expired or exhausted records. Ordinary doctor
execution remains read-only, the scan is capped at 1024 records, and unsafe or
malformed registry paths fail closed. This closes local crash-leftover hygiene,
not durable multi-host authorization or enterprise retention.

The v77 review serializes that repair with the existing per-record Agents SDK
consumption lock. Active records are reported as `locked` and retained; invalid
lock objects fail closed. The repair path re-reads the record after acquiring
the lock before deciding whether to delete it, closing a local cleanup/worker
race without adding a second synchronization contract.

The v78 review verifies that authority locks use an exclusive fixed-path native
`mkdir` operation. Kujo's idempotent `create_dir` is no longer used to acquire
capability or index locks; contract coverage proves the second acquisition
fails. This closes the remaining local lock-acquisition race in the Relay
boundary, not multi-host ownership or crash-lock reconciliation.

Current follow-on backlog: `docs/next-session-enhancement-backlog-2026-07-13-v78.md`.

## v82 delivered — single-scan index recovery

The invalid-cache path now uses `rebuild_and_persist_run_index`, which acquires
the existing bounded lock, rebuilds from authoritative per-run state once, and
persists the returned index. The contract suite proves the returned and stored
records agree. Explicit rebuild/register callers retain the existing
authoritative persistence path.
