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
- required ChangeBucket, Eval, JSON/Markdown report, and RunLedger finish persistence failures fail closed as `evidence_failure`
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

The current run engine still accepts explicit action plans, but missions may now opt into a bounded fixture-driven Agents SDK Tool Registry call list. Provider-driven model tool planning, dynamic role discovery, richer typed tool-result artifacts, arbitrary interrupted-step replay, adaptive failure-repair flows, and external-provider/Ollama verification require follow-up integration work. Local real-Watchdog correlation is covered by the dedicated smoke.

## 2026-07-11 enterprise-readiness review

The current posture is local-first hardened alpha/showcase, not universal enterprise production. This review added realpath workspace checks, shell/Git command deny rules, explicit write approvals, subprocess redaction, packet digest metadata, unique run suffixes, preflight failure handling, ChangeBucket/Eval completion authority, atomic JSON persistence, efficient JSONL append, generated file-existence acceptance checks, shared Capsule process handling, and a real pause-after-plan/resume checkpoint. See `docs/enterprise-readiness-review-2026-07-11.md` and the current `docs/next-session-enhancement-backlog-2026-07-13-v55.md` for the evidence boundary and prioritized remaining work.

## Fifty-fifth 2026-07-13 review

Read-side evidence is now semantic rather than shape-only. `runs verify`,
`runs export`, and `missions report` require report identity/status agreement
with authoritative state and a bounded regular Markdown report. The rebuildable
run index rejects placeholder metadata when matching state is absent, and
`runs sizes` rejects an oversized directory before recursive flattening. Store,
sizes, mission, watch, and resume-integrity smokes pass. Relay remains a local
alpha/showcase; live provider proof, provider-generated tools, workcell crash
recovery, authenticated machine mode, durable storage, and signed export remain
open.

## Fifty-sixth 2026-07-13 review

Relay now revalidates approval, timeout, and byte-budget policy inside the
capability-bound Agents SDK worker, and `runs watch` reads terminal state through
the same identity-checked authoritative evidence boundary used by inspection
and export. Direct-worker, watcher-integrity, mission, store, and CLI smokes
pass. This strengthens local authority and failure detection but does not claim
provider-generated tool planning, authenticated machine invocation, workcell
crash recovery, durable storage, or enterprise readiness.

## Fifty-seventh 2026-07-13 review

The Agents SDK bridge now recursively redacts model output, nested tool output,
and worker error text before emitting its machine summary. The Agents SDK smoke
proves credential-shaped output is not exposed. This improves local disclosure
safety but does not claim provider-native classification, full Redact
integration, authenticated service mode, or enterprise readiness.

## Fifty-third 2026-07-13 review

This review added two bounded local improvements. `runs sizes` now rejects
artifact trees deeper than 16 directory levels before the recursive walker can
hit the Kujo VM stack limit. Run registration now lets the locked authoritative
rebuild perform the single run-tree scan, and cache records preserve
`updated_at`, avoiding unnecessary stale-cache rebuilds. The store and sizes
smokes plus the full configured local gates pass. Durable concurrent storage,
retention, signed export, and authenticated ownership remain open.

## Forty-seventh 2026-07-12 review

Added explicit contract coverage distinguishing safely inspected sibling
dependency paths such as `./../ai-sdk` from the stricter state-store `..`
policy. This prevents fail-closed path hardening from regressing normal
cross-repository composition. Relay remains a local alpha; live provider proof,
authenticated service ownership, full workcells, durable storage, and release
gates remain open.

## Forty-eighth 2026-07-12 review

`runs events` and `runs export` now reject divergence between authoritative
state events and the verified JSONL log even when event IDs still match. A
contract test and store smoke prove the state-only payload tamper case. Relay
remains a local alpha; signed exports, durable retention, live provider proof,
authenticated ownership, workcells, and release gates remain open.

## Forty-ninth 2026-07-12 review

Persisted read boundaries now require `receipts.json` and an identity-matching
`state.json`. Store smoke coverage proves that deleting either artifact fails
inspection rather than trusting an embedded or indexed fallback. Relay remains
a local alpha; durable storage, signed export, live provider proof,
authenticated ownership, workcells, and release gates remain open.

The same review normalizes relative `KUJO_BIN` and sibling adapter paths before
subprocess cwd changes. The dedicated relative-tool-path smoke proves that a
fixture mission still reaches PackWrite, RunLedger, ChangeBucket, and Eval
evidence under the Loop Engineering launch form.

