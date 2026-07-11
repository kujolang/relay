# Kujo Relay

Kujo Relay is a Kujo-native composition and execution layer for bounded agent missions. The CLI is a thin wrapper over reusable runtime modules. It composes existing AI SDK, Agents SDK, PackWrite, RunLedger, ChangeBucket, Eval, Capsule, and Chain of Command contracts instead of replacing them.

Status: `0.1.0` vertical slice. Offline fixture execution is verified locally. Live provider and Watchdog proxy paths are configuration-gated and require environment credentials/services.

## Quick start

```bash
export KUJO_BIN=/Users/robertdevore/2026/Kujolang/kujo-repos/kujo/target/release/kujo
./bin/relay agents validate --json
./bin/relay chat "Summarize the mission boundary" --fixture --json
./bin/relay chat "Stream a short answer" --fixture --stream
```

Run a real bounded repository mutation in a disposable isolated Git workspace:

```bash
git init /tmp/relay-fixture-workspace
git -C /tmp/relay-fixture-workspace config user.email relay@example.invalid
git -C /tmp/relay-fixture-workspace config user.name Relay
touch /tmp/relay-fixture-workspace/README.md
git -C /tmp/relay-fixture-workspace add README.md
git -C /tmp/relay-fixture-workspace commit -m baseline
./bin/relay missions run examples/fixture-mission.json --fixture --json
./bin/relay runs list --json
```

The run writes a PackWrite agent pack, AgentEvent-compatible JSONL, RunLedger receipt, ChangeBucket result, Eval result, resumable state, and Markdown/JSON reports under `.relay/runs/<run-id>/`.

## Provider configuration

Relay uses the AI SDK provider boundary through `src/ai_bridge.kujo`. Fixture mode is default for safe local operation. A live call requires a configured OpenAI-compatible endpoint and key:

```bash
export RELAY_OFFLINE_FIXTURE=false
export RELAY_WATCHDOG_URL=http://127.0.0.1:7700/proxy/v1
export OPENAI_API_KEY=...
./bin/relay chat "hello" --model gpt-4.1-mini --provider openai-compatible --json
```

For Ollama Cloud or another compatible service, keep the provider-specific details in the AI SDK-compatible endpoint configuration. Relay does not interpret vendor response formats. `RELAY_WATCHDOG_URL` routes normal live calls through Watchdog; fixture mode explicitly records `direct_ai_sdk` as a deterministic no-network bypass.

## CLI surface

Implemented and truthful in this slice:

- `chat`, including normalized stream events and JSON output
- `models list|inspect`
- `agents list|inspect|validate`
- `missions create|run|inspect|pause|resume|report`
- `runs list|inspect|events|changes|evaluations`
- `benchmark run` for the Capsule discovery slice

Not yet implemented: adaptive routing, model-generated tool plans, full multi-step Dispatch workflow loading, interactive approval UI, live Ollama Cloud proof, and the complete Capsule A/B benchmark rubric. Those remain explicit follow-up work rather than placeholder commands.

## Safety boundary

Mission actions are declarative and policy checked. Writes require `allow_writes: true` and relative paths. Commands must match an explicit allowlist and deny destructive, credential, force-push, and traversal patterns. Relay does not expose unrestricted shell, root, credential files, publishing, or production access.

## Repository map

- `main.kujo`: thin CLI entrypoint
- `src/runtime.kujo`: mission state machine, actions, evidence, resume
- `src/adapters.kujo`: subprocess adapters to existing Kujo tools and AI SDK
- `src/contracts.kujo`: Relay run and AgentEvent-compatible contracts
- `src/policy.kujo`: authority and failure classification
- `src/registry.kujo`: Chain of Command role registry
- `docs/`: discovery report, integration matrix, ADRs, plan, final report
- `tests/relay_contract_tests.kujo`: deterministic contract tests
