#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
WORK="/tmp/relay-timeout-workspace"
SPEC="/tmp/relay-timeout-mission.json"
OUTPUT="/tmp/relay-timeout-mission-output.json"

rm -rf "$WORK" "$SPEC" "$OUTPUT"
trap 'rm -rf "$WORK" "$SPEC" "$OUTPUT"' EXIT
mkdir -p "$WORK/scripts"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
printf '#!/usr/bin/env bash\nsleep 30\n' > "$WORK/scripts/slow.sh"
chmod +x "$WORK/scripts/slow.sh"
touch "$WORK/README.md"
git -C "$WORK" add README.md scripts/slow.sh
git -C "$WORK" commit -qm baseline
script_sha="$(ruby -rdigest -e 'print Digest::SHA256.file(ARGV.fetch(0)).hexdigest' "$WORK/scripts/slow.sh")"

cat > "$SPEC" <<EOF
{"name":"timeout-smoke","goal":"bounded timeout","repository":"$WORK","actions":[{"type":"run_command","command":"bash scripts/slow.sh","timeout_ms":1000}],"allowed_commands":["bash"],"allowed_script_hashes":{"scripts/slow.sh":"$script_sha"},"budgets":{"max_steps":2,"max_output_bytes":1048576,"max_write_bytes":1048576}}
EOF

started_wait="$(date +%s)"
set +e
"$KUJO" run "$ROOT/main.kujo" -- missions run "$SPEC" --fixture --skip-agent-smoke --json >"$OUTPUT"
mission_status=$?
set -e
elapsed_wait=$(( $(date +%s) - started_wait ))
test "$mission_status" -ne 0
test "$elapsed_wait" -lt 12

run_id="$(jq -r '.run.run_id // .run_id' "$OUTPUT")"
test -n "$run_id" && test "$run_id" != "null"
state="$($KUJO run "$ROOT/main.kujo" -- missions inspect "$run_id" --json)"
printf '%s' "$state" | jq -e '.ok == true and .run.status == "failed" and .run.failure.class == "timeout" and (.run.action_results | any(.timed_out == true and .failure_class == "timeout" and (.exit_code | type) == "number"))' >/dev/null

if ps -axo command | grep -F "$WORK/scripts/slow.sh" | grep -v grep >/dev/null; then
  echo "timed-out command left a descendant process" >&2
  exit 1
fi

echo "PASS relay timeout smoke"
