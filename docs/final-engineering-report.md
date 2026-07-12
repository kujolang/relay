# Final Engineering Report

## What was discovered

Kujo already has nearly all important primitives: AI SDK provider normalization, Agents SDK contracts for agents/tools/approvals/budgets/events, Watchdog proxy telemetry, PackWrite packet compilation, RunLedger receipts, ChangeBucket diff analysis, Eval deterministic checks, Dispatch workflow state, Capsule discovery, Chain of Command roles, and Loop Engineering stop rules. The missing piece was a small composition runtime with a stable machine-facing boundary.

## What was reused and newly built

Reused directly: AI SDK normalized responses and fixture behavior, PackWrite CLI/validator, RunLedger CLI/records, ChangeBucket JSON, Eval config/checks, Capsule CLI shape, Chain of Command role locations, Watchdog's HTTP API/proxy contract, and AgentEvent-compatible field names. Newly built: Relay mission/run state, a narrow Watchdog verification adapter, adapter boundary, policy-checked declarative actions, evidence aggregation, report surface, CLI routing, and a capability-bound Agents SDK Tool Registry worker seam.

Deliberately not built: another provider client, another general workflow engine, another telemetry database, another packet schema, unrestricted shell access, adaptive model router, or a fake claim of live Ollama/Watchdog success.

## Verification

Passed locally with the pinned Kujo release runtime:

- `kujo run tests/relay_contract_tests.kujo --interpreter`
- fixture `relay chat` JSON and normalized stream output
- fixture mission with real write to `/tmp/relay-fixture-workspace`
- Agents SDK offline aggregate smoke executed as part of the mission and recorded in run state
- PackWrite generated and validated 13 artifacts
- RunLedger recorded a pass with starting commit and changed-file count
- ChangeBucket recorded the added file
- Eval passed `git diff --check`
- generated Eval config also checks that each declared `write_file` action produced a file
- six AgentEvent-compatible lifecycle/artifact/tool/evaluation events were persisted
- pause/resume path persisted a resumable checkpoint and completion report
- isolated mission through the Agents SDK Tool Registry created a real file and
  approval denial created no file
- event-chain tamper rejection and versioned `runs export` verification passed

Not proven in this local session: live Ollama Cloud or another external provider, multi-model Capsule A/B implementation scoring, Paperclip/Hermes invocation, and container/microVM-grade workcell isolation. A local real Watchdog process forwarding to a Kujo stub provider is proven, including token-authenticated proxy/API calls, persisted correlation lookup, and secret non-leakage. Detached Git worktree provisioning and explicit cleanup are proven locally, while rollback-on-failure and crash recovery remain open. These are known limitations, not successful external integrations.

## Ecosystem recommendations

1. Publish a supported cross-repository Kujo package/dependency mechanism so composition layers do not need subprocess adapters.
2. Add a single Agents SDK mission/workflow loader that can consume Chain of Command role metadata without product-specific prompt flattening.
3. Add a Watchdog client library or health/telemetry correlation contract for local Kujo runtimes.
4. Add RunLedger correlation fields for mission, workflow, step, packet revision, tool call, artifact, and evaluation IDs.
5. Add PackWrite packet revision/hash fields and an offline compiler mode with a first-class fixture flag.
6. Add ChangeBucket and Eval library APIs in addition to their CLIs for composition runtimes.

## Known limitations

The current run engine still accepts explicit action plans, but missions may now opt into a bounded fixture-driven Agents SDK Tool Registry call list. Provider-driven model tool planning, dynamic role discovery, richer typed tool-result artifacts, arbitrary interrupted-step replay, and failure-repair flows require follow-up integration work. External-provider/Ollama remains unverified; local real-Watchdog correlation is covered by the dedicated smoke.

## 2026-07-11 enterprise-readiness review

The current posture is local-first hardened alpha/showcase, not universal enterprise production. This review added realpath workspace checks, shell/Git command deny rules, explicit write approvals, subprocess redaction, packet digest metadata, unique run suffixes, preflight failure handling, ChangeBucket/Eval completion authority, atomic JSON persistence, efficient JSONL append, generated file-existence acceptance checks, shared Capsule process handling, and a real pause-after-plan/resume checkpoint. See `docs/enterprise-readiness-review-2026-07-11.md` and `docs/next-session-enhancement-backlog.md` for the evidence boundary and prioritized remaining work.

## Second 2026-07-11 review

