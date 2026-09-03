#!/usr/bin/env python3
"""The tree rule, matched against a diff -- and against what actually ships.

Built from thegraph@50664f1133e6.

A file written to the wrong directory breaks a seam while producing no error, no
failing test and no warning. This is the only check that can see that.

Exit codes:
  0  every changed path is owned, and no unowned root document would ship
  1  a violation (see the report)
"""

from __future__ import annotations

import argparse
import fnmatch
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]

# Concrete paths. A rule stated as a layer cannot be matched against a diff.
TREE_RULE: list[tuple[str, str]] = [
    ("lib/x509_cert_store.dart", "the only public barrel -- export directives only"),
    ("lib/src/*.dart", "Dart implementation; not imported by consumers directly"),
    ("test/*.dart", "Dart unit tests for lib/"),
    ("windows/*.cpp", "Windows native implementation and the C-API shim"),
    ("windows/*.h", "Windows native implementation and the C-API shim"),
    ("windows/include/x509_cert_store/*.h", "the Windows public header"),
    ("windows/test/*.cpp", "Windows native unit tests (gtest)"),
    ("windows/CMakeLists.txt", "the Windows build and test target"),
    ("windows/.gitignore", "build artefacts"),
    ("macos/Classes/*.swift", "macOS native implementation"),
    ("macos/Resources/*", "macOS bundle resources"),
    ("macos/x509_cert_store.podspec", "the macOS package manifest"),
    ("example/**", "the host application, its native harnesses and its tests"),
    ("docs/adr/*.md", "decision records"),
    ("docs/agents/*.md", "agent skill bindings"),
    (".claude/agents/*.md", "generated agents"),
    (".claude/scripts/*.py", "generated scripts"),
    (".github/**", "CI configuration"),
    (".vscode/**", "editor configuration"),
    ("README.md", "consumer-facing, published"),
    ("CHANGELOG.md", "consumer-facing, published"),
    ("MIGRATION.md", "consumer-facing, published"),
    ("LICENSE", "consumer-facing, published"),
    ("CLAUDE.md", "agent-facing, at root by declaration, excluded from the package"),
    ("CONTEXT.md", "agent-facing, at root by declaration, excluded from the package"),
    ("pubspec.yaml", "the package manifest"),
    ("pubspec.lock", "the resolved manifest"),
    ("analysis_options.yaml", "lint configuration"),
    (".gitignore", "version control configuration"),
    (".gitattributes", "version control configuration"),
    (".pubignore", "publish exclusions"),
    (".metadata", "Flutter tooling"),
]

# The four documents that are consumer-facing by rule. Any other *.md at the
# repo root has no owner: it is scratch, and it must be excluded from the
# package. This is war story W5 -- todo.md shipped to pub.dev in 2.0.2 carrying
# a note about an unfixed bug, and no gate noticed.
CONSUMER_ROOT_DOCS = {"README.md", "CHANGELOG.md", "MIGRATION.md"}
ROOT_DOCS_EXCLUDED_BY_DECLARATION = {"CLAUDE.md", "CONTEXT.md"}


def matches(path: str) -> str | None:
    for pattern, owner in TREE_RULE:
        if fnmatch.fnmatch(path, pattern):
            return owner
        # ** should span directory separators; fnmatch does not do that on its own.
        if pattern.endswith("/**") and path.startswith(pattern[:-2]):
            return owner
    return None


def changed_paths(base: str) -> list[str]:
    out = subprocess.run(
        ["git", "diff", "--name-only", base], cwd=REPO, capture_output=True, text=True
    )
    if out.returncode != 0:
        sys.exit(f"FAIL: git diff against {base!r} failed:\n{out.stderr.strip()}")
    return [line.strip().replace("\\", "/") for line in out.stdout.splitlines() if line.strip()]


def pubignore_entries() -> set[str]:
    f = REPO / ".pubignore"
    if not f.is_file():
        return set()
    return {
        line.strip()
        for line in f.read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    }


def check_root_docs() -> list[str]:
    """Every root *.md that is neither consumer-facing nor declared must be excluded."""
    excluded = pubignore_entries()
    problems = []
    for md in sorted(REPO.glob("*.md")):
        name = md.name
        if name in CONSUMER_ROOT_DOCS or name in ROOT_DOCS_EXCLUDED_BY_DECLARATION:
            continue
        if name not in excluded:
            problems.append(
                f"{name} has no owner in the tree rule and is not in .pubignore, "
                f"so it ships to pub.dev consumers"
            )
    return problems


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("base", nargs="?", default="HEAD", help="diff base (default: HEAD)")
    args = ap.parse_args()

    failures = []

    unowned = [p for p in changed_paths(args.base) if matches(p) is None]
    for p in unowned:
        failures.append(f"changed path matches no rule in the tree: {p}")

    failures.extend(check_root_docs())

    if failures:
        print("FAIL -- tree rule violations:")
        for f in failures:
            print(f"  - {f}")
        print(
            "\nA path with no owner is a decision nobody made. Either it belongs to an\n"
            "existing rule, or the rule needs a new row -- which is a change to\n"
            "docs/agents/thegraph.md, not a silent addition here."
        )
        return 1

    print("tree rule: every changed path is owned, and no unowned root document ships")
    return 0


if __name__ == "__main__":
    sys.exit(main())