## Fiftieth 2026-07-13 review

Added the read-only `runs verify` contract and made ChangeBucket/Eval artifact
inspection fail closed on missing, malformed, oversized, symbolic-linked, or
wrong-shaped files. The store smoke proves a positive verification verdict and
negative missing-artifact cases. Relay remains a local alpha; external provider
proof, authenticated ownership, full workcells, durable storage, and release
gates remain open.

## Fifty-first 2026-07-13 review

Hardened `runs export` against incomplete result bundles. ChangeBucket, Eval,
and JSON report artifacts must now be present, bounded, regular, and correctly
shaped before export can claim `integrity_valid: true`; `runs verify` reports
`report_valid` as well. Store-smoke coverage proves missing changes and report
artifacts fail closed. Relay remains a local alpha; external provider proof,
authenticated ownership, full workcells, durable storage, and release gates
remain open.

## Fifty-second 2026-07-13 review

Added explicit `relay-run-export-partial-v1` output through opt-in
`runs export --partial` for paused/failed runs that lack post-verification
artifacts. Partial output always reports `integrity_valid: false`, per-artifact
presence, and null unavailable fields; completed runs cannot use the downgrade
path. Store-smoke coverage proves full export remains fail-closed and partial
export is explicit. Relay remains a local alpha; external provider proof,
authenticated ownership, full workcells, durable storage, and release gates
remain open.

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

## Nineteenth 2026-07-11 review

The Agents SDK bridge no longer trusts payload-selected worker paths. It binds
the Relay source root and Kujo executable to trusted environment values,
rejects mismatches and unsafe roots before process spawn, and records the
failure through the existing bounded agent-run result. The focused Agents SDK
smoke proves a tampered root is rejected without writing to the workspace.
Authenticated service identity, binary signing, and workcell isolation remain
deferred.

## Twentieth 2026-07-11 review

The AI, Agents SDK, and tool-worker environment bridges now enforce a 128 KiB
pre-parse payload limit and return structured errors for malformed or non-object
JSON. The input-boundary smoke proves oversized and malformed payload handling
across all three machine-callable paths. This is a bounded local transport
contract; authenticated file/socket transport and larger prompt semantics
remain deferred.

## Thirty-first 2026-07-12 review

The cancellation path now composes with Kujo's process lifecycle contract.
Relay supplies `cancel_file` for active mission commands; Kujo's Unix runtime
uses a per-command process group and terminates the group for cancellation or
timeout. The bounded smoke test uses a 30-second descendant task and returns
within eight seconds with terminal evidence. This extends cancellation
evidence without making Relay responsible for shell-level process discovery.
Non-Unix descendant guarantees, rollback, workcell recovery, and distributed
control authorization remain open.

## Twenty-sixth 2026-07-12 review

This review reused checkpoint integrity for operator pause and cancel controls.
Non-terminal control mutations now verify the mission policy, workspace, event,
receipt, and budget state before changing persisted run state. The PackWrite
integration was also restored after its existing atomic-write migration lacked
the referenced helper; PackWrite verification passed 144 unit and 47 CLI
assertions, and Relay’s 19-gate suite passed. Distributed identity, signed
state, and authenticated control channels remain deferred.

## Twenty-first 2026-07-11 review

Live AI invocation now validates the configured Watchdog URL before starting
the AI SDK bridge. Unsupported schemes and embedded credentials fail closed as
`invalid_watchdog_route`; the contract and CLI smokes pass. TLS policy,
authenticated route discovery, and external-provider verification remain
deferred.

## Twenty-second 2026-07-11 review

Live Watchdog route validation now allows cleartext HTTP only for loopback and
requires HTTPS for non-loopback hosts. Contract and CLI route smokes pass.
Certificate validation, mTLS, authenticated route discovery, and external
provider verification remain deferred.

## Twenty-fourth 2026-07-12 review

This review closed a paused-run authority gap. Resume now verifies the mission
policy digest, run identity, source/workspace and Git metadata, effective
budgets, event chain, and receipt sequence before changing state to running.
Tampered workspace and policy state fail as `state_integrity_failure` before
any resumed repository action. This is local checkpoint integrity, not signed
state, authenticated multi-user ownership, or durable crash recovery.

## Twenty-fifth 2026-07-12 review