The follow-up review preserved the alpha boundary and added fail-closed live Watchdog routing, explicit subprocess environment allowlists, provider-key environment validation, atomic mission writes, output-truncation evidence fields, configurable mission budgets, an explicit Agents SDK smoke skip with receipt, detached worktree provisioning with confirmed cleanup, `doctor --json`, `models probe`, budget and worktree regression smokes, a command reference, and versioned next-session backlogs. The root layout was re-audited and remains intentionally conventional: `main.kujo`, `kujo.toml`, and `bin/relay` are necessary entry/package/launcher files; runtime behavior remains under `src/`. See `docs/enterprise-readiness-review-2026-07-11.md`, `docs/command-reference.md`, and `docs/next-session-enhancement-backlog-2026-07-11-v5.md`.

## Additional 2026-07-11 audit slice

The next audit corrected the stale README claim that worktree provisioning was still absent, forwarded streaming and optional Watchdog proxy authorization through the AI SDK bridge, restricted `kujo run` to approved workspace-local `.kujo` files, made the run index self-healing from authoritative state, and added output/write budgets plus timeout bounds. New store and output-budget smokes pass alongside the prior acceptance set. The implementation was committed as `0e030ed` and pushed. The remaining storage implementation was intentionally described as a rebuildable cache, not durable concurrent transaction storage. The current handoff is now `docs/next-session-enhancement-backlog-2026-07-11-v5.md`.

## Watchdog verification slice — 2026-07-11

Relay now propagates a run correlation ID through the existing AI SDK bridge as observation headers, passes Watchdog proxy authorization only through a bounded environment seam, and can optionally fail closed unless Watchdog health, proxy configuration, and the matching `/api/requests` row are all verified. The adapter exposes sanitized status only; it does not copy prompt/response summaries or raw API bodies into Relay artifacts. `tests/relay_watchdog_smoke.sh` proves the contract against a Kujo HTTP stub. `tests/relay_watchdog_real_smoke.sh` proves the same path through the actual local Watchdog server with token auth and a stub OpenAI-compatible upstream. This is real Watchdog integration evidence, but not external-provider or Ollama Cloud evidence.

## Fifth 2026-07-11 review

This review removed `/bin/sh -lc` from mission execution, added direct-argv
tokenization and shell-syntax rejection, hardened worktree cleanup against
tampered state paths and Git option injection, added an atomic lock around the
rebuildable run index with state freshness validation, and added deterministic
SHA-256 integrity fields to AgentEvent-compatible records. Focused contract,
store, mission, and worktree tests pass. The root-layout audit still finds no
redundant root implementation files: `main.kujo`, `kujo.toml`, and `bin/relay`
remain idiomatic Kujo entry/package/launcher files. The current handoff is
`docs/next-session-enhancement-backlog-2026-07-11-v5.md`.

## Sixth 2026-07-11 review

This review added a Kujo-native Agents SDK Tool Registry bridge. Mission specs
can provide bounded `agent_tools`; the bridge registers existing SDK tools and
approval providers, then delegates to a capability-bound Relay worker so
workspace, direct-argv, write, and budget policy remain authoritative. The
isolated mission smoke created a real repository artifact through
`relay.write_file`, captured the tool result in the run event stream, and proved
approval denial. The bridge is intentionally fixture-driven for now; live
provider-generated tool planning, richer artifact receipts, authenticated
service mode, and stronger workcell isolation remain open. The next handoff is
`docs/next-session-enhancement-backlog-2026-07-11-v6.md`.

## Seventh 2026-07-11 review

This review fixed subprocess executable resolution to a known system PATH,
bound Agents SDK worker capabilities to the run/session/workspace scope, added
validated tool-call ceilings, and extended deterministic acceptance checks to
Agent SDK-created files. `runs events` now parses and verifies hashes, parent
ordering, and duplicate IDs; `runs export` produces a versioned machine bundle
and refuses tampered event logs. The root audit still finds only the necessary
Kujo entrypoint, package manifest, README, and thin launcher at the top level;
runtime code remains under `src/`. The next handoff is
`docs/next-session-enhancement-backlog-2026-07-11-v7.md`.

## Eighth 2026-07-11 review

This review extended event verification from hash/parent validation to complete
evidence validation: event IDs must match authoritative state, truncated or
malformed logs fail closed, and event inspection/export is bounded to 8 MiB.
The store smoke now proves both sequence truncation and payload tampering are
rejected. The next handoff is
`docs/next-session-enhancement-backlog-2026-07-11-v8.md`.

## Ninth 2026-07-11 review

This review attaches workflow, model, provider, packet revision, and RunLedger
IDs to every newly emitted AgentEvent-compatible record before integrity
sealing. The mission smoke proves the context is visible in resumable run
state. Retry, repair, escalation, approval, and cancellation receipts remain
follow-up work. The next handoff is
`docs/next-session-enhancement-backlog-2026-07-11-v9.md`.

## Repository handoff

