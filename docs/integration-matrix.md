# Integration Matrix

| Capability | Preferred existing owner | Reuse method | Required adaptation | MVP test/evidence | Risk |
|---|---|---|---|---|---|
| Provider communication | AI SDK | `src/ai_bridge.kujo` | runtime payload adapter; stream option and optional Watchdog proxy header forwarded through the AI SDK; live calls fail closed without Watchdog URL | fixture response, normalized stream JSONL, model probe, blocked-live test; live provider pending | medium |
| Agent execution | Agents SDK + Chain of Command | role registry plus a bounded Agents SDK runner bridge | provider-driven model tool planning and richer role loading pending | agent validation + isolated mission Tool Registry smoke | medium |
| AI telemetry | Watchdog | configured proxy URL plus `src/watchdog.kujo` HTTP adapter | authenticated health/config/correlation verification is opt-in; returned telemetry is sanitized | local contract stub and real Watchdog + stub-provider smoke; external-provider evidence pending | high |
| Mission packet | PackWrite | fake-response `init`, validate generated pack | revision/digest recorded; canonical whole-pack manifest pending | 13-file validated pack + SHA-256 evidence | medium |
| Execution evidence | RunLedger | `start`/`finish` subprocess calls plus AgentEvent-compatible JSONL | Relay receipt index adds sealed typed references and context metadata for RunLedger, model, tool, PackWrite, ChangeBucket, and Eval evidence; upstream stores remain canonical | pass receipt with Git commit, workflow/model/provider/packet/attempt context, correlated event context, receipt tamper, store recovery, truncation/tamper, event-integrity, and export smokes | low |
| Live run observation | Relay CLI + AgentEvent contract | bounded `runs watch` over the existing JSONL event stream; parses only newly appended complete lines plus a pending partial line, rejects replacement/truncation/disappearance, and validates the chain only when the raw stream changes | poll/timeout bounds, remote sinks, durable subscriptions, and multi-host fan-out remain open | concurrent watch smoke with complete event stream, terminal `run_completed`, incremental parser path, and disappearance fail-closed smoke | medium |
| Mission cancellation | Relay runtime + Kujo `spawn_process` + RunLedger | cooperative `missions cancel` request is passed as `cancel_file` to active commands; Kujo terminates Unix process groups and Relay records the terminal transition | rollback, non-Unix descendant guarantees, distributed cancellation, and identity-aware authorization remain open | 30-second descendant cancellation returns within eight seconds with terminal `run_cancelled` and no completion event | high |
| Action failure classification | Relay policy + runtime + RunLedger | cancellation and timeout are preserved as distinct `cancelled` and `timeout` action/evidence classes instead of generic tool failures | provider-specific taxonomy, retry/repair receipts, and cross-system normalization remain open | contract classification checks and cancellation smoke assert the persisted action class | medium |
| Timeout process ownership | Kujo `spawn_process` + Relay runtime | bounded command timeout terminates the Unix process group, preserves `timed_out`, and records `failure_class: timeout` | non-Unix process-tree guarantees, rollback, and workcell ownership remain open | 30-second descendant timeout returns within 12 seconds with no orphan and typed terminal evidence | high |
| Performance evidence | AI SDK/Watchdog + Relay adapters | bounded subprocess `duration_ms` propagated into telemetry and action/evidence results | aggregate metrics, cost normalization, and provider availability remain upstream concerns | fixture chat/mission metrics smoke | medium |
| Artifact size inspection | Relay run store boundary | read-only `runs sizes` inventory for persisted run artifacts, with workspace exclusion, a 4096-file bound, and a 16-level directory-depth bound | rotation, compaction, retention, resumable export, and durable storage ownership remain open | fixture size inventory plus symlink and deep-tree fail-closed smoke | medium |
| Evidence path safety | Relay common/CLI boundaries | JSON reads, JSONL appends, event inspection, export, workspace controls, dependency checks, and Agents SDK worker binding reject symbolic-linked or non-regular files; metadata-first probing catches dangling links, probe errors fail closed, and missing paths remain absent | complete no-follow atomic filesystem primitives and multi-user ownership remain upstream/platform concerns | contract probe-error check, dedicated dangling-link smoke, store smoke, worker smoke, and symlink rejection coverage | high |
| Mission input safety | Relay runtime loader | regular-file, non-symlink, 1 MiB mission-spec bound before JSON parsing | schema negotiation, authenticated caller identity, and richer streaming input remain open | oversized and symlink mission-spec smoke | high |
| Persisted JSON safety | Relay common/store/CLI boundaries | bounded pre-parse readers for index, lock owner, run state, receipts, and export-side artifacts | durable schema migration, compaction, and no-follow kernel primitives remain open | contract bounded-read checks plus oversized-index store smoke | high |
| Model fallback policy | AI SDK adapter boundary | fallback only for explicit transient/capability classes; non-retryable reasons are visible and skipped | adaptive routing, provider-specific taxonomy, and cost aggregation remain open | contract retryable/non-retryable classification checks | high |
| Worker executable authority | Agents SDK bridge + Relay worker | `relay_root` and `kujo_bin` are bound to trusted environment values and unsafe roots are rejected before spawn | authenticated caller identity, signed binaries, and workcell isolation remain open | tampered-root Agents SDK smoke | high |
| Bridge payload safety | AI SDK, Agents SDK, and Relay CLI boundaries | environment-backed JSON is capped at 128 KiB and malformed payloads return structured errors before parse/use | authenticated file/socket transport and larger prompt contracts remain open | input-boundary smoke | high |
| Live route safety | Relay AI adapter + Watchdog contract | live calls and `doctor --json` reject malformed/credential-bearing routes, dangerous provider credential environment names, allow HTTP only for loopback, require HTTPS for remote Watchdog hosts, and expose only non-secret posture in diagnostics and AI telemetry | authenticated route discovery, certificate policy, and provider-specific network controls remain open | contract and CLI invalid-route/credential-environment/doctor/telemetry-redaction smoke | high |
| Correlation input safety | Relay AI adapter + Watchdog contract | accept only bounded alphanumeric/hyphen/underscore correlation IDs before forwarding them in headers, telemetry, or Watchdog query parameters | authenticated caller identity and distributed correlation ownership remain open | contract delimiter checks plus CLI replacement smoke | high |
| Watchdog diagnostic disclosure | Relay Watchdog adapter + doctor | normalize health/configuration transport failures to endpoint-independent errors before diagnostics or run telemetry | authenticated error taxonomy and remote incident correlation remain open | unreachable-route doctor redaction smoke | high |
| Dependency integrity | Relay doctor + filesystem boundary | required runtime, entrypoint, source, SDK, ecosystem-tool, and registry paths must have the expected type and must not be symbolic links; doctor also runs bounded Kujo/PackWrite/RunLedger/ChangeBucket version probes and optionally verifies configured SHA-256 pins with explicit environments | signed dependency manifests, semantic compatibility ranges, provenance, and deployment ownership remain open | fixture doctor path/version/hash assertions plus symlinked Kujo runtime and wrong-hash rejection | high |
| Resume state authority | Relay runtime + event/receipt contracts | paused runs bind the mission policy digest, workspace identity, Git metadata, effective budgets, event chain, and receipt sequence before resuming | signed state, crash recovery, multi-user ownership, and durable storage remain open | contract and tampered-resume smoke | high |
| Worktree cleanup authority | Relay runtime + Git worktree contract | confirmed cleanup revalidates policy digest, run-owned worktree path, source repository, Git metadata, event chain, and receipts before `git worktree remove --force` | signed state, authenticated ownership, rollback, and crash recovery remain open | worktree tamper smoke plus cleanup contract | high |
| Control-plane mutation authority | Relay runtime + checkpoint contract | `pause` and `cancel` revalidate checkpoint state before mutating a non-terminal run | signed state, authenticated ownership, and distributed control remain open | contract and cancellation/resume smokes | high |
| Evidence persistence authority | Relay common/runtime contracts | state, receipt, and event write failures mark `evidence_failure`, force failed status before terminal reporting, clean failed atomic-write temps, and read boundaries require persisted receipt/state evidence instead of embedded/index fallbacks | durable append-only storage, fsync semantics, and crash recovery remain open | contract failure injection, missing receipt/state probes, and full mission evidence | high |
| Run verification | Relay CLI + existing evidence contracts | `runs verify` aggregates authoritative state, complete events, persisted receipts, ChangeBucket, Eval, and report shape checks into `relay-run-verification-v1`; valid export fails closed and explicit partial export is versioned separately | signed manifests, upstream correlation IDs, durable storage, and authenticated partial-export authorization remain open | store smoke positive verdict plus missing changes/evaluations/export-report and paused partial-export cases | medium |
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
| Tools | Agents SDK registry/MCP patterns | `src/agent_bridge.kujo` registers `relay.write_file` and `relay.run_command`; worker delegates to `execute_tool_request` with workspace-bound capability and tool-call budget | broader tool catalog, model-driven tool loops, typed tool-result artifact persistence, and authenticated service mode pending | isolated mission tool, approval denial, and budget denial smokes | high |
| Workspace isolation | Git worktree/workcell conventions | `workspace_mode: worktree` provisions a detached worktree from an immutable commit; provided mode remains available | full workcell/container isolation, rollback-on-failure, and crash recovery pending | worktree smoke protects source HEAD and requires confirmed cleanup | high |
| Resource and cache bounds | Kujo runtime + Relay store | mission budgets, bounded process output, fixed subprocess PATH, bounded Agents SDK tool calls, atomic state, atomic index lock with four-attempt backoff, race-safe symlink probes, cache-consistent `updated_at` index metadata, single-scan registration, rebuildable index, and bounded artifact depth | database-backed retention, crash recovery, and multi-host concurrency pending | output-budget, store/export, tool-budget, lock-contention stress, index metadata, and deep-tree smokes | medium |

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
