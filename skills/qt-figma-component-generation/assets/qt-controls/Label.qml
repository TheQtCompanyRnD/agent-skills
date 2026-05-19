// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T

import Qt.Fonts as Fonts

T.Label {
    id: control

    property int typeVariant: LabelStyle.TypeVariant.Primary
    property int sizeVariant: LabelStyle.SizeVariant.Medium

    property LabelStyle.Type _type: {
        switch (control.typeVariant) {
            case LabelStyle.TypeVariant.Primary: return LabelStyle.primary
            case LabelStyle.TypeVariant.Muted: return LabelStyle.muted
            case LabelStyle.TypeVariant.Subtle: return LabelStyle.subtle

            default: return LabelStyle.primary
        }
    }

    property LabelStyle.Size _size: {
        switch (control.sizeVariant) {
            case LabelStyle.SizeVariant.Medium: return LabelStyle.medium
            case LabelStyle.SizeVariant.Small: return LabelStyle.small
            case LabelStyle.SizeVariant.Caption: return LabelStyle.caption

            default: return LabelStyle.medium
        }
    }

    text: qsTr("Label")

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    color: control._type.text
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
