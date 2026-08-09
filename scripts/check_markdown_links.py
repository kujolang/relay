#!/usr/bin/env python3
import re
import sys
from pathlib import Path
from urllib.parse import unquote


LINK = re.compile(r"!?\[[^\]]*\]\(([^)]+)\)")


def main():
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    failures = []
    checked = 0
    for document in sorted(root.rglob("*.md")):
        if any(part in {".git", ".relay", ".workcell", "dist", "kennel_packages"} for part in document.parts):
            continue
        text = document.read_text(encoding="utf-8")
        for match in LINK.finditer(text):
            raw = match.group(1).strip()
            if raw.startswith("<") and raw.endswith(">"):
                raw = raw[1:-1]
            target = raw.split()[0].split("#", 1)[0]
            if not target or target.startswith(("http://", "https://", "mailto:", "data:")):
                continue
            checked += 1
            candidate = (document.parent / unquote(target)).resolve()
            try:
                candidate.relative_to(root)
            except ValueError:
                failures.append(f"{document.relative_to(root)}: link escapes repository: {raw}")
                continue
            if not candidate.exists():
                failures.append(f"{document.relative_to(root)}: missing local target: {raw}")
    if failures:
        for failure in failures:
            print(f"FAIL {failure}", file=sys.stderr)
        return 1
    print(f"PASS Markdown local links ({checked} checked)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
