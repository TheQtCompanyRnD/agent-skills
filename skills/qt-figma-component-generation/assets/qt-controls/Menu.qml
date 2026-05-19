// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T
import Qt.Controls as Controls

T.Menu {
    id: control

    property int typeVariant: MenuStyle.TypeVariant.Primary
    property int sizeVariant: MenuStyle.SizeVariant.Base

    property MenuStyle.Type _type: {
        switch (control.typeVariant) {
            case MenuStyle.TypeVariant.Primary: return MenuStyle.primary

            default: return MenuStyle.primary
        }
    }

    property MenuStyle.Size _size: MenuStyle.base

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    margins: 0
    horizontalPadding: control._size.horizontalPadding
    verticalPadding: control._size.verticalPadding
    overlap: -control._size.subMenuGap

    delegate: Controls.MenuItem {}

    contentItem: ListView {
        implicitHeight: contentHeight
        model: control.contentModel
        interactive: Window.window
                     ? contentHeight + control.topPadding + control.bottomPadding > control.height
                     : false
        clip: true
        currentIndex: control.currentIndex

        T.ScrollIndicator.vertical: T.ScrollIndicator { }
    }

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 40
        border.width: control._size.borderWidth
        border.color: control._type.border
        color: control._type.background
        radius: control._size.radius
    }

    // T.Overlay.modal: Rectangle {
    //     color: Color.transparent(control.palette.shadow, 0.5)
    // }

    // T.Overlay.modeless: Rectangle {
    //     color: Color.transparent(control.palette.shadow, 0.12)
    // }
}
