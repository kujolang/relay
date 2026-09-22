# v88 execution status

Objective: complete every checkbox in the
[v88 next-session list](next-session-enhancement-backlog-2026-09-22-v88.md).
All eleven requested items are verified for the scopes recorded below.
The owner-approved pinned live chat/tool proof now passes. This completes the
engineering backlog, not publication approval or universal enterprise certification.
Historical receipts must not be promoted to the eventual final candidate.

| ID | Required outcome | Current evidence / remaining work |
| --- | --- | --- |
| G1 | Final candidate acceptance and reproducibility on Linux, macOS Intel, macOS ARM with immutable dependencies | Completed for frozen candidate `e48bc56`: all three platform jobs passed full gates, deterministic two-build artifacts, clean archive installs and representative benchmarks. Manifest pins and downloaded checksums verified. |
| G2 | Explicitly approved bounded external provider/model proof through Watchdog | Completed for `e48bc56`, pinned Kujo/Watchdog/SDK revisions and Ollama `glm-5.3-flash`. Chat plus two mission turns reconciled with Watchdog; one allowed write tool, run integrity and complete export passed. [Proof](review-evidence/2026-09-22/live-provider-candidate/proof.json). |
| G3 | Final-candidate Workcell success/failure proof, or permitted host blocker plus closest proof | Completed remotely at `e48bc56`, job `106860615852`: successful workload and intentional exit 17 both have valid receipts and complete cleanup. [Proof](review-evidence/2026-09-22/workcell-candidate/proof.json). Local host blocker retained as historical context. |
| G4 | Quiescent-host five-sample performance measurements; diagnose breaches without loosening budgets | Completed at `ddf690f`: six dedicated Linux profiles, five samples per command/cache mode, all unchanged budgets passed. See [controlled measurements](controlled-store-performance.md). |
| G5 | Operator-owned identity/role/tenant/action/approval mappings; forged claims, replay, expiry and cross-tenant tests | Implemented in `5c5a909`; operator-owned v2 policy, per-identity credentials, registered resources, exact actions, bound approval and persistent replay tests pass. Full pinned gate: 37 smokes and 28 schemas. |
| G6 | Authoritative backup/restore drill, both cache rebuilds, partial/corrupt/interrupted restoration, measured recovery objectives | Implemented in `76b5e64`; isolated drill restores with original location unavailable, rebuilds both caches and rejects partial/corrupt/interrupted publication. Measured fixture receipt retained. |
| G7 | SQLite reader/init split with missing/future schemas, locks and unsafe sidecars covered | Implemented in `ef02ab0`; pinned-runtime boundary, migration/recovery and state-store safety tests verify the change. |
| G8 | Quoted credentials, whitespace, escaped quotes and chunk-boundary redaction fixtures | Implemented in `f324e90` with `2926cdb`/`838a05e` follow-ups; real buffered chat/stream fixtures, contracts and pinned-dependency integration gate passed. See redaction evidence below. |
| G9 | Cold/warm latency and memory comparison on both index backends, small/medium/large profiles, preserved tamper detection | Completed at `ddf690f`: JSON/SQLite, all three sizes, cold/warm latency and child peak RSS, phase timings and tamper/restore checks. [Report and raw receipts](controlled-store-performance.md). |
| G10 | Streaming discovery and chunked-evidence design beyond current limits, stable cursors, mutation, cancellation and bounded acceptance | Design delivered in [streaming/evidence design](streaming-evidence-design.md): pinned-runtime prerequisite, bounded snapshot/cursor and chunk contracts, mutation/cancellation state machine and acceptance matrix. The requested deliverable is a design; implementation is explicitly future work. |
| G11 | Isolated fixture installation-to-export walkthrough, generated screenshots, Kujo learning links, clean-host validation | Implemented in `757cd96`; archive installation into fresh HOME, full fixture mission and portable signed-export verification pass with exact pinned siblings. Screenshots visually reviewed; fresh-host platform CI remains part of G1. |

