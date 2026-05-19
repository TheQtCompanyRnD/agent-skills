// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
// FontInterface.qml — [Project] Design System — Font Loaders & Icon Index
// Source: design-tokens.json › typography + icon font file
// CMake: set_source_files_properties(FontInterface.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
// Usage:
//   font.family:    FontInterface.interFont.name
//   font.family:    FontInterface.titilliumSemiBold.name
//   text:           FontInterface.icons.close_16
pragma Singleton
import QtQuick

QtObject {
    // ── Font loaders ──────────────────────────────────────────────────────────
    // Each font file must be present in the fonts/ folder alongside this file.
    // Qt resolves the path relative to this QML file at runtime.

    component InterFont: FontLoader {
        source: Qt.resolvedUrl("InterVariableFont.ttf")
    }
    property InterFont interFont: InterFont {}

    component TitilliumSB: FontLoader {
        source: Qt.resolvedUrl("TitilliumWeb-SemiBold.ttf")
    }
    property TitilliumSB titilliumSemiBold: TitilliumSB {}

    component Inconsolata: FontLoader {
        source: Qt.resolvedUrl("Inconsolata-VariableFont_wdth,wght.ttf")
    }
    property Inconsolata inconsolata: Inconsolata {}

    // ── Icon font ─────────────────────────────────────────────────────────────
    component IconFont: FontLoader {
        source: Qt.resolvedUrl("ControlIconFont.ttf")
    }
    property IconFont iconFont: IconFont {}

    // ── Icon index ────────────────────────────────────────────────────────────
    // Unicode character mappings for the icon font.
    // Each property name matches the icon name in Figma.
    // Usage: text: FontInterface.icons.close_16
    //        font.family: FontInterface.iconFont.name
    component Icons: QtObject {
        readonly property string add_16:            "!"
        readonly property string add_fill_16:       "\""
        readonly property string alert_16:          "$"
        readonly property string alert_fill_16:     "%"
        readonly property string close_16:          "M"
        readonly property string close_fill_16:     "P"
        readonly property string delete_16:         "h"
        readonly property string delete_fill_16:    "i"
        readonly property string edit_16:           "r"
        readonly property string edit_fill_16:      "u"
        readonly property string search_16:         "â"
        readonly property string search_fill_16:    "ã"
        readonly property string settings_16:       "ë"
        readonly property string settings_fill_16:  "ì"
        readonly property string warning_16:        "Ę"
        readonly property string warning_fill_16:   "ę"
        // ... add all icons from the icon font mapping
    }
    property Icons icons: Icons {}
}
