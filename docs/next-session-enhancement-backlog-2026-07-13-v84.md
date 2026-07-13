# Kujo Relay Next-Session Enhancement Backlog — v84

Relay remains a hardened local alpha/showcase, not an enterprise-production
platform or universally useful runtime. v84 makes bounded JSONL evidence
persistence report native Kujo write failures truthfully. The next session
should prioritize external authority and integration evidence rather than
adding more local wrappers.

## P0 — External authority and provider evidence

- [ ] Exercise Ollama Cloud and one independent OpenAI-compatible provider
  through the real Watchdog server with redacted usage, latency, fallback, and
  correlation evidence.
- [ ] Add authenticated multi-tenant machine mode through guarded MCP or an
  equivalent boundary with identity, role, approval, and audit mappings.
- [ ] Replace the rebuildable JSON index with durable transactional storage
  supporting crash recovery, retention, migration, multi-host concurrency, and
  signed export.
- [ ] Prove isolated workcell/container missions with rollback, crash recovery,
  retention, and explicit process/filesystem/network limits.
- [ ] Prove provider-generated Agents SDK tool planning through Watchdog in an
  isolated mission with typed tool-result artifacts and bounded fallback.

## P1 — Composition and evidence

- [ ] Import canonical Spec/Dispatch contracts with schema/version negotiation.
- [ ] Attach causal mission/run/workflow/step/agent/model/provider/packet/tool/
  artifact/evaluation/retry/repair IDs to every event and receipt.
- [ ] Integrate CaseFile and Redact for failed-run bundles and sensitive
  prompts, packets, reports, and handoffs.
- [ ] Complete Capsule A/B scoring with fresh sessions and comparable Eval
  reports; add optional Paperclip and Hermes adapters.
- [ ] Add typed retry, fallback, repair, escalation, cancellation, and
  regression-evaluation receipts where upstream contracts support them.

## P2 — Performance, operations, and release posture

- [ ] Add true streaming sinks, bounded parallel read-only discovery,
  retention/compaction, resumable export, and aggregate metrics.
- [ ] Add doctor checks for ownership, lock age/recovery, durable-store and
  Watchdog reachability, provider profiles, and release posture.
- [ ] Run Fence, Concord, ShipCheck, and Eval release gates with verified local
  badges and pinned macOS/Linux/CI installation paths.
- [ ] Add committed fixture transcripts, generated architecture diagrams, and a
  truthful showcase gallery backed by machine-readable artifacts.
- [ ] Add repeatable install/upgrade and dependency provenance checks for
  supported macOS/Linux/CI paths.

## Definition of done for the next session

- [ ] Changed behavior has focused Kujo tests and the 25-script acceptance set
  remains green.
- [ ] At least one external provider is exercised through real Watchdog with
  authenticated correlation and redacted usage evidence.
- [ ] Provider-generated tool planning is proven in an isolated mission.
- [ ] Live, configured-live, fixture, and blocked evidence are separated in
  reports and documentation.
- [ ] Changes are committed in small meaningful commits, pushed, and clean.

## Verification baseline

```bash
bash tests/relay_acceptance.sh
../kujo-workflows/loop-engineering/scripts/run-workflow.sh --config .loop-engineering/loop.yml
```

These local gates do not prove live providers, multi-host durability,
authenticated tenancy, or enterprise release readiness.
