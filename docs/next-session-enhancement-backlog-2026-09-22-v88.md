# Relay review and next-session backlog — v88

Reviewed 2026-09-22. Relay remains a bounded local/operator-controlled mission
runner, not a universally enterprise-ready service. This review covers the
CLI, redaction and process helpers, mission policy/lifecycle, signed exports,
run-index validation, SQLite integration, test/release tooling, and public
documentation. It is a targeted engineering review, not an exhaustive security
certification or proof of every deployment environment.

## Changes from this review

- Complete and truncated PEM private-key bodies are removed from redacted
  output, including JSON-escaped blocks; public-key text is preserved.
- Invalid configured signing keyrings cannot silently select the legacy secret.
  Signed-export verification validates wrapper metadata and works without the
  originating local state store. Existing HMAC payload inputs are unchanged.
- Bounded JSON reads reuse one file-size probe, and signed exports reuse their
  canonical payload serialization for the size check and digest.
- Benchmark p95 now uses nearest rank rather than rounding down. Five-sample
  CI evidence replaces single-sample representative runs. This improves
  measurement integrity; it does not establish a throughput improvement.
- The lifecycle projection assertion now handles Kujo's integer `contains`
  result instead of aborting the contract suite on unary negation.
- README and security guidance distinguish optional local SQLite transactions,
  retention, and HMAC authentication from hosted tenancy and key custody.

## Repository layout decision

All tracked runtime modules already live in `src/`. Keep root `main.kujo`:
launchers, package manifests, release archives, and tests require that small
entrypoint. Keep package manifests, version pins, license, changelog, and
contributor/security guidance at the root. No obsolete tracked root runtime
copies were found. Ignored historical test/state directories are operator-local
artifacts and were not deleted as part of source cleanup.

## P0 — Release evidence before production claims

- [ ] Run the final candidate on Linux and both supported macOS architectures,
  retain full acceptance and artifact reproducibility evidence, and confirm
  all immutable ecosystem revisions match `release/dependencies.json`.
- [ ] Obtain explicit owner approval for credentials/provider/model and run
  `scripts/live_provider_verification.sh` through Watchdog. Fixture and local
  stub results cannot establish external provider compatibility.
- [ ] Rerun Workcell success/failure proof on the final candidate. If Docker or
  the host is unavailable, retain a blocker receipt and closest local proof;
  never carry an old commit's receipt forward as current evidence.

Acceptance: candidate-specific receipts and CI results, no unresolved required
release gate, and explicit deployment scope. These continue the v87 P0 gates.

## P1 — Strengthen boundaries before extending the product

- [ ] Define operator-owned machine identity/role/tenant mappings before adding
  socket or MCP transport. `src/enterprise.kujo::authorize_machine_request`
  currently trusts caller-supplied claims after shared-secret authentication;
  it accepts action prefixes and approved operator actions rather than a fixed
  action dictionary. The CLI primitive is not a service authorization layer.
  Add exact action mappings, deny unknown actions, derive approval server-side,
  and test forged role/tenant/approval, replay, expiry, and cross-tenant access.
- [ ] Add a documented backup/restore drill for authoritative run directories;
  rebuild both index backends from restored evidence and test partial copies,
  corruption, and interrupted restore. Define recovery objectives from measured
  results instead of implying multi-host durability.
- [ ] Review SQLite open behavior: `sqlite_read_index` calls `sqlite_open`, which
  performs schema creation, migration insertion, and WAL configuration even on
  read paths. Separate initialization from read-only validation and add fixtures
  for missing/unknown schema versions, locked databases, and unsafe sidecars.
  This is a follow-up design review, not a demonstrated exploit in this session.
- [ ] Expand redaction fixtures for quoted credentials containing whitespace,
  escaped quotes, and chunk boundaries. Preserve useful diagnostics without
  treating pattern matching as a general secret-classification guarantee.

## P2 — Measure scale and improve adoption

- [ ] Collect fresh five-sample small/medium/large results after the percentile
  correction. `run_directories_match_index` reparses all authoritative states
  on a cache hit; aggregate metrics reads them again. Profile this cost before
  designing an invalidation strategy. Preserve tamper detection and bounded
  reads; compare cold/warm latency and memory on both backends.
- [ ] Design streaming tracked-file discovery beyond the current 16 MiB envelope
  and versioned chunked evidence beyond the 1 MiB JSON ceiling. Acceptance must
  cover stable cursors, concurrent repository changes, cancellation, and bounds.
- [ ] Add an isolated fixture walkthrough from installation to verified export,
  with generated screenshots and clear links to Kujo learning material. Confirm
  it works with pinned sibling dependencies on a clean host.

Asymmetric custody and full Spec/Dispatch execution remain deferred v87 items;
implementing them requires explicit contracts and compatibility fixtures.

## Verification record

Verification results are recorded below after running the candidate checks.
Do not infer external provider, Workcell, or cross-platform success from local
contract tests.
