// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Qt.Fonts as Fonts

T.ComboBox {
    id: control

    property int popupPosition: ComboBox.PopupPosition.Under
    property int popupGap: control._size.popupGap

    enum PopupPosition {
        Under,
        AlignedUnder,
        Centered,
        Over,
        AlignedOver
    }

    function getPopupPosition(): int {
        if (control.popupPosition === ComboBox.PopupPosition.Under)
            return control.height + control.popupGap
        else if (control.popupPosition === ComboBox.PopupPosition.AlignedUnder)
            return 0
        else if (control.popupPosition === ComboBox.PopupPosition.Over)
            return -popup.height - control.popupGap
        else if (control.popupPosition === ComboBox.PopupPosition.AlignedOver)
            return control.height - popup.height
        else if (control.popupPosition === ComboBox.PopupPosition.Centered)
            return control.height / 2 - popup.height / 2
        else {
            console.error("error with popup position")
            return 0
        }
    }

    property int typeVariant: ComboBoxStyle.TypeVariant.Primary
    property int sizeVariant: ComboBoxStyle.SizeVariant.Large

    property ComboBoxStyle.Type _type: {
        switch (control.typeVariant) {
            case ComboBoxStyle.TypeVariant.Primary: return ComboBoxStyle.primary
            case ComboBoxStyle.TypeVariant.Ghost: return ComboBoxStyle.ghost

            default: return ComboBoxStyle.primary
        }
    }

    property ComboBoxStyle.Size _size: {
        switch (control.sizeVariant) {
            case ComboBoxStyle.SizeVariant.Large: return ComboBoxStyle.large
            case ComboBoxStyle.SizeVariant.Small: return ComboBoxStyle.small

            default: return ComboBoxStyle.large
        }
    }

    property ComboBoxStyle.StateStyle _style: {
        if (control.enabled && popup.opened)
            return control._type.active
        else if (control.enabled && !control.hovered)
            return control._type.idle
        else if (control.enabled && control.hovered)
            return control._type.hover
        else if (!control.enabled)
            return control._type.disable
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    leftPadding: padding + (!control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
    rightPadding: padding + (control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)

    spacing: control._size.spacing

    delegate: T.ItemDelegate {
        required property var model
        required property int index

        implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                                implicitContentWidth + leftPadding + rightPadding)
        implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                                 implicitContentHeight + topPadding + bottomPadding,
                                 implicitIndicatorHeight + topPadding + bottomPadding)

        width: ListView.view.width

        padding: control._size.padding
        spacing: control._size.spacing

        text: model[control.textRole]
        font.weight: control._size.fontWeight
        highlighted: control.highlightedIndex === index
        hoverEnabled: control.hoverEnabled

        contentItem: Text {
            text: model[control.textRole]
            color: control._style.text
            font.pixelSize: control._size.fontSize
        }

        background: Rectangle {
            color: index === control.currentIndex ? control._style.selection : highlighted
                                                  ? control._style.highlight : control._style.background
            radius: control._size.radius
        }

        HoverHandler {
            id: delegateCursorHandler
            cursorShape: Qt.PointingHandCursor
        }
    }

    indicator: Text {
        x: control.mirrored ? control.padding : control.width - width - control.padding
        y: control.topPadding + (control.availableHeight - height) / 2
        text: Fonts.FontInterface.icons.arrowHead_down_16
        color: control._style.icon
        topPadding: control._size.verticalPadding
        bottomPadding: control._size.verticalPadding
        leftPadding: control._size.horizontalPadding
        rightPadding: control._size.horizontalPadding
        rotation: popup.opened ? 180 : 0

        font {
            family: Fonts.FontInterface.iconFont.font.family
            pixelSize: control._size.iconSize
        }
    }

    contentItem: T.TextField {
        leftPadding: !control.mirrored ? 12 : control.editable && activeFocus ? 3 : 1
        rightPadding: control.mirrored ? 12 : control.editable && activeFocus ? 3 : 1
        topPadding: 6 - control.padding
        bottomPadding: 6 - control.padding

        text: control.editable ? control.editText : control.displayText

        font {
            pixelSize: control._size.fontSize
            weight: control._size.fontWeight
        }

        enabled: control.editable
        autoScroll: control.editable
        readOnly: control.down
        inputMethodHints: control.inputMethodHints
        validator: control.validator
        selectByMouse: control.selectTextByMouse

        color: control._style.text
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        implicitWidth: control.indicator.width + control.leftPadding + control.rightPadding + control.contentItem.contentWidth
        implicitHeight: control._size.lineHeight + control._size.verticalPadding * 2

        color: control._style.background
        border.color: control._style.border
        border.width: control._size.borderWidth
        radius: control._size.radius
    }

    popup: T.Popup {
        id: popup

        y: control.getPopupPosition()

        width: control.width
        height: contentItem.implicitHeight + horizontalPadding + verticalPadding

        horizontalPadding: control._size.horizontalPadding
        verticalPadding: control._size.verticalPadding

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.delegateModel
            currentIndex: control.highlightedIndex
            highlightMoveDuration: 0
            spacing: control._size.spacing

            T.ScrollIndicator.vertical: T.ScrollIndicator { }
        }

        background: Rectangle {
            color: control._style.popup
            border.color: control._style.popupBorder
            border.width: control._size.borderWidth
            radius: control._size.radius
        }
    }

    HoverHandler {
        id: cursorHandler
        cursorShape: Qt.PointingHandCursor
    }
}
