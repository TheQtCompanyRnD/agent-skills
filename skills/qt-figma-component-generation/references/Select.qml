// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
// Select.qml — reference implementation
// Maps to Figma: Qt Product Components → Select / Dropdown
// Sizes: "small" | "medium" (default) | "large"
//
// Usage:
//   import DesignSystem
//   Select {
//       label: "Country"
//       model: ["Australia", "Finland", "Germany"]
//       onCurrentIndexChanged: console.log(currentValue)
//   }

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import DesignSystem

Item {
    id: root

    // ── Public API ────────────────────────────────────────────────────────────
    property string       label:        ""
    property var          model:        []
    property int          currentIndex: -1
    property string       currentValue: currentIndex >= 0 ? model[currentIndex] : ""
    property string       placeholder:  "Select…"
    property string       size:         "medium"
    property bool         enabled:      true
    property string       errorMessage: ""

    // ── Geometry ──────────────────────────────────────────────────────────────
    readonly property bool _isSmall: size === "small" || size === "sm"
    readonly property bool _isLarge: size === "large" || size === "lg"

    readonly property int _height:  _isSmall ? Spacing.height_sm
                                  : _isLarge ? Spacing.height_lg
                                  : Spacing.height_md

    // Figma-verified: Inter/Label/M-Default (Medium 500, 12px) for all sizes of select text
    // Small control uses caption_size (10px) to match the smaller height
    readonly property int _fontSize:  _isSmall ? Typography.caption_size
                                    : Typography.label_m_size   // 12 px (medium + large)

    // Field label above the trigger: same spec as TextField — Inter/Label/M-Default 12px
    readonly property int _labelSize: Typography.label_m_size   // 12 px

    implicitWidth:  240
    implicitHeight: _col.implicitHeight

    // ── Layout ────────────────────────────────────────────────────────────────
    ColumnLayout {
        id: _col
        anchors { left: parent.left; right: parent.right }
        spacing: Spacing.gap_v_xs

        // Label row — Inter/Label/M-Default: Medium 500, 12 px (Figma-verified)
        Text {
            id: _lbl
            text:            root.label
            visible:         root.label.length > 0
            font.family:     Typography.body
            font.pixelSize:  root._labelSize                  // 12 px
            font.weight:     Typography.label_m_default_weight    // Medium 500
            color:           root.enabled ? Theme.text_default : Theme.text_subtle
            Layout.fillWidth: true
        }

        // Trigger button — Figma-verified: radius=4px, paddingH=8px, height=32px (medium)
        // Figma tokens (Combobox, 2026-04-16):
        //   Default: bg=backgroundMuted, border=strokeSubtle
        //   Hover:   bg=foregroundSubtle, border=strokeSubtle (border does NOT change on hover)
        //   Open:    border=accentDefault (UX focus indicator, not in Figma but kept for clarity)
        //   Disabled/error states follow standard pattern
        Rectangle {
            id: _trigger
            Layout.fillWidth: true
            height: root._height
            radius: Spacing.corner_radius   // 4 px — universal component radius

            color: !root.enabled ? Theme.background_muted
                 : _hovered.hovered ? Theme.foreground_subtle
                 :                    Theme.background_muted
            border.width: 1
            border.color: root.errorMessage.length > 0 ? Theme.notification_danger_default
                        : _popup.visible               ? Theme.primary_default
                        :                               Theme.stroke_subtle

            Behavior on border.color { ColorAnimation { duration: 100 } }

            HoverHandler { id: _hovered }

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin:  Spacing.x4   // 8 px — Figma: spacing/m (was 16 — incorrect)
                    rightMargin: Spacing.x4   // 8 px
                }
                spacing: Spacing.gap_h_m

                Text {
                    id: _valueText
                    Layout.fillWidth: true
                    text: root.currentIndex >= 0 ? root.currentValue : root.placeholder
                    font.family:    Typography.body
                    font.pixelSize: root._fontSize   // 12 px (M) — Inter/Label/M-Default
                    font.weight:    root.currentIndex >= 0
                                    ? Typography.label_m_active_weight    // SemiBold 600 — selected
                                    : Typography.label_m_default_weight   // Medium 500  — placeholder
                    color: root.currentIndex >= 0
                           ? (root.enabled ? Theme.text_default : Theme.text_subtle)
                           : Theme.text_subtle
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }

                // Chevron icon
                Text {
                    text:  _popup.visible ? "▲" : "▼"
                    font.family:    Typography.body
                    font.pixelSize: Typography.caption_size
                    color:          root.enabled ? Theme.text_muted : Theme.text_subtle
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
            }

            TapHandler {
                enabled: root.enabled
                onTapped: _popup.visible ? _popup.close() : _popup.open()
            }

            HoverHandler { cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor }

            // Focus ring
            Rectangle {
                anchors { fill: parent; margins: -3 }
                radius: parent.radius + 3
                color: "transparent"
                border.color: Theme.primary_default
                border.width: 2
                visible: root.activeFocus && !_popup.visible
            }
        }

        // Error message
        Text {
            id: _errText
            visible: root.errorMessage.length > 0
            text:    root.errorMessage
            font.family:    Typography.body
            font.pixelSize: Typography.caption_size
            color:          Theme.notification_danger_default
            Layout.fillWidth: true
        }
    }

    // ── Popup / dropdown ──────────────────────────────────────────────────────
    Popup {
        id: _popup
        y:     _trigger.y + _trigger.height + Spacing.gap_v_xs
        width: _trigger.width
        padding: 0
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color:        Theme.background_muted   // Figma: background/muted for popup bg
            radius:       Spacing.corner_radius   // 4 px — universal component radius
            border.color: Theme.stroke_subtle
            border.width: 1
            // Subtle shadow via stroke
            Rectangle {
                anchors { fill: parent; margins: -1 }
                radius: parent.radius + 1
                color: "transparent"
                border.color: Qt.rgba(0, 0, 0, 0.08)
                border.width: 1
                z: -1
            }
        }

        contentItem: ListView {
            id: _list
            model:       root.model
            clip:        true
            implicitHeight: Math.min(contentHeight, 220)

            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            delegate: Rectangle {
                id: _item
                width:  _list.width
                height: root._height
                color: _itemHovered.hovered ? Theme.background_muted
                     : root.currentIndex === index ? Theme.primary_muted
                     : "transparent"

                required property string modelData
                required property int    index

                Text {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left;  leftMargin: Spacing.x4   // 8 px
                        right: parent.right; rightMargin: Spacing.x4  // 8 px
                    }
                    text:           _item.modelData
                    font.family:    Typography.body
                    font.pixelSize: root._fontSize   // 12 px — Inter/Label/M-*
                    font.weight:    root.currentIndex === _item.index
                                    ? Typography.label_m_active_weight    // SemiBold 600 — selected
                                    : Typography.label_m_default_weight   // Medium 500  — default
                    color: root.currentIndex === _item.index
                           ? Theme.text_accent : Theme.text_default
                    elide: Text.ElideRight
                }

                HoverHandler { id: _itemHovered }
                TapHandler {
                    onTapped: {
                        root.currentIndex = _item.index
                        _popup.close()
                    }
                }
            }
        }
    }
}
