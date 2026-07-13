# Relay command reference

Relay commands return process exit code `0` on success and nonzero on invalid input, policy denial, failed evidence, or failed provider execution. Add `--json` to machine-facing commands; JSON output is the stable integration surface and terminal prose is for humans.

## Environment

| Variable | Purpose | Default |
|---|---|---|
| `KUJO_BIN` | Kujo runtime binary | `../kujo/target/release/kujo` |
| `RELAY_ROOT` | Relay checkout used to resolve sibling tools | current directory |
| `RELAY_PACKWRITE_BIN` / `RELAY_RUNLEDGER_BIN` / `RELAY_CHANGEBUCKET_BIN` | Optional explicit sibling tool binaries | ecosystem release paths |
| `RELAY_EVAL_ENTRY` / `RELAY_CAPSULE_BIN` | Optional Eval entrypoint or Capsule binary | ecosystem paths |
| `RELAY_OFFLINE_FIXTURE` | Select deterministic fixture mode | `true` |
| `RELAY_WATCHDOG_URL` | Watchdog-compatible OpenAI base URL for live calls | required when live |
| `RELAY_WATCHDOG_PROXY_TOKEN` | Optional Watchdog proxy-route token forwarded as a bounded request header | unset |
| `RELAY_WATCHDOG_API_URL` | Optional Watchdog API base URL for health/config/request verification | derived from proxy URL |
| `RELAY_WATCHDOG_API_TOKEN` | Watchdog API token for authenticated telemetry verification | unset |
| `RELAY_WATCHDOG_VERIFY` | Require health, proxy-config, and correlated request-row verification after live AI calls | `false` |
| `RELAY_CORRELATION_ID` | Optional safe correlation ID for standalone chat/probe calls | generated |
| `RELAY_API_KEY_ENV` | Name of the provider credential environment variable | `OPENAI_API_KEY` |
| `RELAY_MODEL` / `RELAY_PROVIDER` | Defaults for model listing/probes | `gpt-4.1-mini` / `openai-compatible` |
| `RELAY_FALLBACK_MODEL` | Visible model fallback after a failed primary call | unset |

Boolean environment controls accept `true`, `false`, `1`, `0`, `yes`, and `no`
(case-insensitive, with surrounding whitespace ignored). Unrecognized or empty
values use the documented default; this keeps fixture mode fail-safe and makes
shell/CI environment conventions equivalent.

The AI bridge entrypoint is also fail-closed: `RELAY_AI_BRIDGE`, when set, must
resolve to a regular, non-symlinked `.kujo` file inside the configured Relay
root. `chat`, `models probe`, and `doctor` reject an external or unsafe bridge
before spawning Kujo, so an environment override cannot silently replace the
provider adapter with arbitrary source.

The launcher resolves Kujo from `KUJO`/`KUJO_BIN`, then `PATH`, then the sibling
release binary, and exports the resolved path as `KUJO_BIN`. Runtime adapters
apply the same trust boundary to configured PackWrite, RunLedger, ChangeBucket,
Eval, and Capsule dependencies: the target and its existing parent components
must resolve to regular, non-symlinked files before execution. Doctor reports
the raw configured path and its symlink posture, but never executes an unsafe
target.

The environment-backed AI, Agents SDK, and tool-worker JSON bridges reject
payloads larger than 128 KiB before parsing and return structured invalid-payload
errors. This protects the machine boundary and stays below common process
environment limits; larger future requests should use an authenticated file or
socket transport rather than an unbounded environment variable.

Run `relay doctor --json` before a live or CI invocation. Fixture mode does not require Watchdog or credentials; live mode fails closed when either is absent.

`relay doctor --repair --json` explicitly removes expired or exhausted Agents
SDK capability records from the local registry. Cleanup takes each record's
consumption lock and skips active records, reporting `locked` instead of
deleting them. The default doctor command is read-only. Both modes report
bounded registry posture counts and never emit capability secrets; the scan is
limited to 1024 records and fails closed on unsafe or malformed registry
paths.

