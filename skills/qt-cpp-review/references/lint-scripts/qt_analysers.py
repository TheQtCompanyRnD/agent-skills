#!/usr/bin/env python3
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
"""
qt_analysers.py — clang-tidy and clazy integration for qt_review_lint.py.

Finds the analysers (Qt Creator's bundled copies first, then PATH) and a
compile_commands.json, runs both tools once per translation unit in
parallel, and returns their diagnostics restricted to the files in scope
as Diag tuples (rule CT:<check> or CZ:<check>) plus status lines.

Also names the linter rules the tools supersede (SUPERSEDED_RULES) and
reports which files each tool analysed without failure.

Imported by qt_review_lint.py; not meant to be run on its own. Read-only:
it never configures or builds a project.
"""

from __future__ import annotations

import glob
import json
import os
import re
import shutil
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from typing import NamedTuple

ANALYSERS_DIR = Path(__file__).resolve().parent.parent / "analysers"
CLANG_TIDY_CONFIG = ANALYSERS_DIR / "clang-tidy.yaml"
CLAZY_CHECKS = ANALYSERS_DIR / "clazy-checks.txt"
FRAMEWORK_CLAZY_CHECKS = ("qt-keywords",)
DEFAULT_TIMEOUT = 120

# Linter rules whose defect a shipped check detects as well, with type
# information: the linter drops them on files that tool analysed. Only
# exact overlaps (Table C of the static-analysis overlap study); partial
# ones keep the rule. INC-2 is absent: llvm-include-order is not enabled.
SUPERSEDED_RULES = {
    "ENM-2": "clang-tidy",  # cppcoreguidelines-use-enum-class
    "ERR-1": "clang-tidy",  # bugprone-unused-return-value (CheckedFunctions)
    "PAT-1": "clang-tidy",  # bugprone-unchecked-optional-access
    "TRN-3": "clang-tidy",  # readability-simplify-boolean-expr
    "PAT-8": "clazy",       # qmap-with-pointer-key
}

NO_DB_HINT = ("no compile_commands.json; configure with "
              "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON or open the project in Qt Creator")

# Where Qt Creator keeps its clang tools, below <qt root>/Tools/QtCreator
if sys.platform == "win32":
    BUNDLE_SUBDIR = os.path.join("bin", "clang", "bin")
elif sys.platform == "darwin":
    BUNDLE_SUBDIR = os.path.join("Qt Creator.app", "Contents", "Resources",
                                 "libexec", "clang", "bin")
else:
    BUNDLE_SUBDIR = os.path.join("libexec", "qtcreator", "clang", "bin")

# file:line:col: severity: message [check1,check2]
RE_DIAG = re.compile(
    r"^(?P<file>[^:]+(?::[^:]*)*?):(?P<line>\d+):(?P<col>\d+):\s+"
    r"(?P<sev>warning|error|fatal error):\s+(?P<msg>.*?)"
    r"(?:\s*\[(?P<checks>[\w.,+-]+)\])?\s*$")
RE_PROCESS_ERROR = re.compile(r"^Error while processing ", re.MULTILINE)
HEADER_SUFFIXES = (".h", ".hh", ".hpp", ".hxx")


class Diag(NamedTuple):
    file: str
    line: int
    rule: str
    message: str


# ---------------------------------------------------------------------------
# Discovery
# ---------------------------------------------------------------------------

def list_qt_roots() -> list[str]:
    """Qt installation roots to look in: the one above $QT_HOST_PATH
    (<root>/6.x/<kit>), then the usual defaults."""
    roots = []
    host = os.environ.get("QT_HOST_PATH")
    if host:
        roots.append(os.path.dirname(os.path.dirname(os.path.normpath(host))))
    roots.extend([os.path.expanduser("~/Qt"), "/opt/Qt", "C:\\Qt"])
    return roots


