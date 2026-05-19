// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
// Checkbox.qml — reference implementation
// Maps to Figma: Qt Product Components → Checkbox
// States: unchecked | checked | indeterminate
// Sizes:  "small" | "medium" (default) | "large"
//
// Usage:
//   import DesignSystem
//   Checkbox { label: "Accept terms"; checked: true }
//   Checkbox { checkState: Qt.PartiallyChecked }   // indeterminate

import QtQuick
import QtQuick.Controls.Basic
import DesignSystem

CheckBox {
    id: root

    // ── Public API ────────────────────────────────────────────────────────────
    property string label:     text    // alias — set either `text` or `label`
    property string size:      "medium"
    property bool   error:     false   // error / invalid state highlight

    // Forward `label` to the base `text` property
    onLabelChanged: root.text = label

    // ── Geometry ──────────────────────────────────────────────────────────────
    readonly property bool _isSmall: size === "small" || size === "sm"
    readonly property bool _isLarge: size === "large" || size === "lg"

    // Box sizes — Figma-verified (component overview, 2026-04-14):
    //   Figma defines a single 16×16 checkbox. Small/Large are design-system extensions
    //   on the 4 px grid. Medium (default) MUST be 16×16 to match Figma spec.
    //   Previous medium=20 was incorrect — corrected via Figma MCP component overview.
    readonly property int _boxSize: _isSmall ? 12 : _isLarge ? 20 : 16
    readonly property int _radius:  Spacing.corner_radius   // 4 px — universal component radius
    readonly property int _fontSize: _isSmall ? Typography.caption_size
                                   : _isLarge ? Typography.body_01_size
                                   : Typography.body_02_size   // 12 px for medium — matches 16px box
    readonly property int _gap:     Spacing.gap_h_m   // 8 px

    spacing: _gap

    // ── Indicator (the box) ───────────────────────────────────────────────────
    indicator: Rectangle {
        id: _box
        width:  root._boxSize
        height: root._boxSize
        radius: root._radius
        anchors.verticalCenter: parent.verticalCenter

        // Border — Figma-verified (Checkbox, 2026-04-16):
        //   Unchecked: strokeSubtle (all interactive states — border does not change on hover)
        //   Checked/indeterminate: no separate border (accent fill covers it)
        //   Error: dangerDefault
        //   Disabled: strokeSubtle
        border.width: 1
        border.color: root.error                      ? Theme.notification_danger_default
                    : !root.enabled                   ? Theme.stroke_subtle
                    : root.checkState !== Qt.Unchecked ? "transparent"
                    :                                   Theme.stroke_subtle

        // Fill — Figma-verified state machine (Subtle/Default style, 2026-04-20):
        //   Checked and Unchecked share the same fill progression — only the border
        //   and check mark distinguish them visually.
        //   Unchecked default → foregroundSubtle   (was backgroundMuted — wrong)
        //   Unchecked hover   → foregroundMuted    (was foregroundSubtle — wrong)
        //   Unchecked pressed → foregroundDefault
        //   Checked default   → foregroundSubtle   (Subtle/Default style; Highlighted style uses accentDefault)
        //   Checked hover     → foregroundMuted
        //   Checked pressed   → foregroundDefault
        //   Indeterminate     → foregroundDefault
        //   Disabled          → backgroundMuted
        color: !root.enabled ? Theme.background_muted
             : root.checkState === Qt.PartiallyChecked ? Theme.foreground_default
             : root.checkState === Qt.Checked
                 ? (root.pressed ? Theme.foreground_default : root.hovered ? Theme.foreground_muted : Theme.foreground_subtle)
             : root.pressed  ? Theme.foreground_default
             : root.hovered  ? Theme.foreground_muted
             :                  Theme.foreground_subtle

        Behavior on color       { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }

        // Check mark (tick)
        Canvas {
            anchors.centerIn: parent
            width:  parent.width  * 0.6
            height: parent.height * 0.6
            visible: root.checkState === Qt.Checked

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                // Figma-verified (2026-04-20): check mark uses textDefault (light) on dark foregroundSubtle bg
                ctx.strokeStyle = Theme.text_default
                ctx.lineWidth   = Math.max(1.5, width * 0.15)
                ctx.lineCap     = "round"
                ctx.lineJoin    = "round"
                ctx.beginPath()
                ctx.moveTo(0,         height * 0.5)
                ctx.lineTo(width * 0.38, height)
                ctx.lineTo(width,     0)
                ctx.stroke()
            }

            // Repaint when theme or state changes
            Connections { target: Theme; ignoreUnknownSignals: true; function onActiveThemeChanged() { requestPaint() } }
            onVisibleChanged: if (visible) requestPaint()
            Component.onCompleted: requestPaint()
        }

        // Indeterminate dash
        Rectangle {
            anchors.centerIn: parent
            width:  parent.width  * 0.55
            height: Math.max(1.5, parent.height * 0.14)
            radius: height / 2
            // Figma-verified (2026-04-20): dash uses textDefault (light) on dark foregroundSubtle/foregroundDefault bg
            color:  root.enabled ? Theme.text_default : Theme.text_subtle
            visible: root.checkState === Qt.PartiallyChecked
        }

        // Focus ring
        Rectangle {
            anchors { fill: parent; margins: -3 }
            radius: parent.radius + 3
            color: "transparent"
            border.color: Theme.primary_default
            border.width: 2
            visible: root.visualFocus
        }
    }

    // ── Label text ────────────────────────────────────────────────────────────
    contentItem: Text {
        id: _lbl
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
