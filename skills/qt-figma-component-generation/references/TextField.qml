// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
// TextField.qml — reference implementation
// Maps to Figma: Qt Product Components → Text Field / Input
// States: Default | Hover | Active (focus) | Disabled | Error
//
// Usage:
//   import DesignSystem
//   TextField { label: "Email"; placeholder: "you@qt.io" }
//   TextField { label: "API Key"; echoMode: TextInput.Password }
//   TextField { label: "Name"; errorMessage: "This field is required" }

import QtQuick
import QtQuick.Layouts
import DesignSystem

ColumnLayout {
    id: root

    // ── Public API ────────────────────────────────────────────────────────────
    property string label:        ""
    property string placeholder:  ""
    property alias  text:         textInput.text
    property string errorMessage: ""
    property string helperText:   ""
    property int    echoMode:     TextInput.Normal
    property bool   readOnly:     false
    property string size:         "medium"    // small | medium | large

    signal accepted()
    signal editingFinished()
    // textChanged is auto-emitted by the `text` property — no manual declaration needed

    // ── Sizing — Figma verified (component overview, 2026-04-14) ─────────────
    // Input shell heights: Small=24, Medium=32, Large=40 (same scale as buttons)
    // PaddingH: 8px (spacing/m) — same across all sizes
    // PaddingV: 6px (spacing/s) — implicit from fixed height
    // Radius: 4px (corner_radius — universal component radius, not corner_radiusL=12)
    // Label font: Inter/Label/M-Default — Medium 500, 12 px
    // Label→shell gap: 8px (spacing/m); shell→caption gap: 4px (spacing/xs)
    readonly property bool _isSmall: size === "small" || size === "sm"
    readonly property bool _isLarge: size === "large" || size === "lg"
    readonly property int  _height:  _isSmall ? Spacing.height_sm : _isLarge ? Spacing.height_lg : Spacing.height_md
    readonly property int  _hPad:    Spacing.x4   // 8 px (spacing/m) — uniform across sizes

    // ── Layout ────────────────────────────────────────────────────────────────
    // Label-to-input gap: spacing/m = 8px (Figma: gap-[var(--spacing/m,8px)] in Container)
    // Input-to-caption gap: spacing/xs = 4px (Figma: outer column gap-xs)
    spacing: Spacing.gap_v_xs   // 4 px — between compound sections (input→caption)

    // ── Field label ───────────────────────────────────────────────────────────
    // Figma: Inter/Label/M-Default — Medium 500, 12 px, lineHeight 16
    Text {
        text: root.label
        font.family: Typography.body
        font.pixelSize: Typography.label_m_size          // 12 px
        font.weight: Typography.label_m_default_weight    // Medium 500
        color: root.enabled ? Theme.text_default : Theme.text_subtle
        visible: root.label.length > 0
    }

    // ── Input shell ───────────────────────────────────────────────────────────
    Rectangle {
        id: shell
        Layout.fillWidth: true
        Layout.topMargin: Spacing.gap_v_xs   // extra 4 px → total label-to-shell gap = 8 px (Figma: spacing/m)
        height: root._height
        radius: Spacing.corner_radius       // 4 px — universal component radius (Figma: rounded-[4px])
        // Figma-verified (TextField, 2026-04-20): disabled uses same backgroundMuted as default
        color: Theme.background_muted

        border.width: 1
        border.color: {
            if (!root.enabled)              return Theme.stroke_subtle
            if (root.errorMessage.length)   return Theme.notification_danger_default
            if (textInput.activeFocus)      return Theme.stroke_strong    // Figma: --stroke/strong (NOT accentDefault)
            if (hoverHandler.hovered)       return Theme.stroke_muted     // Figma: --stroke/muted on hover
            return Theme.stroke_subtle
        }

        Behavior on border.color { ColorAnimation { duration: 100 } }

        TextInput {
            id: textInput
            anchors {
                left: parent.left;  leftMargin: root._hPad
                right: clearBtn.visible ? clearBtn.left : parent.right
                rightMargin: Spacing.gap_h_xs
                verticalCenter: parent.verticalCenter
            }

            echoMode:   root.echoMode
            readOnly:   root.readOnly || !root.enabled
            enabled:    root.enabled
            clip:       true

            // Figma-verified (TextField, 2026-04-16): input text uses Inter/Label/M-Default = 12px (was body_01_size 14px)
            font.family:    Typography.body
            font.pixelSize: Typography.label_m_size     // 12 px (was body_01_size 14px)
            color:          root.enabled ? Theme.text_default : Theme.text_subtle
            selectionColor: Theme.primary_default
            selectedTextColor: Theme.text_on_accent

            // Placeholder text
            Text {
                anchors.fill: parent
                text: root.placeholder
                font: parent.font
                // Figma-verified (TextField error state, 2026-04-20): placeholder uses dangerDefault in error state
                color: root.errorMessage.length > 0 ? Theme.notification_danger_default : Theme.text_subtle
                visible: parent.text.length === 0 && !parent.activeFocus
                elide: Text.ElideRight
            }

            onAccepted:    root.accepted()
            onEditingFinished: root.editingFinished()
        }

        // Clear (×) button — only for plain text inputs
        Rectangle {
            id: clearBtn
            anchors { right: parent.right; rightMargin: Spacing.gap_h_xs; verticalCenter: parent.verticalCenter }
            width: 20; height: 20; radius: 10
            color: clearHover.hovered ? Theme.foreground_default : "transparent"
            visible: textInput.text.length > 0 && root.enabled
                     && root.echoMode === TextInput.Normal

            Text {
                anchors.centerIn: parent
                text: "×"
                font.pixelSize: Typography.body_01_size
                color: Theme.text_muted
            }

            HoverHandler  { id: clearHover }
            TapHandler    { onTapped: { textInput.clear(); root.textChanged("") } }
        }

        HoverHandler { id: hoverHandler }
    }

    // ── Helper / error text ───────────────────────────────────────────────────
    Text {
        text: root.errorMessage.length ? root.errorMessage : root.helperText
        font.family:    Typography.body
        font.pixelSize: Typography.caption_size
        color: root.errorMessage.length ? Theme.notification_danger_default : Theme.text_muted
        visible: text.length > 0
    }
}
