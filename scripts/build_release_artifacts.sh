#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT="${1:-$ROOT/dist/release}"
COMMIT="${2:-HEAD}"
VERSION="$(tr -d '\r\n' < "$ROOT/VERSION")"
COMMIT="$(git -C "$ROOT" rev-parse "$COMMIT^{commit}")"

test "$COMMIT" = "$(git -C "$ROOT" rev-parse HEAD)"
test -z "$(git -C "$ROOT" status --porcelain)"
test ! -e "$OUTPUT"
mkdir -p "$OUTPUT"

archive="$OUTPUT/relay-v$VERSION.tar.gz"
git -C "$ROOT" archive --format=tar --prefix="relay-v$VERSION/" "$COMMIT" | gzip -n -9 > "$archive"
python3 "$ROOT/scripts/build_release_metadata.py" "$ROOT" "$OUTPUT" "$COMMIT" "$archive"

(
  cd "$OUTPUT"
  for artifact in "relay-v$VERSION.tar.gz" "relay-v$VERSION.sbom.spdx.json" "relay-v$VERSION.provenance.json" "relay-v$VERSION.manifest.json" "relay-v$VERSION.evidence.md"; do
    if command -v sha256sum >/dev/null 2>&1; then
      sha256sum "$artifact"
    else
      shasum -a 256 "$artifact"
    fi
  done > "relay-v$VERSION.SHA256SUMS"
)

echo "PASS built deterministic Relay release artifacts in $OUTPUT"
