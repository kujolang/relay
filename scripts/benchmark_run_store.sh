#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
RUN_ID="${RELAY_BENCHMARK_RUN_ID:-}"
ITERATIONS="${RELAY_BENCHMARK_ITERATIONS:-5}"
OUTPUT="${1:-$ROOT/benchmarks/latest-local.json}"
[[ -n "$RUN_ID" ]] || { echo "RELAY_BENCHMARK_RUN_ID is required" >&2; exit 2; }
[[ "$ITERATIONS" =~ ^[1-9][0-9]*$ ]] && (( ITERATIONS <= 50 )) || { echo "iterations must be 1..50" >&2; exit 2; }

measure() {
  python3 - "$@" <<'PY'
import subprocess, sys, time
started = time.perf_counter_ns()
result = subprocess.run(sys.argv[1:], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
elapsed = (time.perf_counter_ns() - started) // 1_000_000
if result.returncode:
    raise SystemExit(result.returncode)
print(elapsed)
PY
}

tmp="$(mktemp -d "${TMPDIR:-/tmp}/relay-benchmark.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT
for i in $(seq 1 "$ITERATIONS"); do
  measure "$KUJO" run "$ROOT/main.kujo" -- runs list --limit 100 --json >> "$tmp/list"
  measure "$KUJO" run "$ROOT/main.kujo" -- runs verify "$RUN_ID" --json >> "$tmp/verify"
  measure "$KUJO" run "$ROOT/main.kujo" -- runs watch "$RUN_ID" --timeout-ms 1 --poll-ms 1 --json >> "$tmp/watch"
  measure "$KUJO" run "$ROOT/main.kujo" -- runs export "$RUN_ID" --output "$tmp/export-$i.json" --json >> "$tmp/export"
done
sizes="$($KUJO run "$ROOT/main.kujo" -- runs sizes "$RUN_ID" --json)"
python3 - "$tmp" "$OUTPUT" "$RUN_ID" "$ITERATIONS" "$sizes" <<'PY'
import json, pathlib, platform, statistics, sys
tmp, output, run_id, iterations, sizes = sys.argv[1:]
def summary(name):
    values = [int(x) for x in pathlib.Path(tmp, name).read_text().split()]
    ordered = sorted(values)
    return {"samples_ms": values, "min_ms": min(values), "median_ms": statistics.median(values), "p95_ms": ordered[max(0, int(len(ordered)*.95)-1)], "max_ms": max(values)}
payload = {"contract_version":"relay-run-store-benchmark-v1","platform":f"{platform.system().lower()}-{platform.machine().lower()}","run_id":run_id,"iterations":int(iterations),"sizes":json.loads(sizes),"commands":{"runs_list":summary("list"),"runs_verify":summary("verify"),"runs_watch_completed":summary("watch"),"runs_export":summary("export")}}
pathlib.Path(output).write_text(json.dumps(payload, sort_keys=True, indent=2)+"\n")
PY
echo "$OUTPUT"
