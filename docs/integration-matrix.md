# Integration Matrix

| Capability | Preferred existing owner | Reuse method | Required adaptation | MVP test/evidence | Risk |
|---|---|---|---|---|---|
| Provider communication | AI SDK | `src/ai_bridge.kujo` | runtime payload adapter; stream option and optional Watchdog proxy header forwarded through the AI SDK; live calls fail closed without Watchdog URL | fixture response, normalized stream JSONL, model probe, blocked-live test; live provider pending | medium |
| Agent execution | Agents SDK + Chain of Command | role registry plus a bounded Agents SDK runner bridge | provider-driven planning is opt-in through `agent_tool_mode` and an explicit allowlist; richer role loading pending | agent validation + isolated declared and provider-generated Tool Registry smokes | medium |
| AI telemetry | Watchdog | configured proxy URL plus `src/watchdog.kujo` HTTP adapter | authenticated health/config/correlation verification is opt-in; returned telemetry is sanitized | local contract stub and real Watchdog + stub-provider smoke; external-provider evidence pending | high |
| Mission packet | PackWrite | fake-response `init`, validate generated pack | revision/digest recorded; canonical whole-pack manifest pending | 13-file validated pack + SHA-256 evidence | medium |
| Execution evidence | RunLedger | `start`/`finish` subprocess calls plus AgentEvent-compatible JSONL | Relay receipt index adds sealed typed references and normalized mission/run/workflow/step/agent/model/provider/packet/tool/artifact/evaluation/retry/repair context for RunLedger, model, tool, PackWrite, ChangeBucket, and Eval evidence; required ChangeBucket/Eval/report artifacts are shape-checked and RunLedger finish must persist before completion; upstream stores remain canonical | pass receipt with Git commit, workflow/model/provider/packet/attempt context, correlated event context, receipt tamper, store recovery, truncation/tamper, event-integrity, artifact-write failure, and export smokes | high |
| Live run observation | Relay CLI + AgentEvent contract | bounded `runs watch` over the existing JSONL event stream; parses only newly appended complete lines plus a pending partial line, rejects replacement/truncation/disappearance, validates the chain only when the raw stream changes, and exposes verified paged `runs events` windows for machine callers | poll/timeout bounds, remote sinks, durable subscriptions, and multi-host fan-out remain open | concurrent watch smoke with complete event stream, terminal `run_completed`, incremental parser path, paged event window/cursor, and disappearance fail-closed smoke | medium |
| Mission cancellation | Relay runtime + Kujo `spawn_process` + RunLedger | cooperative `missions cancel` request is bound to the target run ID and sealed before it is passed as `cancel_file`; Kujo terminates Unix process groups and Relay records the terminal transition | rollback, non-Unix descendant guarantees, distributed cancellation, replay protection, and authenticated ownership remain open | 30-second descendant cancellation returns within eight seconds with terminal `run_cancelled` and no completion event; tampered request is rejected | high |
| Action failure classification | Relay policy + runtime + RunLedger | canonical classifier preserves cancellation, timeout, authentication, rate/allowance, policy, workflow-definition, permission, malformed-tool, invalid-model, missing-context, implementation, evaluation, repository, tool, and provider classes; specific authority failures precede generic tool failures | provider-specific taxonomy, retry/repair receipts, and cross-system normalization remain open | contract taxonomy checks plus cancellation/timeout action evidence assert typed classes | medium |
| Timeout process ownership | Kujo `spawn_process` + Relay runtime | bounded command timeout terminates the Unix process group, preserves `timed_out`, and records `failure_class: timeout` | non-Unix process-tree guarantees, rollback, and workcell ownership remain open | 30-second descendant timeout returns within 12 seconds with no orphan and typed terminal evidence | high |
| Performance evidence | AI SDK/Watchdog + Relay adapters | bounded subprocess `duration_ms` propagated into telemetry and action/evidence results | aggregate metrics, cost normalization, and provider availability remain upstream concerns | fixture chat/mission metrics smoke | medium |
| Artifact size inspection | Relay run store boundary | read-only `runs sizes` inventory for persisted run artifacts, with workspace exclusion, a 4096-file bound, and a 16-level directory-depth bound | rotation, compaction, retention, resumable export, and durable storage ownership remain open | fixture size inventory plus symlink and deep-tree fail-closed smoke | medium |
| Evidence path safety | Relay common/CLI boundaries | JSON reads, JSONL appends, event inspection, export, workspace controls, dependency checks, and Agents SDK worker binding reject symbolic-linked or non-regular files; metadata-first probing catches dangling links, probe errors fail closed, and missing paths remain absent | complete no-follow atomic filesystem primitives and multi-user ownership remain upstream/platform concerns | contract probe-error check, dedicated dangling-link smoke, store smoke, worker smoke, and symlink rejection coverage | high |
| Mission input safety | Relay runtime loader | regular-file, non-symlink, 1 MiB mission-spec bound before JSON parsing | schema negotiation, authenticated caller identity, and richer streaming input remain open | oversized and symlink mission-spec smoke | high |
| Persisted JSON safety | Relay common/store/CLI boundaries | bounded pre-parse readers for index, lock owner, run state, receipts, and export-side artifacts | durable schema migration, compaction, and no-follow kernel primitives remain open | contract bounded-read checks plus oversized-index store smoke | high |
| Model fallback policy | AI SDK adapter boundary | fallback only for explicit transient/capability classes; non-retryable reasons are visible and skipped | adaptive routing, provider-specific taxonomy, and cost aggregation remain open | contract retryable/non-retryable classification checks | high |
| Worker executable authority | Agents SDK bridge + Relay worker | `relay_root` and `kujo_bin` are bound to trusted environment values, the worker capability includes a short-lived nonce, child `PATH` is fixed, and unsafe environment overrides are dropped before spawn | authenticated caller identity, signed binaries, nonce replay protection, and workcell isolation remain open | tampered-root, legacy-capability, process-environment, and Agents SDK tool smokes | high |
| Bridge payload safety | AI SDK, Agents SDK, and Relay CLI boundaries | environment-backed JSON is capped at 128 KiB and malformed payloads return structured errors before parse/use | authenticated file/socket transport and larger prompt contracts remain open | input-boundary smoke | high |
| Live route safety | Relay AI adapter + Watchdog contract | live calls and `doctor --json` reject malformed/credential-bearing routes, dangerous provider credential environment names, allow HTTP only for loopback, require HTTPS for remote Watchdog hosts, and expose only non-secret posture in diagnostics and AI telemetry | authenticated route discovery, certificate policy, and provider-specific network controls remain open | contract and CLI invalid-route/credential-environment/doctor/telemetry-redaction smoke | high |
| Correlation input safety | Relay AI adapter + Watchdog contract | accept only bounded alphanumeric/hyphen/underscore correlation IDs before forwarding them in headers, telemetry, or Watchdog query parameters | authenticated caller identity and distributed correlation ownership remain open | contract delimiter checks plus CLI replacement smoke | high |
| Watchdog diagnostic disclosure | Relay Watchdog adapter + doctor | normalize health/configuration transport failures to endpoint-independent errors before diagnostics or run telemetry | authenticated error taxonomy and remote incident correlation remain open | unreachable-route doctor redaction smoke | high |
| Dependency integrity | Relay doctor + filesystem boundary | required runtime, entrypoint, source, SDK, ecosystem-tool, and registry paths must have the expected type and must not be symbolic links; doctor also runs bounded Kujo/PackWrite/RunLedger/ChangeBucket version probes and optionally verifies configured SHA-256 pins with explicit environments | signed dependency manifests, semantic compatibility ranges, provenance, and deployment ownership remain open | fixture doctor path/version/hash assertions plus symlinked Kujo runtime and wrong-hash rejection | high |
| Resume state authority | Relay runtime + event/receipt contracts | paused runs bind the mission policy digest, workspace identity, Git metadata, effective budgets, event chain, and receipt sequence before resuming | signed state, crash recovery, multi-user ownership, and durable storage remain open | contract and tampered-resume smoke | high |
| Worktree cleanup authority | Relay runtime + Git worktree contract | confirmed cleanup revalidates policy digest, run-owned worktree path, source repository, Git metadata, event chain, and receipts before `git worktree remove --force` | signed state, authenticated ownership, rollback, and crash recovery remain open | worktree tamper smoke plus cleanup contract | high |
| Control-plane mutation authority | Relay runtime + checkpoint contract | `pause` and `cancel` revalidate checkpoint state before mutating a non-terminal run | signed state, authenticated ownership, and distributed control remain open | contract and cancellation/resume smokes | high |
| Evidence persistence authority | Relay common/runtime contracts | state, receipt, event, ChangeBucket, Eval, report, and RunLedger finish write failures mark `evidence_failure`, force failed status before final reporting, and read boundaries require persisted receipt/state evidence; report readers also verify identity/status and Markdown presence instead of accepting shape-only or index fallback data | durable append-only storage, fsync semantics, crash recovery, and signed provenance remain open | contract failure injection, required-artifact/report identity/Markdown failure probes, missing receipt/state probes, and full mission evidence | high |
| Run verification | Relay CLI + existing evidence contracts | `runs verify` aggregates authoritative state, complete events, persisted receipts, ChangeBucket, Eval, report identity, and required provider-generated tool-result integrity into `relay-run-verification-v1`; valid export fails closed and explicit partial export is versioned separately | signed manifests, upstream correlation IDs, durable storage, and authenticated partial-export authorization remain open | store smoke plus provider-tool smoke prove positive and tampered `tool-results.json` verdicts | medium |
| State-store path authority | Relay store/runtime/CLI/doctor boundaries | reject symbolic-linked `.relay`, `.relay/runs`, and existing parent path components before state, index, mission, or operator-control access; dangling links and probe errors fail closed | no-follow kernel primitives, authenticated ownership, and durable multi-host storage remain open | state-store root/runs/parent redirection smoke, contract probe, and doctor posture | high |
| Repository changes | ChangeBucket | `--json --repo` | workcell orchestration pending; mission budgets bound action count | added-file change report and budget failure smoke | low |
| Evaluation | Eval | generated `eval.json`, run command | richer multi-step suites pending | passing `git diff --check` | low |
| Capsule context | Capsule | `capsule make` adapter | A/B benchmark loop pending | discovery command | medium |
| Routing | AI SDK model preferences; Dispatch patterns | explicit model profile fields | adaptive routing deferred | models list and telemetry reason | medium |
| Context compression | Scent/Muzzle | pre/post workflow integration | no runtime dependency in MVP | discovery inventory | medium |
| Authority | Agents SDK approvals + MCP/Fence patterns | Agents SDK approval policy/provider wraps Relay's policy worker; Relay remains authoritative for workspace and exact read-only Git argv checks | interactive approvals, identity, cancellation, and network controls pending | denied Tool Registry write plus direct policy/argv tests | high |
| Failure evidence | CaseFile | deferred command adapter | capture failed run bundle | failure classification contract | medium |
| Release verification | ShipCheck/Concord | deferred release workflow | report aggregation | docs and contract tests | medium |
| Secrets/output | Relay redaction boundary + Redact + Watchdog redaction | persisted subprocess and adapter evidence redacts structured API keys, access/auth tokens, secrets, passwords, common provider token formats, private-key markers, and existing bearer/env forms | full Redact integration across prompts, packets, handoffs, and multi-tenant secret custody remains open | contract coverage for JSON credentials, provider tokens, private-key markers, bearer headers, and environment-style secrets | high |
| Agent definitions | Kujo Agents | role registry paths | dynamic discovery pending | validate/list/inspect | low |
| Workflow definitions | Spec + Dispatch + Loop Engineering | JSON mission slice | declarative loader pending | verified-feature spec | medium |
| Tools | Agents SDK registry/MCP patterns | `src/agent_bridge.kujo` registers `relay.write_file` and `relay.run_command`; provider-generated plans are normalized by the AI SDK adapter and forwarded to the same worker, which delegates to `execute_tool_request` with nonce-bound workspace capability, fixed child environment, tool-call/turn budgets, cancellation checks, and redacted `relay-tool-result-bundle-v1` persistence | broader tool catalog, provider dialect negotiation, typed retry/repair receipts, and authenticated service mode pending | isolated declared/provider-generated multi-turn mission, tool-result bundle, approval denial, legacy-capability rejection, environment-boundary, cancellation, and budget denial smokes | high |
| Workspace isolation | Git worktree/workcell conventions | `workspace_mode: worktree` provisions a detached worktree from an immutable commit; provided mode remains available; mission repositories and tool workspaces reject parent symlink components | full workcell/container isolation, rollback-on-failure, and crash recovery pending | worktree smoke protects source HEAD, spec safety rejects repository symlink components, and cleanup requires confirmation | high |
| Run-state integrity | Relay contracts + runtime/CLI read boundaries | persisted `state.json` carries a seal over the state without the seal field; read, resume, cleanup, and report paths verify it before trusting state | signed state, authenticated ownership, key rotation, and durable crash recovery remain open | contract mutation rejection plus mission/store/resume evidence | high |
| Machine contracts | Relay `schemas/` + upstream SDK contracts | committed JSON Schemas describe mission, run/report, event, receipt, doctor, probe, and tool-result boundaries without replacing upstream validation | schema negotiation, generated compatibility tests, and version migration remain open | schema JSON parse/id/title smoke and aggregate acceptance runner | medium |
| Acceptance orchestration | Loop Engineering + Relay test suite | `tests/relay_acceptance.sh` runs the contract suite, every committed smoke, schema checks, and `git diff --check` | CI/release ownership, platform matrix, and external-provider gates remain open | 24 local smoke scripts plus contract suite | medium |
| Resource and cache bounds | Kujo runtime + Relay store | mission budgets, bounded process output, fixed subprocess PATH, bounded Agents SDK tool calls/turns, bounded tool-result bundle, atomic state, atomic index lock with four-attempt backoff, race-safe symlink probes, cache-consistent `updated_at` index metadata, missing-state cache rejection, single-scan registration, rebuildable index, and bounded per-directory artifact entries/depth | database-backed retention, crash recovery, and multi-host concurrency pending | output-budget, store/export, provider-tool, lock-contention stress, index metadata, missing-state, entry-overflow, and deep-tree smokes | medium |

