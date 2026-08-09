#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
version="$(tr -d '\r\n' < "$ROOT/VERSION")"
test "$version" = "1.0.0"
grep -Fqx 'version = "1.0.0"' "$ROOT/kujo.toml"
grep -Fqx 'version = "1.0.0"' "$ROOT/kennel.toml"
grep -Fq 'export RELAY_VERSION := "1.0.0"' "$ROOT/src/contracts.kujo"
grep -Fq 'export MISSION_SPEC_VERSION := "1.0.0"' "$ROOT/src/contracts.kujo"
grep -Fq '[![Version](https://img.shields.io/badge/version-1.0.0-black)]' "$ROOT/README.md"
grep -Fq '## [1.0.0]' "$ROOT/CHANGELOG.md"
test "$(tr -d '\r\n' < "$ROOT/RUNTIME_VERSION")" = "$(jq -r '.dependencies.kujo.revision' "$ROOT/release/dependencies.json")"
jq -e --arg version "$version" '.relay_version == $version and (.dependencies | type == "object") and (all(.dependencies[]; (.revision | test("^[0-9a-f]{40}$")) and (.required | type == "boolean")))' "$ROOT/release/dependencies.json" >/dev/null
jq -e --arg version "$version" '.relay_product == $version and .mission_current == "1.0.0" and .mission_supported == ["1.0.0", "0.1.0"]' "$ROOT/release/contracts.json" >/dev/null

for mission in "$ROOT"/examples/*-mission.json; do
  test "$(jq -r '.version' "$mission")" = "1.0.0"
done

if [[ -x "$KUJO" ]]; then
  test "$(KUJO_BIN="$KUJO" "$ROOT/bin/relay" --version)" = "relay 1.0.0"
fi

grep -Fqx 'minimum_version = "1.0.0"' "$ROOT/kennel.toml"
grep -Fqx 'entry = "main.kujo"' "$ROOT/kennel.toml"
grep -Fqx 'stage = "production"' "$ROOT/kennel.toml"
grep -Fqx 'stability = "stable"' "$ROOT/kennel.toml"
grep -Fqx 'public_api = true' "$ROOT/kennel.toml"

echo "PASS Relay release metadata consistency"
