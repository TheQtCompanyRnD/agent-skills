// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T

T.ProgressBar {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    property int typeVariant: ProgressBarStyle.TypeVariant.Primary
    property int sizeVariant: ProgressBarStyle.SizeVariant.Large

    property ProgressBarStyle.Type _type: {
        switch (control.typeVariant) {
            case ProgressBarStyle.TypeVariant.Primary: return ProgressBarStyle.primary

            default: return ProgressBarStyle.primary
        }
    }

    property ProgressBarStyle.Size _size: {
        switch (control.sizeVariant) {
            case ProgressBarStyle.SizeVariant.Small: return ProgressBarStyle.small
            case ProgressBarStyle.SizeVariant.Large: return ProgressBarStyle.large

            default: return ProgressBarStyle.large
        }
    }

    enum ProgressBarState {
        Active,
        Success,
        Error
    }

    property int progressBarState: ProgressBar.ProgressBarState.Active

    property ProgressBarStyle.StateStyle _style: {
        switch (control.progressBarState) {
            case ProgressBar.ProgressBarState.Active: return control._type.active
            case ProgressBar.ProgressBarState.Success: return control._type.success
            case ProgressBar.ProgressBarState.Error: return control._type.error

            default: return control._type.active
        }
    }

    contentItem: Item {
        implicitWidth: 200
        implicitHeight: control._size.height
        clip: true // TODO indeterminate needs double clip?!

        // Progress indicator for determinate state
        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: control._size.radius
            color: control._style.barIndicator
            visible: !control.indeterminate
        }

        // Scrolling animation for indeterminate state
        Item {
            anchors.fill: parent
            visible: control.indeterminate
            clip: true

            Rectangle {
                width: control.width * 0.5
                height: control.height
                radius: control._size.radius
                color: control._style.barIndicator
            }

            XAnimator on x {
                from: -control.width * 0.5
                to: control.width
                loops: Animation.Infinite
                running: control.indeterminate
                duration: 1000
            }
        }
    }

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: control._size.height

        radius: control._size.radius
        y: (control.height - height) / 2
        height: control._size.height

        color: control._style.track
    }
}
