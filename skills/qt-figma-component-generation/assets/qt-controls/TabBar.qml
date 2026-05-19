// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T

T.TabBar {
    id: control

    property bool hasDivider: false

    property int typeVariant: TabBarStyle.TypeVariant.Primary
    property int sizeVariant: TabBarStyle.SizeVariant.Base

    property TabBarStyle.Type _type: {
        switch (control.typeVariant) {
            case TabBarStyle.TypeVariant.Primary: return TabBarStyle.primary

            default: return TabBarStyle.primary
        }
    }

    property TabBarStyle.Size _size: {
        switch (control.sizeVariant) {
            case TabBarStyle.SizeVariant.Base: return TabBarStyle.base

            default: return TabBarStyle.base
        }
    }

    property TabBarStyle.StateStyle _style: {
        return control._type.idle
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    spacing: control._size.spacing

    contentItem: ListView {
        model: control.contentModel
        currentIndex: control.currentIndex

        spacing: control.spacing
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.AutoFlickIfNeeded
        snapMode: ListView.SnapToItem

        //highlightMoveDuration: 0
        //highlightRangeMode: ListView.ApplyRange
        //preferredHighlightBegin: 40
        //preferredHighlightEnd: width - 40
    }

    background: Rectangle {
        color: control._style.background

        Rectangle {
            visible: control.hasDivider
            anchors.bottom: parent.bottom
            width: parent.width
            height: control._size.borderWidth
            color: control._style.border
        }
    }
}
