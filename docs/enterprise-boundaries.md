# Enterprise-oriented local boundaries

Relay provides composable controls for enterprise wrappers without claiming a
hosted enterprise platform.

## Spec and Dispatch negotiation

`relay contracts negotiate envelope.json --json` accepts a regular JSON file
up to 1 MiB with `kind`, `version`, and object `payload`. Relay currently
negotiates explicit Spec or Dispatch `1.0.0` envelopes and rejects every
unknown kind or version before using the payload. The compatibility fixtures
in `tests/fixtures/contracts/` are the canonical boundary; negotiation does not
silently reinterpret a full upstream workflow.

## Machine authorization

Machine access defaults to disabled. A trusted transport may set
`RELAY_MACHINE_ACCESS_ENABLED=true`, provide an operator-owned
`RELAY_MACHINE_ACCESS_SECRET`, and invoke `relay machine authorize` with a
bounded `RELAY_MACHINE_REQUEST`. Relay requires identity, recognized role,
tenant, action, and explicit approval for operator actions. Every accepted or
denied authenticated request is appended to a bounded, integrity-sealed local
audit log. This is an authorization primitive, not a network server, SSO
implementation, or multi-tenant isolation claim.

## Failed-run handoff

`relay runs handoff <run-id> --output <path> --confirm` accepts only an
integrity-valid failed or cancelled run. It emits a bounded
`relay-failure-handoff-v1` object marked CaseFile-compatible after applying
Relay's credential redaction filter. Policy selection and explicit
confirmation prevent automatic exfiltration; the output references the local
evidence root and remains subject to its access controls.

## Signed export and rotation

Unsigned `relay-run-export-v1` remains unchanged. `runs export --signed`
wraps a verified complete export in `relay-signed-export-v1` and authenticates
the canonical payload digest with HMAC-SHA256. Operators own secret generation,
storage, access, rotation, and retirement. Use a bounded JSON map during
rotation:

```bash
export RELAY_SIGNING_KEYS='{"2026-q3":"old-secret","2026-q4":"new-secret"}'
relay runs export <run-id> --signed --key-id 2026-q4 --output signed.json --json
relay runs verify-signature signed.json --json
```

Retain old keys only while their exports must remain verifiable, then remove
them according to organizational policy. `RELAY_SIGNING_KEY` is a single-key
compatibility fallback. HMAC proves possession of a shared key; it does not
provide public verifiability, non-repudiation, hardware custody, notarization,
or asymmetric signer identity.