## SQLite evidence

Pinned Kujo: `9b77dce592047121cb71066629836ad89252f3ce` (1.0.0).
Source: `ef02ab081764a113c1f31d8a775e000f006d5b89`.
The existing integration tests run with the pinned sibling dependency worktrees.

- `kujo check src/store_sqlite.kujo`: passed.
- `tests/relay_sqlite_boundaries_smoke.sh`: passed. Reads preserve database bytes;
  absent files are not created; missing/extra/future migrations and missing
  columns fail closed; URI path metacharacters are escaped; symlink/directory
  sidecars are rejected; exclusive locks fail within the configured wait;
  WAL readers see committed data while competing writers fail, then recover.
- `tests/relay_sqlite_store_smoke.sh`: passed migration, corrupt-cache failure,
  absent-cache reconstruction, run listing and doctor posture.
- `tests/relay_state_store_safety_smoke.sh`: passed existing state boundaries.
- Markdown links and `git diff --check`: passed.

The final full release gate will include the newly discovered smoke script.
No final-candidate platform, provider, performance or Workcell claim is made here.

## Redaction evidence

[Component receipt](review-evidence/2026-09-22/redaction-verification.json).
The full release gate passed at `f324e90` with pinned Kujo and siblings:
36 smoke scripts, contracts, 25 schemas, source/link/metadata checks, Kennel,
ShipCheck 16/16, deterministic two-build archives and clean archive installation.
Follow-up commits `2926cdb` and `838a05e` retain multiline mixed-log context and
credential-name suffix compatibility; the expanded redaction smoke and contract
suite passed again. These are component receipts, not final candidate receipts.

Fixtures cover quoted whitespace, escaped quotes, multiline/truncated values,
JSON strings and malformed JSON continuation tails, nesting bounds, idempotence,
public/private PEM handling, preserved benign structure and diagnostics, and
actual buffered chat/stream subprocess output with split content/tool arguments.

## Machine authorization and recovery evidence

The [G5 remediation report](review-evidence/2026-09-22/machine-authorization-review.md)
records the original reproduced authority bypass, new operator-owned v2 boundary,
independent review and exact pinned release-gate evidence at `5c5a909`.
The full gate passed 37 smoke scripts, 28 schemas, contracts, source/link/metadata,
Kennel, ShipCheck 16/16 and reproducible archives/clean installation.

The [G6 recovery receipt](review-evidence/2026-09-22/backup-restore-verification.json)
records 34 authoritative files / 93,039 bytes from one completed fixture run,
zero lost completed runs and observed restore times of 4,152 ms (JSON) and
3,705 ms (SQLite). The original source location was unavailable throughout
recovery. Partial/corrupt copies were rejected by both inventory and Relay
verification; interrupted staging was not published and clean retry passed.
The script hash binds the receipt to the drill committed in `76b5e64`.
These measurements are not production SLOs; see [recovery guidance](backup-restore.md).
The added `tests/relay_backup_restore_smoke.sh` passed separately at `76b5e64`
in the same pinned environment. The final candidate gate must include it.

## Walkthrough evidence

[First verified run](first-verified-run.md) contains the pinned install procedure,
copyable offline runner, generated transcript screenshots and official Kujo
learning links. [Receipt](walkthrough/receipt.json) binds the full command
[transcript](walkthrough/transcript.json) to source `757cd96`, the generator hash,
the Kujo binary hash and immutable required dependency revisions.

`tests/relay_walkthrough_smoke.sh` passed in the isolated pinned tree. The runner
extracts a committed archive into an empty HOME, uses an explicit environment
allowlist, validates agents, runs the complete fixture mission, verifies evidence,
exports under an ephemeral random fixture signing key and verifies with an absent
origin store. The fixture key is never stored. Both PNG transcript views were
rendered with an isolated Chromium profile and visually checked. Platform clean-host
runs remain in the final G1 matrix; local clean installation is not evidence for
unrun platforms.

