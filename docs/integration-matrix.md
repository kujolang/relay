# Integration Matrix

| Capability | Preferred existing owner | Reuse method | Required adaptation | MVP test/evidence | Risk |
|---|---|---|---|---|---|
| Provider communication | AI SDK | `src/ai_bridge.kujo` | runtime payload adapter; stream option and optional Watchdog proxy header forwarded through the AI SDK; live calls fail closed without Watchdog URL | fixture response, normalized stream JSONL, model probe, blocked-live test; live provider pending | medium |
| Agent execution | Agents SDK + Chain of Command | registry and compatible event fields | full runner wiring pending | agent validation + role paths | medium |
| AI telemetry | Watchdog | configured proxy URL plus `src/watchdog.kujo` HTTP adapter | authenticated health/config/correlation verification is opt-in; returned telemetry is sanitized | local contract stub and real Watchdog + stub-provider smoke; external-provider evidence pending | high |
| Mission packet | PackWrite | fake-response `init`, validate generated pack | revision/digest recorded; canonical whole-pack manifest pending | 13-file validated pack + SHA-256 evidence | medium |
| Execution evidence | RunLedger | `start`/`finish` subprocess calls plus AgentEvent-compatible JSONL | attach all event IDs in notes pending; local event hashes and locked rebuildable index improve integrity | pass receipt with git commit, store recovery, and event-integrity contract smoke | low |
| Repository changes | ChangeBucket | `--json --repo` | workcell orchestration pending; mission budgets bound action count | added-file change report and budget failure smoke | low |
| Evaluation | Eval | generated `eval.json`, run command | richer multi-step suites pending | passing `git diff --check` | low |
| Capsule context | Capsule | `capsule make` adapter | A/B benchmark loop pending | discovery command | medium |
| Routing | AI SDK model preferences; Dispatch patterns | explicit model profile fields | adaptive routing deferred | models list and telemetry reason | medium |
| Context compression | Scent/Muzzle | pre/post workflow integration | no runtime dependency in MVP | discovery inventory | medium |
| Authority | Agents SDK approvals + MCP/Fence patterns | Relay policy for declarative actions | Agents SDK approval-provider bridge pending | denied write/command tests; explicit mission approval now required | high |
| Failure evidence | CaseFile | deferred command adapter | capture failed run bundle | failure classification contract | medium |
| Release verification | ShipCheck/Concord | deferred release workflow | report aggregation | docs and contract tests | medium |
| Secrets/output | Redact + Watchdog redaction | documented boundary | redaction adapter pending | no secret fixtures in output | high |
| Agent definitions | Kujo Agents | role registry paths | dynamic discovery pending | validate/list/inspect | low |
| Workflow definitions | Spec + Dispatch + Loop Engineering | JSON mission slice | declarative loader pending | verified-feature spec | medium |
| Tools | Agents SDK registry/MCP patterns | policy-checked `write_file`, `run_command` | SDK Tool contract bridge pending | action evidence | high |
| Workspace isolation | Git worktree/workcell conventions | `workspace_mode: worktree` provisions a detached worktree from an immutable commit; provided mode remains available | full workcell/container isolation, rollback-on-failure, and crash recovery pending | worktree smoke protects source HEAD and requires confirmed cleanup | high |
| Resource and cache bounds | Kujo runtime + Relay store | mission budgets, bounded process output, atomic state, atomic index lock, rebuildable index | database-backed retention, crash recovery, and multi-host concurrency pending | output-budget, store, and index-lock smokes | medium |
