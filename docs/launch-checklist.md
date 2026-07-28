# Launch Checklist

Current launch scope: `technical preview`. Relay's local fixture and acceptance gates pass, but hosted orchestration, live-provider use, durable multi-host storage, authenticated tenancy, full Workcell isolation, and enterprise readiness remain unproven.

## Local Gates

- [x] Doctor checked with `./bin/relay doctor --json`.
- [x] Agent registry checked with `./bin/relay agents validate --json`.
- [x] Fixture chat checked with `./bin/relay chat "Summarize the mission boundary" --fixture --json`.
- [x] Contract tests executed with `$KUJO_BIN run tests/relay_contract_tests.kujo --interpreter`.
- [x] Aggregate acceptance checked with `bash tests/relay_acceptance.sh`.
- [x] Formatting checked with `git diff --check`.
- [ ] Workcell proof checked with `workcell run --file docs/workcell-launch-gate.json --repo .`.
- [ ] Live provider and Watchdog route proof with explicit credentials and route configuration.

## Current External Blocker

Workcell proof is blocked by the local Docker image build/pull path. The Workcell base image could not be fetched from Docker Hub because `auth.docker.io` timed out.

Closest equivalent proof: Relay local fixture, contract, and acceptance gates.

Safe resume command:

```bash
cd /Users/robertdevore/2026/Kujolang/kujo-repos/workcell
DOCKER_HOST=unix:///Users/robertdevore/.colima/kujo-workcell/docker.sock docker build --tag kujolang/workcell-base:local docker/
cd /Users/robertdevore/2026/Kujolang/kujo-repos/relay
workcell run --file docs/workcell-launch-gate.json --repo .
```

## Forbidden Launch Actions

Hosted deployment, live credentials, package publication, final release tags, public releases, signing/notarizing, branch-protection changes, force-pushes, and production/enterprise claims remain out of scope.
