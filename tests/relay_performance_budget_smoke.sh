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
jq -e '.contract_version == "relay-run-store-benchmark-v1" and .iterations == 3 and (.commands | keys | length) == 4 and all(.commands[]; .p95_ms >= 0)' "$TMP_ROOT/result.json" >/dev/null
jq -e '
  .contract_version == "relay-performance-budgets-v1" and
  .regression_percent >= 0 and
  (.representative_profiles | map(.name) == ["small", "medium", "large"]) and
  all(.representative_profiles[]; .runs > 0 and .events_per_target_run >= 0 and .artifact_bytes_per_target_run >= 0) and
  all(.p95_ms[]; all(.[]; type == "number" and . > 0))
' "$ROOT/benchmarks/budgets.json" >/dev/null
jq -e -s --slurpfile budget "$ROOT/benchmarks/budgets.json" '
  [ .[] as $sample
    | $sample.commands | to_entries[]
    | ($budget[0].p95_ms.small[.key] * (1 + $budget[0].regression_percent / 100)) as $limit
    | select(.value.p95_ms > $limit)
    | {platform: $sample.platform, command: .key, p95_ms: .value.p95_ms, limit_ms: $limit}
  ] as $over
  | if ($over | length) == 0 then true else error("Performance budget exceeded: " + ($over | tojson)) end
' "$TMP_ROOT/result.json" "$ROOT/benchmarks/macos-x86_64-small.json" >/dev/null
if [[ -n "${RELAY_PERFORMANCE_EVIDENCE_OUTPUT:-}" ]]; then
  test ! -e "$RELAY_PERFORMANCE_EVIDENCE_OUTPUT"
  cp "$TMP_ROOT/result.json" "$RELAY_PERFORMANCE_EVIDENCE_OUTPUT"
fi
echo "PASS Relay performance contract and committed budgets"
