# Architecture Decision Records

## ADR-001: New composition repository

Context: Dispatch, Agents SDK, and the workflow kits each own adjacent but different concerns. Decision: create `relay` as a thin composition/runtime repository. Rationale: adding mission coordination to any one subsystem would blur ownership. Consequence: adapters must preserve upstream contracts and report unavailable integrations honestly. Rejected: replacing Dispatch or embedding a second provider SDK.

## ADR-002: Library-first runtime with thin CLI

Context: Paperclip, Hermes, CI, MCP, and humans need the same operation surface. Decision: `src/runtime.kujo` owns state transitions and evidence; `src/cli.kujo` only parses and renders. Rationale: machine callers should not depend on terminal prose. Consequence: the runtime's JSON state is the integration boundary.

## ADR-003: Explicit mission/run vocabulary

Context: existing tools use run, workflow, task, packet, and report with distinct meanings. Decision: mission is the requested bounded objective; run is one execution; workflow is the selected step template. Rationale: matches Dispatch and RunLedger without collapsing their ownership.

## ADR-004: Adapter composition over copied implementations

Context: Kujo currently has no stable cross-repository package import contract for these repos. Decision: use narrow subprocess adapters plus one AI SDK bridge. Rationale: avoids a third provider/tool contract and proves the actual CLIs. Consequence: process startup and path configuration are explicit risks.

## ADR-005: Watchdog is the live AI route

Context: Watchdog owns proxying and telemetry; AI SDK owns normalized provider calls. Decision: live requests use `RELAY_WATCHDOG_URL` as the configured compatible base URL, while fixture mode is explicitly marked as a no-network bypass. Rationale: preserves provider independence and avoids an unverified fake telemetry claim.

## ADR-006: Deterministic completion authority

Context: model claims are not evidence. Decision: completion requires action success plus Eval success; ChangeBucket and RunLedger artifacts are persisted regardless. Rationale: follows Eval and Loop Engineering contracts. Consequence: model-generated plans and adaptive repair are deferred.

## ADR-007: Declarative, least-privilege actions

Context: unrestricted shell/filesystem authority is unsafe. Decision: MVP accepts explicit `write_file` and allowlisted `run_command` actions, with approval metadata, realpath workspace checks, deny patterns, and `allow_writes`. Rationale: makes authority inspectable and testable. Consequence: agents cannot yet invent arbitrary tool calls.

## ADR-008: File artifacts plus JSONL events

Context: RunLedger, PackWrite, ChangeBucket, and Eval already produce inspectable files. Decision: keep run state/report JSON, human Markdown, and AgentEvent-compatible JSONL under one run directory, append JSONL with the Kujo append primitive, and record artifact digests. Rationale: simple resume/export, bounded write cost, and machine-readable integrity evidence without a parallel database.

## ADR-009: Explicit subprocess environment

Context: Kujo's process contract supports `inherit_env`, `env_allow`, `env_deny`, and explicit `env` values, while AI and evidence tools need only a small set of runtime variables. Decision: Relay subprocess adapters disable wholesale environment inheritance, allow baseline runtime variables, and add only explicitly supplied variables; live provider credentials are passed to the AI bridge only when selected by `RELAY_API_KEY_ENV`. Rationale: reduce accidental secret exposure and make process authority auditable. Consequence: a host with unusual tool-specific environment requirements must configure an explicit adapter seam rather than relying on ambient state.

## ADR-010: Fail-closed live routing and bounded execution

Context: Watchdog owns live AI telemetry, and mission state needs explicit stop conditions. Decision: live AI calls require `RELAY_WATCHDOG_URL`; fixture mode is the only direct AI SDK bypass. Mission specs may override non-negative step, repair, and token budgets, and budget exhaustion fails the run with evidence. Rationale: prevent silent telemetry bypass and uncontrolled work. Consequence: `doctor` reports missing live prerequisites and operators must choose `--skip-agent-smoke` explicitly when startup validation is intentionally deferred.

## ADR-011: Operator-facing health and probe commands

Context: a showcase needs a truthful first-run path and machine-callable diagnostics. Decision: add `doctor --json` for dependency/agent/route/credential posture and `models probe` for a minimal fixture or configured-live model call. Rationale: make environment failures actionable without introducing a service layer or placeholder command. Consequence: probes remain bounded checks, not provider certification or benchmark results.

## ADR-012: Explicit detached worktree mode

