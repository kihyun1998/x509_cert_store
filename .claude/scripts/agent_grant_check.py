#!/usr/bin/env python3
"""Assert that no generated agent holds a write-capable tool it never declared.

Built from thegraph@50664f1133e6.

Read-only is the **default**, not a claim to be matched. This check asks:

    is a write-capable tool granted, and does the brief declare that tool by name?

It deliberately does NOT ask whether the description says "read-only". That
version was written first and it is dodgeable: an agent granted a shell whose
description read "proposes edits rather than making them" passed a check looking
for the phrase "read-only" -- the same claim, different words, no violation
reported. A rule whose question can be sidestepped by rephrasing is not a rule.

A declaration that names no tool licenses nothing.

Exit codes:
  0  every agent's grant is licensed by its brief
  1  at least one grant is wider than its brief
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
AGENTS = REPO / ".claude" / "agents"

# Tools that can change state. A tool that cannot change state is read-only, and
# reaching the network is not writing: WebFetch and WebSearch are not here.
WRITE_CAPABLE = {
    "Bash",
    "BashOutput",
    "Edit",
    "Write",
    "MultiEdit",
    "NotebookEdit",
    "KillShell",
    "Task",
    "Agent",
}


def frontmatter_tools(text: str) -> list[str]:
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, re.DOTALL)
    if not m:
        return []
    t = re.search(r"^tools:\s*(.+)$", m.group(1), re.MULTILINE)
    if not t:
        return []
    raw = t.group(1).strip()
    if raw in ("*", "all"):
        return sorted(WRITE_CAPABLE)  # a wildcard grants everything, writes included
    return [x.strip() for x in raw.strip("[]").split(",") if x.strip()]


def declared_tools(text: str) -> set[str]:
    """Tools named on a `**Runs:**` line. A line naming no tool licenses nothing."""
    declared: set[str] = set()
    for line in text.splitlines():
        if "**Runs:**" not in line:
            continue
        for tool in WRITE_CAPABLE:
            if re.search(rf"`{tool}`|\b{tool}\b", line):
                declared.add(tool)
    return declared


def main() -> int:
    if not AGENTS.is_dir():
        print(f"no generated agents at {AGENTS}; nothing to check")
        return 0

    failures: list[str] = []
    checked = 0

    for f in sorted(AGENTS.glob("*.md")):
        text = f.read_text(encoding="utf-8")
        granted = frontmatter_tools(text)
        checked += 1

        writes = {t for t in granted if t in WRITE_CAPABLE}
        if not writes:
            continue

        declared = declared_tools(text)
        undeclared = writes - declared
        if undeclared:
            failures.append(
                f"{f.name}: grants {sorted(undeclared)} with no `**Runs:**` line "
                f"naming them. The default is read-only; only an explicit "
                f"declaration moves one."
            )

    if failures:
        print(f"FAIL -- {len(failures)} of {checked} agents hold an unlicensed grant:")
        for x in failures:
            print(f"  - {x}")
        print(
            "\nInvariant 1 licenses delegating these nodes on the grounds that they\n"
            "read without adjudicating. A write-capable tool in the grant makes that\n"
            "false no matter what the prose above it says."
        )
        return 1

    print(f"agent grants: {checked} agents checked, none holds an unlicensed grant")
    return 0


if __name__ == "__main__":
    sys.exit(main())
