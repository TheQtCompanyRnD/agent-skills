// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import Qt.Fonts as Fonts

T.RangeSlider {
    id: control

    property int typeVariant: RangeSliderStyle.TypeVariant.Primary
    property int sizeVariant: RangeSliderStyle.SizeVariant.Small

    property RangeSliderStyle.Type _type: {
        switch (control.typeVariant) {
            case RangeSliderStyle.TypeVariant.Primary: return RangeSliderStyle.primary

            default: return RangeSliderStyle.primary
        }
    }

    property RangeSliderStyle.Size _size: {
        switch (control.sizeVariant) {
            case RangeSliderStyle.SizeVariant.Small: return RangeSliderStyle.small
            case RangeSliderStyle.SizeVariant.Large: return RangeSliderStyle.large

            default: return RangeSliderStyle.small
        }
    }

    property RangeSliderStyle.StateStyle _style: {
        if (control.enabled && !(control.first.pressed || control.second.pressed) && !control.hovered)
            return control._type.idle
        else if (control.enabled && !(control.first.pressed || control.second.pressed) && control.hovered)
            return control._type.hover
        else if (control.enabled && (control.first.pressed || control.second.pressed))
            return control._type.active
        else if (!control.enabled)
            return control._type.disable

        return control._type.idle
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            first.implicitHandleWidth + leftPadding + rightPadding,
                            second.implicitHandleWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             first.implicitHandleHeight + topPadding + bottomPadding,
                             second.implicitHandleHeight + topPadding + bottomPadding)

    //padding: control._size.padding

    hoverEnabled: true

    first.handle: Rectangle {
        x: control.leftPadding + (control.horizontal ? control.first.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.first.visualPosition * (control.availableHeight - height))
        implicitWidth: control._size.handleSize
        implicitHeight: control._size.handleSize
        radius: control._size.handleRadius

        color: control._style.handle
        border {
            width: control._style.handleBorderWidth
            color: control._style.handleBorder
        }
    }

    second.handle: Rectangle {
        x: control.leftPadding + (control.horizontal ? control.second.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.second.visualPosition * (control.availableHeight - height))
        implicitWidth: control._size.handleSize
        implicitHeight: control._size.handleSize
        radius: control._size.handleRadius

        color: control._style.handle
        border {
            width: control._style.handleBorderWidth
            color: control._style.handleBorder
        }
    }

    background: Rectangle {
        x: control.leftPadding + (control.horizontal ? 0 : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : 0)

        implicitWidth: control.horizontal ? 120 : control._size.trackThickness
        implicitHeight: control.horizontal ? control._size.trackThickness : 120

        width: control.horizontal ? control.availableWidth : implicitWidth
        height: control.horizontal ? implicitHeight : control.availableHeight

        radius: control._size.trackRadius

        color: control._style.track
        scale: control.horizontal && control.mirrored ? -1 : 1

        border {
            width: control._style.trackBorderWidth
            color: control._style.trackBorder
        }

        // Filled portion of the track
        Rectangle {
            x: control.horizontal ? control.first.position * parent.width + control._size.trackRadius : 0
            y: control.horizontal ? 0 : control.second.visualPosition * parent.height + control._size.trackRadius
            width: control.horizontal ? control.second.position * parent.width - control.first.position * parent.width - control._size.trackThickness : control._size.trackThickness
            height: control.horizontal ? control._size.trackThickness : control.second.position * parent.height - control.first.position * parent.height - control._size.trackThickness

            color: control._style.fill
        }
    }

    // Cursor behaviour
    HoverHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.Stylus
        cursorShape: Qt.PointingHandCursor
    }
}
