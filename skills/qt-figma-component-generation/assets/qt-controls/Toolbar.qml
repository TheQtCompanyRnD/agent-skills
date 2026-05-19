// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Layouts
import Qt.Fonts as Fonts

Rectangle {
    id: control

    default property alias content: layout.children
    property int orientation: Qt.Horizontal

    property int typeVariant: ToolbarStyle.TypeVariant.Primary
    property int sizeVariant: ToolbarStyle.SizeVariant.Base

    property ToolbarStyle.Type _type: {
        switch (control.typeVariant) {
            case ToolbarStyle.TypeVariant.Primary: return ToolbarStyle.primary

            default: return ToolbarStyle.primary
        }
    }

    property ToolbarStyle.Size _size: {
        switch (control.sizeVariant) {
            case ToolbarStyle.SizeVariant.Base: return ToolbarStyle.base

            default: return ToolbarStyle.base
        }
    }

    implicitWidth: layout.childrenRect.width + (control._size.horizontalPadding * 2)
    implicitHeight: layout.childrenRect.height + (control._size.verticalPadding * 2)

    color: control._type.background
    border {
        color: control._type.border
        width: control._size.borderWidth
    }
    radius: control._size.radius

    GridLayout {
        id: layout
        x: control._size.horizontalPadding
        y: control._size.verticalPadding

        // TODO set proper upper limit
        columns: control.orientation === Qt.Vertical ? 1 : 1000
        rows: control.orientation === Qt.Horizontal ? 1 : 1000

        columnSpacing: control._size.spacing
        rowSpacing: control._size.spacing
    }
}
