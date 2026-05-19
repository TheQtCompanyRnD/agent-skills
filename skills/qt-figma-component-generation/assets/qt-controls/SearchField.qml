// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T

import Qt.Controls as Controls
import Qt.Fonts as Fonts

T.SearchField {
    id: control

    property string placeholderText: qsTr("Search...")

    property int typeVariant: SearchFieldStyle.TypeVariant.Primary
    property int sizeVariant: SearchFieldStyle.SizeVariant.Large

    property SearchFieldStyle.Type _type: {
        switch (control.typeVariant) {
            case SearchFieldStyle.TypeVariant.Primary: return SearchFieldStyle.primary

            default: return SearchFieldStyle.primary
        }
    }

    property SearchFieldStyle.Size _size: {
        switch (control.sizeVariant) {
            case SearchFieldStyle.SizeVariant.Small: return SearchFieldStyle.small
            case SearchFieldStyle.SizeVariant.Large: return SearchFieldStyle.large

            default: return SearchFieldStyle.large
        }
    }

    property SearchFieldStyle.StateStyle _style: {
        if (control.enabled && !control.focus && !control.hovered)
            return control._type.idle
        else if (control.enabled && !control.focus && control.hovered)
            return control._type.hover
        else if (control.enabled && control.focus)
            return control._type.active
        else if (!control.enabled)
            return control._type.disable

        return control._type.idle
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    spacing: control._size.spacing

    leftPadding: control._size.horizontalPadding + searchIndicator.indicator.width + spacing
    rightPadding: control._size.horizontalPadding + clearIndicator.indicator.width + spacing

    verticalPadding: control._size.verticalPadding

    delegate: Controls.ItemDelegate {
        width: ListView.view.width
        text: model[control.textRole]
        highlighted: control.highlightedIndex === index
        hoverEnabled: control.hoverEnabled

        required property var model
        required property int index

        sizeVariant: control.sizeVariant === SearchFieldStyle.SizeVariant.Small ? Controls.ItemDelegateStyle.SizeVariant.Small
                                                                                : Controls.ItemDelegateStyle.SizeVariant.Large
    }

    searchIndicator.indicator: Text {
        width: control._size.iconSize
        height: control._size.iconSize

        x: control._size.horizontalPadding
        y: control.topPadding + (control.availableHeight - height) / 2

        text: Fonts.FontInterface.icons.search_16
        color: control._style.icon

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        font {
            family: Fonts.FontInterface.iconFont.font.family
            pixelSize: control._size.iconSize
        }
    }

    clearIndicator.indicator: Controls.IconButton {
        iconGlyph: Fonts.FontInterface.icons.close_16
        sizeVariant: Controls.IconButtonStyle.SizeVariant.Small16

        x: control.width - width - control._size.horizontalPadding
        y: control.topPadding + (control.availableHeight - height) / 2

        visible: control.text.length > 0

        onClicked: {
            textInput.clear()
            textInput.forceActiveFocus()
        }
    }

    contentItem: TextInput {
        id: textInput
        text: control.text

        color: control._style.text
        selectionColor: control._style.textSelection
        selectedTextColor: control._style.textSelected
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter

        font {
            family: Fonts.FontInterface.interFont.font.family
            pixelSize: control._size.fontSize
            variableAxes: {
                "wght": control._size.fontWeight
            }
        }

        Text {
            id: placeholder

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.alignWhenCentered: false //text field placeholder is magically half a pixel off, this fixes it somehow

            text: control.placeholderText
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter

            lineHeightMode: Text.FixedHeight
            lineHeight: control._size.lineHeight

            font {
                family: Fonts.FontInterface.interFont.font.family
                pixelSize: control._size.fontSize
                variableAxes: {
                    "wght": control._size.fontWeight
                }
            }
            color: control._style.textPlaceholder
            visible: !textInput.length && !textInput.preeditText
            elide: Text.ElideRight
            renderType: textInput.renderType
        }
    }

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: control._size.lineHeight + (control._size.verticalPadding * 2)
        color: control._style.background
        radius: control._size.radius
        border {
            color: control._style.border
            width: control._size.borderWidth
        }
    }

    popup: Controls.Popup {
        y: control.height + 4 // TODO magic number
        width: control.width
        height: Math.min(contentItem.implicitHeight, control.Window.height - control.y - control.height - control.padding)

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight + control.popup.verticalPadding * 2
            model: control.delegateModel
            currentIndex: control.highlightedIndex
            highlightMoveDuration: 0

            spacing: control._size.spacing

            T.ScrollIndicator.vertical: T.ScrollIndicator { }
        }
    }
}