Context: repository-writing missions must not mutate a caller's source checkout by default, while some local workflows need a real Git workspace. Decision: `workspace_mode: "provided"` preserves the explicit existing behavior; `workspace_mode: "worktree"` resolves an immutable starting commit, creates a detached worktree for the run, records source/worktree/commit metadata, and retains the result until an operator runs `missions cleanup <run-id> --confirm`. Rationale: provide a real isolation primitive without pretending it is a container or identity boundary. Consequence: full workcell isolation, rollback-on-failure, and crash recovery remain follow-up work; cleanup is destructive and therefore explicit.

## ADR-013: Forward streaming and Watchdog proxy authorization through the AI SDK

Context: Relay's stream flag previously stopped at the runtime boundary, and authenticated Watchdog proxy routes need a header without exposing the proxy token in the model request payload. Decision: Relay passes `stream` and optional `X-Watchdog-Proxy-Token` request headers through the existing AI SDK options boundary; the token is injected only into the bounded bridge environment. Rationale: preserve provider independence and keep Watchdog ownership of proxy authentication. Consequence: fixture chat emits normalized JSONL, while true live provider and Watchdog correlation remain environment-dependent.

## ADR-014: Per-run state is authoritative over the run index

Context: a shared JSON index can be malformed, torn, stale, or last-writer-wins under concurrent local processes. Decision: treat `.relay/runs/<run-id>/state.json` as authoritative, validate cached index paths, rebuild from safe run directories when the cache is invalid or incomplete, and expose `runs rebuild`. Rationale: improve recovery without inventing a second database before a locking/storage contract is selected. Consequence: the cache is self-healing but not yet a full multi-process transaction store.

## ADR-015: Explicit mission resource budgets

Context: bounded action count and tokens do not bound repository file writes, command output, or command lifetime. Decision: add positive output/write byte budgets capped at 8 MiB and command timeout validation capped at ten minutes; preserve truncation markers in action evidence. Rationale: reduce denial-of-service and oversized-artifact risk while keeping evidence inspectable. Consequence: missions needing larger limits require a deliberate future storage/workcell policy rather than silently inheriting unlimited process behavior.

## ADR-016: Opt-in fail-closed Watchdog verification

Context: routing a live AI call through Watchdog is necessary but does not by itself prove that the proxy is healthy or that the request was persisted under the intended Relay run correlation. Decision: when `RELAY_WATCHDOG_VERIFY=true`, Relay calls Watchdog's authenticated health, proxy-configuration, and correlation query endpoints and marks the AI result unsuccessful if any required check fails. Correlation is sent through the AI SDK bridge as observation headers and the verification adapter returns only sanitized status fields. Rationale: preserve Watchdog ownership of telemetry while making the evidence boundary executable and provider-independent. Consequence: enabled live calls require a reachable, correctly authenticated Watchdog API; returned telemetry rows and summaries are never copied into Relay output. Rejected: direct Watchdog SQLite reads, trusting route metadata alone, or treating a local HTTP stub as production evidence.

## ADR-017: Execute mission commands as direct argv

Context: policy-denying shell metacharacters still left an unnecessary `/bin/sh -lc` interpreter in the repository-writing path. Decision: tokenize the already restricted command string and execute it through `/usr/bin/env -C <workspace> <argv>` without a shell. Rationale: remove shell parsing, command substitution, globbing, and quoting ambiguity from the tool boundary while preserving the existing allowlist. Consequence: mission commands intentionally support simple allowlisted argv forms; shell pipelines and quoted shell expressions are rejected rather than interpreted.

## ADR-018: Lock the rebuildable index and integrity-seal events

Context: per-run state is authoritative, but concurrent index refreshes could still lose cache updates and JSONL event records had no local tamper signal. Decision: serialize index refreshes with an atomic lock directory, validate cached status against each run's state, reject oversized/symlinked index files, and add deterministic SHA-256 integrity fields to AgentEvent-compatible records. Rationale: improve local concurrency and evidence review without prematurely inventing a database or replacing RunLedger. Consequence: the index remains a rebuildable cache, lock recovery is bounded/stale-aware, and durable retention, export signing, and multi-host storage remain follow-up work.

## ADR-020: Keep subprocess resolution explicit and bind tool workers to their workspace

