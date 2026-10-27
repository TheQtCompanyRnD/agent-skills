#!/usr/bin/env python3
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
"""
Regression test for qt_review_lint.py.

Runs the linter against test files in two modes:
  1. Universal mode (no flags) — verifies all universal rules
  2. Framework mode (--framework) — verifies framework-only rules
It also checks that framework rules stay silent without the flag, and
that --diff reports only changed lines with root-relative summary paths.
The --analyse integration is tested against a stub analyser, and against
the real clang-tidy and clazy when the Qt installation provides them.

Usage:
    python3 tests/qt-cpp-review/run_tests.py
"""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent.parent
LINTER = REPO_ROOT / "skills" / "qt-cpp-review" / "references" / "lint-scripts" / "qt_review_lint.py"
# Inputs only: sources the linter is run on, a stub analyser, and a CMake
# project for the real analysers. The tests themselves are all in this file.
FIXTURES = Path(__file__).parent / "fixtures"
FAKE_ANALYSER = FIXTURES / "fake_analyser.py"
FIXTURE_DIR = FIXTURES / "analyser_fixture"


def git(repo: str | Path, *args: str) -> None:
    """Run git in `repo` with a throwaway identity, failing on error."""
    subprocess.run(["git", "-C", str(repo), "-c", "user.name=test",
                    "-c", "user.email=test@example.com", *args],
                   check=True, capture_output=True)

