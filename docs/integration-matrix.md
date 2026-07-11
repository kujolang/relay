# Integration Matrix

| Capability | Preferred existing owner | Reuse method | Required adaptation | MVP test/evidence | Risk |
|---|---|---|---|---|---|
| Provider communication | AI SDK | `src/ai_bridge.kujo` | runtime payload adapter | fixture response; live provider pending | medium |
| Agent execution | Agents SDK + Chain of Command | registry and compatible event fields | full runner wiring pending | agent validation + role paths | medium |
| AI telemetry | Watchdog | configured proxy URL | startup/health/correlation adapter pending | route metadata; live Watchdog pending | high |
| Mission packet | PackWrite | fake-response `init`, validate generated pack | revision/digest recorded; canonical whole-pack manifest pending | 13-file validated pack + SHA-256 evidence | medium |
| Execution evidence | RunLedger | `start`/`finish` subprocess calls | attach all event IDs in notes pending | pass receipt with git commit | low |
| Repository changes | ChangeBucket | `--json --repo` | workcell orchestration pending | added-file change report | low |
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
| Workspace isolation | Git worktree/workcell conventions | user-provided isolated repo | automated worktree creation pending; realpath parent checks added | `/tmp` Git fixture + symlink/traversal policy tests | high |