Context: Relay launches Git, Kujo, and sibling ecosystem tools through bounded subprocess adapters, while the Agents SDK bridge delegates tool calls to a worker process. An inherited PATH and a command-line-only capability made executable substitution and worker-scope confusion harder to audit. Decision: bounded subprocess environments use a fixed system PATH, worker capabilities are passed through the child environment rather than argv, and the capability digest binds run ID, session ID, workspace, and worker purpose. Agent tool calls also have a validated 16-call ceiling and mission-configured limit. Rationale: reduce PATH hijacking and prevent a capability issued for one mission workspace from being replayed against another. Consequence: custom executable locations must be configured through absolute adapter paths, and provider-generated tool planning remains deferred.

## ADR-021: Verify event chains before machine export

Context: individual AgentEvent hashes detect payload mutation, but consumers could still read a reordered, duplicated, truncated, or malformed JSONL stream as if it were valid evidence. Decision: `runs events` parses and verifies event hashes, parent ordering, and unique IDs; `runs export` refuses invalid logs and emits a versioned bundle containing verified events, state, changes, evaluations, and report data. Rationale: give Paperclip, CI, and future machine callers a truthful evidence boundary without inventing a second event store. Consequence: tampered or partially written logs fail closed; signed export and durable retention remain future work.

## ADR-022: Treat event-log completeness as part of evidence validity

Context: a valid hash chain can still be a truncated prefix after a crash or partial copy. Decision: `runs events` and `runs export` compare the parsed event IDs and order with authoritative `state.events`, enforce an 8 MiB inspection bound, and fail closed on missing, oversized, malformed, or sequence-inconsistent logs. Rationale: prevent machine callers from mistaking a valid prefix for a complete run. Consequence: a crash between event append and state persistence is surfaced as an evidence inconsistency for repair rather than silently accepted; durable append-only storage remains future work.

## ADR-023: Put execution context in every Relay event

Context: RunLedger, model, provider, workflow, and packet revision were present in run state but not consistently attached to each AgentEvent-compatible record, making downstream correlation more expensive. Decision: Relay enriches event metadata with workflow, model, provider, packet revision, and RunLedger run ID before resealing the event integrity hash. Rationale: make machine inspection and future Paperclip/Hermes adapters able to correlate evidence without reconstructing context from neighboring files. Consequence: lifecycle receipt IDs now cover the core artifact path; retry, repair, escalation, approval, and cancellation IDs still need typed receipts as their workflows mature.

## ADR-019: Use the Agents SDK Tool Registry behind a Relay policy worker

Context: explicit Relay actions provide deterministic authority, but they do not prove that an Agents SDK agent can request a tool while preserving Relay's workspace and command policy. Decision: mission specs may opt into a narrow `agent_tools` list. A Kujo bridge registers the existing Agents SDK Tool Registry and approval provider, then delegates each approved call to a separate Relay worker process through a capability-bound JSON request. The worker calls Relay's existing policy-checked tool executor; the mission records the summarized result as a signed lifecycle event. Rationale: reuse Agents SDK registry and approval contracts without moving repository authority into the SDK or creating a competing tool protocol. Consequence: one isolated fixture mission and approval-denial path are proven, while provider-driven model tool planning, cancellation, richer tool-result artifacts, and authenticated service mode remain open. Rejected: giving the Agents SDK direct filesystem/shell access, or duplicating its registry and approval semantics inside Relay.

## ADR-024: Use a Relay receipt index over canonical ecosystem artifacts

Context: event metadata correlated runs, but tool, model, packet, ChangeBucket, Eval, and RunLedger evidence still required consumers to infer relationships from filenames and neighboring events. Decision: Relay emits a versioned, SHA-256-sealed `RelayReceipt` index at `receipts.json`; each receipt names its run, step, agent, artifact reference, status, and source payload, and relevant lifecycle events carry the receipt ID. `runs events` and `runs export` verify receipt integrity and exact agreement with authoritative run state before returning evidence. Rationale: provide typed cross-artifact references without replacing RunLedger, PackWrite, ChangeBucket, or Eval as canonical owners. Consequence: receipts improve local correlation and tamper detection, while signed export, durable retention, provider-generated tool loops, and richer retry/repair receipts remain future work. Rejected: copying upstream artifact stores into Relay or treating the receipt index as an independent source of truth.

## ADR-025: Allow only explicit read-only Git argv profiles

Context: shell-free execution removed shell injection, but broad string-prefix checks could still permit unintended Git subcommands or arbitrary pathspec reads through an otherwise approved `git` command. Decision: tokenize mission commands and allow only exact read-only Git subcommands with a small option catalog; reject positional pathspecs, unknown options, destructive subcommands, and script arguments. Rationale: least privilege must constrain the resulting argv, not only the human-readable prefix. Consequence: repository missions can inspect status, bounded diffs, logs, shows, and safe metadata, while advanced Git queries must be added as explicit policy profiles with tests. Rejected: accepting arbitrary read-only-looking Git strings or returning to shell parsing.

