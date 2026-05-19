// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T

T.Popup {
    id: control

    property int typeVariant: PopupStyle.TypeVariant.Primary
    property int sizeVariant: PopupStyle.SizeVariant.Base

    property PopupStyle.Type _type: {
        switch (control.typeVariant) {
            case PopupStyle.TypeVariant.Primary: return PopupStyle.primary

            default: return PopupStyle.primary
        }
    }

    property PopupStyle.Size _size: PopupStyle.base

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    horizontalPadding: control._size.horizontalPadding
    verticalPadding: control._size.verticalPadding

    background: Rectangle {
        color: control._type.background
        border.color: control._type.border
        border.width: control._size.borderWidth
        radius: control._size.radius
    }

    // T.Overlay.modal: Rectangle {
    //     color: Color.transparent(control.palette.shadow, 0.5)
    // }

    // T.Overlay.modeless: Rectangle {
    //     color: Color.transparent(control.palette.shadow, 0.12)
    // }
}