This review extended state integrity to confirmed worktree cleanup. Cleanup now
revalidates the mission-policy digest, run identity, source repository,
run-owned worktree path, Git metadata, event chain, and receipt sequence before
calling destructive Git removal. Tampered terminal state fails as
`state_integrity_failure`; the existing worktree smoke and contract coverage
pass. Signed state, authenticated ownership, rollback, and crash recovery
remain deferred.

## Twenty-third 2026-07-12 review

This review aligned operator diagnostics with live Watchdog enforcement. The
route policy now rejects missing hosts and query/fragment-bearing endpoints,
while `doctor --json` fails live readiness for unsafe routes and reports only
non-secret posture fields. CLI and contract coverage proves remote HTTP
rejection, malformed-route handling, and credential-bearing URL non-disclosure.
Authenticated route discovery, certificate validation, mTLS, and external
provider verification remain deferred.

## Twenty-seventh 2026-07-12 review

This review closed an evidence-truthfulness gap. State, receipt, and event
persistence failures now propagate as `evidence_failure`, force a failed status
before terminal success reporting, and clean temporary files after failed
atomic writes. Contract failure injection and the full Relay suite pass. Fsync,
append-only durability, retention, and crash recovery remain deferred.

## Twenty-eighth 2026-07-12 review

Relay now validates the state-store authority boundary before using `.relay` or
`.relay/runs`. Symbolic-linked roots fail closed as `state_store_failure` for
mission, index, inspection, and operator-control paths; `doctor --json` exposes
the required posture without following the link. Contract and redirection
smoke evidence pass. Durable no-follow storage, authenticated ownership, and
full workcell isolation remain deferred.

## Twenty-ninth 2026-07-12 review

AI telemetry now follows the same non-disclosure contract as `doctor --json`.
Raw Watchdog URLs are not persisted or returned; only bounded route posture is
available for diagnostics and machine callers. Correlation IDs are also bounded
before transport, preventing query-delimiter injection into Watchdog lookups.
Remote-host, credential-bearing-route, and unsafe-correlation regression checks
pass. External-provider proof, authenticated route discovery, certificate
validation, and mTLS remain deferred.

The concurrent index-lock probe was also made race-safe. A disappearing lock
path is treated as a normal bounded contention lifecycle rather than an
interpreter failure; the lock stress gate passes.

## Thirtieth 2026-07-12 review

Watchdog health and proxy-configuration transport failures now use an
endpoint-independent error class. `doctor --json` retains status and logical
endpoint information but no longer returns raw constructed URLs or transport
exception text. The unreachable-route redaction smoke and full Relay gates
pass. External provider proof, authenticated route discovery, TLS policy,
certificate validation, and mTLS remain deferred.

## Thirty-second 2026-07-12 review

Relay's shared evidence redactor now covers structured credential fields and
common provider token/private-key markers in addition to bearer and
environment-style secrets. This is a local disclosure reduction with focused
contract evidence; it does not replace the deferred Redact integration,
tenant-aware secret custody, or prompt/packet/handoff policy.

## Thirty-third 2026-07-12 review

Relay's doctor now treats dependency identity as a safety boundary rather than
an existence check. Required paths must have the expected file/directory type
and cannot be symbolic links; JSON callers receive explicit safety fields. A
symlinked Kujo runtime is rejected before readiness is reported. This remains
local path posture, not signed supply-chain provenance or deployment attestation.

## Thirty-fourth 2026-07-12 review

Action evidence now distinguishes cancelled commands and timed-out commands
from generic tool failures. This gives RunLedger, operator reports, and machine
callers a truthful stop reason without inferring from exit codes. Provider
taxonomy normalization and typed retry/repair receipts remain open.

## Thirty-fifth 2026-07-12 review

Relay now has a dedicated timeout smoke, not only timeout input validation. It
runs a 30-second descendant task with a one-second limit, proves bounded return
within 12 seconds, verifies typed timeout evidence, and checks for orphaned
processes. The result strengthens the local Unix process lifecycle claim while
leaving non-Unix and workcell ownership contracts open.

## Thirty-sixth 2026-07-12 review

`runs watch` now avoids reparsing the complete JSONL history on every poll. It
processes appended complete lines and pending partial lines incrementally,
rejects replacement/truncation/disappearance, and preserves full chain
validation whenever the stream changes. This improves local watcher scaling
while leaving remote subscriptions and multi-host event fan-out open.

## Thirty-seventh 2026-07-12 review