## Candidate platform evidence

Frozen verification candidate: `e48bc56c71fdcae5b8e852419672836f00edb99f`.
[Release preparation run](https://github.com/kujolang/relay/actions/runs/35757708307)
has live-provider and publication disabled. Subsequent commits retain documentation
and receipts; they are not silently substituted for the tested candidate.

Linux and both macOS architectures completed the full release gate and five-sample representative
benchmarks. Downloaded artifact checksums passed. Their uncompressed source tar
archives are byte-identical (`e8fe4e4d0bf665480315ed116c4537accd69e0dba9fee8258b3b874bd83bf129`);
compressed bytes differ across host gzip implementations. Each platform's own
two-build reproducibility gate passed; cross-host compressed-byte identity is not
claimed. Retained [Linux verification](review-evidence/2026-09-22/platform-candidate/linux-x86_64-verification.json),
[Linux manifest](review-evidence/2026-09-22/platform-candidate/linux-x86_64-manifest.json),
[Linux benchmarks](review-evidence/2026-09-22/platform-candidate/linux-x86_64-benchmarks.json),
[ARM verification](review-evidence/2026-09-22/platform-candidate/macos-arm64-verification.json),
[ARM manifest](review-evidence/2026-09-22/platform-candidate/macos-arm64-manifest.json) and
[ARM benchmarks](review-evidence/2026-09-22/platform-candidate/macos-arm64-benchmarks.json).

Intel evidence: [verification](review-evidence/2026-09-22/platform-candidate/macos-x86_64-verification.json), [manifest](review-evidence/2026-09-22/platform-candidate/macos-x86_64-manifest.json), [benchmarks](review-evidence/2026-09-22/platform-candidate/macos-x86_64-benchmarks.json). All three source tar archives match; dependency manifests match every entry in `release/dependencies.json`. The Workcell job subsequently passed; see final candidate proof below. Run
`35756595210` was cancelled after Linux exposed a missing pinned Workcell checkout
in the walkthrough environment; `e48bc56` adds that checkout, and the corrected
Linux and ARM gates pass. Controlled profiling at `ddf690f` uses identical runtime
and profiling source to `e48bc56`; the intervening change only adds CI checkout.

## Exact-candidate Workcell fallback

Local run `wc-46ca4a78378c4bc09aa494cafe77fdb8` used candidate `e48bc56` and
pinned Kujo/Workcell revisions. It exited 4 during preparation because Docker
security-profile inspection timed out. Cleanup completed; no container execution
or verification success is claimed. The sanitized [receipt](review-evidence/2026-09-22/workcell-e48-blocker.json)
retains the original receipt SHA256. The same clean candidate passed local
`tests/relay_worktree_smoke.sh` and `tests/relay_walkthrough_smoke.sh`, covering
fixture execution, worktree integrity/cleanup, archive installation and portable
signed-export verification. This satisfies the backlog's explicit host-blocker
alternative; it does not authorize a successful container-runtime claim.

## Final candidate proof and remaining approval gate

Run `35757708307` completed the three platform gates, Workcell and candidate
artifact construction. The [Workcell proof](review-evidence/2026-09-22/workcell-candidate/proof.json)
binds both container runs to candidate `e48bc56` and immutable Kujo/Workcell pins.
The successful workload exited 0; intentional workload failure exited 17 and
Workcell returned 7. Both cleaned up and passed receipt-integrity verification
([success](review-evidence/2026-09-22/workcell-candidate/success-verify.json),
[failure](review-evidence/2026-09-22/workcell-candidate/failure-verify.json)).
A valid failure receipt does not mean the intentionally failed workload succeeded.

The combined [candidate manifest](review-evidence/2026-09-22/platform-candidate/release-manifest.json)
and [download verification](review-evidence/2026-09-22/platform-candidate/release-verification.json)
retain passed platform/Workcell status and explicitly blocked live-provider status.
All downloaded checksums, source identity and dependency pins were independently
checked. No release was published.

G2 is the sole remaining checkbox. Required owner input: an approved provider/model,
Watchdog proxy/API configuration and verified deployed revision, existing credential
environment-variable names or trusted upstream profile, and explicit approval for
one bounded chat plus the bounded provider-tool mission. Do not place secret values
in the conversation or evidence. The guarded [procedure](live-provider-verification.md)
is prepared; fixtures cannot satisfy this external-provider requirement.

## Approved live chat — partial G2 evidence

The owner approved a chat request through available Watchdog Ollama models.
Candidate `e48bc56` with pinned Kujo/AI SDK returned `relay-watchdog-live-ok`
from `glm-5.3-flash` through the existing Watchdog `default` Ollama profile.
Relay exited 0; Watchdog correlation and usage reconciled (21 input, 106 output,
127 total tokens). The [sanitized receipt](review-evidence/2026-09-22/approved-live-chat.json)
records the exact request and evidence without credentials. Two earlier requests
through the named `ollama-tud-work` profile returned HTTP 401; the configured
default profile succeeded. No provider was contacted outside Watchdog.

This establishes working live chat, not the complete G2 release gate. The existing
Watchdog checkout differs from the pinned release revision, the running process
revision was not independently established, and no provider-tool mission was run.
The earlier approval/configuration blocker description above is historical; chat
approval and a working route are now established. Remaining work is bounded
provider-tool verification against an independently verified pinned deployment.

## Final approved pinned provider/tool proof

The owner subsequently approved the bounded tool mission. The committed guarded
script passed unchanged at frozen candidate `e48bc56` using clean ordinary clones
of all pinned dependencies and a separately launched pinned Watchdog instance.
The existing shared Watchdog instance was unchanged. The isolated instance and
temporary transport helper were shut down after verification.

[Execution receipt](review-evidence/2026-09-22/live-provider-candidate/execution.json)
records runtime and entrypoint hashes, exact revisions, budgets and the zero-match
configured-secret scan. Host DNS resolution failed for the pinned HTTP client;
a temporary loopback CONNECT helper resolved only `ollama.com:443` via DNS and
forwarded encrypted bytes. TLS certificate verification remained enabled end to
end. The [helper source](review-evidence/2026-09-22/live-provider-candidate/dns-connect-helper.py)
is retained and hash-bound; this environment workaround is part of the evidence,
not a Relay runtime change or a direct-provider bypass.

[Watchdog API rows](review-evidence/2026-09-22/live-provider-candidate/watchdog-requests.json)
independently show three successful correlated requests: 719 tokens for chat,
and 1,863 total across two mission turns, within the unchanged 4,000-token budget.
The model called `relay.write_file` once, creating
[mission-plan.md](review-evidence/2026-09-22/live-provider-candidate/mission-plan.md)
in the disposable workspace. The [tool bundle](review-evidence/2026-09-22/live-provider-candidate/tool-results.json),
[run verification](review-evidence/2026-09-22/live-provider-candidate/verify.json)
and [complete export](review-evidence/2026-09-22/live-provider-candidate/export.json)
passed. [Mission definition](review-evidence/2026-09-22/live-provider-candidate/mission-definition.json)
records the allowlist and approval; [proof](review-evidence/2026-09-22/live-provider-candidate/proof.json)
binds Relay, Kujo, Watchdog and both SDK revisions. Earlier pending/blocked
snapshots above remain historical and are superseded by this result.

This proves the selected Ollama model and bounded tool path under the recorded
conditions. It does not certify other providers/models, eliminate the documented
local-first boundaries, or authorize a tag, deployment or public release.

The [completed candidate manifest](review-evidence/2026-09-22/live-provider-candidate/completed-candidate-manifest.json) records all verified gates as passed. Its rebuilt archive checksums passed, and the uncompressed tar matches the three platform artifacts. The earlier blocked manifest remains historical evidence.
