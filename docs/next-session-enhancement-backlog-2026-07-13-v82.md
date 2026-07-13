# Kujo Relay Next-Session Enhancement Backlog — v82

Relay remains a local-first hardened alpha/showcase, not a universally useful
enterprise-production platform. v82 removes a duplicate filesystem scan from
invalid run-index recovery. The next session should prioritize external
authority and cross-repository usefulness.

## P0 — Production authority and external integrations

- [ ] Exercise Ollama Cloud and one independent OpenAI-compatible provider
  through the real Watchdog server with redacted usage, latency, fallback, and
  correlation evidence.
- [ ] Add authenticated multi-tenant machine mode through the guarded MCP or
  equivalent boundary with identity, role, approval, and audit mappings.
- [ ] Replace the rebuildable JSON index with durable transactional storage
  supporting crash recovery, retention, migration, multi-host concurrency, and
  signed export.
- [ ] Prove isolated workcell/container missions with rollback, crash recovery,
  retention, and explicit process/filesystem/network limits.

## P1 — Composition and evidence

- [ ] Import canonical Spec/Dispatch contracts with version negotiation.
- [ ] Attach causal mission/run/workflow/step/agent/model/provider/packet/tool/
  artifact/evaluation/retry/repair IDs to every event and receipt.
- [ ] Integrate CaseFile and Redact for failed-run bundles and sensitive
  prompts, packets, reports, and handoffs.
- [ ] Complete Capsule A/B scoring with fresh sessions and comparable Eval
  reports; add optional Paperclip and Hermes adapters.

## P2 — Performance, operations, and presentation

- [ ] Add true streaming sinks, bounded parallel read-only discovery,
  retention/compaction, resumable export, and aggregate metrics.
- [ ] Add doctor checks for ownership, lock age/recovery, durable-store and
  Watchdog reachability, provider profiles, and release posture.
- [ ] Run Fence, Concord, ShipCheck, and Eval release gates with verified local
  badges and pinned macOS/Linux/CI installation paths.
- [ ] Publish a truthful showcase gallery backed by fixture transcripts and
  machine-readable artifacts.

## Verification baseline

```bash
bash tests/relay_acceptance.sh
../kujo-workflows/loop-engineering/scripts/run-workflow.sh --config .loop-engineering/loop.yml
```

These local gates do not prove live providers, multi-host durability,
authenticated tenancy, or enterprise release readiness.
