# Kujo Relay Enterprise-Readiness Review — 2026-07-11

## Executive conclusion

Relay is not production-ready in a universal enterprise-grade sense today. It is a credible, well-presented Kujo-native local foundation and a useful showcase of Kujo composition, but its current proof is fixture-first and single-workspace. Calling it universally production-ready would overstate the evidence.

The correct posture is: **local-first hardened alpha / ecosystem showcase**. The second review landed in commits `7dd7cea` and `b0d1712`, pushed to `origin/main`.

## Evidence reviewed

- Existing Relay history on `main`, clean working tree at the start of this review, configured `origin/main`.
- Kujo release runtime contract test.
- Fixture chat and stream output through the AI SDK bridge.
- Real bounded write to `/tmp/relay-fixture-workspace`.
- PackWrite validation, Agents SDK offline smoke, RunLedger receipt, ChangeBucket report, Eval result, AgentEvent JSONL, packet hash, and pause-after-plan/resume.
- Capsule adapter failure reproduced: `Symbol 'run_cli' not found in module 'src.cli'`.
- Existing ecosystem READMEs, source modules, tests, and workflow contracts.
- Second-review evidence: `doctor --json`, fixture `models probe`, fail-closed live-route check, budget failure smoke, all Relay `kujo check` targets, and expanded Loop Engineering gates.

## Enhancements made in this review

| Area | Change | Evidence |
|---|---|---|
| Path security | Canonical lexical containment, realpath parent checks, traversal/secret-directory rejection | `src/policy.kujo`, contract tests |
| Command security | Reject shell metacharacters, destructive Git, credential, force, and config/remote operations | `src/policy.kujo`, contract tests |
| Approval boundary | Write-enabled mission specs require explicit approval metadata | `src/runtime.kujo`, fixture mission |
| Evidence safety | Redact common bearer/API-key material from subprocess output | `src/common.kujo`, `src/adapters.kujo` |
| Packet integrity | Record revision and SHA-256 digest for `agent/MASTER.md` | mission `artifacts` state |
| Run uniqueness | Add random suffix to mission run IDs | `src/runtime.kujo` |
| Preflight correctness | Fail before repository actions when PackWrite, Agents SDK, AI, RunLedger, or token budget checks fail | `src/runtime.kujo` |
| Evaluation authority | Failed ChangeBucket or Eval evidence now fails the run | `src/runtime.kujo` |
| Resume correctness | `--pause-after-plan` creates a real checkpoint; resume executes pending actions and re-verifies evidence | mission run events/state |
| Event performance | JSONL uses `append_file` instead of rereading/rebuilding the whole file | `src/common.kujo` |
| State durability | JSON state writes use sibling temp files and rename into place | `src/common.kujo` |
| Acceptance coverage | Generated Eval config checks each declared file-write output in addition to `git diff --check` | `src/runtime.kujo`, mission smoke |
| Capsule adapter | Uses the shared process adapter and preserves truthful failure output | `src/adapters.kujo`, `src/cli.kujo` |
| Live-route safety | Live AI calls fail closed when Watchdog is not configured; provider-key environment names are validated | `src/adapters.kujo`, `src/doctor.kujo`, blocked-live smoke |
| Process isolation | Adapter subprocesses use explicit bounded environment allowlists instead of wholesale inheritance | `src/common.kujo`, contract tests |
| Atomic tool writes | Mission file actions and Markdown artifacts use sibling temp files plus rename | `src/common.kujo`, mission smoke |
| Budget enforcement | Mission specs can override step, repair, and token limits; action loops stop at `max_steps` | `src/runtime.kujo`, budget smoke |
| Operator onboarding | `doctor --json` and `models probe` expose truthful environment and model checks | `src/doctor.kujo`, CLI smoke |
| Presentation contract | README, command reference, root-layout explanation, and a versioned follow-up backlog document the evidence boundary | README, `docs/command-reference.md`, backlog v2 |

## Remaining enterprise gaps

### P0 — Must close before production claims

1. Live Watchdog proxy correlation and telemetry export proof.
2. Live Ollama Cloud and at least one other OpenAI-compatible provider smoke test.
3. Authenticated service/MCP boundary with identity, tenant, role, and approval mapping.
4. Automated isolated worktree/workcell creation, cleanup, and rollback.
5. Full Agents SDK Tool Registry and approval-provider execution instead of explicit action lists.
6. Durable run store with locking/concurrent-run behavior, retention, recovery, and tamper-evident export.

### P1 — Required for broad enterprise usefulness

1. Dispatch/Spec workflow import with schema version negotiation.
2. CaseFile and Redact failure evidence integration.
3. Watchdog rate limits, budget accounting, and correlation IDs attached to every event.
4. Capsule A/B benchmark execution and comparable Eval reports.
5. Bounded cancellation, timeouts, retry classes, provider fallback, and repair receipts.
6. CI gates using Fence, Concord, ShipCheck, and deterministic release manifests.

### P2 — Performance and product maturity

1. Avoid running Agents SDK aggregate smoke on every production mission; make it a startup or release gate.
2. Add bounded parallel read-only verification with serialized writes.
3. Add streaming event sinks rather than only file-backed post-run JSONL.
4. Add structured metrics for latency, tokens, retries, queue time, tool duration, and artifact sizes.
5. Add retention/compaction for `.relay` artifacts and configurable output limits.
6. Add model capability discovery and explicit fallback-selection explanations.

## Root-layout review

The root files are still justified by established Kujo conventions: `main.kujo` is the executable entrypoint, `kujo.toml` is package metadata, `bin/relay` is a thin launcher, and `README.md` is the package landing page. Runtime logic is correctly under `src/`; no root implementation file should be moved into `src/` without breaking the conventional entrypoint.

The second review found no redundant root implementation files. New behavior remains under `src/`, tests under `tests/`, examples under `examples/`, and operator-facing material under `docs/`.

## Security posture

The local runtime now fails closed for the highest-risk MVP paths, but it is not a complete security boundary. The process adapter inherits the host environment, external commands remain local process authority, and there is no identity-aware remote service. Never expose the CLI or future MCP adapter to untrusted callers until auth, tenancy, secret policy, network egress, and workcell isolation are implemented and tested.

## Release recommendation

Publish Relay only as a local-first alpha/showcase until all P0 items have executable evidence. The review hardening is committed as `b21ef02` and pushed to `origin/main`; keep the README's enterprise-readiness disclaimer and require a release report that distinguishes fixture, configured-live, and production-environment evidence.
