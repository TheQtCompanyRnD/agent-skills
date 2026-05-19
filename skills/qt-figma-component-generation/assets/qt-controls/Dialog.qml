// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T
import QtQuick.Layouts
import Qt.Controls as Controls
import Qt.Fonts as Fonts

T.Dialog {
    id: control

    property alias iconGlyph: dialogIcon.text
    property alias iconColor: dialogIcon.color
    property alias info: info.text

    property int typeVariant: DialogStyle.TypeVariant.Primary
    property int sizeVariant: DialogStyle.SizeVariant.Large

    property DialogStyle.Type _type: {
        switch (control.typeVariant) {
            case DialogStyle.TypeVariant.Primary: return DialogStyle.primary

            default: return DialogStyle.primary
        }
    }

    property DialogStyle.Size _size: {
        switch (control.sizeVariant) {
            case DialogStyle.SizeVariant.Large: return DialogStyle.large
            case DialogStyle.SizeVariant.Small: return DialogStyle.small

            default: return DialogStyle.large
        }
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding,
                            implicitHeaderWidth, implicitFooterWidth) + control._size.horizontalPadding * 2
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding
                             + (implicitHeaderHeight > 0 ? implicitHeaderHeight + spacing : 0)
                             + (implicitFooterHeight > 0 ? implicitFooterHeight + spacing : 0))

    parent: T.Overlay.overlay
    horizontalPadding: control._size.horizontalPadding
    verticalPadding: control._size.verticalPadding

    title: qsTr("Title")

    background: Rectangle {
        border.width: control._size.borderWidth
        border.color: control._type.border
        color: control._type.background
        radius: control._size.radius
    }

    header: ColumnLayout {
        id: header

        Text {
            id: dialogIcon

            text: Fonts.FontInterface.icons.info_circle_16
            Layout.alignment: Qt.AlignCenter
            color: control._type.icon
            visible: dialogIcon.text.length > 0
            topPadding: control._size.verticalPadding
            bottomPadding: dialogIcon.topPadding / 2
            verticalAlignment: Text.AlignVCenter

            font {
                family: Fonts.FontInterface.iconFont.font.family
                pixelSize: control._size.iconSize
            }
        }

        Text {
            id: title

            Layout.alignment: Qt.AlignCenter
            text: control.title
            color: control._type.title
            lineHeight: control._size.lineHeight
            lineHeightMode: Text.FixedHeight
            verticalAlignment: Text.AlignVCenter

            font {
                family: Fonts.FontInterface.interFont.font.family
                pixelSize: control._size.titleSize
                variableAxes: {
                    "wght": control._size.titleWeight
                }
            }
        }
    }

    contentItem: ColumnLayout {
        id: content

        Text {
            id: info

            Layout.alignment: Qt.AlignCenter
            horizontalAlignment: Text.AlignHCenter
            text: control.info
            color: control._type.text
            lineHeight: control._size.lineHeight
            lineHeightMode: Text.FixedHeight
            bottomPadding: control._size.verticalPadding
            verticalAlignment: Text.AlignVCenter
            visible: control.info

            font {
                family: Fonts.FontInterface.interFont.font.family
                pixelSize: control._size.fontSize
                variableAxes: {
                    "wght": control._size.fontWeight
                }
            }
        }
    }

    footer: Controls.DialogButtonBox {
        id: footer

        visible: count > 0
    }

    // T.Overlay.modal: Rectangle {
    //     color: Color.transparent(control.palette.shadow, 0.5)
    // }

    // T.Overlay.modeless: Rectangle {
    //     color: Color.transparent(control.palette.shadow, 0.12)
    // }
}
