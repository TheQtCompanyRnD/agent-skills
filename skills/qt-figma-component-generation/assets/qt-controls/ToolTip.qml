// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import Qt.Fonts as Fonts

T.ToolTip {
    id: control

    property alias title: title.text

    property int typeVariant: ToolTipStyle.TypeVariant.Primary
    property int sizeVariant: ToolTipStyle.SizeVariant.Large
    property int popupPosition: ToolTip.PopupPosition.Default

    enum PopupPosition {
        Over,
        Under,
        Left,
        Right,
        Default
    }

    function getPopupX() {
        if (control.popupPosition === ToolTip.PopupPosition.Default || control.popupPosition === ToolTip.PopupPosition.Over || control.popupPosition === ToolTip.PopupPosition.Under)
            return (control.parent.width - control.implicitWidth) / 2
        else if (control.popupPosition === ToolTip.PopupPosition.Left)
            return -control.implicitWidth - control._size.arrowSize / 2 - control._size.popupGap
        else if (control.popupPosition === ToolTip.PopupPosition.Right)
            return control.parent.width + control._size.arrowSize / 2 + control._size.popupGap
        else {
            console.error("error with popup position")
            return 0
        }
    }

    function getPopupY() {
        if (control.popupPosition === ToolTip.PopupPosition.Default)
            return -control.implicitHeight - control._size.popupGap
        else if (control.popupPosition === ToolTip.PopupPosition.Over)
            return -control.implicitHeight - 3 - control._size.arrowSize / 2
        else if (control.popupPosition === ToolTip.PopupPosition.Under)
            return control.parent.height + control._size.arrowSize / 2 + control._size.popupGap
        else if (control.popupPosition === ToolTip.PopupPosition.Left || control.popupPosition === ToolTip.PopupPosition.Right)
            return -(control.implicitHeight - control.parent.height) / 2
        else {
            console.error("error with popup position")
            return -control.implicitHeight - control._size.popupGap
        }
    }

    property ToolTipStyle.Type _type: {
        switch (control.typeVariant) {
            case ToolTipStyle.TypeVariant.Primary: return ToolTipStyle.primary

        default: return ToolTipStyle.primary
        }
    }

    property ToolTipStyle.Size _size: {
        switch (control.sizeVariant) {
            case ToolTipStyle.SizeVariant.Large: return ToolTipStyle.large
            case ToolTipStyle.SizeVariant.Small: return ToolTipStyle.small

        default: return ToolTipStyle.large
        }
    }

    x: parent ? getPopupX() : 0
    y: getPopupY()

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    horizontalPadding: control._size.horizontalPadding
    verticalPadding: control._size.verticalPadding
    spacing: control._size.spacing

    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent | T.Popup.CloseOnReleaseOutsideParent

    contentItem: ColumnLayout {
        id: content

        spacing: control._size.spacing

        Text {
            id: title

            visible: control.title
            text: control.title
            wrapMode: Text.Wrap
            color: control._type.text
            lineHeight: control._size.titleLineHeight
            lineHeightMode: Text.FixedHeight
            verticalAlignment: Text.AlignVCenter

            font {
                family: Fonts.FontInterface.interFont.font.family
                pixelSize: control._size.fontSize
                variableAxes: {
                    "wght": control._size.titleWeight
                }
            }
        }

        Text {
            id: body

            visible: control.text
            text: control.text
            wrapMode: Text.Wrap
            color: control._type.text
            lineHeight: control._size.bodyLineHeight
            lineHeightMode: Text.FixedHeight
            verticalAlignment: Text.AlignVCenter

            font {
                family: Fonts.FontInterface.interFont.font.family
                pixelSize: control._size.fontSize
                variableAxes: {
                    "wght": control._size.fontWeight
                }
            }
        }
    }

    background: Rectangle {
        id: background

        border.width: control._size.borderWidth
        border.color: control._type.border
        color: control._type.background
        radius: control._size.radius

        Canvas {
            id: canvas

            rotation: control.popupPosition === ToolTip.PopupPosition.Over ? 180
                    : control.popupPosition === ToolTip.PopupPosition.Left ? 90
                    : control.popupPosition === ToolTip.PopupPosition.Right ? 270
                    : 0

            width: control._size.arrowSize
            height: control._size.arrowSize

            x: control.popupPosition === ToolTip.PopupPosition.Over ? background.width / 2 - canvas.width / 2
             : control.popupPosition === ToolTip.PopupPosition.Left ? background.width - canvas.width / 2 - control._size.borderWidth
             : control.popupPosition === ToolTip.PopupPosition.Right ? -canvas.width / 2 + control._size.borderWidth
             : background.width / 2 - canvas.width / 2

            y: control.popupPosition === ToolTip.PopupPosition.Over ? background.height - canvas.height / 2 - control._size.borderWidth
             : control.popupPosition === ToolTip.PopupPosition.Left ? background.height / 2 - canvas.height / 2
             : control.popupPosition === ToolTip.PopupPosition.Right ? background.height / 2 - canvas.height / 2
             : -canvas.height / 2 + control._size.borderWidth

            visible: control.popupPosition === ToolTip.PopupPosition.Over ||
                     control.popupPosition === ToolTip.PopupPosition.Under ||
                     control.popupPosition === ToolTip.PopupPosition.Left ||
                     control.popupPosition === ToolTip.PopupPosition.Right

            onPaint: {
                var ctx = getContext("2d")

                ctx.strokeStyle = control._type.border
                ctx.fillStyle = control._type.background
                ctx.lineWidth = control._size.borderWidth

                ctx.beginPath()
                ctx.moveTo(canvas.width / 2 - control._size.arrowSize / 2, canvas.height / 2)

                ctx.lineTo(canvas.width / 2, 0)
                ctx.lineTo(canvas.width / 2 + control._size.arrowSize / 2, canvas.height / 2)
                ctx.fill()
                ctx.stroke()

                ctx.beginPath()
                ctx.strokeStyle = control._type.background
                ctx.lineWidth = control._size.borderWidth * 2
                ctx.moveTo(canvas.width / 2 + control._size.arrowSize / 2 - 1, canvas.height / 2)
                ctx.lineTo(canvas.width / 2 - control._size.arrowSize / 2 + 1, canvas.height / 2)
                ctx.stroke()
            }

            Rectangle {
                id: iHideGlitches

                y: control._size.arrowSize / 2
                height: control._size.borderWidth
                width: canvas.width
                color: control._type.background
            }
        }
    }
}