# Universal-mode expected findings (no --framework flag)
EXPECTED_UNIVERSAL = {
    # --- test_all_rules.h ---
    ("test_all_rules.h", "DEP-1"): 1,
    ("test_all_rules.h", "DEP-5"): 1,
    ("test_all_rules.h", "DEP-9"): 1,
    ("test_all_rules.h", "DEP-13"): 1,
    ("test_all_rules.h", "PAT-9"): 1,
    ("test_all_rules.h", "ENM-2"): 1,
    ("test_all_rules.h", "ENM-9"): 1,
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
    ("test_all_rules.cpp", "ENM-9"): 1,
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


def run_linter(files: list[str], extra_args: list[str] | None = None,
               cwd: str | None = None) -> str:
    """Run the linter and return combined stdout+stderr."""
    cmd = [sys.executable, str(LINTER)] + (extra_args or []) + files
    result = subprocess.run(cmd, capture_output=True, cwd=cwd)
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


def check_diff_mode() -> list[str]:
    """Commit a file with one DEP-7 violation, add a second one in the
    working tree, and expect --diff=HEAD to report only the new line."""
    errors: list[str] = []
    with tempfile.TemporaryDirectory() as repo:
        source = Path(repo) / "src" / "clamp.cpp"
        source.parent.mkdir()
        source.write_text("int a = qMin(1, 2);\n")
        git(repo, "init", "-q")
        git(repo, "add", "-A")
        git(repo, "commit", "-qm", "initial")
        source.write_text("int a = qMin(1, 2);\nint b = qMax(1, 2);\n")

        actual = parse_output(run_linter([], ["--diff=HEAD"], cwd=repo))
        if actual != {("clamp.cpp", "DEP-7"): 1}:
            errors.append(f"  FAIL  --diff=HEAD expected one DEP-7, got {actual}")

        summary = run_linter([], ["--summary", "--diff=HEAD"], cwd=repo)
        for expected in ("1 C++ file(s), 1 added or modified line(s)",
                         "src/clamp.cpp:2"):
            if expected not in summary:
                errors.append(f"  FAIL  --summary --diff=HEAD lacks {expected!r}")
        if str(source) in summary:
            errors.append("  FAIL  --summary printed an absolute location")
        if "working tree differs" in summary:
            errors.append("  FAIL  drift reported for a range ending at the working tree")
    return errors


def check_diff_drift() -> list[str]:
    """Review a change after the working tree has moved on: lint rows
    carry the line numbers at the end of the range, and the stub
    analyser's working tree lines (3 and 4) are mapped back to it, or
    dropped on a line edited since. A superseded lint rule stays on a
    line the analyser never saw."""
    errors: list[str] = []
    with tempfile.TemporaryDirectory() as tmp:
        stub = Path(tmp) / "clang-tidy-stub"
        stub.write_text(f'#!/bin/sh\nexec "{sys.executable}" '
                        f'"{FAKE_ANALYSER}" clang-tidy "$@"\n')
        stub.chmod(0o755)
        repo = Path(tmp) / "repo"
        source = repo / "drift_ok.cpp"     # "_ok": the stub compiles it cleanly
        source.parent.mkdir()
        db_dir = repo / "build"
        db_dir.mkdir()
        (db_dir / "compile_commands.json").write_text(json.dumps(
            [{"directory": str(db_dir), "file": str(source),
              "command": f"c++ -c {source}"}]))

        source.write_text("#include <QFile>\nvoid f() {\n}\n")
        git(repo, "init", "-q")
        git(repo, "add", "-A")
        git(repo, "commit", "-qm", "initial")
        # ERR-1 on lines 4 and 6 at the end of the range
        source.write_text('#include <QFile>\nvoid f() {\n    QFile a("x");\n'
                          '    a.open(QIODevice::ReadOnly);\n    QFile b("y");\n'
                          '    b.open(QIODevice::ReadOnly);\n}\n')
        git(repo, "add", "-A")
        # Working tree: a line inserted above, line 6 fixed
        worktree = ('#include <QFile>\nvoid f() {\n    // inserted\n    QFile a("x");\n'
                    '    a.open(QIODevice::ReadOnly);\n    QFile b("y");\n'
                    '    if (!b.open(QIODevice::ReadOnly))\n        return;\n}\n')
        source.write_text(worktree)

        def rows(out: str) -> list[str]:
            return sorted(ln.split(" ")[0].rsplit(":", 1)[1] + " " + ln.split(" ")[1]
                          for ln in out.splitlines() if ln.startswith(str(source)))

        rc, out, err = run_linter_rc(["--diff=--cached"], cwd=str(repo))
        if rows(out) != ["4 ERR-1", "6 ERR-1"]:
            errors.append(f"  FAIL  --diff=--cached expected ERR-1 on 4 and 6, got {rows(out)}")
        if "working tree differs: drift_ok.cpp" not in err:
            errors.append("  FAIL  --diff=--cached lacks the drift status line")

        git(repo, "commit", "-qm", "change")
        rc, out, err = run_linter_rc(
            [f"--clang-tidy={stub}", f"--build-dir={db_dir}", "--diff=HEAD~1..HEAD"],
            cwd=str(repo))
        # CT on working tree 3 is on the inserted line; 4 maps to 3.
        # ERR-1 on 4 is superseded; on 6 the analyser saw other code.
        want = ["3 CT:bugprone-use-after-move", "6 ERR-1"]
        if rows(out) != want:
            errors.append(f"  FAIL  --analyse --diff=HEAD~1..HEAD expected {want}, got {rows(out)}")
        if "analysers: 1 diagnostic(s) dropped" not in err:
            errors.append("  FAIL  no status line for the dropped diagnostic")
        if source.read_text() != worktree:
            errors.append("  FAIL  the working tree was modified")
    return errors


def check_err1_checked() -> list[str]:
    """ERR-1 fires on an open() whose result is discarded, not on one
    whose result is tested, asserted, stored or returned."""
    discarded = ["    file.open(QIODevice::ReadOnly);",
                 "    d->file.open(QFile::WriteOnly | QFile::Text);",
                 "    m_log->open(QIODevice::Append);",
                 "    QFile image(path); image.open(QFile::ReadOnly);"]
    checked = ["    QVERIFY(f.open(QFile::ReadWrite | QFile::Text | QFile::Append));",
               "    QVERIFY2(f.open(QIODevice::ReadOnly), qPrintable(f.errorString()));",
               "    QCOMPARE(f.open(QIODevice::ReadOnly), true);",
               "    if (!file.open(QIODevice::ReadOnly))",
               "    if (file.open(QIODevice::ReadOnly)) {",
               "    const bool ok = file.open(QIODevice::ReadOnly);",
               "    auto ok = file.open(QIODevice::ReadOnly);",
               "    return file.open(QIODevice::ReadOnly);",
               "    ok = ok && file.open(QIODevice::ReadOnly);",
               "    Q_UNUSED(file.open(QIODevice::ReadOnly));",
               "    if (QFile file(path); file.open(QIODevice::ReadOnly)) {"]
    errors: list[str] = []
    with tempfile.TemporaryDirectory() as tmp:
        source = Path(tmp) / "err1.cpp"
        source.write_text("\n".join(discarded + checked) + "\n")
        out = run_linter([str(source)])
        hits = sorted(int(m) for m in re.findall(r":(\d+) ERR-1 ", out))
        want = list(range(1, len(discarded) + 1))
        if hits != want:
            errors.append(f"  FAIL  ERR-1 expected on lines {want}, got {hits}")
    return errors


def run_linter_rc(args: list[str], cwd: str | None = None) -> tuple[int, str, str]:
    """Run the linter; return (exit code, stdout, stderr)."""
    result = subprocess.run([sys.executable, str(LINTER), *args],
                            capture_output=True, text=True, cwd=cwd)
    return result.returncode, result.stdout, result.stderr


def check_stub_analysers() -> list[str]:
    """Run --analyse against a stub clang-tidy/clazy that prints one
    diagnostic on a changed line, one on an unchanged line, one in a Qt
    header and one compiler error (none for a TU named *_ok). Also checks
    which linter rules the tools supersede."""
    errors: list[str] = []
    with tempfile.TemporaryDirectory() as tmp:
        stubs = {}
        for tool in ("clang-tidy", "clazy"):
            stub = Path(tmp) / f"{tool}-stub"
            stub.write_text(f'#!/bin/sh\nexec "{sys.executable}" '
                            f'"{FAKE_ANALYSER}" {tool} "$@"\n')
            stub.chmod(0o755)
            stubs[tool] = f"--{tool}={stub}"

        repo = Path(tmp) / "repo"
        source = repo / "src" / "stub.cpp"
        source.parent.mkdir(parents=True)
        # Lines 9 and 10 hit ENM-2 (clang-tidy) and PAT-8 (clazy) rules
        body = ("\n".join(f"int v{i} = {i};" for i in range(8)) + "\n"
                "enum Color { Red };\nQMap<Color*, int> byPtr;\n")
        source.write_text(body)
        ok_source = repo / "src" / "stub_ok.cpp"   # stubs compile it cleanly
        ok_source.write_text(body)
        ok_header = repo / "src" / "stub_ok.h"     # stem-matched to stub_ok.cpp
        ok_header.write_text("enum Color { Red };\n")
        lonely = repo / "src" / "lonely.h"         # no translation unit
        lonely.write_text("enum Color { Red };\n")
        db_dir = repo / "build"
        db_dir.mkdir()
        (db_dir / "compile_commands.json").write_text(
            '[{"directory": "%s", "file": "%s", "command": "c++ -c %s"},'
            ' {"directory": "%s", "file": "%s", "command": "c++ -c %s"}]'
            % (db_dir, source, source, db_dir, ok_source, ok_source))

        git(repo, "init", "-q")
        git(repo, "add", "-A")
        git(repo, "commit", "-qm", "initial")
        lines = source.read_text().splitlines()
        lines[2] = "int changed = 3;"
        source.write_text("\n".join(lines) + "\n")

        # Findings, header filtering, failure counting, --build-dir
        rc, out, err = run_linter_rc(
            [*stubs.values(), f"--build-dir={db_dir}", str(source)])
        text = out + err
        expected = [f"{source}:3 CT:bugprone-use-after-move stub finding",
                    f"{source}:4 CZ:old-style-connect stub finding on an unchanged line"]
        for want in expected:
            if want not in text:
                errors.append(f"  FAIL  --analyse output lacks {want!r}")
        if "qobject.h" in text or "header noise" in text:
            errors.append("  FAIL  header diagnostic was not filtered")
        if "stub compile failure" in out and "failed" not in err:
            errors.append("  FAIL  compiler error leaked into the findings")
        if f"{source}:7" in out:
            errors.append("  FAIL  compiler error was reported as a finding")
        for tool in ("clang-tidy", "clazy"):
            if not re.search(rf"^{tool}: ran \(.*, 1 TUs, 1 failed", err, re.MULTILINE):
                errors.append(f"  FAIL  no 'ran (..., 1 failed' status for {tool}")
        if rc != 1:
            errors.append(f"  FAIL  exit code {rc} with analyser findings, expected 1")

        # --diff keeps only the changed line; the DB is found in build/
        rc, out, err = run_linter_rc(
            [stubs["clang-tidy"], "--diff=HEAD"], cwd=str(repo))
        stub_lines = [ln for ln in out.splitlines() if "CT:" in ln]
        if len(stub_lines) != 1 or ":3 CT:" not in stub_lines[0]:
            errors.append(f"  FAIL  --diff expected one CT: finding on line 3, got {stub_lines}")
        if "clang-tidy: ran" not in err:
            errors.append("  FAIL  DB in build/ was not discovered")

        # Summary mode prints the status before the table
        rc, out, err = run_linter_rc(
            ["--summary", stubs["clazy"], "--diff=HEAD"], cwd=str(repo))
        if not (re.search(r"^clazy: ran \(.*\)$", out, re.MULTILINE)
                and out.index("clazy: ran") < out.index("finding(s)")):
            errors.append("  FAIL  --summary lacks the status line before the table")
        if "clang-tidy:" in out:
            errors.append("  FAIL  status printed for a tool that was not requested")

        # Linter rules superseded by the tools, dropped on analysed files
        def hit(out: str, path: Path, rule: str) -> bool:
            return bool(re.search(rf"^{re.escape(str(path))}:\d+ {rule} ", out,
                                  re.MULTILINE))

        def superseded(err: str) -> str | None:
            m = re.search(r"^analysers: superseded on analysed files: (.*)$", err, re.MULTILINE)
            return m.group(1) if m else None

        # Both tools ran cleanly: dropped, also for a header via its stem;
        # a header without a TU keeps its hits and is listed
        rc, out, err = run_linter_rc(
            [*stubs.values(), f"--build-dir={db_dir}",
             str(ok_source), str(ok_header), str(lonely)])
        for path, rule in ((ok_source, "ENM-2"), (ok_source, "PAT-8"),
                           (ok_header, "ENM-2")):
            if hit(out, path, rule):
                errors.append(f"  FAIL  {rule} on {path.name} not superseded")
        if not hit(out, lonely, "ENM-2"):
            errors.append("  FAIL  header without a TU lost its ENM-2 hit")
        if superseded(err) != "clang-tidy (ENM-2, ERR-1, PAT-1, TRN-3), clazy (PAT-8)":
            errors.append(f"  FAIL  superseded status line wrong: {err.strip()}")
        if not re.search(r"^analysers: not analysed: \S*lonely\.h$", err, re.MULTILINE):
            errors.append(f"  FAIL  lonely.h not listed as not analysed: {err.strip()}")
        if "no translation unit" in err:
            errors.append("  FAIL  old 'no translation unit' wording is still printed")

        # A failed TU keeps the hits and is listed; the clean one is dropped
        rc, out, err = run_linter_rc(
            [*stubs.values(), f"--build-dir={db_dir}", str(source), str(ok_source)])
        for rule in ("ENM-2", "PAT-8"):
            if not hit(out, source, rule):
                errors.append(f"  FAIL  {rule} dropped on stub.cpp whose TU failed")
            if hit(out, ok_source, rule):
                errors.append(f"  FAIL  {rule} on stub_ok.cpp not superseded")
        if not re.search(r"^analysers: not analysed: \S*stub\.cpp$", err, re.MULTILINE):
            errors.append(f"  FAIL  stub.cpp not listed as not analysed: {err.strip()}")
        rc, out, err = run_linter_rc(
            [*stubs.values(), f"--build-dir={db_dir}", str(source)])
        if superseded(err) is not None:
            errors.append("  FAIL  superseded status printed with no analysed file")

        # Only clazy: PAT-8 goes, the clang-tidy rules stay
        rc, out, err = run_linter_rc(
            [stubs["clazy"], f"--build-dir={db_dir}", str(ok_source)])
        if hit(out, ok_source, "PAT-8") or not hit(out, ok_source, "ENM-2"):
            errors.append("  FAIL  with only clazy, PAT-8 should go and ENM-2 stay")
        if superseded(err) != "clazy (PAT-8)":
            errors.append(f"  FAIL  clazy-only superseded line wrong: {err.strip()}")

        # A custom clang-tidy configuration keeps the clang-tidy rules
        tidy_config = Path(tmp) / "custom.yaml"
        tidy_config.write_text("Checks: '-*'\n")
        rc, out, err = run_linter_rc(
            [*stubs.values(), f"--clang-tidy-config={tidy_config}",
             f"--build-dir={db_dir}", str(ok_source)])
        if hit(out, ok_source, "PAT-8") or not hit(out, ok_source, "ENM-2"):
            errors.append("  FAIL  with --clang-tidy-config, ENM-2 should stay, PAT-8 go")
        if superseded(err) != "clazy (PAT-8)":
            errors.append(f"  FAIL  custom-config superseded line wrong: {err.strip()}")

        # No compile database: reported, exit code unchanged
        work = Path(tmp) / "empty" / "work"
        work.mkdir(parents=True)
        plain = run_linter_rc([str(source)], cwd=str(work))[0]
        rc, out, err = run_linter_rc(
            ["--summary", *stubs.values(), str(source)], cwd=str(work))
        if "skipped (no compile_commands.json" not in out:
            errors.append("  FAIL  missing DB did not print 'skipped (no compile_commands.json'")
        if rc != plain:
            errors.append(f"  FAIL  missing DB changed the exit code ({plain} -> {rc})")

        # Missing tool: reported, no crash
        rc, out, err = run_linter_rc(
            ["--summary", "--clazy=/nonexistent/clazy", str(source)], cwd=str(work))
        if "clazy: not available" not in out or rc != plain:
            errors.append("  FAIL  missing tool did not print 'clazy: not available'")
    return errors


def find_qt_prefixes() -> list[str]:
    """Qt 6 kits with CMake config files: those named by the environment,
    then ~/Qt kits by descending version."""
    candidates = [os.environ.get("CMAKE_PREFIX_PATH", "").split(os.pathsep)[0],
                  os.environ.get("QT_HOST_PATH", "")]
    kits = (Path.home() / "Qt").glob("6.*/gcc_64")
    candidates += [str(k) for k in sorted(
        kits, key=lambda k: [int(n) for n in re.findall(r"\d+", k.parent.name)],
        reverse=True)]
    return [p for p in candidates
            if p and (Path(p) / "lib" / "cmake" / "Qt6" / "Qt6Config.cmake").is_file()]


def check_real_analysers() -> tuple[list[str], str | None]:
    """Run the real clang-tidy and clazy on a configured fixture. Returns
    (errors, reason the test was skipped or None)."""
    sys.path.insert(0, str(LINTER.parent))
    import qt_analysers
    for name in ("clang-tidy", "clazy-standalone"):
        if qt_analysers.find_tool(name) is None:
            return [], f"{name} not found"
    if shutil.which("cmake") is None:
        return [], "cmake not found"
    prefixes = find_qt_prefixes()
    if not prefixes:
        return [], "no Qt 6 kit with CMake config files found"

    errors: list[str] = []
    with tempfile.TemporaryDirectory() as build:
        # Try the kits in turn: a kit can be too new for the installed cmake.
        # Release on purpose: clazy's connect checks must work without a
        # Debug build. -Werror and a GCC-only warning, as in a Qt developer
        # build, must not fail the TU under clang.
        flags = "-Werror" if shutil.which("clang++") and not shutil.which("g++") \
            else "-Werror -Werror=stringop-overflow"
        for prefix in prefixes:
            configure = subprocess.run(
                ["cmake", "-S", str(FIXTURE_DIR), "-B", build,
                 "-DCMAKE_BUILD_TYPE=Release", f"-DCMAKE_PREFIX_PATH={prefix}",
                 f"-DCMAKE_CXX_FLAGS={flags}",
                 "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"],
                capture_output=True, text=True)
            if configure.returncode == 0:
                break
            shutil.rmtree(build, ignore_errors=True)
            os.makedirs(build)
        else:
            return [], "cmake could not configure the fixture with any Qt kit"
        rc, out, err = run_linter_rc(
            ["--analyse", f"--build-dir={build}",
             str(FIXTURE_DIR / "smoke.cpp"), str(FIXTURE_DIR / "smoke.h")])
        for rule in ("CZ:old-style-connect", "CT:bugprone-unused-return-value"):
            if not re.search(rf"smoke\.cpp:\d+ {re.escape(rule)} ", out):
                errors.append(f"  FAIL  real analysers did not report {rule}")
        for tool in ("clang-tidy", "clazy"):
            if not re.search(rf"^{tool}: ran \(.*, 1 TUs\)", err, re.MULTILINE):
                errors.append(f"  FAIL  {tool} status is not 'ran (..., 1 TUs)': {err.strip()}")
    return errors, None


def check_header_mapping() -> list[str]:
    """select_tus: Qt private headers map to the source beside them, a
    header without a source goes through a file that includes it, and a
    same-named source in another directory is not used."""
    sys.path.insert(0, str(LINTER.parent))
    import qt_analysers
    errors: list[str] = []
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        for rel, text in {
                "a/qfoo.cpp": '#include "qfoo_p_p.h"\n',
                "a/qfoo_p.h": "", "a/qfoo_p_p.h": '#include "qbar_p.h"\n',
                "a/qbar_p.h": "", "a/qlone_p.h": "", "a/qother_p.h": "",
                "z/qfoo.cpp": "", "z/qother.cpp": ""}.items():
            (root / rel).parent.mkdir(parents=True, exist_ok=True)
            (root / rel).write_text(text)
        db = root / "compile_commands.json"
        db.write_text(json.dumps([{"directory": str(root), "file": str(root / f),
                                   "command": "c++ -c " + f}
                                  for f in ("z/qfoo.cpp", "a/qfoo.cpp", "z/qother.cpp")]))
        files = [str(root / f) for f in
                 ("a/qfoo_p.h", "a/qfoo_p_p.h", "a/qbar_p.h", "a/qlone_p.h",
                  "a/qother_p.h")]
        tus, missing, tu_of = qt_analysers.select_tus(str(db), files)
        want = os.path.realpath(root / "a" / "qfoo.cpp")
        for f in files[:3]:
            if tu_of.get(f) != want:
                errors.append(f"  FAIL  {Path(f).name} -> {tu_of.get(f)}, expected a/qfoo.cpp")
        if missing != files[3:]:
            errors.append(f"  FAIL  missing is {missing}, expected qlone_p.h and qother_p.h")
    return errors


def check_compile_db_discovery() -> list[str]:
    """find_compile_db looks in build folders inside the source and beside
    it, and ignores a sibling project's newer database."""
    sys.path.insert(0, str(LINTER.parent))
    import qt_analysers
    errors: list[str] = []
    with tempfile.TemporaryDirectory() as tmp:
        src = Path(tmp) / "proj"
        src.mkdir()

        def add_db(rel: str, mtime: int) -> str:
            db = Path(tmp) / rel / "compile_commands.json"
            db.parent.mkdir(parents=True, exist_ok=True)
            db.write_text("[]")
            os.utime(db, (mtime, mtime))
            return os.path.abspath(db)

        # The newest wins among the candidates; the other project's
        # database is newest of all but never a candidate
        add_db("other-build", 9000)
        for rel, mtime in (("proj/build/Desktop_Qt_6-Debug/.qtc_clangd", 1000),
                           ("proj-build", 2000), ("proj_build-release", 3000)):
            want = add_db(rel, mtime)
            got = qt_analysers.find_compile_db(None, [str(src)])
            if got != want:
                errors.append(f"  FAIL  {rel}: found {got}")
    return errors


def main() -> int:
    all_ok = True

    # --- Test 1: Universal mode ---
    print("=" * 60)
    print("Test 1: Universal mode (no --framework)")
    print("=" * 60)

    universal_files = [
        str(FIXTURES / "test_all_rules.h"),
        str(FIXTURES / "test_all_rules.cpp"),
        str(FIXTURES / "test_mdl1.cpp"),
        str(FIXTURES / "test_mdl6.cpp"),
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
        str(FIXTURES / "test_framework.h"),
        str(FIXTURES / "test_framework.cpp"),
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

    # --- Test 4: Diff mode ---
    print("=" * 60)
    print("Test 4: --diff reports only changed lines")
    print("=" * 60)

    errors = check_diff_mode()
    if errors:
        for e in errors:
            print(e)
        all_ok = False
    else:
        print("PASSED: Only the changed line was reported")
    print()

    # --- Test 5: Stub analysers ---
    print("=" * 60)
    print("Test 5: --analyse with a stub clang-tidy/clazy")
    print("=" * 60)

    if sys.platform == "win32":
        print("SKIP: the stub analysers are shell scripts")
    else:
        errors = check_stub_analysers()
        if errors:
            for e in errors:
                print(e)
            all_ok = False
        else:
            print("PASSED: CT:/CZ: findings merged, noise filtered, "
                  "--diff and missing DB/tool handled")
    print()

    # --- Test 6: Real analysers ---
    print("=" * 60)
    print("Test 6: --analyse with the real clang-tidy and clazy")
    print("=" * 60)

    errors, skipped = check_real_analysers()
    if skipped:
        print(f"SKIP: {skipped}")
    elif errors:
        for e in errors:
            print(e)
        all_ok = False
    else:
        print("PASSED: CZ:old-style-connect and CT:bugprone-unused-return-value found")
    print()

    # --- Test 7: Header to translation unit mapping ---
    print("=" * 60)
    print("Test 7: --analyse maps headers to translation units")
    print("=" * 60)

    errors = check_header_mapping()
    if errors:
        for e in errors:
            print(e)
        all_ok = False
    else:
        print("PASSED: _p/_p_p headers and included headers mapped")
    print()

    # --- Test 8: Diff range ending before the working tree ---
    print("=" * 60)
    print("Test 8: --diff lines refer to the end of the range")
    print("=" * 60)

    errors = check_diff_drift()
    if errors:
        for e in errors:
            print(e)
        all_ok = False
    else:
        print("PASSED: lint rows and mapped analyser rows use the range's line numbers")
    print()

    # --- Test 9: ERR-1 on discarded results only ---
    print("=" * 60)
    print("Test 9: ERR-1 skips checked QFile::open() results")
    print("=" * 60)

    errors = check_err1_checked()
    if errors:
        for e in errors:
            print(e)
        all_ok = False
    else:
        print("PASSED: discarded open() flagged; QVERIFY, if, assignment, return not")
    print()

    # --- Test 10: compile_commands.json discovery ---
    print("=" * 60)
    print("Test 10: --analyse finds the build folder")
    print("=" * 60)

    errors = check_compile_db_discovery()
    if errors:
        for e in errors:
            print(e)
        all_ok = False
    else:
        print("PASSED: build/<kit>/, <name>-build and <name>_build found; other projects ignored")
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
