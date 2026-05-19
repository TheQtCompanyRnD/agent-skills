// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T
import Qt.Controls as Controls

T.DialogButtonBox {
    id: control

    property int typeVariant: DialogButtonBoxStyle.TypeVariant.Primary
    property int sizeVariant: DialogButtonBoxStyle.SizeVariant.Base

    property DialogButtonBoxStyle.Type _type: {
        switch (control.typeVariant) {
            case DialogButtonBoxStyle.TypeVariant.Primary: return DialogButtonBoxStyle.primary

            default: return DialogButtonBoxStyle.primary
        }
    }

    property DialogButtonBoxStyle.Size _size: DialogButtonBoxStyle.base

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                   (control.count === 1 ? implicitContentWidth * 2 : implicitContentWidth) + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                    implicitContentHeight + topPadding + bottomPadding)
    contentWidth: (contentItem as ListView)?.contentWidth

    spacing: control._size.spacing
    horizontalPadding: control._size.horizontalPadding
    bottomPadding: control._size.verticalPadding
    alignment: count === 1 ? Qt.AlignCenter : undefined

    delegate: Controls.Button {
        text: ""

        // removing the elide here since it sometimes results in text disappearing from buttons or just three dots (...)
        // eliding seems to make something somewhere think the text won't fit even when there's plenty of space
        label.elide: Text.ElideNone
        label.horizontalAlignment: Text.AlignHCenter
        width: control.count === 1 ? control.availableWidth / 2 : undefined
    }

    contentItem: ListView {
        implicitWidth: contentWidth
        model: control.contentModel
        spacing: control.spacing
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        snapMode: ListView.SnapToItem
    }
}
