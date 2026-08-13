#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
TMP_BASE="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
TMP_ROOT="$(mktemp -d "$TMP_BASE/relay-enterprise.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT
export RELAY_ROOT="$ROOT"
export RELAY_STATE_ROOT="$TMP_ROOT/state"

spec="$($KUJO run "$ROOT/main.kujo" -- contracts negotiate "$ROOT/tests/fixtures/contracts/spec-v1.json" --json)"
jq -e '.ok and .compatible and .contract_version == "relay-spec-import-v1"' <<<"$spec" >/dev/null
dispatch="$($KUJO run "$ROOT/main.kujo" -- contracts negotiate "$ROOT/tests/fixtures/contracts/dispatch-v1.json" --json)"
jq -e '.ok and .compatible and .contract_version == "relay-dispatch-import-v1"' <<<"$dispatch" >/dev/null
set +e
unsupported="$($KUJO run "$ROOT/main.kujo" -- contracts negotiate "$ROOT/tests/fixtures/contracts/spec-unsupported.json" --json 2>&1)"
unsupported_rc=$?
set -e
test "$unsupported_rc" -ne 0
jq -e '.ok == false and .compatible == false' <<<"$unsupported" >/dev/null

status="$($KUJO run "$ROOT/main.kujo" -- machine status --json)"
jq -e '.ok and .enabled == false and .default == "disabled"' <<<"$status" >/dev/null
request='{"identity":"ci-reader","role":"reader","tenant":"fixture-tenant","action":"runs.read.list","approval":false}'
set +e
disabled="$(RELAY_MACHINE_REQUEST="$request" RELAY_MACHINE_REQUEST_SECRET=fixture-secret RELAY_MACHINE_ACCESS_SECRET=fixture-secret $KUJO run "$ROOT/main.kujo" -- machine authorize --json 2>&1)"
disabled_rc=$?
set -e
test "$disabled_rc" -ne 0
jq -e '.ok == false' <<<"$disabled" >/dev/null
authorized="$(RELAY_MACHINE_ACCESS_ENABLED=true RELAY_MACHINE_REQUEST="$request" RELAY_MACHINE_REQUEST_SECRET=fixture-secret RELAY_MACHINE_ACCESS_SECRET=fixture-secret $KUJO run "$ROOT/main.kujo" -- machine authorize --json)"
jq -e '.ok and .authorized and .role == "reader" and .tenant == "fixture-tenant"' <<<"$authorized" >/dev/null
jq -e '.contract_version == "relay-machine-access-v1" and .allowed == true and (.integrity_sha256 | length == 64)' "$RELAY_STATE_ROOT/machine-audit.jsonl" >/dev/null

WORK="$TMP_ROOT/work"
mkdir -p "$WORK"
git init -q "$WORK"
git -C "$WORK" config user.email relay@example.invalid
git -C "$WORK" config user.name Relay
touch "$WORK/README.md"
git -C "$WORK" add README.md
git -C "$WORK" commit -qm baseline
MISSION="$TMP_ROOT/mission.json"
jq --arg repo "$WORK" '.repository=$repo' "$ROOT/examples/fixture-mission.json" > "$MISSION"
run="$($KUJO run "$ROOT/main.kujo" -- missions run "$MISSION" --fixture --skip-agent-smoke --json)"
run_id="$(jq -r '.run.run_id' <<<"$run")"
metrics="$($KUJO run "$ROOT/main.kujo" -- runs metrics --json)"
jq -e '.ok and .format == "relay-aggregate-metrics-v1" and .run_count == 1 and .cardinality_limit == 4096 and .artifact_bytes_total > 0 and (.tool_duration_ms_total | type == "number") and (.token_total | type == "number")' <<<"$metrics" >/dev/null
signed_path="$TMP_ROOT/signed.json"
signing_keys='{"fixture-2025":"retained-old-secret","fixture-2026":"fixture-signing-secret"}'
RELAY_SIGNING_KEYS="$signing_keys" "$KUJO" run "$ROOT/main.kujo" -- runs export "$run_id" --signed --key-id fixture-2026 --output "$signed_path" --json >/dev/null
jq -e '.format == "relay-signed-export-v1" and .key_id == "fixture-2026" and (.signature | length == 64)' "$signed_path" >/dev/null
verified="$(RELAY_SIGNING_KEYS="$signing_keys" $KUJO run "$ROOT/main.kujo" -- runs verify-signature "$signed_path" --json)"
jq -e '.ok and .signature_valid and .key_id == "fixture-2026"' <<<"$verified" >/dev/null
jq '.payload.run.status="tampered"' "$signed_path" > "$TMP_ROOT/tampered.json"
set +e
tampered="$(RELAY_SIGNING_KEY=fixture-signing-secret $KUJO run "$ROOT/main.kujo" -- runs verify-signature "$TMP_ROOT/tampered.json" --json 2>&1)"
tampered_rc=$?
set -e
test "$tampered_rc" -ne 0
jq -e '.signature_valid == false' <<<"$tampered" >/dev/null

FAILED_MISSION="$TMP_ROOT/failed-mission.json"
jq --arg repo "$WORK" '.repository=$repo' "$ROOT/examples/step-budget-mission.json" > "$FAILED_MISSION"
set +e
failed_run="$($KUJO run "$ROOT/main.kujo" -- missions run "$FAILED_MISSION" --fixture --skip-agent-smoke --json 2>&1)"
failed_rc=$?
set -e
test "$failed_rc" -ne 0
failed_id="$(jq -r '.run.run_id' <<<"$failed_run")"
handoff_path="$TMP_ROOT/failure-handoff.json"
$KUJO run "$ROOT/main.kujo" -- runs handoff "$failed_id" --output "$handoff_path" --confirm --json >/dev/null
jq -e --arg id "$failed_id" '.contract_version == "relay-failure-handoff-v1" and .casefile_compatible == true and .redaction_policy == "relay-redact-v1" and .run_id == $id and (.integrity_sha256 | length == 64)' "$handoff_path" >/dev/null

echo "PASS relay enterprise contracts, machine access, metrics, and signed export smoke"
