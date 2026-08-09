# Contributing to Relay

Relay is a local-first safety boundary for bounded agent missions. Keep `main.kujo` and `bin/relay` thin, put reusable implementation under `src/`, schemas under `schemas/`, deterministic examples under `examples/`, and regression coverage under `tests/`.

## Development setup

Use the pinned Kujo runtime recorded in `RUNTIME_VERSION` and the exact sibling revisions in `release/dependencies.json`. Do not make tests depend on a developer-specific directory layout; CI checks out those repositories as siblings at immutable revisions.

```bash
export KUJO_BIN=/path/to/pinned/kujo
test "$(git -C /path/to/kujo rev-parse HEAD)" = "$(cat RUNTIME_VERSION)"
./bin/relay --version
bash scripts/release_gate.sh
```

## Change rules

- Preserve direct-argv execution. Do not introduce shell interpolation for mission, provider, repository, or tool input.
- Keep writes behind explicit mission approval and path authority. Never broaden command, script, environment, worktree-cleanup, or credential authority without focused negative tests.
- Treat product, mission, event, receipt, state, tool-result, packet, export, and schema versions as independent contracts. A product bump alone does not rename machine contracts.
- Add a new contract identifier and migration guidance for incompatible machine changes. Maintain committed fixtures for every supported version.
- Keep fixture, local Watchdog/stub, and external live-provider evidence clearly separated.
- Update `README.md`, `docs/command-reference.md`, schemas, CLI help, compatibility policy, and tests together when public behavior changes.
- Generated release files belong under ignored `dist/`; do not commit runtime runs, credentials, or local proof directories.

## Verification

Run the focused command checks while iterating, then the complete gate:

```bash
"$KUJO_BIN" check main.kujo
"$KUJO_BIN" run tests/relay_contract_tests.kujo --interpreter
bash tests/relay_acceptance.sh
bash tests/markdown_links.sh
bash tests/release_metadata.sh
bash tests/release_artifacts_smoke.sh
git diff --check
```

Live provider verification is never implicit. Follow `docs/live-provider-verification.md`, use only explicitly approved credentials, route through Watchdog, and retain redacted evidence outside Git unless a reviewed compact fixture is intended.
