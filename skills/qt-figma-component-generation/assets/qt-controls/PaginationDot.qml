// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T

T.PageIndicator {
    id: control

    property int typeVariant: PaginationDotStyle.TypeVariant.Primary
    property int sizeVariant: PaginationDotStyle.SizeVariant.Medium

    property PaginationDotStyle.Type _type: {
        switch (control.typeVariant) {
            case PaginationDotStyle.TypeVariant.Primary: return PaginationDotStyle.primary

            default: return PaginationDotStyle.primary
        }
    }

    property PaginationDotStyle.Size _size: {
        switch (control.sizeVariant) {
            case PaginationDotStyle.SizeVariant.Small: return PaginationDotStyle.small
            case PaginationDotStyle.SizeVariant.Medium: return PaginationDotStyle.medium
            case PaginationDotStyle.SizeVariant.Large: return PaginationDotStyle.large

            default: return PaginationDotStyle.medium
        }
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: 0
    spacing: control._size.spacing

    hoverEnabled: true

    delegate: Rectangle {
        id: dot

        required property int index

        implicitWidth: control._size.dotSize
        implicitHeight: control._size.dotSize

        radius: dot.width / 2

        HoverHandler { id: hoverHandler }

        property PaginationDotStyle.StateStyle _style: {
            let active = (dot.index === control.currentIndex)

            if (control.enabled && !hoverHandler.hovered && !active)
                return control._type.idle
            else if (control.enabled && hoverHandler.hovered && !active)
                return control._type.hover
            else if (control.enabled && !hoverHandler.hovered && active)
                return control._type.active
            else if (control.enabled && hoverHandler.hovered && active)
                return control._type.activeHover
            else if (!control.enabled)
                return control._type.disable

            return control._type.idle
        }

        color: dot._style.background
        border {
            color: dot._style.border
            width: dot._style.borderWidth
        }

    }

    contentItem: Row {
        spacing: control.spacing

        Repeater {
            model: control.count
            delegate: control.delegate
        }
    }
}
