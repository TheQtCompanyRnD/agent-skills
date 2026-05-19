// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T
import Qt.Fonts as Fonts

T.MenuItem {
    id: control

    property int typeVariant: MenuItemStyle.TypeVariant.Primary
    property int sizeVariant: MenuItemStyle.SizeVariant.Base

    property MenuItemStyle.Type _type: {
        switch (control.typeVariant) {
            case MenuItemStyle.TypeVariant.Primary: return MenuItemStyle.primary

            default: return MenuItemStyle.primary
        }
    }

    property MenuItemStyle.Size _size: MenuItemStyle.base

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    horizontalPadding: control._size.horizontalPadding
    verticalPadding: control._size.verticalPadding
    spacing: control._size.spacing

    arrow: Text {
        x: control.mirrored ? control.leftPadding : control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2

        visible: control.subMenu
        text: Fonts.FontInterface.icons.arrowHead_down_16
        color: control._type.icon
        topPadding: control._size.verticalPadding
        bottomPadding: control._size.verticalPadding
        leftPadding: control._size.horizontalPadding
        rightPadding: control._size.horizontalPadding
        rotation: 270

        font {
            family: Fonts.FontInterface.iconFont.font.family
            pixelSize: control._size.iconSize
        }
    }

    contentItem: Text {
        text: control.text
        color: control._type.text
        lineHeightMode: Text.FixedHeight
        lineHeight: control._size.lineHeight
        leftPadding: control._size.horizontalPadding
        rightPadding: control._size.horizontalPadding
        topPadding: control._size.verticalPadding
        bottomPadding: control._size.verticalPadding
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter

        font {
            pixelSize: control._size.fontSize
            weight: control._size.fontWeight
        }
    }

    background: Rectangle {
        width: control.contentItem.width
        height: control.contentItem.height
        anchors.centerIn: control
        color: control.highlighted ? control._type.highlight : control._type.background
        radius: control._size.radius
    }
}
