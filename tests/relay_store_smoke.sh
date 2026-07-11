#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WORK="/tmp/relay-store-workspace"

rm -rf "$WORK" "$ROOT/.relay"
mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline

export RELAY_ROOT="$ROOT"
result="$($KUJO run "$ROOT/main.kujo" -- missions run "$ROOT/examples/fixture-mission.json" --fixture --skip-agent-smoke --json)"
printf '%s' "$result" | grep -q '"status":"completed"'
run_id="$(printf '%s' "$result" | ruby -rjson -e 'print JSON.parse(STDIN.read)["run"]["run_id"]')"
test -n "$run_id"

# A corrupt or tampered cache must not become an arbitrary filesystem read.
printf '%s' '{"attacker":{"run_dir":"/etc","status":"completed"}}' > "$ROOT/.relay/index.json"
listed="$($KUJO run "$ROOT/main.kujo" -- runs list --json)"
printf '%s' "$listed" | grep -q "\"$run_id\""
printf '%s' "$listed" | grep -q '"index_source":"validated_cache_or_rebuild"'
if printf '%s' "$listed" | grep -q 'attacker'; then
  echo "tampered index entry was trusted" >&2
  exit 1
fi

rebuilt="$($KUJO run "$ROOT/main.kujo" -- runs rebuild --json)"
printf '%s' "$rebuilt" | grep -q '"index_source":"rebuild"'
printf '%s' "$rebuilt" | grep -q "\"$run_id\""

set +e
unknown="$($KUJO run "$ROOT/main.kujo" -- runs inspect attacker --json 2>&1)"
rc=$?
set -e
test "$rc" -ne 0
printf '%s' "$unknown" | grep -q 'unknown run'

echo "PASS relay store smoke"