The live watcher now fails closed if its observed `events.jsonl` disappears,
and it skips duplicate full-chain validation during unchanged polls. The
focused integrity smoke and full configured local gate set pass. Redact
integration remains contract-first: the current Redact CLI does not accept
JSON machine artifacts, so Relay does not claim an unsafe adapter; the local
redactor remains the persisted-evidence boundary until a structured Redact
contract exists.

## Thirty-eighth 2026-07-12 review

Relay now adds sealed execution context metadata to every runtime receipt:
workflow, model, provider, packet revision, attempt, repair attempt, RunLedger,
and AI correlation identifiers. Contract and mission evidence pass. This is a
stronger local machine-consumption boundary, not a replacement for signed
exports, durable retention, tenant-aware secret custody, or typed repair
receipts.

## Thirty-ninth 2026-07-12 review

`doctor --json` now performs bounded version probes for Kujo, PackWrite,
RunLedger, and ChangeBucket with explicit environments and configurable sibling
roots. Required probe failures make readiness fail closed. Full local gates pass;
this remains a dependency-readiness check, not signed supply-chain provenance,
semantic compatibility validation, or enterprise deployment attestation.

## Fortieth 2026-07-12 review

`doctor --json` now optionally verifies SHA-256 pins for the Kujo, PackWrite,
RunLedger, and ChangeBucket executables. Invalid or mismatched pins fail closed;
matching and wrong-hash cases are covered by the CLI smoke. Signed provenance,
semantic compatibility ranges, and deployment ownership remain deferred.

## Forty-first 2026-07-12 review

Hardened provider credential environment selection rejects dynamic-loader,
interpreter-injection, Git override, and trust-store override variables before
the AI bridge receives them. Contract and CLI smoke coverage pass. The change
improves local process authority without claiming secret-broker custody,
authenticated multi-tenant operation, signed provenance, or live external
provider integration.

## Forty-second 2026-07-12 review

Unified Relay's symlink checks behind a fail-closed probe helper. Missing paths
remain absent, but invalid inputs and filesystem inspection errors are treated
as unsafe across evidence, workspace, dependency, control, and Agents SDK
worker boundaries. Source checks, contract tests, Agents SDK tool smoke, and
CLI smoke pass. This is a local authority hardening, not kernel-level no-follow
support, multi-user ownership, durable storage, or enterprise deployment
attestation.

## Forty-third 2026-07-12 review

Corrected the fail-closed symlink helper ordering: metadata is checked before
ordinary existence semantics, preserving detection of dangling links. Added a
dedicated dangling-symlink smoke and a configurable contract probe. The local
boundary is now safer against broken-link redirection, while kernel no-follow
primitives, authenticated ownership, durable storage, and enterprise
deployment attestation remain open.

## Forty-fifth 2026-07-12 review

Extended the shared fail-closed path-component policy to `doctor` dependency
targets and the trusted Agents SDK worker root/source. The contract and
dedicated symlink smoke cover dependency-parent redirection. Focused Kujo
checks, contracts, and the smoke pass. Relay remains a local alpha; live
Ollama/Watchdog proof, authenticated service ownership, full workcells,
durable storage, and release gates are not claimed.

## Forty-fourth 2026-07-12 review

The state-store safety boundary now walks existing parent components as well as
`.relay` and `.relay/runs`, rejecting symlinked directories and `..` before
index or run access. A parent-redirection contract probe was added. This is
stronger local evidence authority, not kernel-level no-follow support,
authenticated ownership, durable storage, or enterprise deployment
attestation.

## Forty-sixth 2026-07-12 review

Relay now probes JSON and JSONL artifact links before existence checks, rejects
dangling cancellation requests, and makes `runs watch` reject dangling event
links immediately. The watcher also reuses one existence result per poll,
reducing redundant local filesystem probes. Focused source checks, contracts,
the symlink smoke, and watch-integrity smoke pass. This improves local evidence
and control authority but does not establish live provider proof, authenticated
tenancy, workcell isolation, durable storage, or enterprise readiness.

Sibling-tool adapters now align subprocess cwd/module context, including the
canonical Kujo module path required by ChangeBucket. The doctor and mission
smokes verify that cross-repository version/change evidence remains truthful
when Relay is launched from its own root.

## Fifty-fourth 2026-07-13 review

