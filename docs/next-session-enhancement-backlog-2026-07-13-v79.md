# Kujo Relay Next-Session Enhancement Backlog — v79

Relay remains a local alpha/showcase composition runtime, not an enterprise
multi-tenant execution plane. v79 hardens mission state-directory creation
with exclusive native `mkdir` and fail-closed symlink-component checks. The
next session should preserve this boundary while closing the external evidence
gaps below.

## P0 — External execution and authority evidence

- [ ] Run a real Ollama Cloud or compatible provider mission through AI SDK and
  Watchdog with captured redacted telemetry and usage reconciliation.
- [ ] Add a real isolated workcell/container provider with rollback and crash
  recovery evidence; keep the local worktree path as a development fallback.
- [ ] Define authenticated ownership and durable storage for capabilities,
  locks, checkpoints, events, and artifacts across concurrent hosts.
- [ ] Add signed dependency/artifact provenance and a release gate that verifies
  the exact Kujo and companion binaries used by a run.

## P1 — Ecosystem composition

- [ ] Import a canonical Spec/Dispatch workflow without creating a competing
  mission schema or state machine.
- [ ] Add causal event IDs, durable event sinks, CaseFile failure bundles, and
  Redact-compatible artifact envelopes.
- [ ] Complete Capsule A/B scoring with independent Eval evidence and repeated
  same-commit comparisons.
- [ ] Add Paperclip and Hermes adapters as optional machine-facing boundaries.

## P2 — Operations and product surface

- [ ] Add bounded streaming mission events, retention/compaction, and aggregate
  metrics without weakening evidence verification.
- [ ] Add doctor checks for state-directory ownership, lock age, recovery
  posture, and durable-store reachability.
- [ ] Run ShipCheck/Concord release gates and document a supported packaging
  and installation path.

## Verification baseline

```bash
bash tests/relay_acceptance.sh
../kujo-workflows/loop-engineering/scripts/run-workflow.sh --config .loop-engineering/loop.yml
```

Neither command is evidence of live provider, multi-host, signed-provenance,
or enterprise release readiness.
