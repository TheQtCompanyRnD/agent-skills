// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T
import Qt.Fonts as Fonts

T.CheckBox {
    id: control

    property int typeVariant: CheckBoxStyle.TypeVariant.Subtle
    property int sizeVariant: CheckBoxStyle.SizeVariant.Large

    property CheckBoxStyle.Type _type: {
        switch (control.typeVariant) {
            case CheckBoxStyle.TypeVariant.Subtle: return CheckBoxStyle.subtle
            case CheckBoxStyle.TypeVariant.Highlight: return CheckBoxStyle.highlight

            default: return CheckBoxStyle.subtle
        }
    }

    property CheckBoxStyle.Size _size: {
        switch (control.sizeVariant) {
            case CheckBoxStyle.SizeVariant.Large: return CheckBoxStyle.large
            case CheckBoxStyle.SizeVariant.Small: return CheckBoxStyle.small

            default: return CheckBoxStyle.large
        }
    }

    property CheckBoxStyle.StateStyle _style: {
        if (control.enabled && !control.hovered)
            return control._type.idle
        else if (control.enabled && (control.pressed))
            return control._type.active
        else if (control.enabled && control.hovered)
            return control._type.hover
        else if (!control.enabled)
            return control._type.disable
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    padding: 0
    spacing: control._size.spacing

    indicator: Rectangle {
        implicitWidth: control._size.iconSize + control._size.horizontalPadding
        implicitHeight: control._size.iconSize + control._size.verticalPadding

        x: control.text ? (control.mirrored ? control.width - width - control.rightPadding
                                            : control.leftPadding)
                        : control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2

        color: control.checkState === Qt.Checked || control.checkState === Qt.PartiallyChecked
               ? control._style.backgroundChecked : control._style.background
        border {
            width: control._size.borderWidth
            color: control.checkState === Qt.Checked || control.checkState === Qt.PartiallyChecked
                   ? control._style.borderChecked  : control._style.border
        }
        radius: control._size.radius

        Text {
            id: checkedIcon
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            color: control._style.icon
            visible: control.checkState === Qt.Checked
            text: Fonts.FontInterface.icons.tickMark_16

            font {
                family: Fonts.FontInterface.iconFont.font.family
                pixelSize: control._size.iconSize
            }
        }

        Text {
            id: partiallyCheckedIcon
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            color: control._style.icon
            visible: control.checkState === Qt.PartiallyChecked
            text: Fonts.FontInterface.icons.minus_16

            font {
                family: Fonts.FontInterface.iconFont.font.family
                pixelSize: control._size.iconSize
            }
        }
    }

    contentItem: Text {
        text: control.text
        color: control._style.text

        lineHeightMode: Text.FixedHeight
        lineHeight: control._size.lineHeight

        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing

        font {
            family: Fonts.FontInterface.interFont.font.family
            pixelSize: control._size.fontSize
            variableAxes: {
                "wght": control._size.fontWeight
            }
        }
    }

    HoverHandler {
        id: cursorHandler
        cursorShape: Qt.PointingHandCursor
    }
}
