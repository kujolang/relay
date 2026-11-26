# Relay v1 compatibility policy

Relay uses semantic versioning for the product and independent identifiers for machine contracts. The product version describes the shipped CLI and implementation; it does not imply that every embedded format has the same number.

| Surface | Current | Relay 1.x guarantee |
| --- | --- | --- |
| Relay product/CLI | `1.1.0` | patch releases preserve behavior; minor releases may add optional surface; incompatible CLI changes require Relay 2.0 |
| Mission files | `1.0.0` | `1.0.0` is current; `0.1.0` remains accepted throughout Relay 1.x; missing/unknown versions fail before action |
| Persisted run state/report | `relay-run-v1` | additive fields allowed; identity, status meaning, integrity input, and required evidence cannot be weakened |
| Events | `AgentEvent-compatible-v1` | existing required fields, parent ordering, identity, and integrity meaning remain stable |
| Receipts | `relay-receipt-v1` | existing correlation and integrity fields remain stable; upstream tools remain canonical owners |
| Complete export | `relay-run-export-v1` | complete verified evidence only; missing required evidence remains failure |
| Partial export | `relay-run-export-partial-v1` | always explicit, incomplete, and `integrity_valid: false` |
| Signed export wrapper | `relay-signed-export-v1` | explicit HMAC-SHA256 wrapper; unsigned v1 remains unchanged; key ID and payload digest retain meaning |
| Aggregate metrics | `relay-aggregate-metrics-v1` | bounded to 4096 validated local runs; dimensions remain low-cardinality |
| Failure handoff | `relay-failure-handoff-v1` | failed/cancelled, confirmed, redacted handoff only |
| Verification response | `relay-run-verification-v1` | boolean verdict fields retain meaning; new checks may be added as optional fields |
| Artifact sizes | `relay-run-sizes-v1` | existing bounds and exclusion meaning remain stable |
| Provider tool results | `relay-tool-result-bundle-v1` | run identity, bounded result list, tool-call correlation, and state digest binding remain stable |
| PackWrite manifest | `relay-packwrite-manifest-v1` | recursive packet coverage and digest meaning remain stable |
| Agent capability record | `relay-agent-capability-v1` | local identity, expiry, call-budget, locking, revocation, and replay semantics remain stable |
| JSON Schema IDs | `https://kujo.dev/relay/schemas/*.schema.json` | IDs remain stable for compatible additive revisions; incompatible schemas receive new IDs/files |

## CLI and JSON evolution

Stable command names, documented flags, exit-code classes, and JSON field meanings are compatible throughout 1.x. Patch releases may fix behavior without changing successful contracts. Minor releases may add commands, optional flags, optional JSON fields, and new failure details. Consumers must ignore unknown JSON fields, but Relay will not silently repurpose a field.

A stable flag is deprecated in documentation for at least one minor release before removal in a future major. Security fixes may reject input that was previously accepted when that input violated the documented authority or bounds.

## Persistence and migration

Relay verifies contract identity, run identity, bounds, integrity, and required artifact presence before reading persisted evidence. It never treats the rebuildable index as authoritative and never fabricates missing evidence. Older runs remain readable only where their contract is supported and their recorded requirements validate.

Mission `0.1.0` and `1.0.0` currently have the same execution meaning. New files should use `1.0.0`; existing `0.1.0` files can be migrated by changing only the top-level `version` after validating against [`mission.schema.json`](../schemas/mission.schema.json). The committed legacy and unsupported fixtures provide regression coverage.

An incompatible future change requires a new contract identifier, changelog entry, updated schema, fixtures for old and new forms, a documented migration, and explicit rejection of unsupported versions.
