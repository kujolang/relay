#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
before="$(shasum -a 256 "$ROOT/docs/showcase-gallery.md" | awk '{print $1}')"
python3 "$ROOT/scripts/generate_showcase_gallery.py"
after="$(shasum -a 256 "$ROOT/docs/showcase-gallery.md" | awk '{print $1}')"
test "$before" = "$after"
grep -q 'Exact-candidate release evidence' "$ROOT/docs/showcase-gallery.md"
echo "PASS Relay generated showcase gallery"
