// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import Qt.Fonts as Fonts

Row {
    id: control

    signal clicked

    property alias text: label.text

    property int typeVariant: LinkListStyle.TypeVariant.Primary
    property int sizeVariant: LinkListStyle.SizeVariant.Large

    property LinkListStyle.Type _type: {
        switch (control.typeVariant) {
            case LinkListStyle.TypeVariant.Primary: return LinkListStyle.primary

            default: return LinkListStyle.primary
        }
    }

    property LinkListStyle.Size _size: {
        switch (control.sizeVariant) {
            case LinkListStyle.SizeVariant.Large: return LinkListStyle.large

            default: return LinkListStyle.large
        }
    }

    property LinkListStyle.StateStyle _style: {
        if (control.enabled && !tapHandler.pressed && !hoverHandler.hovered)
            return control._type.idle
        else if (control.enabled && !tapHandler.pressed && hoverHandler.hovered)
            return control._type.hover
        else if (control.enabled && tapHandler.pressed)
            return control._type.active
        else if (!control.enabled)
            return control._type.disable

        return control._type.idle
    }

    spacing: control._size.spacing

    Text {
        id: icon
        text: Fonts.FontInterface.icons.selection_mode_24
        color: control._style.icon

        width: control._size.iconSize
        height: control._size.iconSize

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        font {
            family: Fonts.FontInterface.iconFont.font.family
            pixelSize: control._size.iconSize
        }
    }

    Text {
        id: label
        text: qsTr("Large Link")
        color: control._style.text
        lineHeight: control._size.lineHeight
        lineHeightMode: Text.FixedHeight

        anchors.verticalCenter: parent.verticalCenter

        font {
            family: Fonts.FontInterface.interFont.font.family
            pixelSize: control._size.fontSize
            variableAxes: {
                "wght": control._size.fontWeight
            }
        }
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: tapHandler
        onTapped: control.clicked()
    }
}