Required acceptance artifacts are now verified as part of completion authority.
`changes.json`, `evaluations.json`, and the JSON/Markdown report must persist
with the expected bounded shape, and a pass-status RunLedger finish must also
persist before Relay emits its final completion event. Injected directory-backed
artifact paths fail closed as `evidence_failure`. The focused contract,
mission, store, sizes, resume-integrity, and Agents SDK tool smokes pass.
Crash recovery, durable transactions, signed export, and live external-provider
proof remain deliberately deferred.

## Fifty-eighth 2026-07-13 review

Centralized `env_bool` now governs fixture-mode selection and optional
Watchdog verification. `true`/`false`, `1`/`0`, and `yes`/`no` are accepted
case-insensitively with fail-safe defaults, and the CLI smoke covers numeric and
word spellings. No external provider or enterprise readiness claim changes;
the v58 backlog records the remaining P0 work.

## Fifty-ninth 2026-07-13 review

Relay now binds `RELAY_AI_BRIDGE` to a regular, non-symlinked `.kujo` source
file inside the Relay root. Runtime calls and `doctor` fail closed before
spawning an external bridge, and the CLI smoke proves the rejected path is not
disclosed. This is local configuration-source hardening; signed provenance,
authenticated invocation, live external providers, and enterprise readiness
remain deferred.

## Sixtieth 2026-07-13 review

Relay model profiles are now truthful about orchestration support. `models list`
and `models probe` report explicit profile selection rationale, chat/streaming
capabilities, `tool_planning: false`, and declared-mission-only tool execution;
the previous optimistic `tool_calls` claim was removed. This is a machine
contract and adoption-quality improvement, not provider-generated tool proof or
enterprise readiness.

## Sixty-first 2026-07-13 review

Persisted run state now carries an integrity seal over the state excluding the
seal field, and read, resume, cleanup, and report boundaries verify it before
trusting state authority. Mission IDs are bounded to a filesystem-safe
alphabet, while mission names, goals, action types, and write payloads receive
earlier fail-fast validation. This improves local tamper evidence and input
resource control without claiming signed state, authenticated ownership, or
durable recovery.

Relay also publishes forward-compatible JSON Schemas for mission, run/report,
AgentEvent, receipt, doctor, model probe, and tool-result boundaries. The new
aggregate acceptance runner discovers every committed smoke test, runs the
contract and schema suites, and checks the diff, making the local verification
surface easier for adopters and machine callers to reproduce. Live external
provider proof, provider-generated tool planning, full workcells,
authenticated machine mode, durable storage, signed export, and release gates
remain deliberately deferred.

## Sixty-second 2026-07-13 review

The adapter now returns a normalized fallback decision for non-successful
primary model calls. Mission planning records a selected or skipped decision
as a sealed `RelayReceipt` and AgentEvent with a retry ID, while preserving
Watchdog/AI SDK telemetry as the call authority. A deterministic mission smoke
proves a non-retryable Watchdog-route failure is not retried and is visible in
run evidence. `runs sizes` also has a complete 8 MiB artifact-byte bound, with
entry and depth limits retained.

Newly built behavior is local policy/evidence composition only. It does not
complete external provider validation, provider-generated tool planning,
authenticated machine adapters, workcell crash recovery, durable transactional
storage, signed export, or enterprise readiness.

## Sixty-third 2026-07-13 review

Relay now supports integrity-verified, bounded `runs events` inspection windows
with `--limit` and `--after` cursors. The implementation validates the full
event chain and authoritative state sequence before slicing, then returns
bounded cursor metadata under the new `schemas/event-bundle.schema.json`
contract. The legacy unpaged response and `runs export` behavior remain
unchanged.

Cooperative cancellation requests are now identity-bound to the target run and
sealed over their request fields. Copied, stale-format, and tampered request
files fail closed at action boundaries. This provides local tamper evidence;
it does not claim authenticated ownership, replay protection, distributed
cancellation, or rollback.

The implementation remains Kujo-native and locally verifiable. The unresolved
production boundary is unchanged: real Ollama Cloud and independent-provider
evidence, provider-driven tool planning, full workcell isolation/recovery,
authenticated Paperclip/Hermes/CI/MCP adapters, durable concurrent storage,
signed export, and ShipCheck/Concord release gates still require future work.

## Sixty-fourth 2026-07-13 review

Relay added four local hardening improvements. Agents SDK worker capabilities
now use a runtime-generated nonce in addition to run/session/workspace identity;
legacy deterministic capabilities are rejected. Common and Agents SDK child
process builders keep `PATH` fixed and drop unsafe environment overrides.

