# Relay machine contracts

These JSON Schemas describe the stable Relay v1 machine-facing shapes.
They are interoperability contracts for Paperclip, Hermes, CI, MCP adapters,
and other Kujo programs; they do not replace Relay's fail-closed in-code
validation or the upstream schemas owned by AI SDK, Agents SDK, PackWrite,
RunLedger, ChangeBucket, and Eval.

The schemas are intentionally forward-compatible: unknown fields are allowed
so upstream evidence can be carried without Relay silently dropping it. The
`format` and `contract_version` fields identify the owning boundary.

`mission.schema.json` requires mission version `1.0.0` or the supported legacy
`0.1.0` format and bounds the aggregate mission token budget to 65,536. Each
provider request remains capped at 16,384 and receives no more than the
remaining mission budget. Unsupported or missing mission versions fail before
execution.

Product `1.0.0` does not rename the existing `v1` event, receipt, run, export,
verification, sizes, tool-result, packet-manifest, or capability identifiers.
Those identifiers describe their own compatibility generations. Additive
fields are allowed where `additionalProperties` permits them; incompatible
changes require a new schema ID/file, migration notes, and old/new fixtures.
See [`docs/compatibility.md`](../docs/compatibility.md).

| Schema | Boundary |
| --- | --- |
| `chat.schema.json` | `chat --json` |
| `models.schema.json` | `models list|inspect --json` |
| `agents.schema.json` | `agents list|inspect|validate --json` |
| `benchmark.schema.json` | `benchmark run --json` wrapper result |
| `mission.schema.json` | `missions create` / `missions run` input |
| `run.schema.json` | persisted `state.json` and report JSON |
| `run-export.schema.json` | complete verified `runs export` response |
| `run-export-partial.schema.json` | explicit incomplete `runs export --partial` response |
| `signed-export.schema.json` | separate HMAC-authenticated `runs export --signed` wrapper |
| `aggregate-metrics.schema.json` | bounded `runs metrics` summary |
| `failure-handoff.schema.json` | redacted, confirmed failed-run handoff |
| `machine-access.schema.json` | authenticated machine authorization result |
| `event.schema.json` | AgentEvent-compatible `events.jsonl` records |
| `event-bundle.schema.json` | verified `runs events` response, including paged windows |
| `run-bundle.schema.json` | validated `runs list` response, including paged windows |
| `run-index-record.schema.json` | cache record exposed inside a validated run index response |
| `receipt.schema.json` | persisted `RelayReceipt` records |
| `doctor.schema.json` | `doctor --json` |
| `probe.schema.json` | `models probe --json` |
| `tool-result.schema.json` | bounded `tools execute --json` result |
| `tool-result-bundle.schema.json` | persisted provider-generated tool results for a bounded multi-turn mission |
| `run-verification.schema.json` | `runs verify --json` integrity verdict |
| `run-sizes.schema.json` | `runs sizes --json`, including optional artifact digests |
| `packet-manifest.schema.json` | recursive PackWrite packet integrity manifest |
