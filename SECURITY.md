# Relay Security Policy

## Supported versions

Security fixes are provided for the current Relay 1.x release line. Pre-v1 product releases are unsupported, although mission format `0.1.0` remains an explicitly tested input compatibility format for Relay 1.x.

## Reporting a vulnerability

Do not open a public issue for a suspected vulnerability or include credentials, private prompts, provider payloads, or run evidence in a public report. Email `security@kujolang.ai` with the affected Relay version and commit, reproduction steps, impact, and the smallest safely redacted evidence bundle. Expect an acknowledgement within five business days. Coordinated disclosure timing is determined after triage and a fix is available.

## Credential and provider boundary

Relay defaults to fixture mode. Live provider traffic requires an explicit `RELAY_WATCHDOG_URL`; Relay fails closed instead of silently bypassing Watchdog. Non-loopback Watchdog endpoints require HTTPS and URLs with credentials, queries, fragments, malformed hosts, or unsupported schemes are rejected. An optional `RELAY_WATCHDOG_UPSTREAM_PROFILE` selects a trusted server-side Watchdog route without exposing its upstream credential; profile values are length and character bounded before becoming a request header. Watchdog proxy/API tokens and provider credentials are passed through bounded named environment values, not stored in mission files, and are redacted from subprocess output, events, receipts, reports, and tool results. Dangerous dynamic-loader, interpreter, Git, proxy, trust-store, and process-environment names are denied.

Provider request payloads are bounded below the bridge transport limit, provider responses are capped, tool arguments and tool-call IDs are validated, and token/tool-turn/tool-call budgets are enforced. Relay records provider and model identifiers, correlation IDs, and reconciled usage when available; it must never record credential values. Watchdog and the provider remain separate trust domains operated by the user.

## Local evidence and integrity

Run evidence is stored below `RELAY_STATE_ROOT` (default `.relay`). State, events, receipts, reports, tool-result bundles, and PackWrite manifests use bounded, symlink-safe reads and fail-closed writes. Every parsed JSON document is limited to the pinned runtime's 1 MiB parser ceiling. Event JSONL, Markdown reports, and exported artifact inventories have separate 8 MiB envelopes plus file, depth, and entry limits.

SHA-256 integrity fields detect local mutation and sequence inconsistency. They are not cryptographic signatures, identity assertions, tenant authorization, non-repudiation, or proof that an operator controls a signing key. Exports must be verified before use and remain local unsigned evidence unless an external approved signing system is applied by the release owner.

## Repository and worktree authority

Mission repositories must be existing Git workspaces reached through non-symlink paths. Worktree missions resolve an immutable starting commit and create a detached run-owned worktree. Resume, pause, cancel, repair, and cleanup revalidate run identity, mission-policy digest, state seal, event/receipt chains, source repository, workspace path, Git metadata, and budgets. Cleanup requires `--confirm` and can remove only the run-owned worktree. Relay does not authorize deleting source repositories or arbitrary directories.

File paths must remain inside the real workspace and cannot traverse `.git`, `.env`, `.relay`, credential paths, control-character names, or symlinked parents. Reserved path matching is case-insensitive so the same boundary holds on case-insensitive filesystems. Writes require both `allow_writes: true` and `approval.approved: true`. Commands execute as direct argv with a fixed search path and explicit environment; shell syntax, destructive Git operations, pushes, force operations, credential access, external diff/config overrides, and unapproved scripts are rejected. `bash` and `sh` scripts require exact repository-relative SHA-256 allowlist entries.

## Capabilities, cancellation, and budgets

Agents SDK tool capabilities bind run, session, workspace, nonce, expiry, and call budget. Issuance, consumption, revocation, and cleanup share per-record locking; exhausted, expired, revoked, malformed, delayed, or replayed capabilities fail closed. Capability secrets are parent/child process values and are not evidence fields.

Every mission has bounded steps, repairs, aggregate tokens, per-request tokens, tool calls, tool turns, output bytes, write bytes, and command timeouts. Cancellation requests bind the target run ID and integrity input. Cancellation is cooperative at controlled action/process boundaries; process-group cancellation and timeout evidence is recorded. Relay cannot guarantee termination of a compromised kernel, container daemon, or external provider.

## Persistence failure and recovery

State, JSONL, receipt, required artifact, and index persistence errors are failures, not successful evidence. Authoritative per-run state and evidence are verified before inspection or export; the run index is a locked, rebuildable cache. This design is for local single-host operation and is not durable transactional storage, disaster recovery, retention management, or multi-host concurrency.

## Deployment limitations

Relay v1 does not provide hosted orchestration, authenticated multi-tenant service operation, durable multi-host storage, unrestricted autonomous shell access, universal enterprise readiness, provider-independent production certification, host/kernel isolation, secret custody, network egress governance, or compliance certification. Worktree isolation is not a container or VM boundary. Use Workcell or an operator-provided stronger sandbox when appropriate and validate the complete host, daemon, network, identity, approval, retention, and provider environment before production use.