Provider credential environment names also reject dynamic-loader, interpreter
injection, Git override, and trust-store override variables such as
`LD_PRELOAD`, `DYLD_INSERT_LIBRARIES`, `PYTHONPATH`, `BASH_ENV`,
`GIT_CONFIG_GLOBAL`, and `SSL_CERT_FILE` before the AI bridge is spawned.

Doctor also probes the configured Kujo, PackWrite, RunLedger, and ChangeBucket
executables for non-empty version output. Version probes run with bounded
timeouts and explicit environments; a failed required probe makes doctor
readiness fail with `version_probe_failed`. Override sibling tool roots with
`RELAY_PACKWRITE_ROOT`, `RELAY_RUNLEDGER_ROOT`, or `RELAY_CHANGEBUCKET_ROOT`
when their launchers are installed outside the default ecosystem checkout.

Deployments may optionally pin executable content with
`RELAY_KUJO_SHA256`, `RELAY_PACKWRITE_SHA256`, `RELAY_RUNLEDGER_SHA256`, and
`RELAY_CHANGEBUCKET_SHA256`. Each value must be a 64-character lowercase or
uppercase SHA-256 digest; a mismatch, malformed digest, missing file, or
symbolic-linked target is a required `doctor` failure. These pins are a local
integrity control, not a signed provenance or deployment-attestation system.

Relay also fails closed when `.relay` or `.relay/runs` is a symbolic link. This
prevents mission, index, and operator-control paths from redirecting evidence
outside the configured Relay root; the failure is reported as
`state_store_failure`.

All Relay symlink checks use the same fail-closed probe boundary. A missing
path is treated as absent, but a runtime error while inspecting an existing or
caller-supplied path is treated as unsafe. Symlink metadata is checked before
ordinary existence semantics so a dangling symlink cannot be misclassified as
an absent path. This prevents filesystem inspection failures from being
interpreted as proof that an evidence, workspace, worker, dependency, or
control path is safe. The state store also checks every existing parent path
component, so a symlinked directory above `.relay` or `.relay/runs` cannot
redirect evidence while the final path itself remains non-symbolic. The same
component walk now protects doctor dependency targets and the trusted Agents
SDK worker root/source; a symlinked parent fails readiness or worker binding
even when the leaf itself is not symbolic.

Bounded JSON reads, JSONL evidence appends, cancellation polling, event
inspection/export, and `runs watch` probe symlink metadata before ordinary
existence semantics. Dangling links therefore fail closed instead of becoming
missing artifacts; `runs watch` caches the existence result for each poll to
avoid repeating the same filesystem lookup.

## Commands

```text
relay doctor [--repair] [--json]
relay chat <prompt> [--model <id>] [--provider <id>] [--fixture] [--stream] [--json]
relay models list [--json]
relay models inspect <model> [--json]
relay models probe <model> [--fixture] [--json]
relay agents list|inspect <agent>|validate [--json]
relay missions create [spec.json] [--output <path>] [--json]
relay missions run <spec.json> [--fixture] [--pause-after-plan] [--skip-agent-smoke] [--json]
relay missions inspect|pause|resume|repair|cancel|cleanup|report <run-id> [--json]
relay runs list [--after <run-id>] [--limit <n>]|rebuild|inspect|verify|events|watch|sizes [--hashes]|changes|evaluations <run-id> [--json]
relay runs export <run-id> [--partial] [--output <path>] [--json]
relay tools execute --json (internal capability-bound worker callback)
relay benchmark run <repository> [--json]
```

`models list --json` and `models probe --json` expose a routing object with the
selection reason. The environment profile advertises
`tool_planning: "opt_in_provider_profile"` and
`tool_execution: "policy_bound_agents_sdk"`; fixture mode remains declared
mission-only. Provider-generated planning is opt-in per mission and remains
bounded by the explicit tool allowlist and Agents SDK policy worker.

## Mission contract

