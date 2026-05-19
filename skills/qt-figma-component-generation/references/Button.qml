// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
// Button.qml — reference implementation
// Maps to Figma: Qt Product Components → Button (node 67:139)
// Figma file: Qt-Product-Components · node-id=5825-147
//
// Figma variants (Figma MCP component set, 2026-04-14):
//   Types:  "primary" | "secondary" | "tertiary" | "ghost"
//   States: Default | Hover | Pressed | Disabled  (Focus is a visual overlay, not a variant)
//   Sizes:  "small" | "medium" | "large"  (aliases: "sm" | "md" | "lg")
//
// Design-system extensions (not in Figma):
//   "danger" variant — same fill logic as Primary, uses dangerDefault accent family
//   `color` prop — tints Primary/Danger with alert/info/success accent families
//
// Figma-verified dimensions (MCP individual component inspection, 2026-04-15):
//   Large:  height=40, outerPaddingH=16, innerLabelPaddingH=4, total=20, paddingV=12, radius=4, font=14px SemiBold600, gap=8
//   Medium: height=32, outerPaddingH=12, innerLabelPaddingH=4, total=16, paddingV=8,  radius=4, font=12px Bold700,     gap=4
//   Small:  height=24, outerPaddingH=8,  innerLabelPaddingH=4, total=12, paddingV=6,  radius=4, font=10px Bold700,     gap=0
//   Note: Figma wraps the label text in an inner container with px-[var(--xxs/h-padding,4px)].
//         QML combines outer + inner into leftPadding/rightPadding on the Text item.
//
// Usage:
//   import DesignSystem
//   Button { label: "Save";   variant: "primary"; onClicked: doSave() }
//   Button { label: "Cancel"; variant: "ghost";   size: "small" }

import QtQuick
import QtQuick.Controls.Basic
import DesignSystem

