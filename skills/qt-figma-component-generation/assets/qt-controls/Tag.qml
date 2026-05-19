// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import Qt.Fonts as Fonts

T.AbstractButton {
    id: control

    property bool dismissible: false

    signal dismiss()

    property int typeVariant: TagStyle.TypeVariant.Primary
    property int sizeVariant: TagStyle.SizeVariant.Large

    property TagStyle.Type _type: {
        switch (control.typeVariant) {
            case TagStyle.TypeVariant.Primary: return TagStyle.primary

            default: return TagStyle.primary
        }
    }

    property TagStyle.Size _size: {
        switch (control.sizeVariant) {
            case TagStyle.SizeVariant.Small: return TagStyle.small
            case TagStyle.SizeVariant.Large: return TagStyle.large

            default: return TagStyle.large
        }
    }

    property TagStyle.StateStyle _style: {
        if (control.enabled && !control.pressed && !control.checked && !control.hovered)
            return control._type.idle
        else if (control.enabled && !control.pressed && !control.checked && control.hovered)
            return control._type.hover
        else if (control.enabled && (control.pressed || control.checked))
            return control._type.active
        else if (!control.enabled)
            return control._type.disable

        return control._type.idle
    }

    text: qsTr("Tag")

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    horizontalPadding: control._size.horizontalPadding
    //verticalPadding: control._size.verticalPadding

    background: Rectangle {
        implicitWidth: 50
        implicitHeight: control._size.lineHeight + (control._size.verticalPadding * 2)

        color: control._style.background
        border {
            color: control._style.border
            width: control._style.borderWidth
        }
        radius: control._size.radius
    }

    contentItem: Item {
        implicitWidth: row.implicitWidth
        implicitHeight: row.implicitHeight

        RowLayout {
            id: row

            spacing: control._size.spacing
            layoutDirection: Qt.LeftToRight
            anchors.centerIn: parent
            anchors.fill: control.width - (control.leftPadding + control.rightPadding) <= row.implicitWidth ? parent : undefined

            Text {
                id: label
                text: control.text
                color: control._style.text

                Layout.fillWidth: true

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

            Text {
                id: icon

                visible: control.dismissible
                color: control._style.icon
                text: Fonts.FontInterface.icons.remove_16

                font {
                    family: Fonts.FontInterface.iconFont.font.family
                    pixelSize: control._size.iconSize
                }

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                HoverHandler {
                    id: cursorHandlerIcon
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    id: tapHandlerIcon
                    onTapped: () => control.dismiss()
                }
            }
        }
    }

    // do cursor changes over the control depending on state
    HoverHandler {
        id: cursorHandler
        cursorShape: {
            if (control.dismissible)
                return
            //else if (control.readOnlyTag)
            //    return Qt.IBeamCursor
            else
                return Qt.PointingHandCursor
        }
    }
}