def find_tool(name: str, explicit: str | None = None) -> str | None:
    """Resolve an analyser binary: an explicit path, then Qt Creator's
    bundle, then PATH. The bundle comes before PATH because distro
    packages are older and lack checks."""
    if explicit:
        return explicit if os.path.isfile(explicit) else None
    exe = name + (".exe" if sys.platform == "win32" else "")
    for root in list_qt_roots():
        candidate = os.path.join(root, "Tools", "QtCreator", BUNDLE_SUBDIR, exe)
        if os.path.isfile(candidate):
            return candidate
    return shutil.which(name)


def get_tool_version(path: str) -> str:
    try:
        out = subprocess.run([path, "--version"], capture_output=True,
                             text=True, timeout=30).stdout
    except (OSError, subprocess.SubprocessError):
        return "?"
    match = (re.search(r"clazy version ([\w.]+)", out)
             or re.search(r"LLVM version ([\w.]+)", out))
    return match.group(1) if match else "?"


def find_compile_db(explicit: str | None, bases: list[str]) -> str | None:
    """Return the compile_commands.json to use, or None. An explicit
    --build-dir wins; otherwise the newest of the usual locations below
    each base directory."""
    def in_dir(d: str) -> list[str]:
        return [p for p in (os.path.join(d, "compile_commands.json"),
                            os.path.join(d, ".qtc_clangd", "compile_commands.json"))
                if os.path.isfile(p)]

    if explicit:
        if os.path.isfile(explicit):
            return os.path.abspath(explicit)
        found = in_dir(explicit)
        return os.path.abspath(found[0]) if found else None
    candidates: list[str] = []
    for base in bases:
        name = glob.escape(os.path.basename(os.path.normpath(base)))
        parent = os.path.join(base, os.pardir)
        dirs = [base]
        # In-tree: build/, build-debug/, and Qt Creator's per-kit
        # build/<kit>-<config>/
        dirs.extend(glob.glob(os.path.join(base, "build*")))
        dirs.extend(glob.glob(os.path.join(base, "build*", "*")))
        # Beside the source: Qt Creator's old build-<project>-<kit>-<config>,
        # and <project>-build, <project>_build, <project>build-debug. The
        # latter carry the source folder's name, not a bare *build*, so
        # that another project's newer database is not picked.
        dirs.extend(glob.glob(os.path.join(parent, "build-*")))
        dirs.extend(glob.glob(os.path.join(parent, name + "*build*")))
        for d in dirs:
            if os.path.isdir(d):
                candidates.extend(in_dir(d))
    candidates = list(dict.fromkeys(os.path.abspath(c) for c in candidates))
    return max(candidates, key=os.path.getmtime) if candidates else None


def read_clazy_checks(framework: bool) -> str:
    text = re.sub(r"#.*", "", CLAZY_CHECKS.read_text(encoding="utf-8"))
    checks = [c for c in re.split(r"[,\s]+", text) if c]
    if framework:
        checks.extend(FRAMEWORK_CLAZY_CHECKS)
    return ",".join(checks)


# ---------------------------------------------------------------------------
# Translation units
# ---------------------------------------------------------------------------

