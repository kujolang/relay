#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WORK="/tmp/relay-budget-workspace"

rm -rf "$WORK"
mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline

export RELAY_ROOT="$ROOT"
set +e
result="$($KUJO run "$ROOT/main.kujo" -- missions run "$ROOT/examples/step-budget-mission.json" --fixture --skip-agent-smoke --json 2>&1)"
rc=$?
set -e
test "$rc" -ne 0
printf '%s' "$result" | grep -q '"class":"budget_exceeded"'
printf '%s' "$result" | grep -q '"status":"failed"'
echo "PASS relay budget smoke"