Mission specs are JSON objects with `name`, `goal`, a Git `repository`, `actions`, and optional `workflow`, `model`, `provider`, `allow_writes`, `approval`, `allowed_commands`, `acceptance_criteria`, `budgets`, bounded `agent_tools`, `agent_tool_mode`, and `agent_tool_allowlist` fields. Supported actions are deliberately narrow:

- `write_file`: relative path, only with `allow_writes: true` and `approval.approved: true`.
- `run_command`: read-oriented `git`, `kujo`, `bash scripts/`, or `sh scripts/` commands that pass policy. Commands are tokenized and executed as direct argv; shell pipelines, substitutions, globbing, tabs, and quoting expressions are rejected.

Shell-script execution is hash-pinned. A mission that allows `bash` or `sh` must
declare `allowed_script_hashes` mapping each `scripts/*.sh` path to its exact
64-character SHA-256. Relay verifies the regular, non-symbolic script and its
digest at validation and execution time; missing hashes, changed scripts, and
symlinked script paths are denied. This prevents a write-enabled mission or
repository mutation from turning the script allowance into arbitrary shell
authority.

Mission input files must be regular, non-symbolic files no larger than 1 MiB.
This bound applies before JSON parsing and persistence, preventing an
unbounded caller-controlled mission document from becoming run state or model
context. Action count and tool-call budgets remain separately bounded. Action
and declared-tool paths are capped at 4 KiB, command strings at 16 KiB, and
declared write content is checked against `max_write_bytes` before any worker
or external adapter starts.

The approved Git profile is intentionally narrow: `status`, `diff`,
`rev-parse`, `log`, and `show` with enumerated read-only options. Positional
pathspecs, unknown options, arbitrary Git subcommands, and script arguments are
rejected so a read-only-looking request cannot escape the workspace or widen
its authority through Git's option surface.

`agent_tools` is an opt-in list of `{name,input}` calls currently limited to
`relay.write_file` and `relay.run_command`. The Agents SDK Tool Registry and
approval provider run in `src/agent_bridge.kujo`; a capability-bound worker then
delegates to Relay's policy executor. It does not grant the Agents SDK direct
filesystem or shell authority. The worker rechecks write approval, command
timeout, and byte-budget bounds instead of trusting only the Agents SDK caller.
The worker capability is bound to a short-lived nonce that is not derived from
public run, session, or workspace identifiers; legacy deterministic capability
requests fail closed. Child processes use a fixed executable `PATH`, and unsafe
loader, interpreter, Git override, and trust-store environment names are
dropped before spawn.
Relay also issues a short-lived registry record per worker session. The record
stores only a digest of a parent-generated secret, binds the run/session/
workspace/nonce identity, expires after a bounded interval, and tracks a
bounded call budget under a lock. The secret crosses only the bounded parent /
child environment; each worker call consumes one allowance, replayed or delayed
calls fail closed, and the record is revoked when the worker exits. This closes
local replay within the capability lifetime but is not an authenticated remote
authorization system.
Interactive approvals and authenticated remote invocation are not yet enabled.
Worker model output, tool output, and worker error text are redacted before the
summary crosses the bridge; this is a local fail-closed filter, not a
substitute for provider-native classification or the deferred Redact
integration. The worker
also ignores or rejects payload-selected `relay_root` and `kujo_bin` values
unless they exactly match the trusted process environment, and refuses a
symbolic-linked or missing trusted Relay root.

Set `agent_tool_mode: "provider"` with a non-empty
`agent_tool_allowlist` to let the selected OpenAI-compatible provider propose
bounded calls. Relay sends only the allowlisted tool schemas through the
Watchdog → AI SDK path, normalizes function arguments, records a
`tool_plan_resolved` event, and hands the normalized calls to the existing
Agents SDK registry. A bounded `max_tool_turns` budget permits follow-up
requests containing the assistant tool call and typed `role: tool` results;
the verified bundle is persisted as `tool-results.json` and described by
`tool-result-bundle.schema.json`. Cancellation, malformed arguments,
unsupported tools, approval failures, tool-call limits, and tool-turn limits
fail closed. Provider-generated planning is not enabled by default.

