# Controlled store performance — 2026-09-22

All six Linux profiles passed their unchanged latency budgets, quiet-host checks
and warm-cache tamper checks. Each command has five cold and five warm samples.
These results characterize this candidate on dedicated GitHub-hosted Linux
runners; they are not a speedup comparison with the earlier contended macOS run.

Source: `ddf690f740ce9647e1be5a062935c3f0e38f03af` · Kujo `9b77dce`.
[Workflow run](https://github.com/kujolang/relay/actions/runs/35757360380).
Raw receipts below retain runtime/generator hashes, runner context, dataset sizes,
all timings, RSS samples, idle observations and tamper/restore results.

## p95 latency (milliseconds)

Nearest-rank p95 is the maximum of five samples. Cold removes only the disposable
persisted index caches; warm primes the selected backend. OS page caches are not
flushed. JSON and SQLite used separate runners, so small differences are not
controlled causal comparisons of backend implementations.

| Backend | Profile | Cache | List | Verify | Watch | Export |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| json | small | cold | 148 | 282 | 276 | 283 |
| json | small | warm | 98 | 231 | 226 | 232 |
| json | medium | cold | 941 | 2155 | 2165 | 2148 |
| json | medium | warm | 602 | 1811 | 1829 | 1801 |
| json | large | cold | 4438 | 7838 | 8116 | 7932 |
| json | large | warm | 2854 | 6268 | 6447 | 6291 |
| sqlite | small | cold | 199 | 348 | 340 | 347 |
| sqlite | small | warm | 147 | 295 | 287 | 292 |
| sqlite | medium | cold | 1309 | 2721 | 2709 | 2699 |
| sqlite | medium | warm | 957 | 2361 | 2373 | 2345 |
| sqlite | large | cold | 6379 | 10471 | 10555 | 10428 |
| sqlite | large | warm | 4618 | 8688 | 8820 | 8610 |

All values are below the committed profile limits plus the existing 20% allowance.
No budgets were changed. The earlier shared-host macOS breaches remain historical
evidence of that environment, not an inferred regression or improvement here.

## Maximum observed peak RSS (MiB)

Per-invocation child high-water RSS, not the sum of process-tree memory.

| Backend | Profile | Cache | List | Verify | Watch | Export |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| json | small | cold | 29.1 | 29.3 | 29.2 | 29.3 |
| json | small | warm | 28.4 | 28.7 | 28.8 | 29.0 |
| json | medium | cold | 29.8 | 34.9 | 32.2 | 36.3 |
| json | medium | warm | 28.8 | 34.4 | 31.5 | 35.9 |
| json | large | cold | 41.1 | 55.4 | 47.8 | 62.2 |
| json | large | warm | 38.0 | 54.9 | 47.5 | 61.7 |
| sqlite | small | cold | 30.8 | 31.0 | 31.1 | 31.0 |
| sqlite | small | warm | 30.2 | 30.5 | 30.6 | 30.6 |
| sqlite | medium | cold | 31.4 | 37.0 | 34.0 | 38.1 |
| sqlite | medium | warm | 30.4 | 36.5 | 33.3 | 37.8 |
| sqlite | large | cold | 42.7 | 57.6 | 49.8 | 64.2 |
| sqlite | large | warm | 40.0 | 56.7 | 49.1 | 63.8 |

## Scan cost and invalidation decision

Median warm index-load time versus the subsequent aggregate-state scan:

| Backend | Profile | Index load (ms) | Aggregate scan (ms) |
| --- | --- | ---: | ---: |
| json | small | 59 | 65 |
| json | medium | 560 | 613 |
| json | large | 2682 | 3007 |
| sqlite | small | 99 | 70 |
| sqlite | medium | 901 | 692 |
| sqlite | large | 4400 | 3467 |

`load_run_index_result` validates authoritative states on a cache hit;
`aggregate_metrics` then reads and validates them again. The phase measurements
make this duplicate scan visible. Current representative commands have substantial
budget headroom, so this review retains full authoritative validation. A future
metrics-specific optimization should combine accumulation with the validated scan,
rather than trust only modification times or cache metadata. Such a change needs
separate concurrency and tamper evidence; it is not implemented or claimed here.

All samples observed at least 90% Linux CPU idle over 250 ms immediately before
measurement. That criterion and dedicated runners reduce contention uncertainty;
they cannot rule out all hypervisor scheduling noise.

## Raw receipts

- [json / small](review-evidence/2026-09-22/controlled-profiles/json-small.json)
- [json / medium](review-evidence/2026-09-22/controlled-profiles/json-medium.json)
- [json / large](review-evidence/2026-09-22/controlled-profiles/json-large.json)
- [sqlite / small](review-evidence/2026-09-22/controlled-profiles/sqlite-small.json)
- [sqlite / medium](review-evidence/2026-09-22/controlled-profiles/sqlite-medium.json)
- [sqlite / large](review-evidence/2026-09-22/controlled-profiles/sqlite-large.json)
