// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import Qt.Fonts as Fonts

Text {
    id: control

    signal clicked

    property int typeVariant: LinkInlineStyle.TypeVariant.Primary
    property int sizeVariant: LinkInlineStyle.SizeVariant.Large

    text: qsTr("Link")

    property LinkInlineStyle.Type _type: {
        switch (control.typeVariant) {
            case LinkInlineStyle.TypeVariant.Primary: return LinkInlineStyle.primary

            default: return LinkInlineStyle.primary
        }
    }

    property LinkInlineStyle.Size _size: {
        switch (control.sizeVariant) {
            case LinkInlineStyle.SizeVariant.Small: return LinkInlineStyle.small
            case LinkInlineStyle.SizeVariant.Large: return LinkInlineStyle.large

            default: return LinkInlineStyle.large
        }
    }

    property LinkInlineStyle.StateStyle _style: {
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

    color: control._style.text
    lineHeight: control._size.lineHeight
    lineHeightMode: Text.FixedHeight

    font {
        family: Fonts.FontInterface.interFont.font.family
        pixelSize: control._size.fontSize
        underline: true
        variableAxes: {
            "wght": control._size.fontWeight
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
