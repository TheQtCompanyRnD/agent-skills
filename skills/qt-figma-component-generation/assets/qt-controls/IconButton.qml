// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T
import Qt.Fonts as Fonts

T.AbstractButton {
    id: control

    // test signal for state forwarding
    signal check() // TODO

    property alias iconFontFamily: buttonIcon.font.family
    property alias iconRotation: buttonIcon.rotation
    property alias iconGlyph: buttonIcon.text

    property int appearanceVariant: IconButtonStyle.AppearanceVariant.Default
    property int typeVariant: IconButtonStyle.TypeVariant.Subtle
    property int sizeVariant: IconButtonStyle.SizeVariant.Large16

    property IconButtonStyle.Type _type: {
        switch (control.typeVariant) {
            case IconButtonStyle.TypeVariant.Subtle: return IconButtonStyle.subtle
            case IconButtonStyle.TypeVariant.Highlight: return IconButtonStyle.highlight

            default: return IconButtonStyle.subtle
        }
    }

    property IconButtonStyle.Size _size: {
        switch (control.sizeVariant) {
            case IconButtonStyle.SizeVariant.Small16: return IconButtonStyle.small16
            case IconButtonStyle.SizeVariant.Medium16: return IconButtonStyle.medium16
            case IconButtonStyle.SizeVariant.Large16: return IconButtonStyle.large16

            case IconButtonStyle.SizeVariant.Small24: return IconButtonStyle.small24
            case IconButtonStyle.SizeVariant.Medium24: return IconButtonStyle.medium24
            case IconButtonStyle.SizeVariant.Large24: return IconButtonStyle.large24

            default: return IconButtonStyle.large16
        }
    }

    property IconButtonStyle.StateStyle _style: {
        if (control.enabled && !control.pressed && !control.checked && !control.hovered)
            return control._type.idle
        else if (control.enabled && !control.pressed && !control.checked && control.hovered)
            return control._type.hover
        else if (control.enabled && (control.pressed || control.checked))
            return control._type.active
        else if (!control.enabled)
            return control._type.disable

        return control._type.idle
    }

    property bool _outline: control.appearanceVariant === IconButtonStyle.AppearanceVariant.Outline

    property bool hoverSend: control.hovered // this seems flakey so I just use the hovered property
    property bool hoverRecieve: false

    property bool activeSend: control.down
    property bool activeRecieve: false

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    background: Rectangle {
        implicitWidth: control._size.iconSize + (control._size.horizontalPadding * 2)
        implicitHeight: control._size.iconSize + (control._size.verticalPadding * 2)

        color: control._style.background
        border {
            color: control._style.border
            width: control._outline ? control._size.borderWidth : 0
        }
        radius: control._size.radius
    }

    contentItem: Text {
        id: buttonIcon
        color: control._style.icon

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        font {
            family: Fonts.FontInterface.iconFont.font.family
            pixelSize: control._size.iconSize
        }
    }

    // do cursor changes over the control depending on state
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