The current Relay implementation includes execution-context event correlation
and typed receipt verification in the current review commits. They are
intended to be pushed to `origin/main`, and the tree should remain clean. The
next session should preserve this evidence boundary rather than widening
claims.

## Tenth 2026-07-11 review

This review adds a versioned `RelayReceipt` index over the canonical
PackWrite, Agents SDK, model, tool, ChangeBucket, Eval, and RunLedger
artifacts. Each receipt is SHA-256 sealed, carries mission/run/step/agent
context, and is referenced by the lifecycle event that creates or completes
the evidence. `runs events` and `runs export` now fail closed when the receipt
file is tampered with or disagrees with authoritative state. The new contract,
mission assertions, export assertions, and tamper regression pass locally.
This is correlation and integrity hardening, not a replacement for upstream
stores or proof of external-provider, durable multi-host, or signed export
support. The next handoff is
`docs/next-session-enhancement-backlog-2026-07-11-v10.md`.

## Eleventh 2026-07-11 review

This review tightened the security and concurrency edges left after the typed
receipt work. Mission commands now use exact read-only Git argv profiles and
reject pathspecs, unknown options, arbitrary subcommands, and script arguments.
The rebuildable index now retries lock acquisition with a bounded linear
backoff, and twelve concurrent rebuild callers pass a deterministic stress
smoke without corrupting the authoritative cache. Relay remains a local-first
alpha; this does not establish durable multi-host storage, stronger workcells,
or production identity/tenancy.
The next handoff is
`docs/next-session-enhancement-backlog-2026-07-11-v11.md`.

## Twelfth 2026-07-11 review

This review adds bounded live mission observation through `runs watch`. The
watcher streams complete AgentEvent-compatible records from the existing
JSONL evidence file, verifies the chain on each poll, uses explicit poll and
timeout limits, and handles the final state/file persistence race without
misclassifying a valid run. A concurrent mission smoke passes through
`run_completed`. Relay remains a local-first alpha; remote subscriptions,
durable event fan-out, external-provider proof, and enterprise identity remain
open. The next handoff is
`docs/next-session-enhancement-backlog-2026-07-11-v12.md`.

## Thirteenth 2026-07-11 review

This review adds bounded duration evidence to the AI bridge, tool commands,
and ecosystem subprocess adapters. Fixture chat and mission telemetry now
expose non-negative `duration_ms` values, with a focused metrics smoke and
Loop Engineering gate. These are local elapsed measurements rather than
provider billing, queue-time, SLA, or enterprise metrics aggregation proof.
The next handoff is
`docs/next-session-enhancement-backlog-2026-07-11-v13.md`.

## Fourteenth 2026-07-11 review

This review adds a read-only `runs sizes <run-id>` artifact inventory with
per-file byte counts, aggregate file/directory totals, an explicit repository
workspace exclusion, and fail-closed symlink/entry-limit handling. The focused
size smoke passes and the feature remains intentionally below retention,
compaction, transfer-cost, and durable multi-host storage semantics. The next
handoff is `docs/next-session-enhancement-backlog-2026-07-11-v14.md`.

## Fifteenth 2026-07-11 review

This review adds cooperative `missions cancel <run-id>` support. A request is
persisted as run evidence, checked around each declared action, and converted
into a sealed `run_cancelled` event plus a failed RunLedger finish. The focused
smoke cancels a slow repository action and verifies the run cannot report
completion. Forced process termination, rollback, distributed cancellation,
and identity-aware remote authorization remain deferred.

## Sixteenth 2026-07-11 review

This review hardens the evidence boundary against symbolic-link redirection.
Generic JSON reads and JSONL appends now reject symbolic-linked or non-regular
files, and event watch/inspection/export refuse such `events.jsonl` artifacts.
The store smoke proves a symlink to `/etc/passwd` fails closed. Kernel-level
no-follow primitives, multi-user ownership, and durable storage isolation are
still deferred.

## Seventeenth 2026-07-11 review

This review bounds mission input before parsing: `load_spec` rejects missing,
symbolic-linked, non-regular, or larger-than-1 MiB files. The focused
spec-safety smoke proves oversized and symlinked mission documents fail closed.
Authenticated input identity, schema negotiation, and larger durable workflow
packets remain deferred.

## Eighteenth 2026-07-11 review

This review added `read_json_limited` and applied it before parsing persisted
index, lock-owner, run-state, receipt, and export-side JSON. An oversized
8 MiB-plus index now fails closed and is rebuilt from authoritative run state;
the contract and store smokes pass. It also restricted `RELAY_FALLBACK_MODEL`
to explicit transient or model-capability failures and records skipped reasons
for authentication, policy, route, and malformed-bridge failures. These are
local resource and cost-control improvements, not durable multi-host storage,
provider taxonomy, or adaptive-routing proof.
