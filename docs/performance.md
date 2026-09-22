# Performance budgets

Relay treats performance as a tested contract, not an unqualified claim. The
committed [budget file](../benchmarks/budgets.json) defines representative
small, medium, and large profiles, five-sample p95 limits, and the
20 percent regression threshold. p95 uses the nearest-rank definition
(`ceil(0.95 * samples)`); for five samples this is the maximum. CI collects
five samples per representative profile. Platform results must name the exact commit
and remain separated; one machine is not evidence for another.

Run a local sample against a completed, verified run:

```bash
export RELAY_BENCHMARK_RUN_ID=relay-...
bash scripts/benchmark_run_store.sh /tmp/relay-benchmark.json
```

The harness measures `runs list`, `runs verify`, completed-run `runs watch`,
and `runs export`, and records run artifact sizes. The representative harness
fails when a p95 exceeds its profile budget plus the declared regression
allowance; optimization is warranted only after a
repeatable budget breach.

Run all representative profiles (10/100/500 indexed runs, 25/250/750 events
on the verified target, and 64 KiB/1 MiB/7 MB target artifacts):

```bash
bash scripts/benchmark_profiles.sh /tmp/relay-representative-benchmarks
```

Each platform CI job retains the generated suite as exact-commit evidence.

The committed [macOS x86_64 small-profile result](../benchmarks/macos-x86_64-small.json)
passes all four budgets. Linux and macOS arm64 results remain platform-specific
CI evidence and must not be inferred from that local sample.

The [2026-09-22 review comparison](review-evidence/2026-09-22/performance-comparison.json)
retains five fresh small-profile samples for baseline and candidate. Both
exceeded three budgets on a busy shared host. Medium/large measurements were
not completed in that experiment. These results require controlled retesting;
the historical passing result above does not establish current readiness.

## Cold/warm cache and memory profiling

Use the disposable profiler for both backend variants and all three profiles:

```bash
KUJO_BIN=/path/to/pinned/kujo python3 scripts/profile_run_store.py \
  --profile small --backend json --iterations 5 --require-quiet \
  --output /tmp/relay-small-json-profile.json
```

Repeat with `medium`/`large` and `sqlite`. The
[controlled profiling workflow](../.github/workflows/profile.yml) runs that matrix
on dedicated Linux jobs, retains unsuccessful measurements too and leaves the
committed budgets unchanged. Every sample must observe at least 90% aggregate
CPU idle over 250 ms immediately beforehand; it waits up to 30 seconds and fails
qualification if the host stays busy. Runner identity and raw idle observations
remain in the receipt. This documents a measurable quiet-host criterion, not
proof that a virtual machine has no host-level scheduling noise.

Cold means the disposable fixture's persisted JSON/SQLite caches are absent;
warm means the selected backend was primed. OS page caches are not flushed.
Every invocation runs in a fresh measurement worker, recording elapsed time and
`RUSAGE_CHILDREN` peak RSS normalized to bytes (macOS bytes; Linux KiB converted).
This is the largest child RSS high-water mark, not a sum of simultaneous process
memory. The profiler also records index-load and aggregate-state-scan phases and
requires cold `rebuild` / warm backend results. JSON/backend copies never replace
or skip authoritative validation.

After measurements, an authoritative state is altered without updating its
integrity seal while the index is warm. Listing must flag invalid integrity and
verification must fail; restoring the original bytes must restore acceptance.
No result qualifies as complete without that check. Non-quiet local smoke runs
can omit `--require-quiet`; their `quiet_verified: false` receipt is tooling
validation, not performance certification. Fewer than five samples likewise do
not satisfy the representative release requirement.

## Controlled candidate measurements

The [2026-09-22 report](controlled-store-performance.md) retains five-sample
cold/warm latency, peak child RSS, scan costs and tamper checks for both backends
at all three sizes. All six dedicated Linux profiles passed unchanged budgets.