## ADR-026: Use bounded lock backoff for the rebuildable index

Context: the local index is a validated cache and concurrent `runs rebuild` callers can briefly contend on its atomic lock. Immediate failure wastes otherwise safe work, while an unbounded wait would hide a stuck writer and weaken operational predictability. Decision: `persist_run_index` retries lock acquisition at most four times with a 20 ms linear backoff; stale-lock recovery remains bounded and authoritative per-run state remains the source of truth. Rationale: improve local multi-process throughput without turning the cache into a durable database or an uncontrolled synchronization point. Consequence: lock stress now has executable evidence; durable multi-host storage, retention, and crash recovery remain separate work.

## ADR-027: Add a bounded live run-event watcher

Context: file-backed AgentEvent JSONL is durable and verifiable, but operators and machine callers otherwise must poll or wait for a mission command to finish before seeing progress. Decision: add `runs watch <run-id>` as a bounded polling watcher that emits each complete AgentEvent-compatible record once, verifies the hash chain on every poll, waits through the final state/file handoff race, and fails closed on malformed, oversized, or inconsistent terminal evidence. Rationale: provide a useful live observation surface without introducing a daemon, second event store, or unbounded follow process. Consequence: local callers can stream mission progress with explicit timeout/poll bounds; true remote sinks, durable subscriptions, and multi-host event fan-out remain future work.

## ADR-028: Record bounded adapter duration metrics

Context: Relay preserved token usage and provider correlation but did not expose elapsed time for AI bridge calls, tool commands, or evidence adapters, making performance regressions and queue/provider comparisons harder to inspect. Decision: every bounded subprocess adapter records non-negative `duration_ms`; AI telemetry and action evidence expose the elapsed value, while existing canonical RunLedger/Watchdog ownership remains unchanged. Rationale: add useful performance evidence without a second metrics backend or unbounded high-cardinality logging. Consequence: local reports can compare call/tool/evidence latency; token cost, queue time, provider availability, and durable metrics aggregation remain future work.

## ADR-029: Add read-only run artifact size inspection

Context: Relay had bounded duration evidence but no machine-readable way to inspect the local disk footprint of a run before future retention or export work. Decision: add `runs sizes <run-id>` as a read-only inventory over the persisted run artifact directory, always exclude and report the repository `workspace` subtree, reject symbolic links and unsupported paths, and cap the inventory at 4096 files. Rationale: provide safe operational evidence without inventing a retention owner or scanning an unbounded repository checkout. Consequence: operators and CI can compare local artifact footprints, while rotation, compaction, retention, transfer metrics, and durable multi-host storage remain deferred. Rejected: deletion/retention flags in the CLI, following links, or counting workspace bytes as Relay-owned evidence.

## ADR-030: Use cooperative cancellation at action boundaries

Context: Relay exposed pause/resume but had no truthful `missions cancel` operation, while forcibly killing arbitrary provider or repository subprocesses would create unsafe partial-work and evidence races. Decision: `missions cancel <run-id>` writes a validated request artifact; the runtime checks it before and after each declared action, transitions the run to `cancelled`, emits a sealed `run_cancelled` event, finishes RunLedger evidence, and preserves the request. Paused runs can transition immediately. Rationale: provide a useful machine-facing stop control without pretending to implement process-group termination, rollback, distributed cancellation, or identity-aware authorization. Consequence: a currently-running external action may finish before cancellation takes effect; callers must inspect terminal evidence and use explicit cleanup. Rejected: silently marking a running process cancelled, killing arbitrary descendants, or treating cancellation as rollback.

## ADR-031: Reject symbolic-linked evidence files

Context: Relay already rejected symbolic-linked run directories and size-inventory entries, but generic JSON reads, JSONL appends, and event inspection could otherwise follow an attacker-replaced artifact symlink. Decision: `read_json_or` and `append_jsonl` reject symbolic links/non-regular files, while `runs watch`, `runs events`, and `runs export` fail closed when `events.jsonl` is symbolic-linked or non-regular. Rationale: prevent evidence redirection and accidental writes outside the run root while preserving the existing atomic write path. Consequence: symlinked evidence is surfaced as invalid and must be repaired; stronger kernel-level no-follow primitives, multi-user ownership, and durable storage isolation remain platform work. Rejected: following links because their target appears readable or trusting only the run-directory path.

