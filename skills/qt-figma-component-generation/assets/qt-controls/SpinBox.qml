// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T

import Qt.Controls as Controls
import Qt.Fonts as Fonts

T.SpinBox {
    id: control

    property bool hasSlider: false

    property int typeVariant: SpinBoxStyle.TypeVariant.Primary
    property int sizeVariant: SpinBoxStyle.SizeVariant.Large

    property SpinBoxStyle.Type _type: {
        switch (control.typeVariant) {
            case SpinBoxStyle.TypeVariant.Primary: return SpinBoxStyle.primary

            default: return SpinBoxStyle.primary
        }
    }

    property SpinBoxStyle.Size _size: {
        switch (control.sizeVariant) {
            case SpinBoxStyle.SizeVariant.Small: return SpinBoxStyle.small
            case SpinBoxStyle.SizeVariant.Large: return SpinBoxStyle.large

            default: return SpinBoxStyle.large
        }
    }

    property SpinBoxStyle.StateStyle _style: {
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

    // Note: the width of the indicators are calculated into the padding
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)


    leftPadding: control._size.horizontalPadding + control._size.spacing
                 + (down.indicator ? down.indicator.width : 0)
    rightPadding: control._size.horizontalPadding + control._size.spacing
                  + (up.indicator ? up.indicator.width : 0)

    validator: IntValidator {
        locale: control.locale.name
        bottom: Math.min(control.from, control.to)
        top: Math.max(control.from, control.to)
    }

    contentItem: TextInput {
        id: textInput
        z: 2
        text: control.displayText

        color: control._style.text
        selectionColor: control._style.textSelection
        selectedTextColor: control._style.textSelected
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter

        //lineHeightMode: Text.FixedHeight
        //lineHeight: control._size.lineHeight

        font {
            family: Fonts.FontInterface.interFont.font.family
            pixelSize: control._size.fontSize
            variableAxes: {
                "wght": control._size.fontWeight
            }
        }
    }

    up.indicator: Controls.Indicator {
        pressed: control.up.pressed
        enabled: control.value !== control.to

        x: control._size.horizontalPadding
        y: (control.height - up.indicator.height - down.indicator.height) / 2

        PathMove { x: 1.5; y: 4.5 }
        PathLine { x: 5; y: 1.5 }
        PathLine { x: 8.5; y: 4.5 }
    }

    down.indicator: Controls.Indicator {
        pressed: control.down.pressed
        enabled: control.value !== control.from

        x: control._size.horizontalPadding
        y: up.indicator.y + up.indicator.height

        PathMove { x: 1.5; y: 1.5 }
        PathLine { x: 5; y: 4.5 }
        PathLine { x: 8.5; y: 1.5 }
    }

    Controls.IconButton {
        id: dropPanelButton
        sizeVariant: Controls.IconButtonStyle.SizeVariant.Small16
        visible: control.hasSlider
        iconGlyph: Fonts.FontInterface.icons.arrow_down_16
        z: 30
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        checkable: true
        onToggled: {
            if (dropPanelButton.checked)
                popup.open()
            else
                popup.close()
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

    Controls.Popup {
        id: popup
        y: control.height + control._size.popupGap
        z: 25
        width: control.width
        height: slider.height + popup.verticalPadding * 2
        popupType: Controls.Popup.Item
        closePolicy: Controls.Popup.CloseOnPressOutsideParent
        clip: false

        Controls.Slider {
            id: slider
            width: popup.width - popup.horizontalPadding * 2

            sizeVariant: control.sizeVariant === SpinBoxStyle.SizeVariant.Small ? SliderStyle.SizeVariant.Small
                                                                                : SliderStyle.SizeVariant.Large
        }

        onOpened: control.focus = true
        onAboutToHide:  {
            dropPanelButton.checked = false
            control.focus = false
        }
    }

    onActiveFocusChanged: popup.close()

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            //control.editText = control.preFocusText
            //control.dirty = false
            control.focus = false
            // This is available in all editors.
            popup.close()
            dropPanelButton.checked = false
        }
        if (event.key === Qt.Key_Return) {
            //control.editText = control.preFocusText
            //control.dirty = false
            control.focus = false
            popup.close()
            dropPanelButton.checked = false
        }
    }
}
