# Approval-gated live provider verification

This procedure is a release gate for an external provider path. Local fixture and Watchdog/stub tests do not satisfy it. Run it only when the release owner has explicitly approved use of already configured credentials.

## Preconditions

1. Check out the exact Relay candidate commit with a clean working tree.
2. Verify the Relay commit and every dependency revision against [`release/dependencies.json`](../release/dependencies.json).
3. Configure a real Watchdog instance and an approved OpenAI-compatible provider/model. Set `RELAY_OFFLINE_FIXTURE=false`, `RELAY_WATCHDOG_URL`, `RELAY_WATCHDOG_API_URL`, `RELAY_WATCHDOG_VERIFY=true`, required Watchdog tokens, `RELAY_API_KEY_ENV`, and the named provider credential.
   Set `RELAY_WATCHDOG_DEPLOYED_REVISION` to the independently verified deployed Watchdog Git revision; the script requires the pinned candidate value.
4. Use an isolated disposable Git repository and a bounded provider-tool mission derived from [`provider-tools-mission.json`](../examples/provider-tools-mission.json). Keep writes, tools, calls, turns, tokens, output, and timeouts at or below the committed limits.
5. Choose a new safe `RELAY_CORRELATION_ID`. Do not place credentials in arguments, mission files, logs, receipts, or committed evidence.

## Execution

Run the guarded script, which refuses fixture mode, missing verification, missing Watchdog configuration, a dirty or mismatched commit, or an unapproved invocation:

```bash
export RELAY_LIVE_PROVIDER_APPROVED=true
export RELAY_EXPECTED_COMMIT=<candidate-commit>
export RELAY_LIVE_MODEL=<approved-model-id>
export RELAY_LIVE_PROVIDER=openai-compatible
export RELAY_LIVE_MISSION=/absolute/path/to/bounded-live-mission.json
bash scripts/live_provider_verification.sh /absolute/path/to/evidence-output
```

The script performs one bounded chat request and one provider-generated tool mission. It requires Watchdog correlation and usage reconciliation, verifies the persisted tool-result bundle, run evidence, and complete export, scans the captured evidence for configured secret values, and records product/dependency/provider/model identifiers without credential values.

## Required review

The release owner must verify:

- both calls used `watchdog_proxy` and no direct route was observed;
- Watchdog request IDs and the safe correlation ID match Relay evidence;
- usage reconciliation is available and matched for the bounded chat and tool mission;
- provider-generated tool results are present, sealed, and required by run state;
- `runs verify` and complete `runs export` pass;
- logs, receipts, tool results, reports, and the release proof contain no credential or private-key material;
- provider/model IDs, exact revisions, timestamps, exit codes, and the candidate commit are present;
- the proof does not claim compatibility with other providers or models.

If approval, credentials, Watchdog API visibility, usage fields, or an external provider are unavailable, record `blocked` in the launch checklist and release manifest. Never substitute fixture or stub evidence.
