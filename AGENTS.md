# Relay Agent Instructions

Relay is a local-first composition and execution layer for bounded agent missions. Treat it as a hardened local alpha/showcase unless live-provider, durable storage, tenancy, Workcell, and release-gate proof exist for the exact commit.

## Required Reading

- `README.md`
- `docs/command-reference.md`
- `docs/integration-matrix.md`
- `docs/launch-checklist.md`
- Latest `docs/next-session-enhancement-backlog*.md`

## Validation

Set `KUJO_BIN` to the intended Kujo runtime.

```bash
./bin/relay doctor --json
./bin/relay agents validate --json
./bin/relay chat "Summarize the mission boundary" --fixture --json
"$KUJO_BIN" run tests/relay_contract_tests.kujo --interpreter
bash tests/relay_acceptance.sh
git diff --check
```

## Evidence Rules

- Preserve `.relay/runs/` evidence only when it is intentionally part of a proof packet; otherwise keep generated runs out of commits.
- Workcell proof is required for this launch batch unless a blocker receipt documents the Docker/host blocker and closest equivalent proof.
- Live provider evidence requires explicit environment configuration and must not bypass Watchdog.

## Prohibited Without Approval

Do not deploy hosted orchestration, use live credentials, publish packages, create public releases, push final tags, alter branch protection, force-push, rewrite history, or claim production/enterprise readiness from fixture proof alone.
