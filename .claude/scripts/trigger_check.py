#!/usr/bin/env python3
"""The `verify` inbound guard: does this diff touch a sacred path?

Built from thegraph@50664f1133e6.

Sacred paths are where a bug costs more than a wrong number. The check is a
script over the diff, not a recollection, and it overrides judgement -- a small
diff does not reason its way out of it.

Exit codes:
  0   no sacred path touched
  10  a sacred path was touched -- verify is mandatory, and the refuting second
      lens is in budget
  1   the guard itself is broken (see below)

The value of this list is decided and has no authority to check it against. Its
*existence* does: every path here must resolve, or a rename silently empties the
guard while every copy of the list stays in perfect agreement about a file that
is gone.
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]

SACRED = [
    # trust application and privilege escalation
    "macos/Classes/SystemKeyChain.swift",
    "macos/Classes/LoginKeyChain.swift",
    # destructive delete on the replace/newer flow, and the ROOT store install
    "macos/Classes/KeyChainProtocol.swift",
    "windows/x509_cert_store_plugin.cpp",
    # the hand-synced wire contract: three copies of the same five keys
    "lib/src/x509_cert_store_method_channel.dart",
    "windows/x509_cert_store_categories.h",
    "macos/Classes/CategoryKeys.swift",
]


def changed_paths(base: str) -> list[str]:
    out = subprocess.run(
        ["git", "diff", "--name-only", base],
        cwd=REPO,
        capture_output=True,
        text=True,
    )
    if out.returncode != 0:
        sys.exit(f"FAIL: git diff against {base!r} failed:\n{out.stderr.strip()}")
    return [line.strip().replace("\\", "/") for line in out.stdout.splitlines() if line.strip()]


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("base", nargs="?", default="HEAD", help="diff base (default: HEAD)")
    args = ap.parse_args()

    missing = [p for p in SACRED if not (REPO / p).is_file()]
    if missing:
        print("FAIL: the guard is broken -- these sacred paths do not resolve, so")
        print("the guard would pass silently on every change to whatever replaced them:")
        for p in missing:
            print(f"  - {p}")
        return 1

    touched = sorted(set(changed_paths(args.base)) & set(SACRED))
    if touched:
        print("TRIGGER FIRED -- verify is mandatory and the refuting lens is in budget.")
        print("Sacred paths in this diff:")
        for p in touched:
            print(f"  - {p}")
        return 10

    print("no sacred path touched; the guard falls back to enumeration risk (AI)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
