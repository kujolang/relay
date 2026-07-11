# Ecosystem Discovery Report

## Scope and evidence

The local checkout was inspected on 2026-07-10/11 across the Kujo language/runtime, SDKs, agent definitions, workflows, and operational tools. Existing repository status was clean before Relay work. Evidence commands included `find`, `rg`, each repository's README/source/test layout, and offline smoke execution for the new slice. The Kujo runtime used for verification was `kujo/target/release/kujo`.

## Capability inventory

| Component | Maturity observed | Contract worth reusing | Relay treatment |
|---|---|---|---|
| `kujo` | mature runtime/compiler checkout | `main.kujo`, `src/`, `kujo.toml`, `kujo run`, deterministic tests | direct runtime |
| `ai-sdk` | production-oriented, fixture-backed, provider-gated | normalized chat response, provider metadata, retries, streaming, structured output, host policy | adapter via `src/ai_bridge.kujo` |
| `agents-sdk` | production-oriented primitives; integration metadata still experimental | agent config, runner, tools, approvals, handoffs, artifacts, budgets, AgentEvent lifecycle | registry and compatible event envelope; full runner integration deferred |
| `watchdog` | strong local-first proxy/telemetry layer | `/proxy/v1`, `/api/requests`, SQLite telemetry, redaction, auth/rate limits | live path selected by `RELAY_WATCHDOG_URL`; fixture bypass explicit |
| `packwrite` | usable local-first pack compiler; model generation needs provider/fake seam | `agent/` pack shape and validation | invoked with fake-response seam for deterministic packet proof |
| `runledger` | usable receipt store with git metadata, usage, cost, reports | `start`, `finish`, `list`, `show`, JSON records | invoked for every mission run |
| `changebucket` | usable read-only diff/risk analyzer | JSON diff/change budget report | invoked after repository actions |
| `eval` | strong deterministic evaluation runner | `eval.json`, command/file/JSON checks, reports and summaries | invoked for acceptance checks |
| `dispatch` | mature composition/control example with state, trace, approval, retry, handoff, reports | workflow state and bridge patterns | boundary reference; not duplicated |
| `benchmarks-capsule` | deterministic, fixture-scale handoff capsule CLI | `make`, `inspect`, `validate`, checksums | benchmark discovery adapter |
| `kujo-agents` | useful role contracts, broad Chain of Command | role `AGENT.md`/`SKILL.md`, planner/developer/reviewer/verifier ranks | loaded by registry paths |
| `kujo-workflows/loop-engineering` | portable bounded loop harness | Goal → Context → Act → Evaluate → Record → Stop | used as execution design and loop gate |
| `casefile` | deterministic failure evidence bundle | redacted case artifacts | deferred adapter for failed runs |
| `fence` | architecture/import boundary checker | zones, baseline, reports | release hardening, not runtime state |
| `muzzle` | quiet workflow runner | JSON workflow summaries/log paths | optional operator wrapper |
| `scent`/`scout` | context-pack and codebase intelligence tools | context packs, manifests, redaction | useful pre-mission context, not MVP dependency |
| `spec` | mature task contract validator/exporter | `.spec.yml`, envelope and Eval export | upstream mission authoring candidate |
| `redact` | deterministic sanitization/audit | model-ready redacted context and leakage checks | required for sensitive future adapters |
| `mcp` | guarded local server/framework and repo generator | least-privilege tools, path roots, safe command map | future machine adapter |
| `shipcheck`/`concord`/`patchbrief` | release/drift/diff evidence tools | release and artifact consistency reports | post-MVP gates |
| `rag`/`intake`/`howl` | domain-specific supporting tools | retrieval, ingestion, deterministic showcase artifacts | out of MVP |

## Current-state execution map

The proven MVP path is:

```text
CLI → Relay runtime → role registry → AI SDK bridge → fixture or configured endpoint
                             ↘ PackWrite packet
                              ↘ controlled actions → isolated repository
                               ↘ ChangeBucket → Eval → RunLedger + AgentEvent JSONL + report
```

The live Watchdog route is selected when `RELAY_WATCHDOG_URL` is set and fixture mode is off. The local proof deliberately used AI SDK fixture mode, so it proves the SDK contract and response normalization but does not claim a live Watchdog or Ollama Cloud request.

## Gaps and cautions

- Cross-repository Kujo imports are not a stable package dependency mechanism in this checkout; Relay uses narrow subprocess adapters and an AI SDK bridge rather than copying large runtimes.
- Agents SDK exposes strong runner/tool contracts, but a product-level mission loader and Chain of Command resolver are not a single existing API.
- Dispatch already owns a broad workflow state machine. Relay must remain a composition layer and should eventually delegate declarative workflow execution rather than grow a second engine.
- PackWrite's fake-response seam is ideal for deterministic tests, but live packet generation needs credentials and should never be conflated with fixture proof.
- Capsule's current contract is repository discovery, not the full two-model implementation benchmark requested by the mission.
- Existing `kujo-agents/tools/proofpack.py` is a supporting evidence utility, not an application architecture; Relay does not depend on it.
