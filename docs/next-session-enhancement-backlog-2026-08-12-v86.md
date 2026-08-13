# Kujo Relay Next-Session Enhancement Backlog — v86

Relay is a strong local-first Kujo showcase with a stable bounded v1 surface.
It is not yet a universal enterprise platform: authenticated tenancy, durable
multi-host state, provider-independent certification, and hosted orchestration
remain outside the current product boundary. This review added fail-closed CLI
shapes and bounded, resumable repository discovery.

## P0 — Release evidence for the exact candidate

- [ ] Rerun the full release gate, Kennel validation, ShipCheck 16/16 gate, and
  two-build artifact reproducibility check against one clean candidate commit.
- [ ] Retain successful Linux, macOS x86_64, and macOS arm64 CI evidence for
  that exact commit.
- [ ] Rerun Workcell success and intentional-failure proofs against that exact
  commit, retaining verified manifests and receipts.
- [ ] With release-owner approval, verify one external provider chat and one
  provider-generated tool mission through Watchdog with redacted correlation
  and usage evidence.

## P1 — Local durability, recovery, and lifecycle

- [x] Design a versioned migration from the rebuildable JSON index to a
  transactional local store with crash recovery; do not claim multi-host
  durability until concurrency and recovery are independently proven.
- [x] Add an explicit retention policy and dry-run inventory for completed run
  evidence, followed by confirmation-gated pruning with ownership and integrity
  checks.
- [x] Add bounded run-index directory limits and a machine-readable doctor
  posture before large local stores can amplify every list or control command.
- [x] Define stale capability/index lock ownership and recovery receipts rather
  than relying only on elapsed wall time.

## P1 — Composition and security

- [x] Import canonical Spec and Dispatch contracts behind explicit version
  negotiation and compatibility fixtures.
- [x] Add authenticated MCP or equivalent machine access with identity, role,
  approval, tenant, and audit mappings; keep it disabled by default.
- [x] Integrate Redact and CaseFile for policy-selected failed-run handoff while
  preserving Relay's bounded evidence contracts.
- [x] Add signed export as a separate contract with key ownership, rotation,
  verification, and unsigned-v1 migration guidance.

## P2 — Performance and product proof

- [x] Benchmark `runs list`, `runs verify`, `runs watch`, and export across
  representative run/event/artifact sizes on macOS and Linux; commit budgets
  and regression thresholds before optimizing.
- [x] Prototype streaming or cursor-backed tracked-file discovery for
  repositories whose `git ls-files` output exceeds `max_output_bytes`.
- [x] Add aggregate latency, token, tool-duration, retry, and artifact-size
  summaries without introducing unbounded metric cardinality.
- [x] Add a generated showcase gallery that links every claim to a committed
  fixture, schema, command transcript, or exact-candidate proof artifact.

## Definition of done for the next session

- [ ] Every behavior change has focused Kujo or shell regression coverage.
- [ ] `bash tests/relay_acceptance.sh`, release metadata, schemas, Markdown
  links, and `git diff --check` pass with the pinned runtime.
- [ ] External/live, local-real, fixture, and blocked evidence remain clearly
  separated.
- [ ] README and command-reference examples remain directly runnable.
- [ ] Changes are committed in small meaningful commits, pushed, and the
  working tree is clean.