def select_tus(db_path: str, files: list[str]
               ) -> tuple[list[str], list[str], dict[str, str]]:
    """Map the files in scope to compile database sources. A .cpp is its
    own TU; a header goes through the DB source with the same basename
    stem, minus Qt's private suffixes (qfoo_p_p.h -> qfoo.cpp), in the
    header's own directory; failing that, through the TU of a file in
    scope that includes it. Returns (TUs, files that have none, file ->
    its TU)."""
    with open(db_path, encoding="utf-8") as fh:
        entries = json.load(fh)
    sources: dict[str, str] = {}
    for entry in entries:
        path = os.path.realpath(os.path.join(entry.get("directory", ""), entry["file"]))
        sources.setdefault(path, path)
    by_stem: dict[str, list[str]] = {}
    for path in sorted(sources):
        by_stem.setdefault(Path(path).stem, []).append(path)

    tus: list[str] = []
    missing: list[str] = []
    tu_of: dict[str, str] = {}
    for f in files:
        real = os.path.realpath(f)
        if Path(real).suffix in HEADER_SUFFIXES:
            stem = Path(real).stem
            while stem.endswith("_p"):
                stem = stem[:-2]
            # Only a source beside the header: a superbuild DB holds
            # same-named sources in other modules that never include it
            match = [m for m in by_stem.get(stem, [])
                     if os.path.dirname(m) == os.path.dirname(real)]
            tu = match[0] if match else None
        else:
            tu = real if real in sources else None
        if tu is not None:
            tu_of[f] = tu

    # Headers with no source of their own (qiooperation_p.h), through a
    # file in scope that includes them, until nothing changes
    unmapped = [f for f in files if f not in tu_of]
    texts: dict[str, str] = {}
    while unmapped:
        progress = False
        for f in list(unmapped):
            if Path(f).suffix not in HEADER_SUFFIXES:
                continue
            include = re.compile(r'^\s*#\s*include\s*[<"](?:[^>"]*/)?'
                                 + re.escape(Path(f).name) + r'[>"]', re.MULTILINE)
            for g, tu in list(tu_of.items()):
                if g not in texts:
                    try:
                        texts[g] = Path(g).read_text(encoding="utf-8", errors="replace")
                    except OSError:
                        texts[g] = ""
                if include.search(texts[g]):
                    tu_of[f] = tu
                    unmapped.remove(f)
                    progress = True
                    break
        if not progress:
            break

    for f in files:
        tu = tu_of.get(f)
        if tu is None:
            missing.append(f)
        elif tu not in tus:
            tus.append(tu)
    return tus, missing, tu_of


def select_superseded_rules(covered: dict[str, set[str]],
                            custom_tidy_config: bool) -> dict[str, str]:
    """The linter rules to drop (rule -> tool) on the files in `covered`.
    A custom clang-tidy configuration may not enable the checks behind
    the clang-tidy rules, so those stay then."""
    return {rule: tool for rule, tool in SUPERSEDED_RULES.items()
            if covered.get(tool)
            and not (tool == "clang-tidy" and custom_tidy_config)}


# ---------------------------------------------------------------------------
# Running and parsing
# ---------------------------------------------------------------------------

def parse_diags(text: str, tool: str,
                scope: dict[str, str]) -> tuple[list[Diag], int]:
    """Return (diagnostics in scope, compiler error count). `scope` maps
    real paths to the path the caller passed. Diagnostics from anywhere
    else, such as Qt headers, are dropped: not every check honours the
    tools' own header filters."""
    prefix = "CZ:" if tool == "clazy" else "CT:"
    diags: list[Diag] = []
    errors = len(RE_PROCESS_ERROR.findall(text))
    for raw in text.splitlines():
        m = RE_DIAG.match(raw.strip())
        if not m:
            continue
        if m.group("sev") != "warning":
            errors += 1
            continue
        path = scope.get(os.path.realpath(m.group("file")))
        if path is None:
            continue
        for check in (m.group("checks") or "").split(","):
            check = check.strip()
            if tool == "clazy":
                if not check.startswith("-Wclazy-"):
                    continue
                check = check[len("-Wclazy-"):]
            elif not check or check.startswith("-W") or check.startswith("clang-diagnostic"):
                continue
            diags.append(Diag(path, int(m.group("line")), prefix + check,
                              m.group("msg")))
    return diags, errors


def run_one(tool: str, binary: str, db_dir: str, tu: str, checks: str,
            header_filter: str, tidy_config: str,
            timeout: int) -> tuple[str, str | None]:
    """Run one tool on one TU. Returns (output, failure reason or None)."""
    # GCC-built databases carry GCC-only warning flags, and -Werror would
    # turn those and every in-header warning into compiler errors that
    # fail the TU
    wno = ["--extra-arg=-Wno-unknown-warning-option", "--extra-arg=-Wno-error"]
    env = dict(os.environ)
    if tool == "clazy":
        # Release builds define QT_NO_DEBUG, which strips the SIGNAL()/SLOT()
        # location info that old-style-connect and connect-not-normalized
        # need; undefine it so they work on any build type.
        cmd = [binary, "-p", db_dir, f"-checks={checks}", *wno,
               "--extra-arg=-UQT_NO_DEBUG", tu]
        env["CLAZY_HEADER_FILTER"] = header_filter
    else:
        cmd = [binary, "-p", db_dir, f"--config-file={tidy_config}",
               "--quiet", f"--header-filter={header_filter}", *wno, tu]
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True,
                              errors="replace", env=env, timeout=timeout)
    except subprocess.TimeoutExpired:
        return "", f"timeout after {timeout}s"
    except OSError as e:
        return "", str(e)
    return proc.stdout + proc.stderr, None