Mission repository and tool-workspace authority now rejects parent symlink
components, not only the final directory and `.git` path. Repository command
evidence exposes the subprocess `exit_code` when available. Failure
classification was expanded and reordered so policy and permission failures
cannot be hidden under generic tool failures.

Evidence: Kujo source checks, contract taxonomy and process-environment checks,
Agents SDK legacy-capability rejection, timeout exit-code, and repository
symlink safety smokes passed locally. Relay remains a hardened local alpha;
live provider evidence, authenticated adapters, provider-generated tools,
workcell recovery, durable storage, signed export, and release gates remain
unproven.

## Sixty-fifth 2026-07-13 review

Relay added bounded run-index inspection for machine callers. `runs list` now
sorts validated run IDs and supports `--limit 1..4096` plus `--after` cursors,
returning count, offset, continuation, and next-cursor metadata. Full index and
per-run state validation still occurs before slicing. The new
`run-bundle.schema.json` and `run-index-record.schema.json` contracts describe
the boundary, and the store smoke proves continuation across two independent
runs.

This is a local response-performance improvement and does not claim durable
concurrent storage, remote subscriptions, authenticated callers, or enterprise
readiness.

## Sixty-sixth 2026-07-13 review

Provider-generated tool planning is now available as an explicit mission mode.
`agent_tool_mode: "provider"` requires `agent_tool_allowlist`; the selected
tool schemas are sent through Watchdog and the AI SDK, normalized into the
Agents SDK call shape, and executed by the existing nonce-bound policy worker.
The path records provider-generated plans as typed receipts and events and is
covered by a local authenticated Watchdog/stub-provider end-to-end mission
that mutates a fixture repository and passes ChangeBucket, Eval, and RunLedger
completion checks.

The implementation remains a hardened local alpha/showcase. It does not claim
real Ollama Cloud or independent-provider credentials, multi-turn provider
tool loops, authenticated machine adapters, full workcell recovery, durable
concurrent storage, signed export, or release-gate completion.

## Sixty-seventh 2026-07-13 review

The v66 implementation closes the next local functionality gap: provider
generated tool calls can now complete a bounded follow-up round. Relay preserves
the assistant call and sends redacted typed `role: tool` results through the
existing AI SDK/Watchdog route; tool-call, tool-turn, cancellation, and
aggregate token budgets remain Relay-controlled. The new
`tool-result-bundle.schema.json` contract and persisted `tool-results.json`
artifact make intermediate tool outcomes inspectable and receipt-linked.

`tests/relay_provider_tool_smoke.sh` proves an authenticated local
Watchdog/stub-provider two-turn response, Agents SDK execution, repository
mutation, result persistence, ChangeBucket, Eval, RunLedger, and terminal event
evidence. This does not establish live provider compatibility, durable storage,
workcell crash recovery, authenticated machine mode, or enterprise readiness.

## Sixty-eighth 2026-07-13 review

The latest hardening pass adds a 112 KiB pre-bridge AI request ceiling, a 1 MiB
provider response ceiling, 64 KiB provider-tool argument bounds, duplicate and
control-character tool-call ID rejection, proxy-environment denial for child
processes, and 8 MiB event/receipt evidence ceilings. PackWrite completion is
now accepted only when a safe regular `agent/MASTER.md` artifact exists.

Focused Kujo checks, contract tests, provider-tool, mission, Agents SDK, and
input-boundary smokes passed. These changes improve local resource safety and
evidence truthfulness; they do not complete live provider verification,
authenticated tenancy, durable storage, recoverable workcells, or release
gates. The next work is recorded in
`docs/next-session-enhancement-backlog-2026-07-13-v67.md`.

## Sixty-ninth 2026-07-13 review

Provider-generated tool execution is now part of the read-side completion
boundary. When state records provider tools, `runs verify` and valid
`runs export` require `tool-results.json`, validate its
`relay-tool-result-bundle-v1` contract and run identity, compare its SHA-256 to
the authoritative state record, and include the verified bundle in exports.
The provider-tool smoke proves both a valid result and a tampered-result
failure. This closes a local evidence gap but does not establish live provider
dialect compatibility, durable storage, authenticated tenancy, or enterprise
production readiness. The next-session work is tracked in
`docs/next-session-enhancement-backlog-2026-07-13-v68.md`.

## Seventieth 2026-07-13 review

