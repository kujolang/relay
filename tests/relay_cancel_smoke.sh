#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WORK="/tmp/relay-cancel-workspace"
MISSION="/tmp/relay-cancel-mission.json"
OUTPUT="/tmp/relay-cancel-output.json"

rm -rf "$WORK" "$ROOT/.relay" "$MISSION" "$OUTPUT"
mkdir -p "$WORK/scripts"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
printf '#!/usr/bin/env bash\nsleep 30\n' > "$WORK/scripts/slow.sh"
chmod +x "$WORK/scripts/slow.sh"
touch "$WORK/README.md"
git -C "$WORK" add README.md scripts/slow.sh
git -C "$WORK" commit -qm baseline

cat > "$MISSION" <<EOF
{"name":"cancel-smoke","goal":"bounded cancellation","repository":"$WORK","actions":[{"type":"run_command","command":"bash scripts/slow.sh","timeout_ms":10000}],"allowed_commands":["bash"],"budgets":{"max_steps":2,"max_output_bytes":1048576,"max_write_bytes":1048576}}
EOF

export RELAY_ROOT="$ROOT"
"$KUJO" run "$ROOT/main.kujo" -- missions run "$MISSION" --fixture --skip-agent-smoke --json >"$OUTPUT" &
mission_pid=$!

run_dir=""
for attempt in $(seq 1 200); do
  candidates=("$ROOT"/.relay/runs/*)
  if [ -f "${candidates[0]}/state.json" ]; then run_dir="${candidates[0]}"; break; fi
  sleep 0.01
done
test -n "$run_dir"
run_id="$(basename "$run_dir")"

for attempt in $(seq 1 200); do
  if grep -q 'model_request_completed' "$run_dir/events.jsonl" 2>/dev/null; then break; fi
  sleep 0.01
done
sleep 0.1
request="$($KUJO run "$ROOT/main.kujo" -- missions cancel "$run_id" --json)"
printf '%s' "$request" | jq -e '.ok == true and .status == "cancellation_requested" and .run.status == "running"' >/dev/null
started_wait="$(date +%s)"
wait "$mission_pid" || true
elapsed_wait=$(( $(date +%s) - started_wait ))
test "$elapsed_wait" -lt 8

state="$($KUJO run "$ROOT/main.kujo" -- missions inspect "$run_id" --json)"
printf '%s' "$state" | jq -e '.ok == true and .run.status == "cancelled" and (.run.events | map(.kind) | index("run_cancelled")) != null and (.run.events | map(.kind) | index("run_completed")) == null and (.run.action_results | any(.cancelled == true and .failure_class == "cancelled"))' >/dev/null
test -f "$run_dir/cancel.request.json"

echo "PASS relay cancel smoke"
