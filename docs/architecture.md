# Relay architecture

This page is the current implementation map. Read it before the historical
[architecture decision records](architecture-decisions.md); the ADRs explain
why individual decisions landed, while this page describes the system as it
exists now.

## Runtime flow

Relay has one executable path:

```text
main.kujo
  -> src/cli.kujo       parse, validate, dispatch, render
  -> src/runtime.kujo   mission lifecycle and run state transitions
  -> src/policy.kujo    workspace, command, and tool authority
  -> src/adapters.kujo  bounded provider and ecosystem subprocesses
  -> .relay/runs/...    authoritative state and evidence
  -> src/store*.kujo    validated, rebuildable run index
```

A mission follows this sequence:

```text
mission JSON -> bounded parse and validation -> workspace provisioning
-> provider planning -> policy-checked actions and agent tools
-> ChangeBucket and Eval -> sealed state, events, receipts, and report
```

Fixture mode stops at deterministic local adapters. Live model traffic must
pass through Watchdog; there is no direct live-provider fallback.

Read-side commands follow a separate, fail-closed path:

```text
validated run index -> authoritative state -> event and receipt verification
-> required artifact verification -> inspect, verify, watch, or export result
```

The index is a cache. Per-run state and evidence remain authoritative.

## Source ownership

| File | Owns | Does not own |
| --- | --- | --- |
| `src/cli.kujo` | CLI grammar, command dispatch, output shaping, read-side evidence presentation | Mission state transitions or provider calls |
| `src/runtime.kujo` | Mission validation, lifecycle transitions, action execution, evidence production, pause/cancel/resume/cleanup/retention | CLI rendering or provider implementation |
| `src/policy.kujo` | Path, command, script, and tool authorization | Filesystem mutation or subprocess orchestration |
| `src/adapters.kujo` | Trusted dependency paths, bounded subprocess calls, provider/tool normalization | Mission policy |
| `src/capabilities.kujo` | Agent-tool capability issuance, locking, consumption, revocation, and repair posture | General filesystem/process helpers |
| `src/common.kujo` | Shared value, JSON, path, process, atomic-write, and redaction primitives | Domain lifecycle state |
| `src/contracts.kujo` | Versioned state/event/receipt constructors and integrity inputs | Persistence |
| `src/store.kujo` | Safe run discovery, cache validation, locking, rebuild, backend selection | Authoritative run behavior |
| `src/store_sqlite.kujo` | Optional SQLite index implementation | Per-run evidence |
| `src/watchdog.kujo` | Route validation and telemetry reconciliation | Provider execution |
| `src/doctor.kujo` | Environment and dependency posture | Repair beyond explicitly supported local cleanup |
| `src/enterprise.kujo` | Experimental contract import, machine authorization, handoff, signed export, aggregate metrics | Hosted service transport or tenancy |
| `src/agent_bridge.kujo` / `src/ai_bridge.kujo` | Narrow subprocess entrypoints into sibling SDKs | Relay mission authority |

## Safety invariants

- Public CLI and JSON behavior is versioned; compatibility rules live in
  [compatibility.md](compatibility.md).
- Mission writes require both declared write authority and approval.
- Commands are tokenized direct argv and checked against explicit profiles.
- External executables and environment forwarding are bounded and explicit.
- Parsed JSON documents are limited to 1 MiB by the pinned runtime. Event
  JSONL and bounded artifact inventories use separate 8 MiB envelopes.
- State, event, receipt, capability, and required artifact persistence fails
  closed.
- Symlink and real-path checks are authority controls, not optional validation.
- Cleanup and retention are confirmation-gated and revalidate exact targets.

## Where to make common changes

| Task | Start here | Usually verify with |
| --- | --- | --- |
| Add or change a CLI option | `src/cli.kujo` command function and `help_text` | `tests/relay_cli_smoke.sh`, `tests/relay_cli_contract_smoke.sh` |
| Change mission parsing or budgets | `src/runtime.kujo::load_spec` | `tests/relay_contract_tests.kujo`, mission/budget smoke tests |
| Add a mission action | `src/runtime.kujo::execute_action`, then `src/policy.kujo` | policy contract tests plus a focused mission smoke test |
| Add an agent tool | `src/adapters.kujo::tool_schema`, normalization, then runtime execution | `tests/relay_agents_tool_smoke.sh` |
| Change run inspection/export | read-side helpers and `cmd_runs` in `src/cli.kujo` | `tests/relay_store_smoke.sh`, schema smoke tests |
| Change persistence | `src/store.kujo`; use `src/store_sqlite.kujo` only for backend-specific behavior | store, SQLite, state-store safety, and lock stress tests |
| Change provider routing | `src/adapters.kujo`, `src/watchdog.kujo`, bridge files | Watchdog and provider-tool smoke tests |
| Change a machine contract | `src/contracts.kujo` or `src/enterprise.kujo`, matching schema and compatibility docs | contract and schema suites |

The aggregate entrypoint is `tests/relay_acceptance.sh`; the complete release
gate is `scripts/release_gate.sh`.