## Current review delta

The shared path-component safety contract now also covers doctor dependency
targets and the trusted Agents SDK worker root/source. This closes the gap
between state-store safety and other local trust boundaries without creating a
second filesystem policy. The focused source checks, contract suite, and
dedicated dangling/parent symlink smoke provide local evidence; kernel no-follow
operations, authenticated ownership, and multi-host storage remain deferred.

The next review extends metadata-first probing to bounded JSON reads, JSONL
append, cancellation requests, and event inspection/watch. The watcher now
reuses one existence result per poll, improving local polling cost while
rejecting dangling evidence links immediately.

Sibling-tool subprocess adapters now align `PWD` with their execution cwd and
pass the Kujo module path where ChangeBucket requires it. This preserves the
existing subprocess ownership boundary while making version probes and mission
change evidence work from Relay's launch context.

The current contract suite also distinguishes safe relative sibling dependency
paths from strict state-store parent traversal. This prevents a security
hardening rule from breaking the normal sibling-repository composition path.

Event inspection/export now compare complete authoritative event records with
the JSONL log after chain validation; state-only payload or metadata divergence
is rejected. This keeps one local evidence history without creating a second
event store.

Read boundaries now require persisted `receipts.json` and identity-matching
`state.json`; embedded state and the rebuildable index are not accepted as
fallback evidence. Relative `KUJO_BIN` and sibling adapter paths are also
normalized against the Relay root before cwd changes, preserving truthful
cross-repository evidence under the Loop Engineering launch form.

The v61 review adds a state integrity seal and committed JSON Schemas for the
machine-facing boundaries. The seal is tamper evidence only; it does not claim
signed export or authenticated multi-user authority. The aggregate acceptance
runner removes drift between the documented verification command and the
committed smoke inventory.

The v67 review adds a pre-bridge 112 KiB AI request bound, a 1 MiB provider
response bound, 64 KiB per-call provider argument and duplicate-call-ID checks,
proxy-environment denial in shared subprocess policy, and 8 MiB event/receipt
write ceilings. PackWrite integration now verifies a safe generated
`agent/MASTER.md` before preflight can pass. Focused contract, provider-tool,
mission, Agents SDK, and input-boundary smokes provide local evidence; live
provider compatibility, durable retention, and authenticated ownership remain
deferred.

The v68 review closes a read-side evidence gap for provider-generated tools.
`runs verify` and valid `runs export` now require the persisted
`relay-tool-result-bundle-v1` artifact when state says provider tools ran, check
its run identity and SHA-256 against authoritative state, and include it in
machine-readable exports. The provider-tool smoke proves a valid bundle and a
tampered bundle failure; this remains local evidence rather than live-provider
dialect or enterprise-storage proof.
