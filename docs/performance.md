# Performance budgets

Relay treats performance as a tested contract, not an unqualified claim. The
committed [budget file](../benchmarks/budgets.json) defines representative
small, medium, and large profiles, five-sample p95 limits, and the
20 percent regression threshold. Platform results must name the exact commit
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
