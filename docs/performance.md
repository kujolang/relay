# Performance budgets

Relay treats performance as a tested contract, not an unqualified claim. The
committed [budget file](../benchmarks/budgets.json) defines representative
small, medium, and maximum-local profiles, five-sample p95 limits, and the
20 percent regression threshold. Platform results must name the exact commit
and remain separated; one machine is not evidence for another.

Run a local sample against a completed, verified run:

```bash
export RELAY_BENCHMARK_RUN_ID=relay-...
bash scripts/benchmark_run_store.sh /tmp/relay-benchmark.json
```

The harness measures `runs list`, `runs verify`, completed-run `runs watch`,
and `runs export`, and records run artifact sizes. CI may compare its p95
values to `benchmarks/budgets.json`; optimization is warranted only after a
repeatable budget breach.

The committed [macOS x86_64 small-profile result](../benchmarks/macos-x86_64-small.json)
passes all four budgets. Linux and macOS arm64 results remain platform-specific
CI evidence and must not be inferred from that local sample.
