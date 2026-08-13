#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
TMP_BASE="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
TMP_ROOT="$(mktemp -d "$TMP_BASE/relay-perf-smoke.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT
WORK="$TMP_ROOT/work"
mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline
jq --arg repo "$WORK" '.repository=$repo' "$ROOT/examples/fixture-mission.json" > "$TMP_ROOT/mission.json"
export RELAY_ROOT="$ROOT"
export RELAY_STATE_ROOT="$TMP_ROOT/state"
run="$($KUJO run "$ROOT/main.kujo" -- missions run "$TMP_ROOT/mission.json" --fixture --skip-agent-smoke --json)"
export RELAY_BENCHMARK_RUN_ID="$(jq -r '.run.run_id' <<<"$run")"
export RELAY_BENCHMARK_ITERATIONS=3
bash "$ROOT/scripts/benchmark_run_store.sh" "$TMP_ROOT/result.json" >/dev/null
jq -e --slurpfile budget "$ROOT/benchmarks/budgets.json" '
  .commands.runs_list.p95_ms <= ($budget[0].p95_ms.runs_list * (1 + $budget[0].regression_percent / 100)) and
  .commands.runs_verify.p95_ms <= ($budget[0].p95_ms.runs_verify * (1 + $budget[0].regression_percent / 100)) and
  .commands.runs_watch_completed.p95_ms <= ($budget[0].p95_ms.runs_watch_completed * (1 + $budget[0].regression_percent / 100)) and
  .commands.runs_export.p95_ms <= ($budget[0].p95_ms.runs_export * (1 + $budget[0].regression_percent / 100))
' "$TMP_ROOT/result.json" >/dev/null
echo "PASS Relay run-store performance budgets"
