#!/usr/bin/env python3
"""Assert every derived slot in the graph doc against the fact it was copied from.

Built from thegraph@50664f1133e6.

A derived slot is a copy of a fact that lives somewhere else. Being a copy, it
is never empty -- it fails by being silently wrong, and no node notices, because
a node that receives a value uses it.

Every assertion below runs in **both** directions: the doc must not claim what
the repo lacks, and the repo must not hold what the doc omits.

Exit codes:
  0  every derived slot agrees with its authority
  1  at least one slot has drifted
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
GRAPH = REPO / "docs" / "agents" / "thegraph.md"

failures: list[str] = []
checks = 0


def fail(msg: str) -> None:
    failures.append(msg)


def check(msg: str, ok: bool) -> None:
    global checks
    checks += 1
    if not ok:
        fail(msg)


def graph_text() -> str:
    if not GRAPH.is_file():
        sys.exit(f"FAIL: the graph doc is missing: {GRAPH}")
    return GRAPH.read_text(encoding="utf-8")


# --- layers: authority is pubspec.yaml -> flutter.plugin.platforms ------------
def check_layers(doc: str) -> None:
    pubspec = (REPO / "pubspec.yaml").read_text(encoding="utf-8")
    platforms = set(re.findall(r"^\s{6}(\w+):$", pubspec, re.MULTILINE))
    check(
        f"pubspec declares platforms {sorted(platforms)}; expected windows and macos",
        platforms == {"windows", "macos"},
    )
    for d in ("lib", "windows", "macos"):
        check(f"layer directory is missing: {d}/", (REPO / d).is_dir())
        check(f"the graph doc does not name the {d}/ layer", f"`{d}/`" in doc)


# --- gate: authority is ci.yml, and the doc must NOT restate a count ----------
def check_gate(doc: str) -> None:
    ci = REPO / ".github" / "workflows" / "ci.yml"
    check(f"the authoritative gate list is missing: {ci}", ci.is_file())
    check(
        "the graph doc does not name ci.yml as the gate authority",
        ".github/workflows/ci.yml" in doc,
    )
    # A count written into the doc is a copy nothing checks, in the document that
    # argues against exactly that.
    bad = re.search(
        r"\b(?:there are\s+)?\d+\s+gate commands\b|\bgate command list has \d+", doc, re.I
    )
    check(
        "the graph doc restates a gate command count; name the source instead",
        bad is None,
    )


# --- record roster: authority is the record FILES, never an index ------------
def check_records(doc: str) -> None:
    adr = REPO / "docs" / "adr"
    on_disk = {f.name.split("-", 1)[0] for f in adr.glob("*.md")}
    in_doc = set(re.findall(r"^\|\s*(\d{4})\s*\|", doc, re.MULTILINE))
    check(
        f"records on disk {sorted(on_disk)} but the doc lists {sorted(in_doc)}",
        on_disk == in_doc,
    )


# --- sacred paths and sweep surfaces: existence is assertable ----------------
SACRED = [
    "macos/Classes/SystemKeyChain.swift",
    "macos/Classes/LoginKeyChain.swift",
    "macos/Classes/KeyChainProtocol.swift",
    "windows/x509_cert_store_plugin.cpp",
    "lib/src/x509_cert_store_method_channel.dart",
    "windows/x509_cert_store_categories.h",
    "macos/Classes/CategoryKeys.swift",
]

SURFACES = [
    "README.md",
    "MIGRATION.md",
    "CHANGELOG.md",
    "CONTEXT.md",
    "docs/adr",
    "pubspec.yaml",
    "example/lib/main.dart",
]


def check_paths(doc: str) -> None:
    for p in SACRED:
        check(f"sacred path does not resolve: {p}", (REPO / p).is_file())
        check(f"the graph doc no longer lists sacred path {p}", p in doc)
    for p in SURFACES:
        check(f"sweep surface does not resolve: {p}", (REPO / p).exists())
        check(f"the graph doc no longer lists sweep surface {p}", p in doc)


# --- the trigger guard must list exactly what the doc lists ------------------
def check_guard_matches_doc() -> None:
    guard = (REPO / ".claude" / "scripts" / "trigger_check.py")
    check("the trigger check is missing", guard.is_file())
    if not guard.is_file():
        return
    text = guard.read_text(encoding="utf-8")
    for p in SACRED:
        check(f"trigger_check.py no longer guards sacred path {p}", p in text)


# --- the unassertable roster must not go quiet -------------------------------
UNASSERTABLE_MARKERS = [
    "Issue.subIssues",
    "apple-oss-distributions/Security",
    "Windows SDK header",
    "peer trees",
]


def check_unassertable(doc: str) -> None:
    """A slot must not leave the authority map by going silent.

    An unassertable slot that announces itself is a known hole. One that says
    nothing is indistinguishable from a checked one.
    """
    for marker in UNASSERTABLE_MARKERS:
        check(
            f"the graph doc no longer marks {marker!r} as unassertable",
            marker in doc,
        )
    check(
        "the graph doc no longer carries a slot authority map",
        "Slot authority map" in doc,
    )


# --- downstream: authority is pubspec.yaml -----------------------------------
def check_downstream(doc: str) -> None:
    pubspec = (REPO / "pubspec.yaml").read_text(encoding="utf-8")
    check("pubspec declares no homepage", "homepage:" in pubspec)
    check("pubspec declares no repository", "repository:" in pubspec)
    check("the graph doc does not name pub.dev as the publish target", "pub.dev" in doc)


# --- glossary and record locations: authority is CLAUDE.md / domain.md -------
def check_declarations(doc: str) -> None:
    claude = (REPO / "CLAUDE.md").read_text(encoding="utf-8")
    check("CLAUDE.md no longer declares CONTEXT.md", "CONTEXT.md" in claude)
    check("CLAUDE.md no longer declares docs/adr/", "docs/adr/" in claude)
    check("CONTEXT.md is missing", (REPO / "CONTEXT.md").is_file())
    check("the graph doc does not name CONTEXT.md as the glossary", "CONTEXT.md" in doc)


def main() -> int:
    doc = graph_text()

    check_layers(doc)
    check_gate(doc)
    check_records(doc)
    check_paths(doc)
    check_guard_matches_doc()
    check_unassertable(doc)
    check_downstream(doc)
    check_declarations(doc)

    if failures:
        print(f"FAIL -- {len(failures)} of {checks} derived-slot assertions drifted:")
        for f in failures:
            print(f"  - {f}")
        print(
            "\nA derived slot fails by being silently wrong, and a node handed a wrong\n"
            "value uses it and reports nothing. Fix the doc or the repo -- whichever\n"
            "one moved -- rather than relaxing the assertion."
        )
        return 1

    print(f"slot authority: {checks} derived-slot assertions hold, both directions")
    return 0


if __name__ == "__main__":
    sys.exit(main())
