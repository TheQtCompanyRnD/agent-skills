// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
// Test file for framework-only rules (--framework flag required)

// CND-2: __has_include for non-Qt header (framework only)
#if __has_include(<format>)
#endif

// PAT-6: make_unique for array (framework only)
auto arr = std::make_unique<int[]>(100);
