// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T

import Qt.Fonts as Fonts

T.ItemDelegate {
    id: control

    property int typeVariant: ItemDelegateStyle.TypeVariant.Primary
    property int sizeVariant: ItemDelegateStyle.SizeVariant.Large

    property ItemDelegateStyle.Type _type: {
        switch (control.typeVariant) {
            case ItemDelegateStyle.TypeVariant.Primary: return ItemDelegateStyle.primary

            default: return ItemDelegateStyle.primary
        }
    }

    property ItemDelegateStyle.Size _size: {
        switch (control.sizeVariant) {
            case ItemDelegateStyle.SizeVariant.Small: return ItemDelegateStyle.small
            case ItemDelegateStyle.SizeVariant.Large: return ItemDelegateStyle.large

            default: return ItemDelegateStyle.large
        }
    }

    property ItemDelegateStyle.StateStyle _style: {
        if (control.enabled && !control.pressed && !control.checked && !control.highlighted && !control.hovered)
            return control._type.idle
        else if (control.enabled && !control.pressed && !control.checked && !control.highlighted && control.hovered)
            return control._type.hover
        else if (control.enabled && (control.pressed || control.checked || control.highlighted))
            return control._type.active
        else if (!control.enabled)
            return control._type.disable

        return control._type.idle
    }

    text: qsTr("ItemDelegate")

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    horizontalPadding: control._size.horizontalPadding

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: control._size.lineHeight + (control._size.verticalPadding * 2)

        color: control._style.background
        border {
            color: control._style.border
            width: 0
        }
        radius: control._size.radius
    }

    contentItem: Text {
        text: control.text
        color: control._style.text

        elide: Text.ElideRight
        textFormat: Text.PlainText
        lineHeightMode: Text.FixedHeight
        lineHeight: control._size.lineHeight

        verticalAlignment: Text.AlignVCenter

        font {
            family: Fonts.FontInterface.interFont.font.family
            pixelSize: control._size.fontSize
            variableAxes: {
                "wght": control._size.fontWeight
            }
        }
    }
}
