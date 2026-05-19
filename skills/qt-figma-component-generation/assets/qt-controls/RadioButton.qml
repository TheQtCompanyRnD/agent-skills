// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T
import Qt.Fonts as Fonts

T.RadioButton {
    id: control

    property int typeVariant: RadioButtonStyle.TypeVariant.Subtle
    property int sizeVariant: RadioButtonStyle.SizeVariant.Base

    property RadioButtonStyle.Type _type: {
        switch (control.typeVariant) {
            case RadioButtonStyle.TypeVariant.Subtle: return RadioButtonStyle.subtle
            case RadioButtonStyle.TypeVariant.Highlight: return RadioButtonStyle.highlight

            default: return RadioButtonStyle.subtle
        }
    }

    property RadioButtonStyle.Size _size: {
        switch (control.sizeVariant) {
            case RadioButtonStyle.SizeVariant.Base: return RadioButtonStyle.base

            default: return RadioButtonStyle.base
        }
    }

    property RadioButtonStyle.StateStyle _style: {
        if (control.enabled  && !control.hovered)
            return control._type.idle
        else if (control.enabled  && control.hovered)
            return control._type.hover
        else if (!control.enabled)
            return control._type.disable

        return control._type.idle
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    padding: 0
    spacing: control._size.spacing

    indicator: Rectangle {
        implicitWidth: 16
        implicitHeight: 16

        x: control.text ? (control.mirrored ? control.width - width - control.rightPadding
                                            : control.leftPadding)
                        : control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2

        radius: width / 2
        color: control._style.background
        border {
            width: 1
            color: control._style.border
        }

        Rectangle {
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: 10
            height: 10
            radius: width / 2
            color: control._style.indicator
            visible: control.checked
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
}
