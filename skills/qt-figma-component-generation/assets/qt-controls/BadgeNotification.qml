// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick

import Qt.Fonts as Fonts

Rectangle {
    id: control

    property int value: 0

    property int typeVariant: BadgeNotificationStyle.TypeVariant.Info
    property int sizeVariant: BadgeNotificationStyle.SizeVariant.Numeric
    property int appearanceVariant: BadgeNotificationStyle.AppearanceVariant.Filled

    property BadgeNotificationStyle.Type _type: {
        switch (control.typeVariant) {
            case BadgeNotificationStyle.TypeVariant.Neutral: return BadgeNotificationStyle.neutral
            case BadgeNotificationStyle.TypeVariant.Info: return BadgeNotificationStyle.info
            case BadgeNotificationStyle.TypeVariant.Alert: return BadgeNotificationStyle.alert
            case BadgeNotificationStyle.TypeVariant.Success: return BadgeNotificationStyle.success
            case BadgeNotificationStyle.TypeVariant.Danger: return BadgeNotificationStyle.danger

            default: return BadgeNotificationStyle.neutral
        }
    }

    property BadgeNotificationStyle.Size _size: {
        switch (control.sizeVariant) {
            case BadgeNotificationStyle.SizeVariant.Dot: return BadgeNotificationStyle.dot
            case BadgeNotificationStyle.SizeVariant.Numeric: return BadgeNotificationStyle.numeric

            default: return BadgeNotificationStyle.numeric
        }
    }

    property bool _outline: control.appearanceVariant === BadgeNotificationStyle.AppearanceVariant.Outline

    implicitWidth: {
        if (control.sizeVariant === BadgeNotificationStyle.SizeVariant.Dot)
            return (control._size.horizontalPadding * 2)

        return Math.max(label.width + (control._size.horizontalPadding * 2) + 1,
                        8 + (control._size.horizontalPadding * 2))
    }
    implicitHeight: control._size.lineHeight + (control._size.verticalPadding * 2)

    color: control._outline ? "transparent" : control._type.background
    radius: control._size.radius

    border {
        width: control._outline ? control._size.borderWidth : 0
        color: control._type.border
    }

    Text {
        id: label
        text: control.formatNumberCompact(control.value)

        anchors.centerIn: parent

        visible: control.sizeVariant === BadgeNotificationStyle.SizeVariant.Numeric
        color: control._type.label
        lineHeight: control._size.lineHeight
        height: control._size.lineHeight

        font {
            family: Fonts.FontInterface.interFont.font.family
            pixelSize: control._size.fontSize
            variableAxes: {
                "wght": control._size.fontWeight
            }
        }
    }

    function formatNumberCompact(num, maxLen = 4) {
        const sign = num < 0 ? "-" : ""
        const abs = Math.abs(num)

        // Try to format a value with optional 1 decimal,
        // but never allow rounding across unit boundaries.
        function fitWithSuffix(value, suffix) {
            const intValue = Math.floor(value)     // prevent 999.9 -> 1000
            const intStr = `${sign}${intValue}${suffix}`
            if (intStr.length <= maxLen) return intStr

            // Try one decimal (but clamp so it never rounds up across the unit)
            let oneDecVal = Math.floor(value * 10) / 10 // e.g. 999.9 -> 999.9, but 999.99 -> 999.9
            const oneDecStr = `${sign}${oneDecVal.toFixed(1)}${suffix}`
            if (oneDecStr.length <= maxLen) return oneDecStr

            return intStr.slice(0, maxLen)
        }

        // 0–999 -> exact value
        if (abs < 1000) {
            const s = `${sign}${abs}`
            return s.length <= maxLen ? s : s.slice(0, maxLen)
        }

        // Thousands
        if (abs < 1000000) {
            return fitWithSuffix(abs / 1000, "k")
        }

        // Millions
        return fitWithSuffix(abs / 1000000, "m")
    }

}
