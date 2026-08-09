# Relay ecosystem discovery

This document records the composition boundary that informed Relay v1. Current release classifications and immutable revisions are maintained in the [integration matrix](integration-matrix.md), which takes precedence over historical maturity observations.

## Reused ownership

| Owner | Contract Relay reuses | Relay responsibility |
| --- | --- | --- |
| Kujo | language/runtime, direct process primitives, filesystem and integrity functions | CLI and mission composition |
| AI SDK | OpenAI-compatible chat/stream/tool response normalization | bounded request construction and evidence correlation |
| Agents SDK | tools, approval providers, runner events and budgets | local capability binding and policy execution |
| Watchdog | provider proxy, telemetry, auth posture, request correlation | mandatory live route selection and reconciliation |
| PackWrite | agent packet generation | recursive packet integrity and completion requirement |
| RunLedger | lifecycle receipt | start/finish authority and correlation |
| ChangeBucket | change/risk report | required post-action evidence |
| Eval | deterministic evaluation | required acceptance evidence |
| Workcell | disposable container execution and receipt verification | exact-candidate release proof |
| ShipCheck / Kennel | release readiness and package metadata | independent release gates |

Relay does not copy these implementations or claim ownership of their canonical stores. It uses narrow subprocess or source bridge boundaries and records typed local references.

## v1 execution map

```text
CLI → Relay policy/runtime → fixture or Watchdog → AI SDK
                          ↘ Agents SDK bounded tools
                           ↘ PackWrite packet
                            ↘ provided repo or detached worktree
                             ↘ ChangeBucket + Eval + RunLedger
                              ↘ state + events + receipts + reports + export
```

Fixture mode proves deterministic Relay and SDK behavior without a network call. Local Watchdog/stub tests prove route, auth, request-correlation, usage-reconciliation, and redaction contracts without proving an external provider. The approval-gated external procedure remains a separate release gate.

## Boundaries retained for v1

- Relay remains a local/operator CLI rather than a hosted service.
- Dispatch and Spec remain upstream workflow-authoring candidates; Relay v1 does not import their complete contracts.
- CaseFile, Redact, Concord, Fence, Muzzle, Scent, Scout, and other ecosystem tools remain optional or experimental rather than hidden runtime dependencies.
- Capsule support is limited to the documented discovery benchmark slice.
- Git worktrees isolate changes from the source checkout but are not hostile-code sandboxes.
- Local SHA-256 evidence is tamper-evident, not signed authority.
