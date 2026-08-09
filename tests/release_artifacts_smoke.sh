#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
TMP_CREATED="$(mktemp -d "${TMPDIR:-/tmp}/relay-release-artifacts.XXXXXX")"
TMP_ROOT="$(cd "$TMP_CREATED" && pwd -P)"
trap 'rm -rf "$TMP_ROOT"' EXIT

test -z "$(git -C "$ROOT" status --porcelain)"
common_env=(
  RELAY_SOURCE_CHECK_RESULT=passed
  RELAY_CLI_CONTRACT_RESULT=passed
  RELAY_SCHEMA_RESULT=passed
  RELAY_MARKDOWN_RESULT=passed
  RELAY_METADATA_RESULT=passed
)
env "${common_env[@]}" "$ROOT/scripts/build_release_artifacts.sh" "$TMP_ROOT/one" HEAD
env "${common_env[@]}" "$ROOT/scripts/build_release_artifacts.sh" "$TMP_ROOT/two" HEAD
diff -rq "$TMP_ROOT/one" "$TMP_ROOT/two"

VERSION="$(cat "$ROOT/VERSION")"
(
  cd "$TMP_ROOT/one"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum -c "relay-v$VERSION.SHA256SUMS"
  else
    shasum -a 256 -c "relay-v$VERSION.SHA256SUMS"
  fi
)

mkdir "$TMP_ROOT/extract"
tar -xzf "$TMP_ROOT/one/relay-v$VERSION.tar.gz" -C "$TMP_ROOT/extract"
PACKAGE="$TMP_ROOT/extract/relay-v$VERSION"
test "$(KUJO_BIN="$KUJO" "$PACKAGE/bin/relay" --version)" = "relay 1.0.0"
RELAY_ROOT="$PACKAGE" \
RELAY_STATE_ROOT="$TMP_ROOT/state" \
KUJO_BIN="$KUJO" \
RELAY_AI_SDK_PATH="$ROOT/../ai-sdk" \
RELAY_AGENTS_SDK_PATH="$ROOT/../agents-sdk" \
KUJO_AGENTS_PATH="$ROOT/../kujo-agents" \
RELAY_PACKWRITE_BIN="$ROOT/../packwrite/bin/packwrite" \
RELAY_PACKWRITE_ROOT="$ROOT/../packwrite" \
RELAY_RUNLEDGER_BIN="$ROOT/../runledger/bin/runledger" \
RELAY_RUNLEDGER_ROOT="$ROOT/../runledger" \
RELAY_CHANGEBUCKET_BIN="$ROOT/../changebucket/bin/changebucket" \
RELAY_CHANGEBUCKET_ROOT="$ROOT/../changebucket" \
RELAY_EVAL_ENTRY="$ROOT/../eval/main.kujo" \
"$PACKAGE/bin/relay" doctor --json | jq -e '.ok == true and .mode == "fixture"' >/dev/null
RELAY_ROOT="$PACKAGE" KUJO_BIN="$KUJO" KUJO_AGENTS_PATH="$ROOT/../kujo-agents" "$PACKAGE/bin/relay" agents validate --json | jq -e '.ok == true' >/dev/null
RELAY_ROOT="$PACKAGE" KUJO_BIN="$KUJO" RELAY_AI_SDK_PATH="$ROOT/../ai-sdk" "$PACKAGE/bin/relay" chat "Summarize the mission boundary" --fixture --json | jq -e '.ok == true' >/dev/null

python3 "$ROOT/scripts/validate_json.py" "$ROOT/schemas/mission.schema.json" "$PACKAGE/examples/fixture-mission.json"
jq -e --arg version "$VERSION" --arg commit "$(git -C "$ROOT" rev-parse HEAD)" '.relay_version == $version and .git_commit == $commit and .source_archive.sha256 != "" and .contracts.mission_current == "1.0.0"' "$TMP_ROOT/one/relay-v$VERSION.manifest.json" >/dev/null

echo "PASS Relay deterministic release artifact and clean-install smoke"
