// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import Qt.Fonts as Fonts

T.AbstractButton {
    id: control

    property alias leadingIconFontFamily: leadingIcon.font.family
    property alias leadingIconRotation: leadingIcon.rotation
    property alias leadingIconGlyph: leadingIcon.text

    // TODO Needs to be renamed to trailingIconButton
    property alias trailingIconFontFamily: trailingIconButton.iconFontFamily
    property alias trailingIconRotation: trailingIconButton.iconRotation
    property alias trailingIconGlyph: trailingIconButton.iconGlyph

    property int typeVariant: MenuButtonStyle.TypeVariant.Primary
    property int sizeVariant: MenuButtonStyle.SizeVariant.Large

    property MenuButtonStyle.Type _type: {
        switch (control.typeVariant) {
            case MenuButtonStyle.TypeVariant.Primary: return MenuButtonStyle.primary

            default: return MenuButtonStyle.primary
        }
    }

    property MenuButtonStyle.Size _size: {
        switch (control.sizeVariant) {
            case MenuButtonStyle.SizeVariant.Small: return MenuButtonStyle.small
            case MenuButtonStyle.SizeVariant.Large: return MenuButtonStyle.large

            default: return MenuButtonStyle.large
        }
    }

    property MenuButtonStyle.StateStyle _style: {
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

    // default text label
    text: qsTr("Menu Button")
    checkable: true

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    horizontalPadding: control._size.horizontalPadding
    //verticalPadding: control._size.verticalPadding

    // Control Implementation
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
            anchors.verticalCenter: parent.verticalCenter
            anchors.fill: parent

            Text {
                id: leadingIcon

                visible: leadingIcon.text.length !== 0
                color: control._style.icon

                font {
                    family: Fonts.FontInterface.iconFont.font.family
                    pixelSize: control._size.iconSize
                }
            }

            Text {
                id: textContent
                text: control.text
                color: control._style.text

                Layout.fillWidth: true
                //Layout.alignment: Qt.AlignVCenter

                elide: Text.ElideRight
                //textFormat: Text.PlainText
                //lineHeightMode: Text.FixedHeight
                //lineHeight: control._size.lineHeight

                //verticalAlignment: Text.AlignVCenter

                font {
                    family: Fonts.FontInterface.interFont.font.family
                    pixelSize: control._size.fontSize
                    variableAxes: {
                        "wght": control._size.fontWeight
                    }
                }
            }

            IconButton {
                id: trailingIconButton
                visible: trailingIconButton.iconGlyph.length !== 0
                sizeVariant: IconButtonStyle.SizeVariant.Small16
            }
        }
    }

    // do cursor changes over the control depending on state
    HoverHandler {
        id: cursorHandler
        cursorShape: Qt.PointingHandCursor
    }
}
