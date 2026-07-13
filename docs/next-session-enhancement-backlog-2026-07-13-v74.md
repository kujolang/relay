# Kujo Relay next-session enhancement backlog — v74

Review date: 2026-07-13

Relay remains a hardened local alpha and Kujo showcase. It is not enterprise-
production-ready or universally useful. The v74 review strengthened dependency
execution trust, but external-provider, tenancy, workcell, storage, and release
evidence remain incomplete.

## Delivered in v74

- Added a shared trusted-path boundary for configured Kujo, PackWrite, RunLedger,
  ChangeBucket, Eval, and Capsule dependencies.
- Rejected symlinked targets, existing symlinked parent components, and
  non-regular dependency files before adapter invocation.
- Updated `bin/relay` to resolve Kujo from an explicit override, `PATH`, or the
  sibling release binary and export the resolved `KUJO_BIN`.
- Preserved raw configured dependency paths and symlink posture in doctor output
  without executing unsafe targets.
- Added CLI smoke coverage proving a symlinked PackWrite target fails readiness.
- Updated architecture, integration, implementation, command, README, and
  readiness records with the new boundary and its limitations.

## P0 — production-blocking evidence

- Run authenticated live Ollama Cloud and one independent OpenAI-compatible
  provider through Watchdog and the AI SDK, including usage and billing
  reconciliation, provider errors, streaming, and provider-generated tools.
- Replace disposable detached worktrees with recoverable, ownership-bound
  workcells that survive interruption and prove cleanup/rollback behavior.
- Add authenticated machine/service adapters for Paperclip, Hermes, CI, and MCP;
  keep organizational state in Paperclip and mission evidence in Relay/RunLedger.
- Add a durable concurrent run/evidence store with crash recovery, retention,
  migration, and backup/restore tests.
- Exercise a real external mission that makes a contained repository change and
  produces PackWrite, ChangeBucket, Eval, RunLedger, report, and resume evidence.

## P1 — coherence and security

- Add one-time capability accounting and nonce replay protection to the Agents
  SDK worker bridge; test copied and delayed capabilities.
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

## P2 — scale and operator experience

- Add bounded streaming sinks, artifact retention/compaction, and metrics export.
- Add safe parallel read-only steps with deterministic evidence ordering.
- Add model capability discovery and explainable routing based on task,
  context, tools, privacy, budget, and historical evaluation.
- Add a doctor stress mode for lock contention, process interruption, and index
  recovery; add ShipCheck, Concord, Fence, and Eval release gates when their
  executable contracts are available.
- Publish pinned installation guidance, fixture transcripts, schemas, diagrams,
  and a reproducible showcase gallery.

## Next-session definition of done

- Focused Kujo checks, all Relay smokes, aggregate acceptance, and Loop
  Engineering pass with a clean working tree.
- Symlinked and non-regular configured dependencies fail before invocation, and
  the launcher works through explicit, system, and sibling Kujo resolution.
- At least one authenticated external provider and one independent provider
  produce real, reconciled Watchdog/AI SDK evidence.
- A recoverable isolated workcell, durable run store, authenticated adapter,
  and Capsule benchmark have executable proof.
- Small meaningful commits are pushed; the next durable state and handoff are
  consolidated in Strata with retrieval checks.
