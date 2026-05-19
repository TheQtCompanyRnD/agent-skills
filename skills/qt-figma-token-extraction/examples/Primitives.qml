// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
// Primitives.qml — [Project] Design System — Global Primitive Color Palette
// Source: design-tokens.json › colors
// CMake: set_source_files_properties(Primitives.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
// Usage: Primitives.neutrals.neutral_900
//        Primitives.accents.neon_500
pragma Singleton
import QtQuick

QtObject {
    // ── Neutrals ──────────────────────────────────────────────────────────────
    readonly property QtObject neutrals: QtObject {
        readonly property color neutral_100: "#f2f2f2"
        readonly property color neutral_150: "#e8e8e8"
        readonly property color neutral_200: "#d9d9d9"
        readonly property color neutral_250: "#cccccc"
        readonly property color neutral_350: "#b3b3b3"
        readonly property color neutral_450: "#8c8c8c"
        readonly property color neutral_550: "#737373"
        readonly property color neutral_600: "#666666"
        readonly property color neutral_650: "#595959"
        readonly property color neutral_700: "#4d4d4d"
        readonly property color neutral_750: "#404040"
        readonly property color neutral_800: "#333333"
        readonly property color neutral_850: "#262626"
        readonly property color neutral_900: "#1a1a1a"
    }

    // ── Accent — Neon ─────────────────────────────────────────────────────────
    readonly property QtObject accents: QtObject {
        readonly property color neon_500:  "#1f9b5d"
        readonly property color neon_700:  "#157a49"
        readonly property color neon_1000: "#0a3d24"

        // ── Accent — Yellow ───────────────────────────────────────────────────
        readonly property color yellow_400: "#F3E565"
        readonly property color yellow_600: "#c9bc3d"
        readonly property color yellow_900: "#5e5719"

        // ── Accent — Blue ─────────────────────────────────────────────────────
        readonly property color blue_400: "#4D9EF5"
        readonly property color blue_500: "#2d88f0"
        readonly property color blue_900: "#0d3566"

        // ── Accent — Red ──────────────────────────────────────────────────────
        readonly property color red_400:  "#F55C5C"
        readonly property color red_600:  "#d93030"
        readonly property color red_1000: "#4d0000"
    }
}
