// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import Qt.Fonts as Fonts

T.Slider {
    id: control

    property int typeVariant: SliderStyle.TypeVariant.Primary
    property int sizeVariant: SliderStyle.SizeVariant.Small

    property SliderStyle.Type _type: {
        switch (control.typeVariant) {
            case SliderStyle.TypeVariant.Primary: return SliderStyle.primary

            default: return SliderStyle.primary
        }
    }

    property SliderStyle.Size _size: {
        switch (control.sizeVariant) {
            case SliderStyle.SizeVariant.Small: return SliderStyle.small
            case SliderStyle.SizeVariant.Large: return SliderStyle.large

            default: return SliderStyle.small
        }
    }

    property SliderStyle.StateStyle _style: {
        if (control.enabled && !control.pressed && !control.hovered)
            return control._type.idle
        else if (control.enabled && !control.pressed && control.hovered)
            return control._type.hover
        else if (control.enabled && control.pressed)
            return control._type.active
        else if (!control.enabled)
            return control._type.disable

        return control._type.idle
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitHandleWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitHandleHeight + topPadding + bottomPadding)

    //padding: control._size.padding

    hoverEnabled: true

    handle: Rectangle {
        x: control.leftPadding
           + (control.horizontal
              ? control.visualPosition * (control.availableWidth - width)
              : (control.availableWidth - width) / 2)

        y: control.topPadding
           + (control.horizontal
              ? (control.availableHeight - height) / 2
              : control.visualPosition * (control.availableHeight - height))

        implicitWidth: control._size.handleSize
        implicitHeight: control._size.handleSize
        radius: control._size.handleRadius

        color: control._style.handle
        border.width: control._style.handleBorderWidth
        border.color: control._style.handleBorder
    }

    background: Rectangle {
        x: control.leftPadding
           + (control.horizontal ? 0 : (control.availableWidth - width) / 2)
        y: control.topPadding
           + (control.horizontal ? (control.availableHeight - height) / 2 : 0)

        implicitWidth: control.horizontal ? 120 : control._size.trackThickness
        implicitHeight: control.horizontal ? control._size.trackThickness : 120

        width: control.horizontal ? control.availableWidth : implicitWidth
        height: control.horizontal ? implicitHeight : control.availableHeight

        radius: control._size.trackRadius

        color: control._style.track
        scale: control.horizontal && control.mirrored ? -1 : 1

        border.width: control._style.trackBorderWidth
        border.color: control._style.trackBorder

        // Filled portion of the track
        Rectangle {
            y: control.horizontal ? 0 : control.visualPosition * parent.height
            width: control.horizontal ? control.position * parent.width : control._size.trackThickness
            height: control.horizontal ? control._size.trackThickness : control.position * parent.height

            radius: control._size.trackRadius
            color: control._style.fill
        }
    }

    // Cursor behaviour
    HoverHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.Stylus
        cursorShape: Qt.PointingHandCursor
    }
}