This review tightened repository command authority and operational inspection.
`bash` and `sh` actions now require an exact caller-declared SHA-256 for a
regular, non-symbolic `scripts/*.sh` file, checked at validation and execution;
changed or undeclared scripts fail closed. `runs sizes --hashes` provides an
opt-in bounded SHA-256 inventory while preserving the default size-only fast
path. New run-verification and run-sizes JSON Schemas make both machine
boundaries explicit. Contract, schema, sizes, timeout, and cancellation tests
passed. These are local security and observability improvements; live provider
compatibility, authenticated tenancy, recoverable workcells, durable storage,
and release gates remain open. The next-session work is tracked in
`docs/next-session-enhancement-backlog-2026-07-13-v69.md`.

## Seventy-first 2026-07-13 review

This review makes PackWrite evidence recursive rather than sentinel-based.
Relay now persists a bounded `relay-packwrite-manifest-v1` for every regular
file under `agent/`, verifies packet contents and digests at `runs verify` and
valid export boundaries, and publishes `packet-manifest.schema.json`. The
Agents SDK worker also preserves `allowed_script_hashes`, so delegated shell
actions retain the same content authority as direct mission actions. Store and
Agents SDK smokes prove packet tamper rejection and delegated script execution.
This remains local unsigned tamper evidence; live provider compatibility,
authenticated tenancy, recoverable workcells, durable storage, and release
gates remain open. The next-session work is tracked in
`docs/next-session-enhancement-backlog-2026-07-13-v70.md`.

## Seventy-second 2026-07-13 review

Relay now exposes explicit bounded repair replay through `missions repair`.
Only transient provider, rate, timeout, tool, repository, implementation, and
evaluation failures may be replayed; policy, authentication, malformed-call,
and context failures remain terminal. Each attempt receives a repair ID,
typed RunLedger receipt, lifecycle events, and a persisted attempt count, with
the mission schema and loader enforcing a four-attempt ceiling. The flaky
worktree smoke proves a failed run can be repaired once and that a zero-repair
budget fails closed. This is explicit replay, not adaptive self-healing or
model rerouting. Live providers, provider dialects, recoverable workcells,
authenticated adapters, durable storage, and release gates remain open. The
next-session work is tracked in
`docs/next-session-enhancement-backlog-2026-07-13-v71.md`.

## Seventy-third 2026-07-13 review

This review closes a mission-budget enforcement gap. Relay now requires a
positive `max_tokens` mission budget, caps it at 16,384, passes it to the AI
SDK/Watchdog request, and reduces every provider-tool follow-up to the
remaining budget. Negative provider usage cannot create budget credit. Generic
child-process environment overrides also reject caller-supplied `PWD`; only a
trusted adapter working directory is restored. Contract, spec-safety, low
budget fixture, repair, and mission smokes passed. This improves local cost,
latency, and environment authority but does not prove provider billing
reconciliation, live-provider compatibility, durable workcells, authenticated
tenancy, or release readiness. The next-session work is tracked in
`docs/next-session-enhancement-backlog-2026-07-13-v72.md`.

## Seventy-fourth 2026-07-13 review

Relay now makes opt-in Watchdog verification request-specific: the authenticated
request row must match both the AI SDK request ID and the bounded run
correlation, and its normalized input/output/total usage must reconcile with the
provider response. Missing or mismatched usage fails closed as
`watchdog_telemetry_unverified`; only sanitized request identity, status, and
usage fields are returned. Contract, local Watchdog-stub, real local Watchdog,
and provider-tool smokes pass. This closes a local telemetry evidence gap but
does not prove external-provider billing, provider dialect compatibility,
durable workcells, authenticated tenancy, or enterprise readiness. The next
session backlog is `docs/next-session-enhancement-backlog-2026-07-13-v73.md`.

## Seventy-fifth 2026-07-13 review

Relay now enforces trusted dependency execution at the adapter boundary. Kujo
launcher resolution supports an explicit binary, system `PATH`, or the sibling
release path and exports the selected `KUJO_BIN`. PackWrite, RunLedger,
ChangeBucket, Eval, and Capsule adapters reject configured symlinked or
non-regular targets before invocation, while doctor preserves raw path and
symlink diagnostics. A CLI smoke proves a symlinked PackWrite target fails
readiness without execution. This improves local authority containment but does
not prove executable signatures, authenticated deployment ownership, external
provider compatibility, durable workcells, or enterprise readiness. The next
session backlog is `docs/next-session-enhancement-backlog-2026-07-13-v74.md`.

