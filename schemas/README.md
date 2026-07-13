# Relay machine contracts

These JSON Schemas describe the stable machine-facing shapes emitted by Relay.
They are interoperability contracts for Paperclip, Hermes, CI, MCP adapters,
and other Kujo programs; they do not replace Relay's fail-closed in-code
validation or the upstream schemas owned by AI SDK, Agents SDK, PackWrite,
RunLedger, ChangeBucket, and Eval.

The schemas are intentionally forward-compatible: unknown fields are allowed
so upstream evidence can be carried without Relay silently dropping it. The
`format` and `contract_version` fields identify the owning boundary.

| Schema | Boundary |
| --- | --- |
| `mission.schema.json` | `missions create` / `missions run` input |
| `run.schema.json` | persisted `state.json` and report JSON |
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
