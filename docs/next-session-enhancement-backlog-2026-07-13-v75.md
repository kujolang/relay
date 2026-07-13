# Kujo Relay next-session enhancement backlog — v75

Review date: 2026-07-13

Relay remains a hardened local alpha and Kujo showcase. It is not enterprise-
production-ready or universally useful. v75 closes a local Agents SDK replay
gap, but external-provider, tenancy, workcell, storage, provenance, and release
evidence remain incomplete.

## Delivered in v75

- Added Relay-owned short-lived capability registry records for Agents SDK
  workers.
- Bound issued capabilities to run, session, workspace, nonce, expiry, and a
  bounded call allowance; persisted only a digest of the parent secret.
- Passed the secret only through the bounded parent/child environment and
  consumed allowances under a lock.
- Revoked capability records after worker exit.
- Added a Kujo capability fixture and Agents SDK smoke coverage for issued use,
  policy denial, and one-time replay rejection.
- Updated README, command reference, integration matrix, ADRs, implementation
  plan, final report, enterprise review, and this backlog.

## P0 — production-blocking evidence

- Run authenticated live Ollama Cloud and one independent OpenAI-compatible
  provider through Watchdog and the AI SDK, including usage/billing
  reconciliation, streaming, errors, and provider-generated tools.
- Replace disposable detached worktrees with recoverable, ownership-bound
  workcells that survive interruption and prove cleanup/rollback behavior.
- Add authenticated machine/service adapters for Paperclip, Hermes, CI, and MCP;
  keep organizational state in Paperclip and mission evidence in Relay/RunLedger.
- Add a durable concurrent run/evidence store with crash recovery, retention,
  migration, backup/restore, and capability-registry reconciliation tests.
- Exercise a real external mission that makes a contained repository change and
  produces PackWrite, ChangeBucket, Eval, RunLedger, report, and resume evidence.

## P1 — coherence and security

- Reuse Spec/Dispatch workflow contracts where they fit instead of extending
  Relay's local mission schema into a second workflow system.
- Add causal IDs across mission, step, agent, model, tool, artifact, repair,
  and evaluation events; preserve them in exported evidence.
- Integrate CaseFile and Redact contracts for failure bundles and redaction
  provenance rather than relying only on Relay-local envelopes.
- Add typed retry/fallback/repair policies with explicit model/context changes,
  regression evaluation, and bounded budget accounting.
- Complete Capsule A/B benchmark runs with fresh receiving sessions, comparable
  JSON/Markdown scores, and repeated immutable-commit trials.
- Add signed or attestable dependency manifests and executable-mode/provenance
  checks for deployments that need stronger supply-chain guarantees.
- Reconcile stale capability records after crash and expose bounded capability
  posture in doctor without disclosing secrets.

## P2 — scale and operator experience

- Add bounded streaming sinks, artifact retention/compaction, and metrics export.
- Add safe parallel read-only steps with deterministic evidence ordering.
- Add model capability discovery and explainable routing based on task,
  context, tools, privacy, budget, and historical evaluation.
- Add a doctor stress mode for lock contention, process interruption, index,
  workcell, and capability recovery; add ShipCheck, Concord, Fence, and Eval
  release gates when their executable contracts are available.
- Publish pinned installation guidance, fixture transcripts, schemas, diagrams,
  and a reproducible showcase gallery.

## Next-session definition of done

- Focused Kujo checks, all Relay smokes, aggregate acceptance, and Loop
  Engineering pass with a clean working tree.
- Agents SDK capabilities require issued, expiring, bounded records; replay and
  stale-record behavior have deterministic tests.
- At least one authenticated external provider and one independent provider
  produce real, reconciled Watchdog/AI SDK evidence.
- A recoverable isolated workcell, durable run store, authenticated adapter,
  and Capsule benchmark have executable proof.
- Small meaningful commits are pushed; the next durable state and handoff are
  consolidated in Strata with exact/conceptual/partial retrieval checks.