Provider requests are rejected before the AI bridge when their serialized
payload exceeds 112 KiB, leaving headroom below the bridge's 128 KiB transport
ceiling. Provider responses larger than 1 MiB are rejected by the bridge.
That response-size failure is eligible for the configured model fallback;
request-size failures are not retried because the same context would exceed
the fixed boundary again.
Provider tool arguments are capped at 64 KiB per call and duplicate provider
call IDs fail closed so follow-up `role: tool` results cannot be ambiguously
correlated. Persisted `events.jsonl` and `receipts.json` evidence are each
capped at 8 MiB; exceeding a cap fails the run's evidence boundary rather than
creating an apparently complete but unreadable run.

`max_steps` and `max_repairs` are non-negative integers; `max_tokens`,
`max_tool_calls`, `max_tool_turns`, `max_output_bytes`, and `max_write_bytes`
must be positive. `max_tokens` is capped at 16,384, `max_repairs` at 4,
`max_tool_calls` at 16, and `max_tool_turns` at 4 per mission. Relay passes
the remaining token budget to every provider request and follow-up, so a low
mission budget cannot silently turn into the default 700-token provider
request. Negative provider usage is treated as zero for accounting. Output
and write budgets are capped at 8 MiB per mission; command timeouts must be
between 1 ms and 10 minutes. A budget failure is recorded as a failed run with
a typed failure class; it is never reported as completed. Provider
request/response and evidence-file ceilings are fixed Relay safety boundaries
rather than caller-widenable mission budgets.

## JSON evidence

A successful mission JSON result contains `run_id`, `status`, `current_step`, `budgets`, `events`, `receipts`, `artifacts`, `action_results`, `changes`, `evaluations`, `runledger`, and `runledger_finish`. Run artifacts live under `.relay/runs/<run-id>/` and include `state.json`, `events.jsonl`, `receipts.json`, `agent/`, `eval.json`, `changes.json`, `evaluations.json`, `report.json`, and `report.md` when the corresponding phase ran.

Event metadata includes the workflow, model, provider, packet revision, and
RunLedger run ID associated with the emission. A completed mission also writes
`receipts.json`, containing versioned SHA-256-sealed `RelayReceipt` references
for PackWrite, Agents SDK, model, tool, ChangeBucket, Eval, and RunLedger
artifacts. Each receipt also seals a context metadata object containing the
workflow, model, provider, packet revision, attempt, repair attempt, RunLedger
run ID, and AI correlation ID available at emission time. Receipt IDs are
included in the lifecycle events that create or complete those artifacts;
upstream tools remain the canonical artifact owners. Provider-generated
multi-turn missions additionally persist `tool-results.json`, a bounded
`relay-tool-result-bundle-v1` artifact containing redacted per-turn results,
provider call IDs, tool names, and the receipt-linked result payloads.

AI telemetry and bounded adapter/action results include non-negative
`duration_ms` values. These are elapsed local measurements for the bridge or
subprocess boundary, not provider billing, queue-time, or globally comparable
latency guarantees. Repository command action evidence also includes the
subprocess `exit_code` when Kujo provides one, allowing machine callers to
distinguish typed timeout/cancellation from an ordinary nonzero command result.

Failure classification is canonicalized before policy consumers see it. Relay
distinguishes cancellation, authentication, rate/allowance, timeout, policy,
workflow-definition, permission, malformed-tool, invalid-model-response,
missing-context, implementation, evaluation, repository, tool, and provider
failures. Specific policy and permission classes take precedence over the
generic tool class.

`--pause-after-plan` creates a supported checkpoint at `implementation`. `missions resume` executes the stored pending actions and reruns ChangeBucket and Eval. Arbitrary crash replay is not yet supported.

`missions cancel <run-id>` records a bounded cancellation request for a running
mission. The active runtime checks the request before and after each declared
action, passes the request to Kujo's process cancellation hook for an active
command, stops before the next action, emits a `run_cancelled` event, finishes
the RunLedger record with failure status, and preserves the request as
`cancel.request.json`. The request is bound to the run ID and sealed with an
integrity hash; copied, stale, or tampered requests fail closed. On Unix, Kujo
runs each spawned command in its own
process group so descendant processes do not keep cancellation pipes open. A
paused run can be cancelled immediately. Cancellation does not claim rollback
of repository changes; callers must wait for terminal state and inspect the
evidence before cleanup. Non-Unix runtimes retain the direct-child fallback.

