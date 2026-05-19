// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T

import Qt.Fonts as Fonts

T.AbstractButton {
    id: control

    property alias iconFontFamily: icon.font.family
    property alias iconRotation: icon.rotation
    property alias iconGlyph: icon.text
    property alias label: label

    property int iconPosition: Button.IconPosition.Left

    enum IconPosition {
        Left,
        Right
    }

    function getIconPosition(): int {
        if (control.iconPosition === Button.IconPosition.Left)
            return Qt.LeftToRight
        else if (control.iconPosition === Button.IconPosition.Right)
            return Qt.RightToLeft

        console.error("button position can only be IconPosition.Left or IconPosition.Right")
        return Qt.LeftToRight
    }

    property int typeVariant: ButtonStyle.TypeVariant.Primary
    property int sizeVariant: ButtonStyle.SizeVariant.Large

    property ButtonStyle.Type _type: {
        switch (control.typeVariant) {
            case ButtonStyle.TypeVariant.Primary: return ButtonStyle.primary
            case ButtonStyle.TypeVariant.Secondary: return ButtonStyle.secondary
            case ButtonStyle.TypeVariant.Tertiary: return ButtonStyle.tertiary
            case ButtonStyle.TypeVariant.Ghost: return ButtonStyle.ghost

            default: return ButtonStyle.primary
        }
    }

    property ButtonStyle.Size _size: {
        switch (control.sizeVariant) {
            case ButtonStyle.SizeVariant.Small: return ButtonStyle.small
            case ButtonStyle.SizeVariant.Medium: return ButtonStyle.medium
            case ButtonStyle.SizeVariant.Large: return ButtonStyle.large

            default: return ButtonStyle.large
        }
    }

    property ButtonStyle.StateStyle _style: {
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

    // check to see if an icon should be shown
    property bool allowIcon: {
        if (icon.text.length === 0)
            return false

        if (control.sizeVariant === ButtonStyle.SizeVariant.Large)
            return true

        console.error(Qt.enumValueToString(ButtonStyle.SizeVariant, control.sizeVariant),
                      "buttons are not allowed icons")
        return false
    }

    text: qsTr("Button")

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
            layoutDirection: control.getIconPosition()
            anchors.centerIn: parent
            anchors.fill: control.width - (control.leftPadding + control.rightPadding) <= row.implicitWidth ? parent : undefined

            Text {
                id: icon

                visible: control.allowIcon
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

                Layout.leftMargin: control._size.horizontalLabelPadding
                Layout.rightMargin: control._size.horizontalLabelPadding

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

    // do cursor changes over the control depending on state
    HoverHandler {
        id: cursorHandler
        //parent: control.parent
        //target: control
        cursorShape: {
            return Qt.PointingHandCursor

            //come back to this for mitch later
            // if (!control.enabled)
            //     return Qt.ForbiddenCursor
            // else
            //     return Qt.PointingHandCursor // never gets here?
        }
    }
}