## ADR-032: Bound mission-spec files before parsing

Context: Relay bounded action count, budgets, and tool calls but accepted any caller-provided mission path and parsed its entire contents before persistence. Decision: `load_spec` requires an existing regular non-symbolic file no larger than 1 MiB before JSON parsing; larger or symbolic-linked inputs fail closed with explicit errors. Rationale: bound memory, parse, prompt, and state amplification at the first input boundary without constraining repository workspaces or legitimate mission actions. Consequence: larger workflows must use a future versioned packet or durable workflow owner; authenticated input identity and schema negotiation remain deferred. Rejected: parsing first and relying only on action-count limits, or silently truncating a mission document.

## ADR-033: Bound persisted JSON before parsing

Context: mission inputs and event logs had size checks, but the run index,
lock-owner metadata, and state/evidence readers could still parse a large
attacker-controlled JSON document before a later validation noticed its size.
Decision: use a bounded JSON reader at persisted-store boundaries: index files
are capped at 8 MiB, lock owners at 64 KiB, and run state at 64 MiB before
parsing. Oversized inputs fail closed and let the authoritative rebuild or
caller-facing error path decide the outcome. Rationale: make the memory bound
apply before parsing, not merely after parsing. Consequence: corrupted or
larger future stores need an explicit migration/retention owner; limits do not
claim durable multi-host storage. Rejected: trusting the JSON parser to absorb
arbitrary cache growth or silently truncating evidence.

## ADR-034: Restrict model fallback to retryable failures

Context: `RELAY_FALLBACK_MODEL` previously retried every failed primary call,
including authentication, policy, Watchdog-route, and malformed-bridge errors.
Decision: attempt fallback only for explicitly bounded transient or model
capability failures; skip it for non-retryable failures and record the reason
in `relay_telemetry`. Rationale: avoid duplicate unauthorized/expensive calls,
preserve policy failures, and make routing behavior predictable. Consequence:
providers that expose novel retryable codes require an explicit adapter update;
adaptive routing remains deferred. Rejected: blanket fallback on every error or
silently hiding the second call.

## ADR-035: Bind Agents SDK worker paths to trusted environment

Context: the Agents SDK bridge used payload-supplied `relay_root` and
`kujo_bin` values to launch the policy worker, while its capability digest
covered the workspace but not the executable or source root. Decision: worker
launch paths must match trusted `RELAY_ROOT` and `KUJO_BIN` environment values;
the bridge rejects mismatches and missing or symbolic-linked Relay roots before
launching. Rationale: prevent a caller-controlled payload from redirecting an
otherwise valid workspace capability into another runtime or source tree.
Consequence: embedding applications must configure worker paths in the
process environment, and authenticated service ownership remains deferred.
Rejected: trusting payload paths because the workspace capability is valid, or
adding executable paths to a user-controlled mission packet.

## ADR-036: Bound environment-backed bridge payloads before parsing

Context: the AI bridge, Agents SDK bridge, and tool-worker CLI receive JSON
through environment variables, but those machine-callable boundaries parsed
the entire value and malformed JSON could surface as raw interpreter failures.
Decision: cap each environment-backed payload at 128 KiB before parsing and
return structured invalid or oversized-payload errors; larger future requests
must use an authenticated file or socket transport. Rationale: enforce a
pre-parse resource bound that is practical below common process environment
limits and make machine failures stable. Consequence: very large prompts or
tool plans need a future transport contract; the mission-file boundary remains
1 MiB because it is file-backed. Rejected: relying on OS argument limits,
parsing unbounded environment strings, or silently truncating JSON.

## ADR-037: Validate Watchdog routes before live AI invocation

Context: Relay already required a Watchdog URL for live calls, but the adapter
could pass a malformed scheme or credential-bearing URL onward to the AI SDK
before Watchdog verification ran. Decision: live calls require an HTTP(S)
Watchdog URL without embedded userinfo before any provider subprocess starts;
invalid routes return a structured `invalid_watchdog_route` failure. Rationale:
keep provider routing and credential-bearing endpoints behind the Relay safety
boundary and make route failures deterministic. Consequence: local deployments
must use a plain configured URL and put authentication in the explicit token
environment seams; custom schemes require a future adapter contract. Rejected:
letting the downstream SDK decide route safety or validating only when optional
Watchdog verification is enabled.
