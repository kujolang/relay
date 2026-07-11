# Final Engineering Report

## What was discovered

Kujo already has nearly all important primitives: AI SDK provider normalization, Agents SDK contracts for agents/tools/approvals/budgets/events, Watchdog proxy telemetry, PackWrite packet compilation, RunLedger receipts, ChangeBucket diff analysis, Eval deterministic checks, Dispatch workflow state, Capsule discovery, Chain of Command roles, and Loop Engineering stop rules. The missing piece was a small composition runtime with a stable machine-facing boundary.

## What was reused and newly built

Reused directly: AI SDK normalized responses and fixture behavior, PackWrite CLI/validator, RunLedger CLI/records, ChangeBucket JSON, Eval config/checks, Capsule CLI shape, Chain of Command role locations, and AgentEvent-compatible field names. Newly built: Relay mission/run state, adapter boundary, policy-checked declarative actions, evidence aggregation, report surface, and CLI routing.

Deliberately not built: another provider client, another general workflow engine, another telemetry database, another packet schema, unrestricted shell access, adaptive model router, or a fake claim of live Ollama/Watchdog success.

## Verification

Passed locally with the pinned Kujo release runtime:

- `kujo run tests/relay_contract_tests.kujo --interpreter`
- fixture `relay chat` JSON and normalized stream output
- fixture mission with real write to `/tmp/relay-fixture-workspace`
- PackWrite generated and validated 13 artifacts
- RunLedger recorded a pass with starting commit and changed-file count
- ChangeBucket recorded the added file
- Eval passed `git diff --check`
- five AgentEvent-compatible lifecycle/artifact/tool/evaluation events were persisted
- pause/resume path persisted a resumable checkpoint and completion report

Not proven in this local session: live Ollama Cloud, live Watchdog proxy telemetry, multi-model Capsule A/B implementation scoring, Paperclip/Hermes invocation, and automated worktree provisioning. These are known limitations, not successful integrations.

## Ecosystem recommendations

1. Publish a supported cross-repository Kujo package/dependency mechanism so composition layers do not need subprocess adapters.
2. Add a single Agents SDK mission/workflow loader that can consume Chain of Command role metadata without product-specific prompt flattening.
3. Add a Watchdog client library or health/telemetry correlation contract for local Kujo runtimes.
4. Add RunLedger correlation fields for mission, workflow, step, packet revision, tool call, artifact, and evaluation IDs.
5. Add PackWrite packet revision/hash fields and an offline compiler mode with a first-class fixture flag.
6. Add ChangeBucket and Eval library APIs in addition to their CLIs for composition runtimes.

## Known limitations

The current run engine accepts explicit action plans instead of allowing an Agents SDK model to request tools. Agent roles are loaded as a small registry, not dynamically resolved from all Chain of Command definitions. `resume` is a checkpoint proof for the MVP and does not yet replay an interrupted step. Live Watchdog/Ollama and failure-repair flows require follow-up integration work.

## Repository handoff

Local commits are `22e9e84`, `b1d911e`, and `9292287`; the working tree is clean. Push was attempted and is blocked because this newly created local repository has no configured remote or push destination. No remote URL was inferred or added.
