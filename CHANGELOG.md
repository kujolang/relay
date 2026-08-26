# Changelog

All notable Relay changes are recorded here. Relay follows semantic versioning for the product; mission and evidence contract identifiers are versioned independently.

## [Unreleased]

- Added bounded, resumable `relay.list_files` pages with an independent 16 MiB discovery envelope, allowing cursor traversal beyond the agent-visible response budget.
- Hardened CLI parsing to reject unknown and duplicate options, missing option values, and unexpected arguments; added the standard `--` option delimiter for prompt text.
- Clarified the source-root layout and corrected the documented four-tool Agents SDK surface.
- Added an optional transactional SQLite run index, authoritative crash rebuild, bounded store posture, retention preview/pruning, and receipted capability/index lease recovery.
- Added version-negotiated Spec/Dispatch envelopes, a disabled-by-default authenticated machine authorization/audit boundary, redacted CaseFile-compatible failed-run handoff, and rotated HMAC-signed exports without changing unsigned v1.
- Added bounded aggregate run metrics, committed performance budgets and benchmark harness, and a generated evidence-linked showcase gallery.
- Fixed retention ordering to use validated completion/update evidence across different mission IDs, and made selected SQLite index rebuild failures propagate instead of returning a healthy run-list result.

## [1.0.0] - 2026-08-08

### Stable local v1 scope

- Added the stable local CLI for chat, model and agent inspection, diagnostics, bounded missions, run evidence, and the Capsule discovery benchmark slice.
- Added bounded mission execution in provided repositories or detached Git worktrees, with explicit write approval, direct-argv command allowlists, script hash enforcement, action/token/tool/output/write budgets, cancellation, timeouts, bounded repair, and confirmed worktree cleanup.
- Added fixture operation and fail-closed live provider routing through Watchdog, including bounded provider-generated Agents SDK tool missions, correlation checks, usage reconciliation, and typed tool-result evidence.
- Added tamper-evident local run state, AgentEvent-compatible event chains, Relay receipts, recursive PackWrite packet manifests, ChangeBucket and Eval results, RunLedger lifecycle evidence, verification, paging, watching, size inventory, and complete or explicitly partial exports.
- Added stable JSON Schemas, compatibility fixtures, aggregate acceptance, security regression coverage, release metadata, deterministic source artifacts, SBOM and provenance generation, ShipCheck and Kennel gates, Linux/macOS CI, and an approval-gated release workflow.

### Compatibility

- Relay product and CLI version is `1.0.0`.
- Mission format `1.0.0` is current. Legacy mission format `0.1.0` remains accepted throughout the Relay 1.x line; unsupported versions fail with an explicit error.
- Existing `AgentEvent-compatible-v1`, `relay-receipt-v1`, `relay-run-v1`, `relay-run-export-v1`, `relay-run-export-partial-v1`, `relay-run-verification-v1`, `relay-run-sizes-v1`, `relay-tool-result-bundle-v1`, `relay-packwrite-manifest-v1`, and `relay-agent-capability-v1` identifiers remain independent v1 machine contracts. They were not renamed solely for the product release.
- Additive fields may appear in v1 JSON objects. Removing or repurposing fields, changing established exit-code meaning, or changing integrity inputs requires a new contract identifier and migration guidance.

### Security boundary

- Hardened path and parent-symlink validation, state-store and repository authority, evidence read/write limits, fail-closed persistence, environment isolation, credential/private-key redaction, provider payload limits, capability issuance/consumption/revocation/replay rejection, and complete evidence verification.
- Integrity seals are SHA-256 tamper-evidence for local artifacts. They are not signatures, user authentication, tenant authorization, or proof of external custody.

### Explicitly outside v1

- Hosted orchestration, authenticated multi-tenant operation, durable multi-host storage, unrestricted shell or production access, universal enterprise certification, and provider-independent production certification.
- External live-provider certification remains approval-gated and must be completed against the exact release candidate before public release.
