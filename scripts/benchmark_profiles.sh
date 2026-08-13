#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
OUTPUT="${1:-}"
test -n "$OUTPUT" && test ! -e "$OUTPUT"
mkdir -p "$OUTPUT"

profiles=(small medium large)
run_counts=(10 100 500)
event_counts=(25 250 750)
artifact_sizes=(65536 1048576 7000000)

for index in 0 1 2; do
  profile="${profiles[$index]}"
  profile_root="$OUTPUT/$profile-state"
  fixture="$(jq -cn --arg root "$profile_root" --arg profile "$profile" --argjson runs "${run_counts[$index]}" --argjson events "${event_counts[$index]}" --argjson bytes "${artifact_sizes[$index]}" '{state_root:$root,profile:$profile,run_count:$runs,event_count:$events,artifact_bytes:$bytes}')"
  generated="$(RELAY_BENCHMARK_FIXTURE="$fixture" "$KUJO" run "$ROOT/scripts/benchmark_fixture.kujo" --interpreter)"
  run_id="$(jq -er '.target_run_id' <<<"$generated")"
  RELAY_ROOT="$ROOT" RELAY_STATE_ROOT="$profile_root" RELAY_BENCHMARK_RUN_ID="$run_id" RELAY_BENCHMARK_ITERATIONS="${RELAY_BENCHMARK_ITERATIONS:-5}" bash "$ROOT/scripts/benchmark_run_store.sh" "$OUTPUT/$profile.json" >/dev/null
  rm -rf "$profile_root"
done

jq -n --arg commit "$(git -C "$ROOT" rev-parse HEAD)" --slurpfile small "$OUTPUT/small.json" --slurpfile medium "$OUTPUT/medium.json" --slurpfile large "$OUTPUT/large.json" '{contract_version:"relay-representative-benchmark-suite-v1",relay_commit:$commit,profiles:{small:$small[0],medium:$medium[0],large:$large[0]}}' > "$OUTPUT/suite.json"
jq -ne --slurpfile suite "$OUTPUT/suite.json" --slurpfile budget "$ROOT/benchmarks/budgets.json" '
  all(["small", "medium", "large"][]; . as $profile |
    all(["runs_list", "runs_verify", "runs_watch_completed", "runs_export"][]; . as $command |
      $budget[0].p95_ms[$profile][$command] > 0 and
      $suite[0].profiles[$profile].commands[$command].p95_ms <= ($budget[0].p95_ms[$profile][$command] * (1 + $budget[0].regression_percent / 100))
    )
  )
' >/dev/null
echo "$OUTPUT/suite.json"