Set `workspace_mode: "worktree"` to have Relay create a detached worktree from the immutable starting commit under the run directory. The source repository remains unchanged. The worktree is retained for inspection until an operator explicitly runs `missions cleanup <run-id> --confirm`; cleanup is refused while a run is active and is never implicit.

`runs list` validates the cached `.relay/index.json` against authoritative per-run `state.json` directories and rebuilds it when it is malformed, unsafe, stale, oversized, symlinked, or incomplete. Index refreshes use an atomic lock directory with a bounded four-attempt backoff; `runs rebuild` forces that recovery path. The index is a cache, not the source of truth. Machine callers may request a bounded deterministic window with `--limit 1..4096` and continue after the returned `next_after` run ID using `--after`; invalid limits and cursors fail closed. The full index is still validated before a response window is sliced.

`runs events`, `runs watch`, and `runs export` also require the persisted
`receipts.json` evidence file. They do not fall back to the copy embedded in
`state.json`: a missing, malformed, oversized, or symlinked receipt file is
reported as invalid evidence so an incomplete run cannot appear fully
receipted.

Run inspection also requires a bounded, regular `state.json` whose `run_id`
matches the requested identifier; the rebuildable index cannot substitute for
authoritative per-run state.

`runs changes` and `runs evaluations` require the same authoritative state and
their persisted JSON artifacts. Missing, malformed, oversized, symbolic-linked,
or wrong-shaped artifacts return a nonzero evidence failure instead of a
successful empty object or array.

Completion is fail closed across the required artifact boundary. A mission is
not completed when ChangeBucket, Eval, `report.json`/`report.md`, or the
RunLedger finish operation cannot be persisted and verified. The run records an
`evidence_failure`, a terminal `run_failed` event, and the failed finish result;
the `artifact_persistence` metadata identifies the required artifact checks.

`runs verify <run-id>` is a compact machine-facing integrity check. It validates
the authoritative state, complete event chain, persisted receipts, state/log
consistency, persisted ChangeBucket/Eval artifact shapes, and the JSON/Markdown
report identity and presence,
returning `relay-run-verification-v1` with individual boolean fields and
`integrity_valid`. Completed or packet-producing runs also require the
recursively verified `packet-manifest.json` (`relay-packwrite-manifest-v1`),
which covers every regular file in the PackWrite agent packet and detects
content, omission, addition, symlink, and path-integrity changes. It does not
repair, mutate, or replace any evidence.

`missions report <run-id>` also verifies that `report.json` matches the
authoritative run ID, mission ID, and status and that `report.md` is a bounded
regular file. A path-only response is never returned for missing or mismatched
report evidence.

Runtime adapters normalize relative `KUJO_BIN` and configured sibling-tool
paths against the Relay root before changing cwd. This preserves the
cross-repository adapter contract when Relay is launched from Loop Engineering,
a repository root, or another supported working directory; Relay does not fall
back to ambient `PATH` lookup for those tools.

Relay bounds JSON parsing at the store boundary as well as at the mission
boundary: the run index is rejected before parsing when it exceeds 8 MiB, lock
owner files are capped at 64 KiB, and authoritative run-state reads are capped
at 64 MiB. Oversized cache/evidence documents fail closed and trigger the
authoritative rebuild or an explicit missing-state error.

Each AgentEvent-compatible JSONL record includes a deterministic `integrity_sha256` field covering its identity, parent, payload, and metadata. The hash detects accidental or unauthorized record mutation; signed export and durable retention remain future work.

`runs export` refuses to claim a valid bundle unless `changes.json`,
`evaluations.json`, and both reports are present, bounded, regular, and have
the expected shapes and identity. A missing, mismatched, or incomplete result
or report is an incomplete export, not an empty successful field.

