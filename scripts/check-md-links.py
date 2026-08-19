#!/usr/bin/env python3
"""Verify every relative markdown link in tracked docs resolves to a real file.

Exists because the docs/ restructure broke a dozen cross-references at once;
this makes that class of breakage impossible to commit. External URLs and
pure anchors are skipped — this checks the repo's internal referencing web.
"""
import re, subprocess, sys
from pathlib import Path

root = Path(__file__).resolve().parent.parent
files = subprocess.run(["git", "ls-files", "*.md"], capture_output=True,
                       text=True, cwd=root).stdout.split()
link_re = re.compile(r'\[[^\]]*\]\(([^)\s]+)\)')
broken = []
for f in files:
    fp = root / f
    for target in link_re.findall(fp.read_text()):
        if target.startswith(("http://", "https://", "mailto:", "#")):
            continue
        path = target.split("#")[0]
        if not path:
            continue
        if not (fp.parent / path).exists():
            broken.append(f"{f}: ({target})")
print(f"  checked {len(files)} markdown files")
if broken:
    print("  BROKEN LINKS:")
    for b in broken:
        print(f"    {b}")
    sys.exit(1)
print("  all relative links resolve")
