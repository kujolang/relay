# Kujo Relay Next-Session Enhancement Backlog — v80

Relay remains a local-first hardened alpha/showcase, not a universally useful
enterprise-production platform. v80 removes a duplicate filesystem writer and
unifies capability-directory creation with the state-directory safety policy.
The next session should move from local filesystem consistency toward stronger
external execution and operational evidence.

## P0 — Production authority and external integrations

- [ ] Exercise Ollama Cloud and one independent OpenAI-compatible provider
  through the real Watchdog server with redacted usage, latency, fallback, and
  correlation evidence.
- [ ] Add authenticated multi-tenant machine mode through the guarded MCP or
  equivalent boundary, with identity, role, approval, and audit mappings.
- [ ] Replace the rebuildable JSON index with a durable transactional owner
  supporting crash recovery, retention, multi-host concurrency, migration, and
  signed export.
- [ ] Prove an isolated workcell/container mission with rollback, crash
  recovery, retention, and explicit process/filesystem/network limits.

## P1 — Composition and evidence

- [ ] Import canonical Spec/Dispatch contracts with version negotiation and no
  competing workflow schema.
- [ ] Attach causal mission/run/workflow/step/agent/model/provider/packet/tool/
  artifact/evaluation/retry/repair IDs to every event and receipt.
- [ ] Integrate CaseFile and Redact for failed-run bundles, prompts, packets,
  reports, and handoffs.
- [ ] Complete Capsule A/B scoring with fresh receiving sessions and
  comparable Eval JSON/Markdown reports.
- [ ] Add optional Paperclip and Hermes adapters over the stable JSON boundary.

## P2 — Performance, operations, and presentation

- [ ] Add true streaming mission sinks, bounded parallel read-only discovery,
  retention/compaction, resumable export, and aggregate metrics.
- [ ] Add doctor checks for capability/state ownership, lock age, recovery,
  durable-store reachability, provider profiles, and release posture.
- [ ] Run Fence, Concord, ShipCheck, and Eval release gates with verified local
  badges and a pinned macOS/Linux/CI installation path.
- [ ] Publish a truthful showcase gallery backed by committed fixture
  transcripts and machine-readable artifacts.

## Verification baseline

```bash
bash tests/relay_acceptance.sh
../kujo-workflows/loop-engineering/scripts/run-workflow.sh --config .loop-engineering/loop.yml
```

These local gates do not prove live providers, multi-host durability,
authenticated tenancy, or enterprise release readiness.
