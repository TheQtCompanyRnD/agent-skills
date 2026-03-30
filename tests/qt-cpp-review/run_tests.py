#!/usr/bin/env python3
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
"""
Regression test for qt_review_lint.py.

Runs the linter against test files in two modes:
  1. Universal mode (no flags) — verifies all universal rules
  2. Framework mode (--framework) — verifies framework-only rules

Usage:
    python tests/run_tests.py
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent.parent
LINTER = REPO_ROOT / "skills" / "qt-cpp-review" / "references" / "lint-scripts" / "qt_review_lint.py"
TEST_DIR = Path(__file__).parent

# Universal-mode expected findings (no --framework flag)
EXPECTED_UNIVERSAL = {
    # --- test_all_rules.h ---
    ("test_all_rules.h", "DEP-1"): 1,
    ("test_all_rules.h", "DEP-5"): 1,
    ("test_all_rules.h", "DEP-9"): 1,
    ("test_all_rules.h", "DEP-13"): 1,
    ("test_all_rules.h", "PAT-9"): 1,
    ("test_all_rules.h", "ENM-2"): 1,
    ("test_all_rules.h", "TMO-1"): 2,  # timeout + interval
    ("test_all_rules.h", "API-5"): 2,  # getNoteTitle + getNoteStatistics

    # --- test_all_rules.cpp ---
    ("test_all_rules.cpp", "INC-2"): 1,  # std header before Qt
    ("test_all_rules.cpp", "DEP-2"): 1,
    ("test_all_rules.cpp", "DEP-3"): 1,
    ("test_all_rules.cpp", "DEP-4"): 1,
    ("test_all_rules.cpp", "DEP-6"): 1,
    ("test_all_rules.cpp", "DEP-7"): 1,
    ("test_all_rules.cpp", "DEP-8"): 1,
    ("test_all_rules.cpp", "DEP-10"): 2,
    ("test_all_rules.cpp", "DEP-11"): 1,
    ("test_all_rules.cpp", "DEP-12"): 2,
    ("test_all_rules.cpp", "HDR-3"): 3,
    ("test_all_rules.cpp", "PAT-1"): 1,
    ("test_all_rules.cpp", "PAT-2"): 1,
    ("test_all_rules.cpp", "PAT-3"): 1,
    ("test_all_rules.cpp", "TRN-3"): 1,
    ("test_all_rules.cpp", "PAT-5"): 1,
    ("test_all_rules.cpp", "PAT-7"): 1,
    ("test_all_rules.cpp", "PAT-8"): 1,
    ("test_all_rules.cpp", "VAL-5"): 1,
    ("test_all_rules.cpp", "VAR-3"): 1,
    ("test_all_rules.cpp", "API-5"): 1,
    ("test_all_rules.cpp", "PAT-10"): 1,
    ("test_all_rules.cpp", "PAT-11"): 1,
    ("test_all_rules.cpp", "PAT-12"): 1,
    ("test_all_rules.cpp", "PAT-14"): 1,
    ("test_all_rules.cpp", "PAT-15"): 1,
    ("test_all_rules.cpp", "MDL-2"): 1,
    ("test_all_rules.cpp", "MDL-4"): 1,
    ("test_all_rules.cpp", "MDL-5"): 1,
    ("test_all_rules.cpp", "MDL-6"): 1,
    ("test_all_rules.cpp", "MDL-7"): 1,
    ("test_all_rules.cpp", "ERR-1"): 1,
    ("test_all_rules.cpp", "ERR-2"): 1,
    ("test_all_rules.cpp", "ERR-3"): 1,
    ("test_all_rules.cpp", "ERR-4"): 1,
    ("test_all_rules.cpp", "ERR-5"): 1,
    ("test_all_rules.cpp", "ERR-6"): 1,
    ("test_all_rules.cpp", "ERR-7"): 1,
    ("test_all_rules.cpp", "ERR-9"): 1,
    ("test_all_rules.cpp", "LCY-1"): 1,
    ("test_all_rules.cpp", "LCY-2"): 1,
    ("test_all_rules.cpp", "LCY-3"): 1,
    ("test_all_rules.cpp", "LCY-4"): 1,
    ("test_all_rules.cpp", "LCY-5"): 2,
    ("test_all_rules.cpp", "LCY-6"): 1,

    # --- separate test files ---
    ("test_mdl1.cpp", "MDL-1"): 1,
    ("test_mdl6.cpp", "MDL-6"): 1,
    ("test_mdl6.cpp", "LCY-5"): 1,
}

# Framework-mode expected findings (--framework flag)
# Only the framework-specific rules from dedicated test files.
EXPECTED_FRAMEWORK = {
    ("test_framework.h", "INC-6"): 1,
    ("test_framework.h", "INC-1"): 1,
    ("test_framework.h", "VAL-6"): 1,
    ("test_framework.cpp", "CND-2"): 1,
    ("test_framework.cpp", "PAT-6"): 1,
}


def parse_output(output: str) -> dict[tuple[str, str], int]:
    """Parse linter output into {(filename, rule): count}."""
    counts: dict[tuple[str, str], int] = {}
    for line in output.strip().splitlines():
        if not line.strip():
            continue
        parts = line.split(None, 2)
        if len(parts) < 2:
            continue
        file_loc = parts[0]
        rule = parts[1]
        colon_idx = file_loc.rfind(":")
        filepath = file_loc[:colon_idx] if colon_idx > 0 else file_loc
        basename = Path(filepath).name
        key = (basename, rule)
        counts[key] = counts.get(key, 0) + 1
    return counts


def run_linter(files: list[str], extra_args: list[str] | None = None) -> str:
    """Run the linter and return combined stdout+stderr."""
    cmd = [sys.executable, str(LINTER)] + (extra_args or []) + files
    result = subprocess.run(cmd, capture_output=True)
    return ((result.stdout or b"").decode("utf-8", errors="replace") +
            (result.stderr or b"").decode("utf-8", errors="replace"))


def check_expectations(
    actual: dict[tuple[str, str], int],
    expected: dict[tuple[str, str], int],
    label: str,
) -> tuple[int, int, list[str]]:
    """Check actual findings against expected. Returns (passed, total, errors)."""
    errors: list[str] = []
    passed = 0
    for key, min_count in sorted(expected.items()):
        actual_count = actual.get(key, 0)
        if actual_count == 0:
            errors.append(f"  FAIL  {key[0]} {key[1]} — expected >= {min_count}, got 0")
        elif actual_count < min_count:
            errors.append(
                f"  FAIL  {key[0]} {key[1]} — expected >= {min_count}, got {actual_count}")
        else:
            passed += 1

    # Unexpected findings (only check against expected keys)
    for key, count in sorted(actual.items()):
        if key not in expected:
            errors.append(f"  WARN  {key[0]} {key[1]} x{count} (unexpected)")

    return passed, len(expected), errors


def main() -> int:
    all_ok = True

    # --- Test 1: Universal mode ---
    print("=" * 60)
    print("Test 1: Universal mode (no --framework)")
    print("=" * 60)

    universal_files = [
        str(TEST_DIR / "test_all_rules.h"),
        str(TEST_DIR / "test_all_rules.cpp"),
        str(TEST_DIR / "test_mdl1.cpp"),
        str(TEST_DIR / "test_mdl6.cpp"),
    ]
    output = run_linter(universal_files)
    actual = parse_output(output)
    passed, total, errors = check_expectations(
        actual, EXPECTED_UNIVERSAL, "Universal")

    if errors:
        for e in errors:
            print(e)
        print()
    print(f"Results: {passed}/{total} expected rules triggered")
    if passed == total and not any("FAIL" in e for e in errors):
        print("ALL UNIVERSAL RULES PASSED")
    else:
        all_ok = False
    print()

    # --- Test 2: Framework mode ---
    print("=" * 60)
    print("Test 2: Framework mode (--framework)")
    print("=" * 60)

    framework_files = [
        str(TEST_DIR / "test_framework.h"),
        str(TEST_DIR / "test_framework.cpp"),
    ]
    output = run_linter(framework_files, extra_args=["--framework"])
    actual = parse_output(output)
    passed, total, errors = check_expectations(
        actual, EXPECTED_FRAMEWORK, "Framework")

    if errors:
        for e in errors:
            print(e)
        print()
    print(f"Results: {passed}/{total} expected framework rules triggered")
    if passed == total and not any("FAIL" in e for e in errors):
        print("ALL FRAMEWORK RULES PASSED")
    else:
        all_ok = False
    print()

    # --- Test 3: Framework rules must NOT fire without flag ---
    print("=" * 60)
    print("Test 3: Framework rules silent without --framework")
    print("=" * 60)

    output = run_linter(framework_files)  # no --framework
    actual = parse_output(output)
    fw_leaked = {k: v for k, v in actual.items()
                 if k in EXPECTED_FRAMEWORK}
    if fw_leaked:
        print("FAIL: Framework rules fired without --framework flag:")
        for (fname, rule), count in fw_leaked.items():
            print(f"  {fname} {rule} x{count}")
        all_ok = False
    else:
        print("PASSED: No framework rules fired without flag")
    print()

    # --- Summary ---
    print("=" * 60)
    if all_ok:
        print("ALL TESTS PASSED")
    else:
        print("SOME TESTS FAILED")
    print("=" * 60)

    return 0 if all_ok else 1


if __name__ == "__main__":
    sys.exit(main())
