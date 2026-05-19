// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T

T.ScrollBar {
    id: control

    property bool isNeeded: control.size < 1.0

    property int typeVariant: ScrollBarStyle.TypeVariant.Floating
    property int sizeVariant: ScrollBarStyle.SizeVariant.Large

    property ScrollBarStyle.Type _type: {
        switch (control.typeVariant) {
            case ScrollBarStyle.TypeVariant.Floating: return ScrollBarStyle.floating
            case ScrollBarStyle.TypeVariant.Docked: return ScrollBarStyle.docked

            default: return ScrollBarStyle.floating
        }
    }

    property ScrollBarStyle.Size _size: {
        switch (control.sizeVariant) {
            case ScrollBarStyle.SizeVariant.Small: return ScrollBarStyle.small
            case ScrollBarStyle.SizeVariant.Medium: return ScrollBarStyle.medium
            case ScrollBarStyle.SizeVariant.Large: return ScrollBarStyle.large

            default: return ScrollBarStyle.large
        }
    }

    // TODO The design system does not specify different states yet
    property ScrollBarStyle.StateStyle _style: control._type.idle

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    hoverEnabled: true
    horizontalPadding: control.orientation === Qt.Horizontal ? control._style.crossPadding
                                                             : control._style.mainPadding
    verticalPadding: control.orientation === Qt.Vertical ? control._style.crossPadding
                                                         : control._style.mainPadding
    minimumSize: control.orientation === Qt.Horizontal ? control.height / control.width
                                                       : control.width / control.height

    visible: control.policy !== T.ScrollBar.AlwaysOff

    contentItem: Rectangle {
        id: controlHandle
        implicitWidth: control._size.thickness - 2 * control.horizontalPadding
        implicitHeight: control._size.thickness - 2 * control.verticalPadding
        radius: control._size.radius
        color: control._style.indicator
    }

    background: Rectangle {
        id: controlTrack
        implicitWidth: control._size.thickness
        implicitHeight: control._size.thickness
        color: control._style.background
        visible: control.typeVariant !== ScrollBarStyle.TypeVariant.Floating
    }
}
