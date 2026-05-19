// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
// Toggle.qml — reference implementation
// Maps to Figma: Qt Product Components → Toggle Switch
// Sizes:  "small" | "medium" (default) | "large"
//
// Usage:
//   import DesignSystem
//   Toggle { label: "Dark mode"; checked: true }
//   Toggle { size: "small"; onToggled: console.log(checked) }

import QtQuick
import QtQuick.Controls.Basic
import DesignSystem

Switch {
    id: root

    // ── Public API ────────────────────────────────────────────────────────────
    property string label: text
    property string size:  "medium"

    onLabelChanged: root.text = label

    // ── Geometry ──────────────────────────────────────────────────────────────
    readonly property bool _isSmall: size === "small" || size === "sm"
    readonly property bool _isLarge: size === "large" || size === "lg"

    // Track dimensions — Figma-verified (component overview, 2026-04-14):
    //   Medium = 32×16 (Figma component overview shows single 32×16 instance)
    //   Small / Large are design-system extensions matching the same proportions.
    readonly property int _trackW: _isSmall ? 24 : _isLarge ? 44 : 32
    readonly property int _trackH: _isSmall ? 14 : _isLarge ? 24 : 16
    readonly property int _thumbD: _trackH - 4          // 2 px inset all sides
    readonly property int _gap:    Spacing.gap_h_m        // 8 px label gap

    readonly property int _fontSize: _isSmall ? Typography.caption_size
                                   : _isLarge ? Typography.body_01_size
                                   : Typography.body_01_size

    spacing: _gap

    // ── Track ─────────────────────────────────────────────────────────────────
    indicator: Rectangle {
        id: _track
        width:  root._trackW
        height: root._trackH
        radius: height / 2
        anchors.verticalCenter: parent.verticalCenter

        // Figma-verified (Toggle, 2026-04-16):
        //   Unchecked default → foregroundMuted
        //   Unchecked hover   → strokeSubtle  (was strokeMuted — corrected)
        //   Checked default   → accentDefault
        //   Disabled          → foregroundSubtle
        color: !root.enabled  ? Theme.foreground_subtle
             : root.checked   ? (_trackHover.hovered ? Qt.lighter(Theme.primary_default, 1.08) : Theme.primary_default)
             :                  (_trackHover.hovered ? Theme.stroke_subtle : Theme.foreground_muted)

        border.color: root.visualFocus ? Theme.primary_default : "transparent"
        border.width: root.visualFocus ? 2 : 0

        HoverHandler { id: _trackHover; enabled: root.enabled }

        Behavior on color { ColorAnimation { duration: 150 } }

        // Thumb
        Rectangle {
            id: _thumb
            width:  root._thumbD
            height: root._thumbD
            radius: height / 2
            color:  root.enabled ? Theme.text_on_accent : Theme.text_subtle

            // Horizontal travel: from left-inset to right-inset
            x: root.checked
               ? _track.width  - width  - 2
               :                          2
            anchors.verticalCenter: parent.verticalCenter

            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
        }

        // Focus ring outside the track
        Rectangle {
            anchors { fill: parent; margins: -3 }
            radius: parent.radius + 3
            color: "transparent"
            border.color: Theme.primary_default
            border.width: 2
            visible: root.visualFocus
        }
    }

    // ── Label ─────────────────────────────────────────────────────────────────
    contentItem: Text {
        leftPadding: root.indicator.width + root.spacing
        text:  root.text
        font.family:    Typography.body
        font.pixelSize: root._fontSize
        font.weight:    Typography.regular
        color: root.enabled ? Theme.text_default : Theme.text_subtle
        verticalAlignment: Text.AlignVCenter
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    HoverHandler { cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor }
}
