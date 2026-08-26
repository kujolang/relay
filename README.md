# Kujo Relay

[![Version](https://img.shields.io/badge/version-1.0.0-black)](https://github.com/kujolang/relay)
[![License](https://img.shields.io/badge/license-MIT-lightgrey)](LICENSE)
[![built with Kujo](https://img.shields.io/badge/built%20with-Kujo-white.svg)](https://github.com/kujolang/kujo)
[![CI](https://img.shields.io/github/actions/workflow/status/kujolang/relay/ci.yml?branch=main&style=flat&label=CI&color=black)](https://github.com/kujolang/relay/actions/workflows/ci.yml)

Relay is a stable local or operator-controlled composition and execution layer for bounded agent missions. It provides a Kujo-native CLI for fixture and Watchdog-routed chat, mission execution in an existing repository or isolated Git worktree, policy-bound Agents SDK tools, and verifiable local evidence.

Relay v1 is deliberately local-first. It is not hosted orchestration, durable multi-host storage, unrestricted shell access, provider-independent production certification, or universal enterprise readiness. SHA-256 evidence seals detect local tampering; separately requested HMAC-signed exports authenticate a bundle to an operator-owned symmetric key but do not establish public-key identity or custody.

## Stable v1 scope

The stable line includes:

- `chat`, `models`, `agents`, and `doctor` for bounded provider and environment operations;
- `missions` for create, run, inspect, pause, resume, repair, cancel, cleanup, and report workflows;
- `runs` for list, aggregate metrics, rebuild, transactional-index migration, retention, inspect, verify, events, watch, sizes, changes, evaluations, failed-run handoff, and complete, partial, or separately signed export;
- version-negotiated Spec/Dispatch envelopes and a disabled-by-default authenticated machine authorization boundary with identity, role, tenant, approval, and sealed audit mappings;
- `benchmark run` for the bounded Capsule discovery slice;
- fixture mode, mandatory Watchdog routing for live calls, provider-generated tool planning, Agents SDK policy execution, PackWrite packets, RunLedger lifecycle evidence, ChangeBucket and Eval results;
- explicit budgets, direct-argv commands, script hashes, cooperative cancellation, timeouts, bounded repair, detached Git worktrees, evidence verification, and cleanup authority.

The complete surface, exit codes, flags, environment, and JSON contracts are in the [command reference](docs/command-reference.md). Experimental and deferred integrations are classified in the [integration matrix](docs/integration-matrix.md).

## Installation

Relay is distributed as source. Use Kujo 1.0.0 at the exact revision in [`RUNTIME_VERSION`](RUNTIME_VERSION); release and CI dependency revisions are recorded in [`release/dependencies.json`](release/dependencies.json).

```bash
git clone https://github.com/kujolang/relay.git
cd relay
git checkout v1.0.0
export KUJO_BIN=/path/to/kujo
test "$($KUJO_BIN --version | awk '{print $2}')" = "1.0.0"
./bin/relay --version
```

Before the final tag exists, release candidates use the approved commit on the release-preparation branch instead of `git checkout v1.0.0`. Relay never downloads or replaces Kujo or sibling tools at runtime.

Supported v1 target hosts are Linux and macOS. The exact release candidate must pass the committed platform matrix before release; Windows is not claimed. Host-specific status and external runner blockers are recorded in the [launch checklist](docs/launch-checklist.md).

## Repository layout

Runtime implementation lives in `src/`. The small root `main.kujo` file is the conventional Kujo executable entrypoint, `kujo.toml` and `kennel.toml` are package manifests, and `bin/relay` resolves and launches the pinned Kujo runtime. Tests, schemas, examples, release metadata, scripts, and operator documentation remain in their named directories. Start with the concise [architecture map](docs/architecture.md) to locate subsystem ownership and the relevant tests.

## Quick start

Fixture mode is deterministic and makes no provider request:

```bash
export KUJO_BIN=/path/to/pinned/kujo
./bin/relay doctor --json
./bin/relay agents validate --json
./bin/relay chat "Summarize the mission boundary" --fixture --json
./bin/relay models probe fixture-model --fixture --json
```

Run the bundled read-only mission from the Relay checkout:

```bash
export RELAY_ROOT="$PWD"
./bin/relay missions run examples/fixture-mission.json --fixture --json
./bin/relay runs list --json
./bin/relay runs verify <run-id> --json
./bin/relay runs export <run-id> --output /tmp/relay-run-export.json --json
```

Create and verify a key-owned signed export without changing unsigned v1:

```bash
export RELAY_SIGNING_KEYS='{"release-2026":"replace-with-secret-from-your-key-manager"}'
./bin/relay runs export <run-id> --signed --key-id release-2026 --output /tmp/relay-signed.json --json
./bin/relay runs verify-signature /tmp/relay-signed.json --json
```

Run a write mission only against a disposable Git repository and with explicit approval in its mission file. `examples/worktree-mission.json` demonstrates a detached worktree whose cleanup requires `--confirm`.

Relay rejects unknown or duplicate CLI options, missing option values, and unexpected positional arguments. Use the standard `--` delimiter when prompt text begins with `--`, for example `./bin/relay chat -- --summarize-this`.

## Common workflows

Inspect and verify evidence:

```bash
./bin/relay missions inspect <run-id> --json
./bin/relay runs events <run-id> --limit 100 --json
./bin/relay runs sizes <run-id> --hashes --json
./bin/relay runs verify <run-id> --json
```

Control a bounded run:

```bash
./bin/relay missions pause <run-id> --json
./bin/relay missions resume <run-id> --json
./bin/relay missions repair <run-id> --json
./bin/relay missions cancel <run-id> --json
./bin/relay missions cleanup <run-id> --confirm --json
```

`repair` is available only for approved repairable failure classes and respects the mission repair ceiling. Cancellation and timeouts are cooperative and recorded in evidence. `runs export --partial` is available only for incomplete runs and always reports `integrity_valid: false` and `completeness: "partial"`.

## Provider configuration

Live requests must route through Watchdog. Relay does not silently fall back to a direct provider path.

```bash
export RELAY_OFFLINE_FIXTURE=false
export RELAY_WATCHDOG_URL=https://watchdog.example.invalid/proxy/v1
export RELAY_WATCHDOG_API_URL=https://watchdog.example.invalid
export RELAY_WATCHDOG_PROXY_TOKEN=...  # if proxy auth is enabled
export RELAY_WATCHDOG_API_TOKEN=...    # if verification API auth is enabled
export RELAY_WATCHDOG_UPSTREAM_PROFILE=openrouter-work  # optional named server-side route
export RELAY_WATCHDOG_VERIFY=true
export OPENAI_API_KEY=...
./bin/relay chat "hello" --model <model-id> --provider openai-compatible --json
```

Preview the local evidence-retention policy before any deletion:

```bash
./bin/relay runs retention --keep-last 100 --json
```

Pruning is confirmation-gated and limited to verified completed runs whose
worktrees have already been cleaned. See the [retention policy](docs/retention-policy.md).

Loopback HTTP is allowed for local Watchdog development; non-loopback routes require HTTPS. Embedded credentials, queries, fragments, malformed hosts, unsafe profile names, and unsafe provider credential environment names are rejected. A named upstream profile reuses Watchdog's server-side provider credential and shared telemetry database; Relay records that profile routing was configured without copying the credential. The approval-gated exact-candidate procedure is in [live provider verification](docs/live-provider-verification.md).

## Security model

Mission actions are declarative and policy checked. Writes require `allow_writes: true` and `approval.approved: true`; repository paths must remain inside the real non-symlink workspace. Commands use exact argv, a fixed executable path, an explicit bounded environment, and an allowlist. Repository shell scripts require exact SHA-256 entries. Destructive Git operations, pushes, force operations, credential paths, shell syntax, dynamic-loader overrides, and unrestricted production access are denied.

Run state, events, receipts, reports, packet manifests, tool results, and exports use bounded fail-closed reads and writes. Capabilities bind run, session, workspace, nonce, expiry, and call count, and reject replay after use or revocation. Read [`SECURITY.md`](SECURITY.md) for reporting, credential handling, evidence limits, worktree authority, cancellation, persistence, and deployment limitations.

## Ecosystem integrations

- Required and proven locally: Kujo, AI SDK fixture/provider boundary, Agents SDK, PackWrite, RunLedger, ChangeBucket, and Eval.
- Optional and proven locally: Watchdog with a real local server and stub provider; Workcell once rerun for the exact candidate; ShipCheck and Kennel release gates.
- Experimental: Capsule benchmark discovery, versioned Spec/Dispatch envelope import, policy-selected Redact/CaseFile-compatible failed-run handoff, and the disabled-by-default authenticated machine boundary.
- Deferred: network service transport, durable multi-host storage, hosted orchestration, public-key signing/custody, and enterprise certification.

Exact immutable revisions and evidence classifications are in the [integration matrix](docs/integration-matrix.md) and [`release/dependencies.json`](release/dependencies.json).
The next bounded improvement set is tracked in the [v87 enhancement backlog](docs/next-session-enhancement-backlog-2026-08-13-v87.md).

## Compatibility

Relay product version, mission format, and evidence contracts are independent:

- product and CLI: `1.0.0`;
- current mission format: `1.0.0`;
- accepted legacy mission format: `0.1.0` for the Relay 1.x line;
- event, receipt, run, export, verification, sizes, tool-result, packet-manifest, and capability identifiers retain their existing `v1` names.

Additive JSON fields may appear within v1 and consumers must ignore unknown fields. Removing or repurposing fields, changing established exit-code meaning, or changing integrity inputs requires a new contract identifier and migration guidance. Unsupported mission versions fail before execution. See [machine contracts](schemas/README.md) and [compatibility policy](docs/compatibility.md).

## Limitations

- The optional SQLite run index is transactional and crash-rebuildable on one host; authoritative evidence is not replicated or multi-host durable.
- Git worktrees isolate source changes but are not containers, VMs, or hostile-code sandboxes.
- Provider compatibility must be verified for the chosen provider/model through the exact Watchdog and SDK revisions.
- Integrity hashes are not signing; signed exports use operator-owned HMAC keys and are not public-key identity, custody, or notarization.
- Relay does not expose hosted orchestration, tenant identity, unrestricted shell, publishing, deployment, or autonomous production access.
- `benchmark run` is a bounded Capsule discovery slice, not a general benchmark certification system.

## Troubleshooting

- `Kujo runtime not found`: set `KUJO_BIN` or `KUJO` to the trusted executable at the revision in `RUNTIME_VERSION`.
- `doctor` reports unsafe/missing dependencies: configure the documented `RELAY_*_ROOT`/path variables and verify exact revisions; Relay refuses symlinked or wrong-hash dependencies.
- Live chat stays in fixture mode: set `RELAY_OFFLINE_FIXTURE=false` and configure a valid Watchdog route.
- Live chat fails with Watchdog verification errors: confirm proxy/API auth, correlation visibility, and usage fields; do not disable verification for release evidence.
- A run cannot resume or export: inspect `missions inspect`, `runs events`, and `runs verify`; tampered, missing, oversized, or inconsistent evidence fails closed.
- Cleanup is denied: only a verified run-owned worktree can be removed, and `--confirm` is mandatory.

## Release verification

```bash
export KUJO_BIN=/path/to/pinned/kujo
bash scripts/release_gate.sh
bash tests/release_artifacts_smoke.sh
```

The release gate checks source, CLI and machine contracts, every committed smoke test, schemas, Markdown links, metadata consistency, Kennel, ShipCheck, and deterministic clean-install artifacts. Workcell and external live-provider evidence are exact-commit gates tracked separately in the [launch checklist](docs/launch-checklist.md).

Relay is licensed under the [MIT License](LICENSE). Contributions follow [`CONTRIBUTING.md`](CONTRIBUTING.md).
