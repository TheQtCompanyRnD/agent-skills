// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
// Spacing.qml — [Project] Design System — Spacing & Shape Tokens
// Source: design-tokens.json › spacing, radii
// CMake: set_source_files_properties(Spacing.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
// Usage:
//   padding:        Spacing.x4        // 8 px
//   radius:         Spacing.radius_m
pragma Singleton
import QtQuick

QtObject {
    // ── Base spacing scale ────────────────────────────────────────────────────
    readonly property int x1: 2
    readonly property int x2: 4
    readonly property int x3: 6
    readonly property int x4: 8
    readonly property int x6: 12
    readonly property int x8: 16
    readonly property int x10: 20
    readonly property int x12: 24
    readonly property int x16: 32
    readonly property int x20: 40
    readonly property int x24: 48

    // ── Corner radii ──────────────────────────────────────────────────────────
    readonly property int radius_s:    4
    readonly property int radius_m:    8
    readonly property int radius_l:    12
    readonly property int radius_xl:   16
    readonly property int radius_full: 9999

    // ── Semantic radius aliases ───────────────────────────────────────────────
    readonly property int corner_radius: radius_s   // 4 px — universal component radius
    readonly property int button_radius: radius_s   // 4 px

    // ── Gap aliases ───────────────────────────────────────────────────────────
    readonly property int gap_h_xs: x2   //  4 px — horizontal gap / xs
    readonly property int gap_h_m:  x4   //  8 px — horizontal gap / m
    readonly property int gap_v_xs: x2   //  4 px — vertical gap / xs

    // ── Component height scale ────────────────────────────────────────────────
    readonly property int height_sm: x12  // 24 px — small control height
    readonly property int height_md: x16  // 32 px — medium control height
    readonly property int height_lg: x20  // 40 px — large control height

    // ── Button tokens — Figma-verified ───────────────────────────────────────
    readonly property int button_height_sm:    x12   // 24 px
    readonly property int button_height_md:    x16   // 32 px
    readonly property int button_height_lg:    x20   // 40 px

    readonly property int button_padding_h_sm:  x4    //  8 px
    readonly property int button_padding_h_md:  x6    // 12 px
    readonly property int button_padding_h_lg:  x8    // 16 px

    readonly property int button_padding_v_sm:  x3    //  6 px
    readonly property int button_padding_v_md:  x4    //  8 px
    readonly property int button_padding_v_lg:  x6    // 12 px

    readonly property int button_icon_gap_sm:   0
    readonly property int button_icon_gap_md:   x2    //  4 px
    readonly property int button_icon_gap_lg:   x4    //  8 px
}
