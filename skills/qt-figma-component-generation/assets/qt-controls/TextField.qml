// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T

import Qt.Controls as Controls
import Qt.Fonts as Fonts

T.TextField {
    id: control

    property alias leftIconFontFamily: leftIcon.font.family
    property alias leftIconGlyph: leftIcon.text

    property alias rightIconFontFamily: rightIcon.iconFontFamily
    property alias rightIconGlyph: rightIcon.iconGlyph

    property alias iconButtonEnabled: rightIcon.enabled

    signal iconButtonClicked
    signal rejected

    property bool showError: false

    property bool error: !control.acceptableInput || control.showError

    property int typeVariant: TextFieldStyle.TypeVariant.Primary
    property int sizeVariant: TextFieldStyle.SizeVariant.Large

    property TextFieldStyle.Type _type: {
        switch (control.typeVariant) {
            case TextFieldStyle.TypeVariant.Primary: return TextFieldStyle.primary

            default: return TextFieldStyle.primary
        }
    }

    property TextFieldStyle.Size _size: {
        switch (control.sizeVariant) {
            case TextFieldStyle.SizeVariant.Small: return TextFieldStyle.small
            case TextFieldStyle.SizeVariant.Large: return TextFieldStyle.large

            default: return TextFieldStyle.large
        }
    }

    property TextFieldStyle.StateStyle _style: {
        if (control.error)
            return control._type.error
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

    placeholderText: qsTr("Text Field")

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding,
                            placeholder.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding,
                             placeholder.implicitHeight + topPadding + bottomPadding)

    topPadding: control._size.verticalPadding
    bottomPadding: control._size.verticalPadding

    leftPadding: {
        if (leftIcon.text.length === 0)
            return control._size.horizontalPadding
        else
            return leftIcon.width + control._size.horizontalPadding + control._size.spacing
    }
    rightPadding: {
        if (rightIcon.text.length === 0)
            return control._size.horizontalPadding
        else
            return rightIcon.width + control._size.horizontalPadding + control._size.spacing
    }

    font {
        family: Fonts.FontInterface.interFont.font.family
        pixelSize: control._size.fontSize
        variableAxes: {
            "wght": control._size.fontWeight
        }
    }

    color: control._style.text
    selectionColor: control._style.textSelection
    selectedTextColor: control._style.textSelected
    placeholderTextColor: control._style.textPlaceholder
    horizontalAlignment: Text.AlignLeft
    verticalAlignment: Text.AlignVCenter

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

    Text {
        id: leftIcon
        width: control._size.iconSize
        height: control._size.iconSize

        visible: leftIcon.text.length
        color: control._style.icon

        lineHeightMode: Text.FixedHeight
        lineHeight: control._size.lineHeight

        anchors.left: parent.left
        anchors.leftMargin: control._size.verticalPadding
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        font {
            family: Fonts.FontInterface.iconFont.font.family
            pixelSize: control._size.iconSize
        }

        HoverHandler {
            id: iconCursorhandler
            cursorShape: Qt.PointingHandCursor
        }
    }

    cursorDelegate: Rectangle {
        id: cursorRect
        visible: control.cursorVisible
        height: control._size.cursorHeight
        width: 1
        color: control._style.text

        Timer {
            id: blinkTimer
            interval: 500
            running: control.cursorRunning
            repeat: true
            onTriggered: control.cursorVisible = !control.cursorVisible
        }
    }

    onFocusChanged: control.cursorRunning = !control.cursorRunning
    onActiveFocusChanged: {
        if (!control.activeFocus)
            control.cursorVisible = false
    }

    property bool cursorVisible: false
    property bool cursorRunning: false

    Text {
        id: placeholder

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: control.leftPadding
        anchors.rightMargin: control.rightPadding
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
        color: control.placeholderTextColor
        visible: !control.length && !control.preeditText && (!control.activeFocus || control.horizontalAlignment !== Qt.AlignHCenter)
        elide: Text.ElideRight
        renderType: control.renderType
    }

    Controls.IconButton {
        id: rightIcon
        visible: rightIcon.iconGlyph.length
        sizeVariant: IconButtonStyle.SizeVariant.Small16
        anchors.right: parent.right
        anchors.rightMargin: control._size.verticalPadding
        anchors.verticalCenter: parent.verticalCenter

        onClicked: function() { control.iconButtonClicked() }
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            //control.editText = control.preFocusText
            //control.dirty = false
            control.focus = false
            control.cursorVisible = false
        } else if (event.key === Qt.Key_Return) {
            //control.editText = control.preFocusText
            //control.dirty = false
            control.focus = false
            control.cursorVisible = false
        }
    }
}
