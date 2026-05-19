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

    property alias trailingIconFontFamily: trailingIcon.font.family
    property alias trailingIconRotation: trailingIcon.rotation
    property alias trailingIconGlyph: trailingIcon.text

    default property alias subItems: inner.children
    property bool hasSubItems: inner.children.length
    property bool isSubItem: false

    property int typeVariant: ListItemStyle.TypeVariant.Primary
    property int sizeVariant: ListItemStyle.SizeVariant.Large

    property ListItemStyle.Type _type: {
        switch (control.typeVariant) {
            case ListItemStyle.TypeVariant.Primary: return ListItemStyle.primary

            default: return ListItemStyle.primary
        }
    }

    property ListItemStyle.Size _size: {
        switch (control.sizeVariant) {
            case ListItemStyle.SizeVariant.Small: return ListItemStyle.small
            case ListItemStyle.SizeVariant.Large: return ListItemStyle.large

            default: return ListItemStyle.large
        }
    }

    property ListItemStyle.StateStyle _style: {
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
    text: qsTr("List Item")
    checkable: true

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    horizontalPadding: 6 //control.style.paddingHorizontal

    component Background: Rectangle {
        implicitWidth: 50 //control.style.defaultWidth
        implicitHeight: control._size.lineHeight + (control._size.verticalPadding * 2)

        color: control._style.background
        border {
            color: control._style.border
            width: 0
        }
        radius: control._size.radius
    }

    // Control Implementation
    background: Background {
        visible: !control.hasSubItems
    }

    contentItem: ColumnLayout {
        implicitWidth: row.implicitWidth
        implicitHeight: row.implicitHeight + inner.implicitHeight

        spacing: 4

        Item {
            Layout.fillWidth: true
            Layout.minimumHeight: control._size.lineHeight + (control._size.verticalPadding * 2)
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            Background {
                anchors.fill: parent
                anchors.leftMargin: -6
                anchors.rightMargin: -6
                visible: control.hasSubItems
            }

            RowLayout {
                id: row

                anchors.fill: parent
                //Layout.minimumHeight: control.style.defaultHeight
                //Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                spacing: 4 //control.style.gapHorizontal

                Text {
                    id: leadingIcon

                    visible: leadingIcon.text.length !== 0

                    font {
                        family: Fonts.FontInterface.iconFont.font.family
                        pixelSize: control._size.iconSize
                    }

                    color: control._style.icon
                }

                Text {
                    id: textContent
                    text: control.text

                    Layout.leftMargin: control.isSubItem ? 20 : 0 // 26 - 6 due to control padding
                    Layout.fillWidth: true

                    elide: Text.ElideRight

                    font {
                        family: Fonts.FontInterface.interFont.font.family
                        pixelSize: control._size.fontSize
                        variableAxes: {
                            //"wght": control.style.fontWeightLarge
                            "wght": control.currentState === "active" ? 600 : 500
                        }
                    }

                    color: control._style.text
                }

                Text {
                    id: trailingIcon

                    visible: control.hasSubItems || trailingIcon.text.length !== 0

                    text: control.hasSubItems ? control.checked ? Fonts.FontInterface.icons.arrow_up_16
                                                                : Fonts.FontInterface.icons.arrow_down_16
                                              : ""


                    font {
                        family: Fonts.FontInterface.iconFont.font.family
                        pixelSize: control._size.iconSize
                    }

                    color: control._style.icon
                }
            }
        }

        ColumnLayout {
            id: inner
            spacing: 4

            visible: control.hasSubItems && control.checked

            //Layout.bottomMargin: 4

            onChildrenChanged: {
                for (let i = 0; i < inner.children.length; i++) {

                    if (inner.children[i] instanceof ListItem) {
                        let subListItem = inner.children[i]
                        //subListItem.styleVariant = ListItem.StyleVariant.PrimarySmall
                        subListItem.Layout.fillWidth = true
                        subListItem.Layout.leftMargin = -control.horizontalPadding
                        subListItem.Layout.rightMargin = -control.horizontalPadding
                        subListItem.isSubItem = true
                    }
                }
            }
        }
    }

    // do cursor changes over the control depending on state
    HoverHandler {
        id: cursorHandler
        cursorShape: Qt.PointingHandCursor
    }
}
