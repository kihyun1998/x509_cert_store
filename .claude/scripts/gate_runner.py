#!/usr/bin/env python3
"""Run every gate, each one bare.

Built from thegraph@50664f1133e6.

The authoritative source for the command list is .github/workflows/ci.yml.
This script does not restate it; it reads it. Every command is invoked bare --
never piped -- because a pipeline's exit status is the last command's, so a
check whose result is filtered through another command always succeeds.
"""

from __future__ import annotations

import argparse
import platform
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
CI = REPO / ".github" / "workflows" / "ci.yml"

# Local-only checks that are not in ci.yml. Each is invoked bare like any other.
LOCAL_CHECKS = [
    ("slot authority", [sys.executable, ".claude/scripts/slot_authority_check.py"], "."),
    ("agent grants", [sys.executable, ".claude/scripts/agent_grant_check.py"], "."),
]

RUNNER_TO_HOST = {
    "ubuntu-latest": "Linux",
    "windows-latest": "Windows",
    "macos-latest": "Darwin",
}


def load_ci():
    try:
        import yaml  # noqa: PLC0415
    except ImportError:
        sys.exit(
            "FAIL: PyYAML is not installed, so the gate list cannot be read from\n"
            f"  {CI}\n"
            "A gate that cannot read its own command list is not a gate. Install it\n"
            "with `python -m pip install pyyaml` rather than skipping this check."
        )
    if not CI.is_file():
        sys.exit(f"FAIL: the authoritative gate list is missing: {CI}")
    with CI.open(encoding="utf-8") as fh:
        return yaml.safe_load(fh)


def commands_from(ci):
    """Yield (job_name, runs_on, step_name, command, working_directory)."""
    for job_name, job in (ci.get("jobs") or {}).items():
        runs_on = job.get("runs-on", "")
        job_wd = job.get("defaults", {}).get("run", {}).get("working-directory", ".")
        for step in job.get("steps") or []:
            run = step.get("run")
            if not run:
                continue
            wd = step.get("working-directory", job_wd)
            name = step.get("name") or run.strip().splitlines()[0]
            yield job_name, runs_on, name, run, wd


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--all-hosts",
        action="store_true",
        help="attempt every job regardless of runs-on (they will mostly fail here)",
    )
    args = ap.parse_args()

    ci = load_ci()
    host = platform.system()

    failed: list[str] = []
    skipped: list[str] = []
    ran = 0

    for job, runs_on, name, run, wd in commands_from(ci):
        want = RUNNER_TO_HOST.get(runs_on)
        if not args.all_hosts and want and want != host:
            skipped.append(f"{job} / {name}  (needs {runs_on}, host is {host})")
            continue

        cwd = (REPO / wd).resolve()
        print(f"\n=== {job} / {name}\n--- cwd: {cwd}\n--- run: {run.strip()}")
        # shell=True is required because ci.yml steps are shell snippets, but the
        # command is never wrapped in a pipeline by this runner: whatever ci.yml
        # says is what runs, and its exit status is what is recorded.
        proc = subprocess.run(run, cwd=cwd, shell=True)
        ran += 1
        if proc.returncode != 0:
            failed.append(f"{job} / {name}  (exit {proc.returncode})")

    for label, cmd, wd in LOCAL_CHECKS:
        cwd = (REPO / wd).resolve()
        print(f"\n=== local / {label}\n--- cwd: {cwd}\n--- run: {' '.join(cmd)}")
        proc = subprocess.run(cmd, cwd=cwd)
        ran += 1
        if proc.returncode != 0:
            failed.append(f"local / {label}  (exit {proc.returncode})")

    print("\n" + "=" * 60)
    print(f"ran: {ran}")
    if skipped:
        print("\nSKIPPED -- these gates were not run and are therefore unknown,\n"
              "not green:")
        for s in skipped:
            print(f"  - {s}")
    if failed:
        print("\nFAILED:")
        for f in failed:
            print(f"  - {f}")
        return 1
    print("\nall attempted gates passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
