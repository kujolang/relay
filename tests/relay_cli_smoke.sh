#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"

json="$($KUJO run "$ROOT/main.kujo" -- agents validate --json)"
case "$json" in
  *'"ok":true'*) ;;
  *) echo "agents validation did not pass" >&2; exit 1 ;;
esac

chat="$($KUJO run "$ROOT/main.kujo" -- chat smoke --fixture --json)"
case "$chat" in
  *'"ok":true'*'"relay_telemetry"'*) ;;
  *) echo "fixture chat contract did not pass" >&2; exit 1 ;;
esac

set +e
invalid="$($KUJO run "$ROOT/main.kujo" -- missions run "$ROOT/examples/invalid-approval-mission.json" --fixture --json 2>&1)"
status=$?
set -e
test "$status" -ne 0
case "$invalid" in
  *"approval.approved=true"*) ;;
  *) echo "unapproved write mission was not rejected" >&2; exit 1 ;;
esac

echo "PASS relay CLI smoke"