def run_analysers(tools: dict[str, str | None], files: list[str],
                  explicit_db: str | None, bases: list[str], framework: bool,
                  tidy_config: str | None = None,
                  timeout: int = DEFAULT_TIMEOUT
                  ) -> tuple[list[Diag], list[str], dict[str, set[str]]]:
    """Run the requested analysers ({"clang-tidy": explicit path or "",
    "clazy": ...}, only the requested ones present) over `files`. Returns
    (diagnostics, status lines, coverage). Coverage maps each tool that
    ran to the files in `files` whose translation unit it analysed
    without a timeout or compiler error. `tidy_config` replaces the
    shipped clang-tidy configuration."""
    status: list[str] = []
    found: dict[str, str] = {}
    for tool, explicit in tools.items():
        binary = find_tool("clazy-standalone" if tool == "clazy" else tool,
                           explicit or None)
        if binary is None:
            status.append(f"{tool}: not available")
        else:
            found[tool] = binary
    if not found:
        return [], status, {}

    db = find_compile_db(explicit_db, bases)
    if db is None:
        return [], status + [f"{t}: skipped ({NO_DB_HINT})" for t in found], {}
    try:
        tus, missing, tu_of = select_tus(db, files)
    except (OSError, ValueError, KeyError) as e:
        return [], status + [f"{t}: failed (cannot read {db}: {e})"
                             for t in found], {}
    if not tus:
        return [], status + [
            f"{t}: skipped (no file in scope has a translation unit in {db})"
            for t in found], {}

    scope = {os.path.realpath(f): f for f in files}
    header_filter = "|".join(re.escape(p) for p in
                             {*scope, *(os.path.abspath(f) for f in files)})
    db_dir = os.path.dirname(db)
    checks = {"clazy": read_clazy_checks(framework)}
    jobs = [(tool, tu) for tool in found for tu in tus]
    with ThreadPoolExecutor(max_workers=os.cpu_count() or 4) as pool:
        results = list(pool.map(
            lambda job: run_one(job[0], found[job[0]], db_dir, job[1],
                                checks.get(job[0], ""), header_filter,
                                tidy_config or str(CLANG_TIDY_CONFIG), timeout),
            jobs))

    diags: dict[tuple[str, int, str, str], Diag] = {}
    failed = dict.fromkeys(found, 0)
    failed_tus: dict[str, set[str]] = {tool: set() for tool in found}
    reasons: dict[str, str] = {}
    for (tool, tu), (output, reason) in zip(jobs, results):
        parsed, errors = parse_diags(output, tool, scope)
        for d in parsed:
            diags.setdefault(tuple(d), d)
        if reason or errors:
            failed[tool] += 1
            failed_tus[tool].add(tu)
            reasons.setdefault(tool, reason or f"{errors} compiler error(s)")
    for tool, binary in found.items():
        detail = f"{binary}, {get_tool_version(binary)}, {len(tus)} TUs"
        if failed[tool]:
            detail += f", {failed[tool]} failed: {reasons[tool]}"
        status.append(f"{tool}: ran ({detail})")
    status.append(f"analysers: compile database {db}")
    covered = {tool: {f for f, tu in tu_of.items() if tu not in failed_tus[tool]}
               for tool in found}
    unanalysed = [f for f in files if any(f not in covered[t] for t in found)]
    if unanalysed:
        names = ", ".join(os.path.relpath(f) for f in unanalysed[:5])
        more = f" +{len(unanalysed) - 5} more" if len(unanalysed) > 5 else ""
        status.append(f"analysers: not analysed: {names}{more}")
    return list(diags.values()), status, covered
