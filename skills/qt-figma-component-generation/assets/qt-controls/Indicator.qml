// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Shapes
import QtQuick.Templates as T

T.Control {
    id: control

    default property alias content: shapePath.pathElements
    property bool pressed: false

    property int typeVariant: IndicatorStyle.TypeVariant.Primary
    property int sizeVariant: IndicatorStyle.SizeVariant.Small

    property IndicatorStyle.Type _type: {
        switch (control.typeVariant) {
            case IndicatorStyle.TypeVariant.Primary: return IndicatorStyle.primary

            default: return IndicatorStyle.primary
        }
    }

    property IndicatorStyle.Size _size: {
        switch (control.sizeVariant) {
            case IndicatorStyle.SizeVariant.Small: return IndicatorStyle.small

            default: return IndicatorStyle.small
        }
    }

    property IndicatorStyle.StateStyle _style: {
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
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    background: Rectangle {
        implicitWidth: 16
        implicitHeight: 8
        radius: 2
        color: control._style.background

        Shape {
            anchors.centerIn: parent
            width: 10
            height: 6

            ShapePath {
                id: shapePath
                strokeWidth: 1.5
                strokeColor: control._style.icon
                fillColor: "transparent"
                joinStyle: ShapePath.RoundJoin
                capStyle: ShapePath.RoundCap
                strokeStyle: ShapePath.SolidLine
            }
        }
    }
}