When authoritative run state records provider-generated Agents SDK tools,
`runs verify` and valid `runs export` additionally require `tool-results.json`
to be present, bounded, regular, a `relay-tool-result-bundle-v1` object for the
same run, and byte-for-byte consistent with the state-recorded SHA-256.
Tampering or deletion therefore invalidates the machine-facing verdict instead
of leaving tool execution as an unverified side artifact.

When a run records `packet_manifest_required`, `runs verify` and valid
`runs export` additionally require `packet-manifest.json` to be present,
bounded, regular, identity-consistent, and byte-for-byte consistent with the
state-recorded digest and recursive PackWrite file inventory. Older runs that
do not record the requirement remain readable for compatibility; new packet
artifacts fail closed if the manifest cannot be created.

For a paused or failed run whose post-verification artifacts were never
supposed to exist, `runs export <run-id> --partial` returns the explicit
`relay-run-export-partial-v1` contract. It reports `completeness: "partial"`,
`integrity_valid: false`, per-artifact presence, and null for unavailable
artifacts. The command is non-mutating and exits successfully only because the
caller explicitly requested an incomplete bundle. Partial export is refused
for completed runs; it never upgrades missing evidence into valid evidence.

`runs events` parses and verifies the complete event chain and checks its event
IDs and complete canonical records against authoritative run state before
returning it. State-only payload or metadata divergence fails closed. Event
inspection and export are bounded to an 8 MiB JSONL log to keep machine callers
memory-safe. Machine callers may request a verified bounded window with
`--limit 1..4096` and continue from the returned `next_after` event ID using
`--after`; the complete chain is still verified before slicing and paged
responses omit the redundant JSONL string.
`runs export` emits a versioned JSON bundle containing run state, verified
events, receipts, changes, evaluations, the final report, the recursive
PackWrite packet manifest, and provider tool results when present; it refuses to
export tampered, inconsistent, malformed, symbolic-linked, or non-regular
event/receipt evidence. Run JSON reads and event appends also reject symbolic
links rather than following them into another filesystem location.

`runs watch <run-id> --poll-ms <n> --timeout-ms <n>` emits each complete event
as a JSONL record while the run is active. Polling is bounded to 1–1000 ms and
the watch timeout to 1–600000 ms. The watcher verifies the event chain on every
poll, tolerates the short final state/file persistence race, and fails closed
on malformed, oversized, symlinked state, or terminally inconsistent evidence.

`runs sizes <run-id>` returns a versioned, read-only inventory of files and
directories under the run artifact directory, including total byte/file counts
and per-file sizes. The repository `workspace` subtree is always excluded and
reported in `excluded`; this prevents a large checkout from dominating an
artifact inspection. The inventory fails closed on symbolic links, unsupported
paths, more than 4096 artifact files, directory nesting deeper than 16 levels,
or more than 8 MiB of total artifact bytes. It does not delete, compact, rotate,
or retain artifacts, and its byte counts are local filesystem sizes rather than
storage-billing or transfer metrics. Add `--hashes` to opt into bounded SHA-256
digests for each regular artifact file; the default remains size-only to avoid
hashing overhead during routine inspection.

`chat --stream` emits normalized JSONL `delta` and `done` events. Relay forwards the stream option through the AI SDK bridge; live Watchdog proxy authorization is supplied through `RELAY_WATCHDOG_PROXY_TOKEN` and is never included in the model payload.

`RELAY_FALLBACK_MODEL` is attempted only for bounded transient or capability
failures such as timeouts, rate limits, provider unavailability, connection
failures, overload, or a missing primary model. Authentication, policy,
Watchdog-route, malformed-bridge, and other non-retryable failures do not
trigger a second provider call; the skipped reason remains visible in
`relay_telemetry`.

Mission planning also persists a `model_fallback_selected` or
`model_fallback_skipped` event and a typed `fallback` receipt when a configured
fallback policy is considered. This exposes the decision and retry ID without
replacing Watchdog or AI SDK telemetry.

