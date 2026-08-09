#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKCELL_ROOT="${WORKCELL_ROOT:-$ROOT/../workcell}"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
OUTPUT="${1:-}"
HOST_TMP="${WORKCELL_HOST_TMP:-$ROOT/../.workcell-host-tmp}"

test -n "$OUTPUT" && test ! -e "$OUTPUT"
test -x "$KUJO"
test -x "$WORKCELL_ROOT/bin/workcell"
test -z "$(git -C "$ROOT" status --porcelain)"
test "$(git -C "$WORKCELL_ROOT" rev-parse HEAD)" = "$(jq -r '.dependencies.workcell.revision' "$ROOT/release/dependencies.json")"
test "$(git -C "$ROOT" rev-parse HEAD)" = "${RELAY_EXPECTED_COMMIT:-$(git -C "$ROOT" rev-parse HEAD)}"
mkdir -p "$OUTPUT"
mkdir -p "$HOST_TMP"
HOST_TMP="$(cd "$HOST_TMP" && pwd -P)"

if ! docker image inspect kujolang/workcell-base:local >/dev/null 2>&1; then
  docker build --tag kujolang/workcell-base:local "$WORKCELL_ROOT/docker"
fi

before_success="$(find "$ROOT/.workcell/runs" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | sort || true)"
TMPDIR="$HOST_TMP" KUJO="$KUJO" "$WORKCELL_ROOT/bin/workcell" run --file "$ROOT/docs/workcell-launch-gate.json" --repo "$ROOT" --no-pull > "$OUTPUT/success-run.txt"
success_dir="$(comm -13 <(printf '%s\n' "$before_success" | sed '/^$/d') <(find "$ROOT/.workcell/runs" -mindepth 1 -maxdepth 1 -type d -print | sort) | tail -1)"
test -n "$success_dir"
KUJO="$KUJO" "$WORKCELL_ROOT/bin/workcell" verify --run "$success_dir" --json > "$OUTPUT/success-verify.json"
jq -e '.ok == true' "$OUTPUT/success-verify.json" >/dev/null

before_failure="$(find "$ROOT/.workcell/runs" -mindepth 1 -maxdepth 1 -type d -print | sort)"
set +e
TMPDIR="$HOST_TMP" KUJO="$KUJO" "$WORKCELL_ROOT/bin/workcell" run --file "$ROOT/docs/workcell-failure-gate.json" --repo "$ROOT" --no-pull > "$OUTPUT/failure-run.txt" 2>&1
failure_status=$?
set -e
test "$failure_status" -eq 7
failure_dir="$(comm -13 <(printf '%s\n' "$before_failure") <(find "$ROOT/.workcell/runs" -mindepth 1 -maxdepth 1 -type d -print | sort) | tail -1)"
test -n "$failure_dir"
KUJO="$KUJO" "$WORKCELL_ROOT/bin/workcell" verify --run "$failure_dir" --json > "$OUTPUT/failure-verify.json"
jq -e '.ok == true' "$OUTPUT/failure-verify.json" >/dev/null

jq -n \
  --arg format relay-workcell-proof-v1 \
  --arg relay_commit "$(git -C "$ROOT" rev-parse HEAD)" \
  --arg kujo_revision "$(cat "$ROOT/RUNTIME_VERSION")" \
  --arg workcell_revision "$(git -C "$WORKCELL_ROOT" rev-parse HEAD)" \
  --arg workcell_version "$(KUJO="$KUJO" "$WORKCELL_ROOT/bin/workcell" --version)" \
  --arg success_run_id "$(basename "$success_dir")" \
  --arg failure_run_id "$(basename "$failure_dir")" \
  --argjson failure_exit "$failure_status" \
  --slurpfile success_receipt "$success_dir/receipt.json" \
  --slurpfile failure_receipt "$failure_dir/receipt.json" \
  '{format:$format,relay_commit:$relay_commit,kujo_revision:$kujo_revision,workcell_revision:$workcell_revision,workcell_version:$workcell_version,success:{run_id:$success_run_id,verified:true,receipt:$success_receipt[0]},intentional_failure:{run_id:$failure_run_id,workload_exit:17,workcell_exit:$failure_exit,verified:true,receipt:$failure_receipt[0]}}' > "$OUTPUT/proof.json"

echo "PASS Relay Workcell success/failure proof: $OUTPUT/proof.json"
