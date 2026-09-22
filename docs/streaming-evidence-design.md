# Streaming discovery and chunked evidence design

Status: proposed contracts, not implemented runtime capability. The existing
16 MiB discovery and 1 MiB JSON limits remain enforced. This design is the G10
follow-up specification; passing existing tests does not validate the proposed
streaming implementation.

## Tracked-file discovery v2

The current `execute_action` starts `git ls-files` for each numeric offset,
buffers the complete result, and splits on newline. Large indexes exceed the
capture envelope; intervening index changes can shift pages. Version 2 must
produce one immutable, NUL-delimited snapshot with `git ls-files -z`, then serve
bounded pages from that snapshot. No path is interpreted as a shell command.

The snapshot producer must use a bounded streaming process API, backpressure,
a deadline and cancellation. Redirecting a buffered result into a file does not
satisfy this requirement. The pinned Kujo runtime's available process API must
be established before implementation; if streaming is unavailable, add and pin
a runtime capability first. Do not silently require an unpinned helper binary.

Acquire an index snapshot without modifying the caller's index. Record the
repository identity, index digest and starting commit. Detect mutation while
capturing; discard and return `snapshot_changed` rather than publish a mixed
snapshot. Later index changes do not change existing snapshot pages. A new
request gets a new snapshot. Reading file contents remains a separate operation
with the existing workspace policy and explicit content digest.

Publish a manifest only after all pages and hashes are durable. Its ID is a
random bounded identifier under an operator-owned directory. Reject symlink
components. Bind each cursor to manifest ID, page ordinal, repository identity,
contract version and expiry with an operator-owned HMAC key. Never accept a
cursor's path, byte limit or repository as authority. Validate authentication
before opening pages; a valid cursor from another run/repository is rejected.

Each page contains at most 256 paths and 16 KiB encoded JSON. Measure serialized
UTF-8 bytes, including escaping and envelope overhead. Store paths as decoded
UTF-8 with an explicit unsupported-encoding error; no lossy replacement and no
newline splitting. A single path exceeding the page allowance fails with a
specific bounded error. Snapshot storage has explicit total-byte, path-count,
duration and concurrent-snapshot quotas, initially operator configured with
conservative defaults. Exceeding a quota fails; it never advertises completion.

Cancellation terminates the child, closes handles and removes unpublished
pages. Expired published snapshots are garbage-collected under the same lease
used by readers; an active reader cannot observe partial deletion. Retry of the
same cursor returns the same page until expiry. Unknown/expired cursors return
an explicit restart requirement, never an offset against a new snapshot.

## Chunked evidence v2

Keep v1 readers and limits unchanged. Introduce a separate versioned manifest,
not a larger `state.json`. The manifest stays below 1 MiB and contains bounded
chunk descriptors: ordinal, relative immutable object ID, byte length, record
count and SHA-256 digest. A root digest covers the canonical ordered descriptor
sequence and contract version. Large descriptor sets use a bounded tree of
manifest pages with fixed depth; no unbounded flat manifest.

Each chunk is at most 512 KiB of encoded JSONL, with records no larger than the
existing document ceiling and the selected chunk capacity. A record is never
silently split. For larger individual content, use a distinct blob contract
with encoding, exact byte length and digest, not an incomplete JSON record.
Readers stream chunks, validate exact lengths/digests/order, reject duplicates,
missing chunks, traversal and symlinks, and retain only one chunk plus bounded
metadata in memory. Cap chunk count, total bytes and nesting before traversal.

Write temporary chunks, flush them, atomically rename immutable objects, then
publish the manifest last. Interrupted publication leaves no accepted manifest.
Recovery removes abandoned temporary objects after lease expiry. Verification
must reject any missing, altered or reordered chunk, even on an index cache hit.
Signed exports authenticate the manifest root and version plus the existing
run identity. A streaming verifier must consume and hash every referenced chunk
before reporting success. Import cannot replace authoritative evidence until
all referenced bytes have passed validation in a staging directory.

## Required implementation acceptance

| Case | Required observable result |
| --- | --- |
| More than 16 MiB of tracked paths | Complete traversal without capturing the full listing in RAM; exact equality to independent NUL-delimited Git listing |
| Newlines, tabs, quotes and multibyte paths | Exact round trip, byte-bounded pages, no duplicates or omissions |
| Mutation during snapshot creation | Consistent captured snapshot or explicit `snapshot_changed`; no mixed result |
| Mutation between pages | Existing cursor retains original membership; new snapshot reflects change |
| Forged/cross-run/expired cursor | Denied before page access; no fallback to current index |
| Repeated cursor and final page | Identical result; final cursor clearly ends traversal |
| Cancellation at capture/write/publish/read | Child terminates, bounded cleanup, no accepted partial manifest |
| Disk-full, quota, oversized path/record | Explicit failure without partial success or dropped data |
| Evidence larger than 1 MiB | Bounded manifest and chunk reads; complete verified reconstruction |
| Missing/reordered/duplicate/tampered chunk | Verification fails, including warm cache paths |
| Interrupted publish/import and stale lease | Previous committed evidence intact; recovery cannot admit partial evidence |
| Memory/duration measurements | Five cold/warm samples, peak RSS and byte counts; scaling does not retain all paths or evidence bytes |
| Compatibility | Existing v1 exports, readers and limits pass unchanged; unsupported v2 fails explicitly |

Keep these acceptance cases pending until an implementation runs them on the
pinned runtime. Required evidence includes the exact candidate/dependency pins,
fixture generator seed, measured bytes/RSS/timing and cancellation receipts.
