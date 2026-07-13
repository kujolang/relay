# Kujo Relay next-session enhancement backlog — v76

Date: 2026-07-13

## Current position

Relay is a hardened local alpha and Kujo showcase, not an enterprise-ready or
universally useful platform. The v76 slice adds bounded capability-registry
posture and explicit stale-record repair. `doctor --json` is read-only;
`doctor --repair --json` removes only expired or exhausted Agents SDK capability
records, with a 1024-entry scan bound and fail-closed unsafe-path handling.

## Delivered in v76

- Added `capability_registry_posture` to the Relay common boundary.
- Added the required `Agents SDK capability registry` doctor check.
- Added explicit `doctor --repair` CLI behavior and JSON counts for records,
  stale entries, invalid entries, and cleaned entries.
- Added CLI smoke coverage for expiry detection, read-only posture, repair, and
  clean follow-up state.
- Documented the lifecycle boundary in the README, command reference,
  integration matrix, ADRs, implementation plan, and engineering reports.

## P0 — prove the real execution boundary

- [ ] Run a real Ollama Cloud or other external OpenAI-compatible provider
  through the normal Watchdog → AI SDK path and preserve redacted evidence.
- [ ] Execute a real bounded mission in an isolated workcell/worktree with
  authenticated caller identity, rollback, and recovery evidence.
- [ ] Replace local JSON/index authority with a durable concurrent store or
  explicitly document and test the single-host ownership model.
- [ ] Add authenticated machine-facing CLI/service adapter boundaries for
  Paperclip, Hermes, CI, and MCP callers without making them core dependencies.
- [ ] Run the full external-provider, workcell, resume, and release-gate proof;
  keep the product status honest if credentials or infrastructure are absent.

## P1 — close composition and observability gaps

- [ ] Import canonical Spec/Dispatch workflow contracts where compatible and
  keep Relay as the execution/evidence composition layer.
- [ ] Add causal event IDs and parent/attempt IDs across RunLedger, Watchdog,
  tool calls, packets, retries, repairs, and evaluations.
- [ ] Integrate CaseFile and Redact contracts for failure bundles and persisted
  evidence instead of maintaining parallel formats.
- [ ] Add typed retry/repair policy receipts with per-class budgets and
  regression evaluation.
- [ ] Complete Capsule A/B benchmark runs against the same immutable commit and
  compare Model A/Model B with Eval reports.
- [ ] Add signed packet/export provenance and explicit stale-capability
  reconciliation for crashes, multi-process runs, and future multi-host use.

## P2 — scale and operator ergonomics

- [ ] Add bounded streaming event sinks and remote watch/export adapters.
- [ ] Define retention, compaction, and artifact-size policy with RunLedger and
  PackWrite ownership boundaries.
- [ ] Add parallel read-only workflow steps with deterministic aggregation and
  bounded resource accounting.
- [ ] Add evidence-backed model routing using Watchdog telemetry and Eval
  history; do not hide fallback decisions.
- [ ] Stress-test registry posture/repair at the 1024-entry ceiling and add
  concurrency, lock-contention, and crash-leftover fixtures.
- [ ] Run ShipCheck/Concord and presentation/release gates before any claim of
  production readiness.

## Explicitly deferred

No adaptive router, background cleanup daemon, unrestricted shell/filesystem
authority, remote capability service, authenticated tenancy, package publish,
production deployment, or vendor-specific provider path belongs in this slice.

## Definition of done for the next session

- Focused Kujo checks and CLI/Agents SDK smokes pass.
- Aggregate Relay acceptance and Loop Engineering gates pass.
- `doctor --repair` remains explicit and bounded, with regression coverage for
  malformed, unsafe, exhausted, expired, and concurrent registry state.
- At least one real provider and one real isolated repository mission produce
  RunLedger, ChangeBucket, Eval, PackWrite, and final JSON/Markdown evidence.
- Small meaningful commits are pushed and the worktree is clean.