AbstractButton {
    id: root

    // ── Public API ────────────────────────────────────────────────────────────
    property string label:   "Button"
    property string variant: "primary"    // primary | secondary | ghost | tertiary | danger
    property string size:    "medium"     // small | medium | large  (sm | md | lg accepted)
    property string color:   "neutral"    // neutral | alert | danger | info | success

    // ── Size helpers ──────────────────────────────────────────────────────────
    readonly property bool _isSmall: size === "small" || size === "sm"
    readonly property bool _isLarge: size === "large" || size === "lg"

    // ── Geometry — Figma-verified per size ────────────────────────────────────
    readonly property int _height:   _isSmall ? Spacing.button_height_sm
                                   : _isLarge ? Spacing.button_height_lg
                                   : Spacing.button_height_md          // 24 | 40 | 32

    readonly property int _paddingH: _isSmall ? Spacing.button_padding_h_sm
                                   : _isLarge ? Spacing.button_padding_h_lg
                                   : Spacing.button_padding_h_md        // 8 | 16 | 12

    readonly property int _paddingV: _isSmall ? Spacing.button_padding_v_sm
                                   : _isLarge ? Spacing.button_padding_v_lg
                                   : Spacing.button_padding_v_md        // 6 | 12 | 8

    readonly property int _iconGap:  _isSmall ? Spacing.button_icon_gap_sm
                                   : _isLarge ? Spacing.button_icon_gap_lg
                                   : Spacing.button_icon_gap_md         // 0 | 8 | 4

    // ── Typography — Figma-verified per size ──────────────────────────────────
    // Large  → Inter/Section-headings/H5: SemiBold 600, 14 px
    // Medium → Inter/Button/Medium:       Bold 700,     12 px
    // Small  → Inter/Button/Small:        Bold 700,     10 px
    readonly property int _fontSize: _isSmall ? Typography.button_label_small_size
                                   : _isLarge ? Typography.button_label_large_size
                                   : Typography.button_label_medium_size

    readonly property int _fontWeight: _isSmall ? Typography.button_label_small_weight
                                     : _isLarge ? Typography.button_label_large_weight
                                     : Typography.button_label_medium_weight

    // ── Accent family — Primary and Danger only ───────────────────────────────
    // Figma-verified: ONLY Primary uses accent/notification colors for its fill.
    // Secondary, Tertiary, Ghost all use neutral foreground/* tokens.
    // The `color` prop only affects Primary/Danger fills.
    readonly property color _accentDefault: ({
        "neutral": Theme.primary_default,
        "alert":   Theme.notification_alert_default,
        "danger":  Theme.notification_danger_default,
        "info":    Theme.notification_info_default,
        "success": Theme.notification_success_default
    })[color] ?? Theme.primary_default

    readonly property color _accentMuted: ({
        "neutral": Theme.primary_muted,
        "alert":   Theme.notification_alert_muted,
        "danger":  Theme.notification_danger_muted,
        "info":    Theme.notification_info_muted,
        "success": Theme.notification_success_muted
    })[color] ?? Theme.primary_muted

    readonly property color _accentSubtle: ({
        "neutral": Theme.primary_subtle,
        "alert":   Theme.notification_alert_subtle,
        "danger":  Theme.notification_danger_subtle,
        "info":    Theme.notification_info_subtle,
        "success": Theme.notification_success_subtle
    })[color] ?? Theme.primary_subtle

    // ── Background — Figma-verified state machine (component set, 2026-04-14) ─
    //
    // Primary / Danger (filled accent):
    //   Default → accentDefault   Hover → accentMuted   Pressed → accentSubtle
    //   Disabled → foregroundSubtle
    //
    // Secondary (subtle container + stroke):
    //   Default → backgroundMuted   Hover → foregroundSubtle   Pressed → foregroundMuted
    //   Disabled → backgroundMuted
    //
    // Tertiary (always has a visible fill — NOT transparent by default):
    //   Default → foregroundSubtle   Hover → foregroundMuted   Pressed → foregroundDefault
    //   Disabled → foregroundSubtle
    //
    // Ghost (transparent default, foreground on interaction):
    //   Default → transparent   Hover → foregroundSubtle   Pressed → foregroundMuted
    //   Disabled → transparent
    readonly property color _bg: {
        if (variant === "primary" || variant === "danger") {
            if (!enabled) return Theme.foreground_subtle
            return pressed ? _accentSubtle
                 : hovered ? _accentMuted
                 :            _accentDefault
        }
        if (variant === "secondary") {
            if (!enabled) return Theme.background_muted
            return pressed ? Theme.foreground_muted
                 : hovered ? Theme.foreground_subtle
                 :            Theme.background_muted
        }
        if (variant === "tertiary") {
            if (!enabled) return Theme.foreground_subtle
            return pressed ? Theme.foreground_default
                 : hovered ? Theme.foreground_muted
                 :            Theme.foreground_subtle
        }
        // ghost
        if (!enabled) return "transparent"
        return pressed ? Theme.foreground_muted
             : hovered ? Theme.foreground_subtle
             :            "transparent"
    }

    // ── Foreground / label — Figma-verified ───────────────────────────────────
    // Primary/Danger: textOnAccent (high-contrast label on filled accent bg)
    // Secondary / Tertiary / Ghost: textDefault (neutral — NOT accent-colored)
    // All disabled: textSubtle
    readonly property color _fg: {
        if (!enabled) return Theme.text_subtle
        if (variant === "primary" || variant === "danger") return Theme.text_on_accent
        return Theme.text_default
    }

    // ── Border ────────────────────────────────────────────────────────────────
    // Only Secondary has a visible border.
    // Figma: strokeSubtle in ALL states (default, hover, pressed, disabled).
    // NOT accent-colored — the backgroundMuted fill differentiates it from Ghost.
    readonly property color _borderColor: variant === "secondary" ? Theme.stroke_subtle : "transparent"
    readonly property int   _borderWidth: variant === "secondary" ? 1 : 0

    // ── Geometry — fully self-managed, no inherited Control padding ──────────
    // AbstractButton (via Control) has default topPadding/bottomPadding that can
    // inflate the rendered height beyond _height. Zero them all out explicitly so
    // our background + contentItem fill exactly the intended pixel dimensions.
    // Horizontal padding is handled inside the contentItem Text via leftPadding/rightPadding.
    topPadding:    0
    bottomPadding: 0
    leftPadding:   0
    rightPadding:  0

    // NOTE: _label.implicitWidth already includes leftPadding + rightPadding
    // (Qt Text.implicitWidth = contentWidth + leftPadding + rightPadding).
    implicitWidth:  _label.implicitWidth
    implicitHeight: _height

    // ── Background rectangle ──────────────────────────────────────────────────
    background: Rectangle {
        color:        root._bg
        radius:       Spacing.button_radius     // 4 px — Figma verified
        border.color: root._borderColor
        border.width: root._borderWidth
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    // ── Label ─────────────────────────────────────────────────────────────────
    // Figma structure: button outer px = _paddingH, PLUS an inner label container
    // with px-[var(--xxs/h-padding, 4px)] around the text. Combined per side:
    //   Large:  16 + 4 = 20 px   Medium: 12 + 4 = 16 px   Small: 8 + 4 = 12 px
    contentItem: Text {
        id: _label
        text:                root.label
        font.family:         Typography.body
        font.pixelSize:      root._fontSize
        font.weight:         root._fontWeight
        color:               root._fg
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment:   Text.AlignVCenter
        leftPadding:         root._paddingH + Spacing.x2   // outer + xxs/h-padding (4 px)
        rightPadding:        root._paddingH + Spacing.x2
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    // ── Focus ring ────────────────────────────────────────────────────────────
    Rectangle {
        anchors { fill: parent; margins: -3 }
        radius:       Spacing.button_radius + 3
        color:        "transparent"
        border.color: Theme.primary_default
        border.width: 2
        visible:      root.visualFocus
    }

    HoverHandler { cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor }
}