## Seventy-sixth 2026-07-13 review

Relay now issues short-lived Agents SDK capability records instead of trusting
caller-supplied nonce material alone. A digest-only parent secret, run/session/
workspace binding, expiry, bounded call allowance, locked consumption, and
worker-exit revocation are enforced by the Relay tool authority. The Agents SDK
tool smoke proves issued capability use and replay rejection. This closes a
local replay gap but does not provide authenticated remote tenancy, signed
provenance, multi-host revocation, or crash-recovery reconciliation. The next
session backlog is `docs/next-session-enhancement-backlog-2026-07-13-v75.md`.

## Seventy-seventh 2026-07-13 review

Relay adds bounded capability-registry posture and explicit stale-record
repair. `doctor --json` remains read-only and reports record, stale, invalid,
and cleaned counts; `doctor --repair --json` removes only expired or exhausted
Agents SDK records. The scan is limited to 1024 records and fails closed on
unsafe or malformed paths. The CLI smoke proves expiry detection, explicit
repair, and a clean subsequent scan. This is local lifecycle hygiene only;
durable multi-host reconciliation, authenticated ownership, signed provenance,
live-provider proof, and release gates remain open. The next session backlog is
`docs/next-session-enhancement-backlog-2026-07-13-v76.md`.

## Seventy-eighth 2026-07-13 review

Capability-registry repair now serializes cleanup with the existing per-record
Agents SDK consumption lock and re-reads records before deletion. Active locks
are reported and retained; malformed lock objects fail closed. Lock creation
uses an exclusive fixed-path native `mkdir`, and contract coverage proves a
second acquisition fails. The CLI smoke proves locked stale records survive
repair and are cleaned after unlock. This closes a local lifecycle race without
claiming crash recovery, durable multi-host storage, authenticated tenancy,
external-provider proof, or release readiness. The next session backlog is
`docs/next-session-enhancement-backlog-2026-07-13-v78.md`.

The v79 review extends that filesystem boundary to mission state directories.
Relay now checks every state path component for symlink redirection and creates
missing mission/run directories with the shared exclusive native `mkdir`
primitive. Unsafe or unavailable paths fail closed as `state_store_failure`,
and the existing state-store smoke plus the full acceptance suite provide local
evidence. This is a local race and redirection hardening step; it does not
establish durable storage, authenticated ownership, kernel no-follow
guarantees, or enterprise readiness.

Current follow-on backlog: `docs/next-session-enhancement-backlog-2026-07-13-v79.md`.

The v80 review reuses Kujo's native `write_file_atomic` for Relay evidence
writes and removes the duplicate timestamp/random temporary-file implementation.
Capability-registry directory creation now uses the shared fail-closed safe
directory helper. A symlink replacement regression proves the new writer
changes the link path without changing its target. This is local filesystem
consistency hardening, not evidence of durable multi-host storage, signed
provenance, authenticated ownership, live-provider compatibility, or enterprise
readiness.

Current follow-on backlog: `docs/next-session-enhancement-backlog-2026-07-13-v80.md`.

The v81 review closes a local capability-issuance race. Relay now serializes
record creation with the existing per-record lock and returns
`capability_already_registered` for duplicate run/session identities rather
than replacing a worker secret. Focused state and Agents SDK coverage proves
the denial. This remains local single-host coordination, not authenticated
multi-host ownership or enterprise readiness.

Current follow-on backlog: `docs/next-session-enhancement-backlog-2026-07-13-v81.md`.

The v82 review removes a duplicate filesystem scan from invalid run-index cache
recovery. `load_run_index` now uses one bounded locked rebuild to produce and
persist the authoritative cache result. This is a measured-scope local
performance improvement; durable storage and multi-host authority remain
deliberately unimplemented.

The v83 review closes the matching capability-revocation race. Revocation now
shares the per-record authority lock, rechecks the regular record under that
lock, and fails closed on contention or unsafe metadata. The Agents SDK smoke
also clears its test-owned capability registry before and after execution so
repeated acceptance runs do not inherit stale fixture identities.

The v84 review closes a local evidence false-success path. Bounded JSONL
evidence persistence now returns the native Kujo append/create result, and the
contract suite proves a missing-parent creation failure is surfaced. No new
durable storage or multi-host authority was introduced. Relay remains a
hardened local alpha; the external provider, authenticated tenancy, workcell
recovery, durable store, and release-gate items remain deferred in the v84
backlog.
