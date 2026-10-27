#!/usr/bin/env python3
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
"""
Stand-in for clang-tidy and clazy-standalone in run_tests.py.

Usage: fake_analyser.py (clang-tidy|clazy) <analyser arguments...> <tu>

Prints canned diagnostics for the translation unit named by the last
argument: warnings on lines 3 and 4, a warning in a Qt header, and a
compiler error, except for a translation unit whose name contains
"_ok", which compiles cleanly.
"""

import sys

tool, tu = sys.argv[1], sys.argv[-1]
if tool == "clazy":
    check, error_check = "[-Wclazy-old-style-connect]", ""
else:
    check, error_check = "[bugprone-use-after-move]", " [clang-diagnostic-error]"

print(f"{tu}:3:5: warning: stub finding {check}")
print(f"{tu}:4:5: warning: stub finding on an unchanged line {check}")
print(f"/usr/include/qt6/QtCore/qobject.h:10:1: warning: header noise {check}")
if "_ok" not in tu:
    print(f"{tu}:7:1: error: stub compile failure{error_check}")
