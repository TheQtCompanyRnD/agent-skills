// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T
import Qt.Fonts as Fonts

T.Switch {
    id: control

    // integration properties - used for controls embedded inside each other
    property bool hoverForward: false
    property bool activeForward: false
    property bool disableForward: false

    property int typeVariant: SwitchStyle.TypeVariant.Primary
    property int sizeVariant: SwitchStyle.SizeVariant.Base

    property SwitchStyle.Type _type: {
        switch (control.typeVariant) {
            case SwitchStyle.TypeVariant.Primary: return SwitchStyle.primary

            default: return SwitchStyle.primary
        }
    }

    property SwitchStyle.Size _size: {
        switch (control.sizeVariant) {
            case SwitchStyle.SizeVariant.Base: return SwitchStyle.base

            default: return SwitchStyle.base
        }
    }

    property SwitchStyle.StateStyle _style: {
        if (control.enabled && !control.pressed && !control.hovered)
            return control._type.idle
        else if (control.enabled && !control.pressed && control.hovered)
            return control._type.hover
        else if (control.enabled && control.pressed)
            return control._type.active
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

    readonly property int _gap: 2

    indicator: Rectangle {
        width: 32
        height: 16
        color: control.checked ? control._style.backgroundChecked : control._style.background
        border.width: 0
        radius: height / 2

        Rectangle {
            x: Math.max(control._gap,
                        Math.min(parent.width - width,
                                 control.visualPosition * parent.width - (width / 2)) - control._gap)
            y: (parent.height - height) / 2
            width: control.pressed ? height + 6 : height
            height: parent.height - (control._gap * 2)
            radius: height / 2
            color: control._style.indicator
            border.width: 0

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

    //do cursor changes over the control depending on state
    HoverHandler {
        id: cursorHandler
        //parent: control.parent
        //target: control
        cursorShape: {
            return Qt.PointingHandCursor

            //come back to this for mitch later
            // if (!control.enabled)
            //     return Qt.ForbiddenCursor
            // else
            //     return Qt.PointingHandCursor // never gets here?
        }
    }
}
