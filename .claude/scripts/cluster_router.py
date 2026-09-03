#!/usr/bin/env python3
"""Search the tracker by the artifact a change touches, before filing anything.

Built from thegraph@50664f1133e6.

Search by the artifact -- the module, the wire field, the predicate, the config
key -- never by the feature name, because a related issue almost never shares
the same vocabulary.

The areas already carrying a decision record are read from the record *files*
in docs/adr/, never from an index. This repo has no index, and a roster
compiled from one drifts.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
ADR_DIR = REPO / "docs" / "adr"


def records() -> list[tuple[str, str, str]]:
    """(number, status, title) read from each record file."""
    out = []
    for f in sorted(ADR_DIR.glob("*.md")):
        text = f.read_text(encoding="utf-8")
        m = re.search(r"^status:\s*(\S+)", text, re.MULTILINE)
        status = m.group(1) if m else "unknown"
        t = re.search(r"^#\s+(.+)$", text, re.MULTILINE)
        title = t.group(1).strip() if t else f.stem
        number = f.name.split("-", 1)[0]
        out.append((number, status, title))
    return out


def search(term: str) -> list[dict]:
    proc = subprocess.run(
        [
            "gh", "issue", "list",
            "--state", "all",
            "--search", term,
            "--limit", "30",
            "--json", "number,title,state,labels",
        ],
        cwd=REPO,
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        sys.exit(f"FAIL: gh issue list failed:\n{proc.stderr.strip()}")
    return json.loads(proc.stdout or "[]")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "artifacts",
        nargs="+",
        help="the artifacts this change touches: a module, a wire field, a symbol",
    )
    args = ap.parse_args()

    print("Areas already carrying a decision record")
    print("(read from docs/adr/*.md, the files themselves)")
    for number, status, title in records():
        print(f"  {number}  [{status}]  {title}")
    if not records():
        print("  (none)")

    for term in args.artifacts:
        print(f"\n--- tracker, searched by artifact: {term!r}")
        hits = search(term)
        if not hits:
            print("  no hit -- this artifact may genuinely be new")
            continue
        for h in hits:
            labels = ",".join(lbl["name"] for lbl in h.get("labels", []))
            print(f"  #{h['number']}  [{h['state']}]  {h['title']}"
                  + (f"  ({labels})" if labels else ""))

    print(
        "\nFour outs: it already exists and gets a comment; it conflicts and both\n"
        "links are made at once; it shares a root and becomes part of a cluster;\n"
        "or it is genuinely new."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