Live AI calls also validate `RELAY_WATCHDOG_URL` before invoking the AI SDK. It
must be an `http://` or `https://` URL without embedded credentials; invalid
schemes and userinfo fail closed as `invalid_watchdog_route`. Plain HTTP is
allowed only for `localhost`, `127.0.0.1`, or `[::1]`; non-loopback Watchdog
hosts must use HTTPS.

`doctor --json` and `relay_telemetry.watchdog_route` report only non-secret route
posture (`configured`, `valid`, `scheme`, and a bounded failure reason). They
never echo the configured Watchdog URL, including when the value contains
rejected credentials.

Watchdog health/configuration failures are also endpoint-independent; doctor
returns a bounded failure class rather than a transport library error that
could contain the configured URL.

Correlation IDs are limited to 160 alphanumeric, hyphen, or underscore
characters before they are placed in Watchdog headers, telemetry, or request
queries. Invalid values are replaced with a generated safe ID.

Set `RELAY_WATCHDOG_VERIFY=true` to make live calls fail closed unless Relay can authenticate to Watchdog's API, verify health and proxy configuration, find the exact request row matching the AI SDK request ID and correlation ID, and reconcile normalized input/output/total token usage. Missing or mismatched usage is reported as `watchdog_telemetry_unverified`; sanitized status and reconciliation fields are retained. `doctor --json` performs the health/config portion of this check.

`missions resume` verifies the persisted mission-policy digest, run identity,
workspace ownership, Git metadata, event/receipt integrity, and effective
budgets before changing a paused run to `running`. A tampered checkpoint fails
as `state_integrity_failure` before any resumed tool or repository action.

`missions repair <run-id>` applies the same integrity checks to a failed run,
then permits one bounded replay only when the recorded failure class is
repairable (`timeout`, rate/allowance, provider, repository, tool,
implementation, or evaluation). The command increments `repair_attempts`,
binds a `repair_id`, emits typed repair receipts/events, and refuses policy,
authentication, malformed-authority, cancellation, evidence, or exhausted
budget failures. A repair replay reuses the persisted mission actions; adaptive
model selection and context mutation remain deferred.

`missions cleanup --confirm` applies the same policy-digest, run-owned
worktree, source-repository, Git-metadata, event, and receipt checks before
calling Git worktree removal. A tampered terminal state cannot redirect cleanup
to another repository.

Operator `missions pause` and `missions cancel` controls also verify the same
checkpoint state before mutating a non-terminal run. This keeps all local
control-plane mutations behind one integrity boundary.

State, receipt, and event persistence failures are recorded as
`evidence_failure`; the run is forced to `failed` before a terminal success can
be reported. Temporary-file cleanup is attempted when an atomic write fails.

Persisted `state.json` records carry an `integrity_sha256` seal over the state
without the seal field itself. Read, resume, cleanup, and report boundaries
verify that seal before trusting status, workspace, budget, or completion data.
If the seal is invalid, the rebuildable run index keeps the run discoverable but
marks its status as `integrity_invalid` rather than presenting the tampered
status as authoritative.
This is tamper evidence, not a signed multi-user authorization mechanism;
signed export and authenticated ownership remain deferred.

Machine callers can use the committed JSON Schemas under `schemas/` for
mission, run, report, AgentEvent, receipt, doctor, model probe, and tool-result
interoperability. The schemas are forward-compatible and supplement Relay's
in-code checks and the upstream SDK contracts.

`tests/relay_acceptance.sh` is the canonical local acceptance entrypoint. It
runs the Kujo contract suite, every committed `relay_*_smoke.sh` test (including
the schema smoke), and `git diff --check`, so newly added smoke tests are not
silently omitted from the documented verification path.

## Exit-code guidance

- `0`: command or mission succeeded and required evidence passed.
- `1`: user-visible failure such as invalid spec, policy denial, failed provider call, failed action, failed evaluation, or budget exhaustion.
- `2`: unknown top-level command or usage failure.
- `3`/`4`: runtime or Kujo interpreter failure; inspect stderr and the run directory if one exists.
