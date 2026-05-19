// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T

import Qt.Fonts as Fonts

T.Control {
    id: control

    property int typeVariant: PaginationIndexStyle.TypeVariant.Primary
    property int sizeVariant: PaginationIndexStyle.SizeVariant.Medium

    property PaginationIndexStyle.Type _type: {
        switch (control.typeVariant) {
            case PaginationIndexStyle.TypeVariant.Primary: return PaginationIndexStyle.primary

            default: return PaginationIndexStyle.primary
        }
    }

    property PaginationIndexStyle.Size _size: {
        switch (control.sizeVariant) {
            case PaginationIndexStyle.SizeVariant.Small: return PaginationIndexStyle.small
            case PaginationIndexStyle.SizeVariant.Medium: return PaginationIndexStyle.medium
            case PaginationIndexStyle.SizeVariant.Large: return PaginationIndexStyle.large

            default: return PaginationIndexStyle.medium
        }
    }

    property int count: 0
    property int currentIndex: 0

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: 0
    spacing: control._size.spacing

    component InternalText: Text {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        lineHeightMode: Text.FixedHeight
        lineHeight: control._size.lineHeight

        font {
            family: Fonts.FontInterface.interFont.font.family
            pixelSize: control._size.fontSize
            variableAxes: {
                "wght": control._size.fontWeight
            }
        }
    }

    contentItem: Row {
        spacing: control.spacing

        InternalText {
            text: control.currentIndex + 1
            color: control._type.index
        }

        InternalText {
            text: "/"
            color: control._type.text
        }

        InternalText {
            text: control.count
            color: control._type.text
        }
    }
}
