# Naming Recommendation

## Decision

- Human-facing product: **Kujo Relay**
- Repository: `relay`
- Package: `relay`
- Binary: `relay`

Relay fits the runtime's role: it connects existing Kujo providers, agents, tools, evidence systems, and external callers without claiming ownership of them. It is short, pronounceable, and describes both the CLI and reusable runtime.

## Audit

An organization-wide `rg` audit found no existing repository, binary, package, or first-class concept using Relay, Conduit, Rally, Sortie, or Cadence in this checkout. Matches for Cadence were ordinary documentation cadence language; none represented a product collision.

Alternatives rejected:

- **Conduit**: technically accurate, but generic and less aligned with rank-to-rank handoffs.
- **Rally**: suggests team coordination or a campaign UI, not controlled execution evidence.
- **Cadence**: suggests scheduling and periodic execution.
- **Sortie**: memorable but implies a single tactical run and is less suitable for a reusable runtime.
- **Dispatch**: already an established workflow engine and would create direct ownership confusion.

No external publishing or rename was performed.
