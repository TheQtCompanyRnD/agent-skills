# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

"""Bump the qtaiskills plugin version across all metadata files.

Updates ``.claude-plugin/marketplace.json``, ``.claude-plugin/plugin.json``,
and ``gemini-extension.json`` to the supplied version on a fresh branch off
``origin/dev``, commits the bump, and optionally pushes it to Gerrit
(``refs/for/dev``). The bump always lands on ``dev`` first: that is the trunk
every release is cut from, and keeping the bump there means cherry-picks and
tags stay consistent with what was actually released.

Cutting a long-lived ``release/<version>`` branch for a maintained release
line is deliberately *not* this script's job -- that is a rarer act, reserved
for major versions, and it branches off ``dev`` at the point the bump has
landed. See ``tools/README.md`` for that manual step.

This is maintainer tooling -- see ``tools/README.md``. It is not part of the
distributed skill set and consumers of the plugin never need to run it.

Every ``"version": "X.Y.Z"`` field in the metadata files is treated as the
plugin version and rewritten to the target. This is deliberate: it keeps the
several copies in lockstep and self-heals a field that has drifted out of sync
(as ``marketplace.json``'s per-plugin version did after the manual 1.6.0 bump).
Fields whose value is not a bare ``MAJOR.MINOR.PATCH`` (e.g. ``$schema`` URLs
or version ranges) are left untouched.

Examples
--------
Bump to 1.7.0 on a fresh branch off origin/dev and push for review::

    python tools/bump-version.py 1.7.0 --reason "Release of the qt-foo skill." --push

Bump without pushing -- the commit stays local for inspection first::

    python tools/bump-version.py 1.7.0 --reason "Release of the qt-foo skill."
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path
from typing import NoReturn

# This script lives in tools/, so the repository root is its parent's parent.
# (The PowerShell predecessor assumed it sat at the root -- deriving the root
# from the script location is what makes the move to tools/ correct.)
REPO_ROOT = Path(__file__).resolve().parent.parent

# Every file that carries the plugin version, relative to the repo root.
VERSION_FILES = (
    ".claude-plugin/marketplace.json",
    ".claude-plugin/plugin.json",
    "gemini-extension.json",
)

# plugin.json is the source of truth for detecting the current version.
SOURCE_OF_TRUTH = ".claude-plugin/plugin.json"

SEMVER = re.compile(r"^\d+\.\d+\.\d+$")
# Matches a "version": "MAJOR.MINOR.PATCH" field, capturing the fixed text
# around the version literal so only the literal itself is rewritten.
VERSION_FIELD = re.compile(r'("version"\s*:\s*")\d+\.\d+\.\d+(")')


def fail(message: str) -> NoReturn:
    """Print an error and exit non-zero (mirrors PowerShell's ``throw``)."""
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(1)


def git(*args: str) -> None:
    """Run a git command at the repo root, failing loudly on non-zero exit."""
    if subprocess.run(["git", *args], cwd=REPO_ROOT).returncode != 0:
        fail(f"git {' '.join(args)} failed")


def read_text(path: Path) -> str:
    # Decode from bytes so we never translate newlines or introduce a BOM.
    return path.read_bytes().decode("utf-8")


def write_text(path: Path, content: str) -> None:
    # Write UTF-8 without a BOM, preserving the file's existing newlines.
    path.write_bytes(content.encode("utf-8"))


def detect_current_version() -> str:
    match = VERSION_FIELD.search(read_text(REPO_ROOT / SOURCE_OF_TRUTH))
    if not match:
        fail(f"could not detect current version in {SOURCE_OF_TRUTH}")
    # match.group(0) is the whole field; pull the literal back out.
    return re.search(r"\d+\.\d+\.\d+", match.group(0)).group(0)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Bump the qtaiskills plugin version across all metadata files."
    )
    parser.add_argument("version", help="target SemVer, e.g. 1.7.0")
    parser.add_argument(
        "--reason",
        required=True,
        help="one-line release note for the commit body (required, so every "
        "bump carries a stated rationale)",
    )
    parser.add_argument(
        "--push",
        action="store_true",
        help="push the commit to refs/for/dev after committing",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    target = args.version

    if not SEMVER.match(target):
        fail(f"'{target}' is not a valid SemVer (expected e.g. 1.7.0)")

    # Every version file must exist before we touch anything.
    for name in VERSION_FILES:
        if not (REPO_ROOT / name).is_file():
            fail(f"missing file: {name}")

    current = detect_current_version()
    if current == target:
        fail(f"version is already {target}; nothing to bump")

    print(f"Bumping {current} -> {target}")

    # The bump always lands on dev. Base the work on fresh origin/dev via a
    # throwaway topic branch so the review is cut from current trunk rather
    # than whatever happened to be checked out.
    print("Fetching origin/dev and creating bump branch...")
    git("fetch", "origin", "dev")
    branch = f"bump-version-{target}"
    # Refuse to clobber an existing local branch.
    exists = subprocess.run(
        ["git", "rev-parse", "--verify", "--quiet", f"refs/heads/{branch}"],
        cwd=REPO_ROOT,
        capture_output=True,
    )
    if exists.returncode == 0:
        fail(f"branch {branch} already exists; delete it before re-running")
    git("checkout", "-b", branch, "origin/dev")

    # Rewrite every semver-valued "version" field to the target.
    for name in VERSION_FILES:
        path = REPO_ROOT / name
        content = read_text(path)
        updated, count = VERSION_FIELD.subn(rf"\g<1>{target}\g<2>", content)
        if count == 0:
            fail(f"{name} has no \"version\": \"X.Y.Z\" field; aborting")
        write_text(path, updated)
        print(f"  updated {name} ({count} field{'s' if count != 1 else ''})")

    # Build the commit message. The Gerrit commit-msg hook adds the Change-Id.
    subject = f"Bump plugin version to {target}"
    message = f"{subject}\n\n{args.reason}\n"

    git("add", *VERSION_FILES)
    git("commit", "-m", message)

    print("\nCommitted:")
    git("log", "-1", "--oneline")

    if args.push:
        print("\nPushing to refs/for/dev...")
        git("push", "origin", "HEAD:refs/for/dev")
    else:
        print("\nSkipped push. Run: git push origin HEAD:refs/for/dev")


if __name__ == "__main__":
    main()
