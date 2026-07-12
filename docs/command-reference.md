# Relay command reference

Relay commands return process exit code `0` on success and nonzero on invalid input, policy denial, failed evidence, or failed provider execution. Add `--json` to machine-facing commands; JSON output is the stable integration surface and terminal prose is for humans.

## Environment

| Variable | Purpose | Default |
|---|---|---|
| `KUJO_BIN` | Kujo runtime binary | `../kujo/target/release/kujo` |
| `RELAY_ROOT` | Relay checkout used to resolve sibling tools | current directory |
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

Run `relay doctor --json` before a live or CI invocation. Fixture mode does not require Watchdog or credentials; live mode fails closed when either is absent.

## Commands

```text
relay doctor [--json]
relay chat <prompt> [--model <id>] [--provider <id>] [--fixture] [--stream] [--json]
relay models list [--json]
relay models inspect <model> [--json]
relay models probe <model> [--fixture] [--json]
relay agents list|inspect <agent>|validate [--json]
relay missions create [spec.json] [--output <path>] [--json]
relay missions run <spec.json> [--fixture] [--pause-after-plan] [--skip-agent-smoke] [--json]
relay missions inspect|pause|resume|cancel|cleanup|report <run-id> [--json]
relay runs list|rebuild|inspect|events|watch|sizes|changes|evaluations <run-id> [--json]
relay runs export <run-id> [--output <path>] [--json]
relay tools execute --json (internal capability-bound worker callback)
relay benchmark run <repository> [--json]
```

## Mission contract

Mission specs are JSON objects with `name`, `goal`, a Git `repository`, `actions`, and optional `workflow`, `model`, `provider`, `allow_writes`, `approval`, `allowed_commands`, `acceptance_criteria`, `budgets`, and bounded `agent_tools` fields. Supported actions are deliberately narrow:

- `write_file`: relative path, only with `allow_writes: true` and `approval.approved: true`.
- `run_command`: read-oriented `git`, `kujo`, `bash scripts/`, or `sh scripts/` commands that pass policy. Commands are tokenized and executed as direct argv; shell pipelines, substitutions, globbing, tabs, and quoting expressions are rejected.

Mission input files must be regular, non-symbolic files no larger than 1 MiB.
This bound applies before JSON parsing and persistence, preventing an
unbounded caller-controlled mission document from becoming run state or model
context. Action count and tool-call budgets remain separately bounded.

The approved Git profile is intentionally narrow: `status`, `diff`,
`rev-parse`, `log`, and `show` with enumerated read-only options. Positional
pathspecs, unknown options, arbitrary Git subcommands, and script arguments are
rejected so a read-only-looking request cannot escape the workspace or widen
its authority through Git's option surface.

`agent_tools` is an opt-in list of `{name,input}` calls currently limited to
`relay.write_file` and `relay.run_command`. The Agents SDK Tool Registry and
approval provider run in `src/agent_bridge.kujo`; a capability-bound worker then
delegates to Relay's policy executor. It does not grant the Agents SDK direct
filesystem or shell authority. Provider-generated tool planning, interactive
approvals, and authenticated remote invocation are not yet enabled.

Budget fields are non-negative integers: `max_steps`, `max_repairs`, and `max_tokens`; `max_tool_calls`, `max_output_bytes`, and `max_write_bytes` must be positive. Agents SDK tool calls are capped at 16 per mission and the configured `max_tool_calls` limit is enforced inside the worker. Output and write budgets are capped at 8 MiB per mission; command timeouts must be between 1 ms and 10 minutes. A budget failure is recorded as a failed run with a typed failure class; it is never reported as completed.

## JSON evidence

A successful mission JSON result contains `run_id`, `status`, `current_step`, `budgets`, `events`, `receipts`, `artifacts`, `action_results`, `changes`, `evaluations`, `runledger`, and `runledger_finish`. Run artifacts live under `.relay/runs/<run-id>/` and include `state.json`, `events.jsonl`, `receipts.json`, `agent/`, `eval.json`, `changes.json`, `evaluations.json`, `report.json`, and `report.md` when the corresponding phase ran.

Event metadata includes the workflow, model, provider, packet revision, and
RunLedger run ID associated with the emission. A completed mission also writes
`receipts.json`, containing versioned SHA-256-sealed `RelayReceipt` references
for PackWrite, Agents SDK, model, tool, ChangeBucket, Eval, and RunLedger
artifacts. Receipt IDs are included in the lifecycle events that create or
complete those artifacts; upstream tools remain the canonical artifact owners.

