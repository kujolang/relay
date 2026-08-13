# Kujo Relay Next-Session Enhancement Backlog — v87

Relay now has a stronger production-oriented local boundary: transactional
single-host indexing, retention, owned lock recovery, negotiated composition
envelopes, authenticated authorization/audit primitives, redacted failure
handoff, HMAC-signed exports, bounded aggregate metrics, performance budgets,
scalable cursor discovery, and an evidence-linked showcase. It still must not
be marketed as hosted, multi-host durable, or universally enterprise certified.

## P0 — Close externally controlled release evidence

- [ ] Obtain release-owner approval for credentials/provider/model, then run
  the bounded external chat and provider-generated tool proof through Watchdog.
- [ ] Rerun the clean exact-candidate release gate and two-build reproducibility
  after any change made to resolve an external gate.

## P1 — Advance local contracts without overstating scope

- [ ] Add an authenticated socket/MCP transport around the existing machine
  authorization primitive, with replay nonces, expiry, rate limits, and
  transport-level integration fixtures; keep the listener disabled by default.
- [ ] Add asymmetric signed-export support backed by an operator-selected OS or
  hardware keystore, preserving HMAC v1 verification and documenting custody.
- [ ] Import complete upstream Spec/Dispatch semantics only after fixture parity
  tests prove field mappings, downgrade rejection, cancellation, and budgets.
- [ ] Define a backup/restore drill for authoritative run evidence and the
  SQLite cache; continue to reject multi-host durability claims.
- [ ] Design a versioned chunked or streaming JSON evidence contract for
  payloads above Kujo 1.0.0's 1 MiB parser ceiling; keep v1 reads fail-closed.

## P2 — Scale and demonstrate

- [ ] Replace the 16 MiB tracked-index collection ceiling with a true streaming
  Git reader or persistent opaque cursor while preserving deterministic pages.
- [ ] Commit five-sample medium and large benchmark evidence on Linux and both
  macOS architectures; tune only repeatable budget breaches.
- [ ] Add bounded percentile/histogram metric exports with fixed dimension
  dictionaries and explicit overflow buckets.
- [ ] Add a narrated fixture-only showcase transcript and screenshots generated
  from committed evidence, with no live-provider claim unless the P0 proof passes.

## Definition of done

- [ ] Every behavior change has focused regression coverage and schema updates.
- [ ] Aggregate acceptance, release gate, reproducibility, Markdown links, and
  `git diff --check` pass with the pinned runtime on the exact candidate.
- [ ] Evidence labels distinguish fixture, local-real, platform CI, external
  live, and blocked results.
- [ ] Small meaningful commits are pushed and the working tree is clean.
