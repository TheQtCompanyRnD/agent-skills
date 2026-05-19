// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import Qt.Fonts as Fonts

T.TabButton {
    id: control

    property alias iconFontFamily: icon.font.family
    property alias iconRotation: icon.rotation
    property alias iconGlyph: icon.text

    property int typeVariant: TabButtonStyle.TypeVariant.Underline
    property int sizeVariant: TabButtonStyle.SizeVariant.Large

    property TabButtonStyle.Type _type: {
        switch (control.typeVariant) {
            case TabButtonStyle.TypeVariant.Underline: return TabButtonStyle.underline
            case TabButtonStyle.TypeVariant.Fill: return TabButtonStyle.fill

            default: return TabButtonStyle.underline
        }
    }

    property TabButtonStyle.Size _size: {
        switch (control.sizeVariant) {
            case TabButtonStyle.SizeVariant.Small: return TabButtonStyle.small
            case TabButtonStyle.SizeVariant.Large: return TabButtonStyle.large

            default: return TabButtonStyle.large
        }
    }

    property TabButtonStyle.StateStyle _style: {
        if (control.enabled && !control.checked && !control.hovered)
            return control._type.idle
        else if (control.enabled && !control.checked && control.hovered)
            return control._type.hover
        else if (control.enabled && control.checked)
            return control._type.active
        else if (!control.enabled)
            return control._type.disable

        return control._type.idle
    }

    enum WidthBehavior {
        Content,
        Equal
    }

    property int widthBehavior: TabButton.WidthBehavior.Content

    text: qsTr("Tab")

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    horizontalPadding: control._size.horizontalPadding
    verticalPadding: control._size.verticalPadding

    width: control.widthBehavior === TabButton.WidthBehavior.Content ? control.implicitWidth : undefined

    contentItem: Item {
        implicitWidth: row.implicitWidth
        implicitHeight: row.implicitHeight

        RowLayout {
            id: row

            spacing: control._size.spacing
            anchors.centerIn: parent

            Text {
                id: icon

                visible: icon.text.length !== 0
                color: control._style.icon

                lineHeightMode: Text.FixedHeight
                lineHeight: control._size.lineHeight

                font {
                    family: Fonts.FontInterface.iconFont.font.family
                    pixelSize: control._size.iconSize
                }
            }

            Text {
                id: label
                text: control.text
                color: control._style.text

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                elide: Text.ElideRight
                textFormat: Text.PlainText
                lineHeightMode: Text.FixedHeight
                lineHeight: control._size.lineHeight

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
    }

    background: Rectangle {
        implicitWidth: 50
        implicitHeight: control._size.lineHeight + (control._size.verticalPadding * 2)

        color: control._style.background
        radius: control._size.radius

        property int bottomRadius: control.typeVariant === TabButtonStyle.TypeVariant.Underline ? 0 : control._size.radius

        bottomLeftRadius: bottomRadius
        bottomRightRadius: bottomRadius

        Rectangle {
            visible: control._style.borderWidth
            width: parent.width
            height: control._style.borderWidth
            anchors.bottom: parent.bottom
            color: control._style.border
        }
    }
}