AI telemetry and bounded adapter/action results include non-negative
`duration_ms` values. These are elapsed local measurements for the bridge or
subprocess boundary, not provider billing, queue-time, or globally comparable
latency guarantees.

`--pause-after-plan` creates a supported checkpoint at `implementation`. `missions resume` executes the stored pending actions and reruns ChangeBucket and Eval. Arbitrary crash replay is not yet supported.

`missions cancel <run-id>` records a bounded cancellation request for a running
mission. The active runtime checks the request before and after each declared
action, stops before the next action, emits a `run_cancelled` event, finishes
the RunLedger record with failure status, and preserves the request as
`cancel.request.json`. A paused run can be cancelled immediately. Cancellation
does not kill an already-running external process or claim rollback; callers
must wait for terminal state and inspect the evidence before cleanup.

Set `workspace_mode: "worktree"` to have Relay create a detached worktree from the immutable starting commit under the run directory. The source repository remains unchanged. The worktree is retained for inspection until an operator explicitly runs `missions cleanup <run-id> --confirm`; cleanup is refused while a run is active and is never implicit.

`runs list` validates the cached `.relay/index.json` against authoritative per-run `state.json` directories and rebuilds it when it is malformed, unsafe, stale, oversized, symlinked, or incomplete. Index refreshes use an atomic lock directory with a bounded four-attempt backoff; `runs rebuild` forces that recovery path. The index is a cache, not the source of truth.

Relay bounds JSON parsing at the store boundary as well as at the mission
boundary: the run index is rejected before parsing when it exceeds 8 MiB, lock
owner files are capped at 64 KiB, and authoritative run-state reads are capped
at 64 MiB. Oversized cache/evidence documents fail closed and trigger the
authoritative rebuild or an explicit missing-state error.

Each AgentEvent-compatible JSONL record includes a deterministic `integrity_sha256` field covering its identity, parent, payload, and metadata. The hash detects accidental or unauthorized record mutation; signed export and durable retention remain future work.

`runs events` parses and verifies the complete event chain and checks its event
IDs against authoritative run state before returning it. Event inspection and
export are bounded to an 8 MiB JSONL log to keep machine callers memory-safe.
`runs export` emits a versioned JSON bundle containing run state, verified
events, receipts, changes, evaluations, and the final report; it refuses to
export tampered, inconsistent, malformed, symbolic-linked, or non-regular
event/receipt evidence. Run JSON reads and event appends also reject symbolic
links rather than following them into another filesystem location.

`runs watch <run-id> --poll-ms <n> --timeout-ms <n>` emits each complete event
as a JSONL record while the run is active. Polling is bounded to 1–1000 ms and
the watch timeout to 1–600000 ms. The watcher verifies the event chain on every
poll, tolerates the short final state/file persistence race, and fails closed
on malformed, oversized, or terminally inconsistent evidence.

`runs sizes <run-id>` returns a versioned, read-only inventory of files and
directories under the run artifact directory, including total byte/file counts
and per-file sizes. The repository `workspace` subtree is always excluded and
reported in `excluded`; this prevents a large checkout from dominating an
artifact inspection. The inventory fails closed on symbolic links, unsupported
paths, or more than 4096 artifact files. It does not delete, compact, rotate,
or retain artifacts, and its byte counts are local filesystem sizes rather than
storage-billing or transfer metrics.

`chat --stream` emits normalized JSONL `delta` and `done` events. Relay forwards the stream option through the AI SDK bridge; live Watchdog proxy authorization is supplied through `RELAY_WATCHDOG_PROXY_TOKEN` and is never included in the model payload.

`RELAY_FALLBACK_MODEL` is attempted only for bounded transient or capability
failures such as timeouts, rate limits, provider unavailability, connection
failures, overload, or a missing primary model. Authentication, policy,
Watchdog-route, malformed-bridge, and other non-retryable failures do not
trigger a second provider call; the skipped reason remains visible in
`relay_telemetry`.

Set `RELAY_WATCHDOG_VERIFY=true` to make live calls fail closed unless Relay can authenticate to Watchdog's API, verify health and proxy configuration, and find a request row matching the correlation ID emitted by the AI SDK request. `doctor --json` performs the health/config portion of this check.

## Exit-code guidance

- `0`: command or mission succeeded and required evidence passed.
- `1`: user-visible failure such as invalid spec, policy denial, failed provider call, failed action, failed evaluation, or budget exhaustion.
- `2`: unknown top-level command or usage failure.
- `3`/`4`: runtime or Kujo interpreter failure; inspect stderr and the run directory if one exists.
