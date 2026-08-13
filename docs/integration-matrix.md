# Relay v1 integration matrix

This matrix separates required local v1 dependencies, optional proven integrations, experimental adapters, and deferred work. A local fixture or stub result is never external-provider certification. Exact immutable candidate pins live in [`release/dependencies.json`](../release/dependencies.json).

| Integration | Candidate identity | v1 classification | Proven Relay v1 boundary | Not claimed |
| --- | --- | --- | --- | --- |
| Kujo | `1.0.0` / `9b77dce592047121cb71066629836ad89252f3ce` | required and proven locally | interpreter, process-group cancellation, filesystem/integrity primitives, CLI execution | compatibility with arbitrary Kujo revisions |
| AI SDK | `1.0.0` / `d3c6def0f7844f8b42bd92d3b176e80283af8e79` | required and proven for fixture/local boundary | bounded OpenAI-compatible requests, streaming normalization, usage and error normalization | provider-independent production certification |
| Agents SDK | `1.0.0` / `e92a61ec1df21c89ae26f411838b4669405a0765` | required and proven locally | bounded tool registry, approval provider, capability-bound tool execution, replay rejection | remote authenticated tool authority |
| Kujo Agents | `f0c95b66fbc74057481ef228961eb6e69ff8886a` | required and proven locally | Chain of Command role catalog loaded by `agents` commands | hosted identity or tenant directory |
| PackWrite | `1.0.0` / `0cb9487e4c02218bb4a18efe68b8a0c22998f715` | required and proven locally | packet generation, required `MASTER.md`, recursive packet manifest | signed packet authority |
| RunLedger | `1.0.0` / `5cf186c9b56b540970f75e33a06f50d3dac833a8` | required and proven locally | start/finish lifecycle receipt and correlation | hosted ledger or custody guarantee |
| ChangeBucket | `1.0.0` / `373ac51a572bd3bb0510ac718ac1bab065c84735` | required and proven locally | bounded change report required for completion | organization-specific change approval |
| Eval | `1.0.0` / `dce9d030a3547803dab876b404c44c25b247dde1` | required and proven locally | deterministic acceptance result required for completion | general model-quality certification |
| Watchdog | `1.0.0` / `7c46cd0bf1680d037c24506be4ed0a2405a9841f` | optional and proven with local server/stub; external proof blocked until approved | mandatory live route, auth posture, request-ID correlation, usage reconciliation, secret-safe evidence | silent bypass, arbitrary provider certification, hosted proxy operation |
| Workcell | `1.0.0` / `28d2c4a3b8d317fedd5e20be618f98bd3859eaea` | required exact-candidate release gate | bounded no-network success/failure execution, manifest and receipt verification when rerun | VM isolation, compromised-daemon defense, universal certification |
| Kennel | `1.0.0` / `6df043c3ba0bde4445cc8f8f7d4c01c60c9c6d7e` | required release gate | manifest validation and public export declaration | package publication during preparation |
| ShipCheck | `1.0.0` / `2768e3040e766b0befd354db4427afc4c7a81899` | required release gate | 16-check repository readiness gate | test, provider, platform, or security certification |
| Concord | `1.0.0` / `d388c951b7ff0e1e03da1cd252ad5b65e25765b9` | experimental | optional artifact-drift review | v1 runtime dependency |
| CaseFile | `1.0.0` / `6e8a6ded379a9882b2e48b0a8f0bad57e284c3bf` | experimental | confirmed, integrity-valid failed-run handoff marked CaseFile-compatible | automatic canonical run evidence ownership |
| Redact | unreleased / `ba317c74ab3e234e33b2a8ca7a2f6d4d94aeaf69` | experimental | policy-selected handoff uses Relay's bounded tested redaction filter | stable upstream dependency or complete data classification |
| Spec | `1.0.0` / `11180d8f6af1ed3eea84abb3434dd736fa51293b` | experimental | explicit `1.0.0` envelope version negotiation and compatibility fixtures | complete upstream Spec execution semantics |
| Dispatch | `1.0.0` / `35b73aca3ce0c51ef480f84b4150ea566d8a26fe` | experimental | explicit `1.0.0` envelope version negotiation and compatibility fixtures | Dispatch graph execution or hosted orchestration |

## Required evidence boundaries

Required local dependencies are checked for regular non-symlink paths, bounded version output, and optional configured SHA-256 pins by `doctor`. The release workflow checks out immutable revisions as siblings and never depends on an undocumented workstation layout.

The aggregate acceptance suite proves fixture, local Watchdog/stub, policy, worktree, capability, cancellation, repair, schema, and evidence paths. External provider proof is a separate approval-gated procedure in [`live-provider-verification.md`](live-provider-verification.md). Workcell proof is a separate exact-commit container receipt. ShipCheck, Kennel, platform CI, artifact reproducibility, and local tests remain distinct gates; none substitutes for another.

## Deferred post-v1 capabilities

Hosted authenticated tenancy, durable transactional multi-host storage, hosted orchestration, full upstream Spec/Dispatch execution, automatic CaseFile export, universal provider certification, asymmetric signing/custody, unrestricted shell, and autonomous production access are outside the local v1 contract.
