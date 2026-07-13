# Kujo Relay next-session enhancement backlog — v73

This backlog follows the Seventy-fourth review on 2026-07-13. Relay remains a
local-first hardened alpha/showcase, not enterprise-production-ready or
universally useful.

## Delivered in this session

- Opt-in Watchdog verification matches the exact AI SDK `request_id` and run
  correlation instead of selecting an arbitrary correlated row.
- Watchdog rows are sanitized before entering Relay verification output.
- Normalized input/output/total token usage is reconciled per provider request.
- Missing observed usage and mismatches fail closed as
  `watchdog_telemetry_unverified`.
- Contract, local Watchdog-stub, real local Watchdog, and provider-tool smokes
  prove the new boundary.

## P0 — required before enterprise claims

1. Run authenticated live missions against Ollama Cloud and one independent
   OpenAI-compatible provider through Watchdog and the AI SDK. Preserve exact
   commands, model/provider identifiers, request IDs, Watchdog usage, and
   RunLedger evidence.
2. Reconcile provider-reported usage with Watchdog usage and billing/cost
   records. Define a typed discrepancy policy for missing, delayed, rounded,
   or contradictory usage; do not treat local token equality as billing proof.
3. Add provider dialect/capability negotiation for tool calls, structured
   output, streaming, context limits, and usage fields without putting vendor
   names in the mission runtime.
4. Replace detached temporary worktrees with recoverable, authenticated
   workcells that survive interruption, prove ownership, and support safe
   rollback/cleanup.
5. Add authenticated Paperclip, Hermes/CI, and MCP adapter boundaries with
   caller identity, approval propagation, quotas, and redacted machine reports.
6. Replace the rebuildable JSON store with a durable transactional backend
   supporting concurrent writers, crash recovery, retention, and migration.
7. Complete one external-provider mission that performs real repository work,
   records PackWrite/RunLedger/ChangeBucket/Eval artifacts, resumes after an
   interruption, and proves one bounded fallback or repair.

## P1 — stronger composition and evidence

- Load Spec/Dispatch workflow contracts instead of keeping mission execution
  plans primarily Relay-local.
- Propagate causal IDs across missions, runs, steps, agents, model requests,
  tool calls, artifacts, evaluations, repairs, and external adapters.
- Produce CaseFile failure bundles and apply Redact at packet, prompt,
  handoff, report, and adapter boundaries.
- Add adaptive repair/model fallback only with explicit policies, budgets,
  approvals, and regression Eval evidence.
- Implement the Capsule A/B benchmark with immutable starting commits and
  comparable JSON/Markdown scores.
- Add signed artifact/export provenance and key-rotation/verification policy.

## P2 — scale and operations

- Add bounded remote event sinks, retention/compaction, and aggregate metrics.
- Add parallel read-only steps with deterministic merge/evidence rules.
- Add a machine-readable `doctor` posture for storage, workcells, providers,
  Watchdog, adapters, and dependency versions.
- Stress test concurrent missions, event append, locks, provider retries, and
  artifact ceilings.
- Wire ShipCheck/Concord release checks and publishable compatibility reports.

## Definition of done for the next session

- `RELAY_WATCHDOG_VERIFY=true` passes against both a local stub and an actual
  authenticated Watchdog route with exact request-ID and usage reconciliation.
- A provider with delayed or incomplete usage produces an explicit typed
  unavailable/discrepancy result and cannot silently complete as verified.
- Ollama Cloud and an independent provider complete the same bounded mission
  through Watchdog, with provider-specific behavior isolated in AI SDK
  configuration/adapters.
- The run can be interrupted and resumed from a durable, ownership-checked
  workcell with complete RunLedger and artifact evidence.
- The aggregate acceptance runner, Loop Engineering workflow, and all focused
  provider/Watchdog/contract tests pass.

## Explicit non-goals

- No unrestricted shell/filesystem authority.
- No direct provider client or vendor-specific logic in Relay core.
- No second workflow, telemetry, packet, run, evaluation, or change-tracking
  store.
- No enterprise or universal-production claim before the P0 evidence exists.
