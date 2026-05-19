// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T

import Qt.Fonts as Fonts

T.Control {
    id: control

    property alias iconFontFamily: icon.font.family
    property alias iconRotation: icon.rotation
    property alias iconGlyph: icon.text

    property alias text: label.text

    property int typeVariant: BadgeLabelStyle.TypeVariant.Info
    property int sizeVariant: BadgeLabelStyle.SizeVariant.Large
    property int appearanceVariant: BadgeLabelStyle.AppearanceVariant.Filled

    property BadgeLabelStyle.Type _type: {
        switch (control.typeVariant) {
            case BadgeLabelStyle.TypeVariant.Neutral: return BadgeLabelStyle.neutral
            case BadgeLabelStyle.TypeVariant.Info: return BadgeLabelStyle.info
            case BadgeLabelStyle.TypeVariant.Alert: return BadgeLabelStyle.alert
            case BadgeLabelStyle.TypeVariant.Success: return BadgeLabelStyle.success
            case BadgeLabelStyle.TypeVariant.Danger: return BadgeLabelStyle.danger

            default: return BadgeLabelStyle.neutral
        }
    }

    property BadgeLabelStyle.Size _size: {
        switch (control.sizeVariant) {
            case BadgeLabelStyle.SizeVariant.Small: return BadgeLabelStyle.small
            case BadgeLabelStyle.SizeVariant.Medium: return BadgeLabelStyle.medium
            case BadgeLabelStyle.SizeVariant.Large: return BadgeLabelStyle.large

            default: return BadgeLabelStyle.large
        }
    }

    property bool _outline: control.appearanceVariant === BadgeLabelStyle.AppearanceVariant.Outline

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)


    horizontalPadding: control._size.horizontalPadding
    //verticalPadding: control._size.verticalPadding

    background: Rectangle {
        implicitWidth: 10
        implicitHeight: control._size.lineHeight + (control._size.verticalPadding * 2)

        color: control._outline ? "transparent" : control._type.background
        radius: control._size.radius

        border {
            width: control._outline ? control._size.borderWidth : 0
            color: control._type.border
        }
    }

    contentItem: Item {
        implicitWidth: row.implicitWidth
        implicitHeight: row.implicitHeight

        RowLayout {
            id: row

            spacing: control._size.spacing
            anchors.verticalCenter: parent.verticalCenter
            anchors.fill: parent

            Text {
                id: icon

                visible: icon.text.length !== 0
                color: control._type.label

                //lineHeightMode: Text.FixedHeight
                //lineHeight: control._size.lineHeight

                font {
                    family: Fonts.FontInterface.iconFont.font.family
                    pixelSize: control._size.iconSize
                }
            }

            Text {
                id: label
                text: qsTr("Badge")
                color: control._type.label

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                //Layout.leftMargin: control._size.horizontalLabelPadding
                //Layout.rightMargin: control._size.horizontalLabelPadding

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
}
