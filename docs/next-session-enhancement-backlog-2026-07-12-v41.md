# Kujo Relay next-session enhancement backlog — v41

Review date: 2026-07-12. This backlog records the next bounded engineering
slice after the provider credential-environment injection review. Relay is a
local alpha and is not yet enterprise-production-ready or universally useful.

## Completed in this review

- Denied `LD_*` and `DYLD_*` provider credential environment names.
- Denied interpreter startup variables including `PYTHONPATH`, `BASH_ENV`,
  `NODE_OPTIONS`, `PERL5OPT`, and `RUBYOPT`.
- Denied Git override variables including `GIT_CONFIG*`,
  `GIT_EXTERNAL_DIFF`, and `GIT_SSH_COMMAND`.
- Denied trust-store override variables including `SSL_CERT_FILE` and
  `CURL_CA_BUNDLE`.
- Added contract and CLI smoke coverage before AI bridge spawn.

## P0 — prove external composition and authority

- Execute a real Ollama Cloud request through the AI SDK and Watchdog, with
  sanitized evidence and explicit provider/model/correlation metadata.
- Execute one live bounded repository mission through Watchdog, Agents SDK,
  PackWrite, RunLedger, ChangeBucket, and Eval; preserve the exact command
  transcript and machine-readable report.
- Define the authenticated multi-tenant boundary: caller identity, secret
  custody, route allowlists, network egress, approval ownership, and retention.
- Extend detached worktrees into a workcell contract with crash recovery,
  rollback, ownership checks, and cleanup receipts.
- Replace the locked JSON index with durable concurrent storage or document a
  supported single-host ownership model with recovery drills.
- Add ShipCheck/Concord release gates and a reproducible dependency manifest;
  SHA-256 pins remain only an operator-controlled local integrity check.

## P1 — complete ecosystem adapters

- Extend the proven Agents SDK registry bridge to provider-driven tool planning,
  typed tool-result artifacts, bounded repair receipts, and cancellation.
- Load Dispatch/Spec workflow contracts without creating a second workflow
  language; keep organizational task state in Paperclip when present.
- Integrate CaseFile and Redact once a structured artifact contract exists;
  keep the local fail-closed redactor until then.
- Complete Capsule A/B benchmark scoring with independent fresh-agent
  comprehension, implementation, review, and deterministic Eval comparisons.
- Add explicit Paperclip and Hermes JSON/MCP adapter contracts without making
  either product a core runtime dependency.
- Version and validate PackWrite, RunLedger, ChangeBucket, Eval, and receipt
  schemas across upgrades, including migration and rejection behavior.

## P2 — operability and performance

- Add remote event sinks, bounded streaming backpressure, aggregate latency/
  token/cost metrics, retention/compaction, and resumable export.
- Add safe parallelism for independent read-only steps with deterministic
  budget accounting and evidence ordering.
- Add model-routing evidence based on capability, budget, context, and tested
  quality rather than undocumented heuristics.
- Add authenticated service mode and identity-aware run inspection/control.
- Add deterministic failure-injection suites for provider, Watchdog, storage,
  workcell, and evaluator recovery paths.

## Presentation and release surface

- Keep the root layout idiomatic (`main.kujo`, `kujo.toml`, `src/`, `tests/`,
  `docs/`) and keep the CLI truthful rather than adding placeholder commands.
- Add a concise architecture gallery showing the evidence path and ownership
  boundaries, plus JSON schema examples for mission, receipt, event, and
  report contracts.
- Add installation and release checks only after live dependency ownership and
  external-provider evidence are reproducible.

## Definition of done for the next session

- All code remains Kujo; no application Python/TypeScript runtime is added.
- Focused contract/CLI tests, full Loop Engineering gates, and PackWrite tests
  pass.
- At least one new P0 item has executable evidence, corresponding docs, and a
  small pushed commit.
- `git status --short` is empty and the branch is synchronized with origin.
- Strata has a deduplicated capture, decision, todo, current-state summary,
  and handoff for the completed work.

## Verification baseline

```bash
export KUJO_BIN=/Users/robertdevore/2026/Kujolang/kujo-repos/kujo/target/release/kujo
"$KUJO_BIN" run tests/relay_contract_tests.kujo --interpreter
bash tests/relay_cli_smoke.sh
KUJO_BIN="$KUJO_BIN" /Users/robertdevore/2026/Kujolang/kujo-workflows/loop-engineering/scripts/run-workflow.sh --config .loop-engineering/loop.yml
```
