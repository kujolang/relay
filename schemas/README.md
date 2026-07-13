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
| `receipt.schema.json` | persisted `RelayReceipt` records |
| `doctor.schema.json` | `doctor --json` |
| `probe.schema.json` | `models probe --json` |
| `tool-result.schema.json` | bounded `tools execute --json` result |
