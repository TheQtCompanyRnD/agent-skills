// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
// Theme.qml — [Project] Design System — Semantic Color Tokens
// Source: design-tokens.json › semanticColors
// CMake: set_source_files_properties(Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
// Usage: Theme.background_default
//        Theme.text_muted
//        Theme.notification_alert_default
//
// Note: Default values apply the dark theme.
//       To switch themes at runtime, replace the singleton instance
//       or bind property values to a theme state in your app root.
pragma Singleton
import QtQuick

QtObject {
    // ── Base ──────────────────────────────────────────────────────────────────
    readonly property color base_black:    Primitives.neutrals.neutral_900
    readonly property color base_white:    Primitives.neutrals.neutral_100
    readonly property color base_inverted: Primitives.neutrals.neutral_900

    // ── Primary / Accent ──────────────────────────────────────────────────────
    readonly property color primary_default: Primitives.neutrals.neutral_150
    readonly property color primary_muted:   Primitives.neutrals.neutral_250
    readonly property color primary_subtle:  Primitives.neutrals.neutral_350

    // ── Background ────────────────────────────────────────────────────────────
    readonly property color background_default: Primitives.neutrals.neutral_850
    readonly property color background_muted:   Primitives.neutrals.neutral_800
    readonly property color background_subtle:  Primitives.neutrals.neutral_750

    // ── Foreground ────────────────────────────────────────────────────────────
    readonly property color foreground_default: Primitives.neutrals.neutral_600
    readonly property color foreground_muted:   Primitives.neutrals.neutral_650
    readonly property color foreground_subtle:  Primitives.neutrals.neutral_700

    // ── Text / Icon ───────────────────────────────────────────────────────────
    readonly property color text_default:   Primitives.neutrals.neutral_150
    readonly property color text_muted:     Primitives.neutrals.neutral_350
    readonly property color text_subtle:    Primitives.neutrals.neutral_550
    readonly property color text_accent:    Primitives.neutrals.neutral_100
    readonly property color text_on_accent: Primitives.neutrals.neutral_900

    // ── Stroke ────────────────────────────────────────────────────────────────
    readonly property color stroke_strong: Primitives.neutrals.neutral_200
    readonly property color stroke_muted:  Primitives.neutrals.neutral_450
    readonly property color stroke_subtle: Primitives.neutrals.neutral_650

    // ── Notification — Alert ──────────────────────────────────────────────────
    readonly property color notification_alert_default: Primitives.accents.yellow_400
    readonly property color notification_alert_muted:   Primitives.accents.yellow_600
    readonly property color notification_alert_subtle:  Primitives.accents.yellow_900

    // ── Notification — Info ───────────────────────────────────────────────────
    readonly property color notification_info_default: Primitives.accents.blue_400
    readonly property color notification_info_muted:   Primitives.accents.blue_500
    readonly property color notification_info_subtle:  Primitives.accents.blue_900

    // ── Notification — Danger ─────────────────────────────────────────────────
    readonly property color notification_danger_default: Primitives.accents.red_400
    readonly property color notification_danger_muted:   Primitives.accents.red_600
    readonly property color notification_danger_subtle:  Primitives.accents.red_1000

    // ── Notification — Success ────────────────────────────────────────────────
    readonly property color notification_success_default: Primitives.accents.neon_500
    readonly property color notification_success_muted:   Primitives.accents.neon_700
    readonly property color notification_success_subtle:  Primitives.accents.neon_1000
}
