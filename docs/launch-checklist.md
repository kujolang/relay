# Launch Checklist

Current launch scope: `technical preview`. Relay's local fixture, acceptance, and Workcell proof gates pass, but hosted orchestration, live-provider use, durable multi-host storage, authenticated tenancy, and enterprise readiness remain unproven.

## Local Gates

- [x] Doctor checked with `./bin/relay doctor --json`.
- [x] Agent registry checked with `./bin/relay agents validate --json`.
- [x] Fixture chat checked with `./bin/relay chat "Summarize the mission boundary" --fixture --json`.
- [x] Contract tests executed with `$KUJO_BIN run tests/relay_contract_tests.kujo --interpreter`.
- [x] Aggregate acceptance checked with `bash tests/relay_acceptance.sh`.
- [x] Formatting checked with `git diff --check`.
- [x] Workcell proof checked with `workcell run --file docs/workcell-launch-gate.json --repo . --no-pull`.
- [ ] Live provider and Watchdog route proof with explicit credentials and route configuration.

## Workcell Proof Notes

Workcell proof passed after building `kujolang/workcell-base:local` with `DOCKER_BUILDKIT=0`, using the Colima Workcell Docker host, and setting `TMPDIR` to a path under `/Users/robertdevore/2026/Kujolang/kujo-repos/.workcell-host-tmp` so the disposable worktree mount was visible inside the Colima VM.

Resume command:

```bash
export DOCKER_HOST=unix:///Users/robertdevore/.colima/kujo-workcell/docker.sock
export DOCKER_CONFIG=/tmp/kujo-next-batch-docker-config
export TMPDIR=/Users/robertdevore/2026/Kujolang/kujo-repos/.workcell-host-tmp
workcell run --file docs/workcell-launch-gate.json --repo . --no-pull
workcell verify --run .workcell/runs/<run-id> --json
```

## Forbidden Launch Actions

Hosted deployment, live credentials, package publication, final release tags, public releases, signing/notarizing, branch-protection changes, force-pushes, and production/enterprise claims remain out of scope.
