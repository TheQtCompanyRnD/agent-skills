// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Controls
import QtQml.Models
import QtQuick.Templates as T
import Qt.Fonts as Fonts
import Qt.Controls as Controls

Item {
    id: control
    width: 200
    height: searchControl.height

    // variant style properties
    enum StyleVariant {
        PrimaryLarge
    }

    //enum for variant stlyes
    property int styleVariant: SearchMenu.StyleVariant.PrimaryLarge

    // integration properties io - used for controls embedded inside each other
    property bool hoverSend
    property bool hoverRecieve
    property bool activeSend
    property bool activeRecieve

    SearchMenuStyle { id: searchMenuStyle }

    property SearchMenuStyle.SearchMenuClass style: {
        switch (control.styleVariant) {
            case SearchMenu.StyleVariant.PrimaryLarge: return searchMenuStyle.primaryLarge
            default: return searchMenuStyle.primaryLarge
        }
    }

    Controls.TextField {
        id: searchControl
        width: control.width
        leftIconGlyph: Fonts.FontInterface.icons.search_16
        rightIconGlyph: Fonts.FontInterface.icons.remove_16

        iconButtonEnabled: searchControl.text !== ""

        onIconButtonClicked: {
            searchControl.text = ""
            popupMenu.open()
            searchControl.focus = true
        }

        placeholderText: "Search..."
        onTextChanged: sortFilterModel.update()
        onActiveFocusChanged: if (activeFocus) popupMenu.open()
        onReleased: searchControl.focus = !searchControl.focus
        onPressed: searchControl.focus = !searchControl.focus
    }

    property int maxSize: 300

    T.Popup {
        id: tagPopup
        popupType: Popup.Item
        closePolicy: Popup.NoAutoClose
        visible: tagNameModel.count > 0 && searchControl.activeFocus // Show only when tags exist and search control is focused
        width: searchControl.width
        y: control.height + 4
        implicitHeight: Math.min(tagFlow.implicitHeight, control.tagPopMax) // Cap height

        background: Rectangle {
            color: control.style.popupBackground
            border.color: control.style.popupOutline
            radius: control.style.popupRadius
        }

        Flickable {
            id: flickable
            width: parent.width
            clip: true
            contentHeight: tagFlow.implicitHeight
            implicitHeight:  Math.min(tagFlow.implicitHeight, control.tagPopMax) // Cap height
            boundsBehavior: Flickable.StopAtBounds
            onContentHeightChanged:  {
                if (tagPopup.height < (control.tagPopMax - 10))
                    return
                else
                    tagPopup.scrollToBottom() // Auto-scroll when content changes
            }

            Flow {
                id: tagFlow
                spacing: 8
                width: parent.width
                padding: 8

                Repeater { model: tagModel }
            }
        }

        function scrollToBottom() {
            console.log("flicked")
            flickable.flick(0, -400); // flick down when contentHeight changes
        }

        onHeightChanged: control.sortPos() // check position of both popup when the height changes
    }

    property int tagPopMax: 80
    property bool showTags: false

    T.Popup {
        id: popupMenu
        popupType : Popup.Item
        width: searchControl.width
        y: control.height + 4
        height: {
            if ((popupListView.implicitHeight + 16) > control.maxSize)
                return control.maxSize
            else
                return popupListView.implicitHeight + 16
        }
        padding: 8
        visible: searchControl.activeFocus

        contentItem: ListView {
            id: popupListView
            model: {
                if (popupMenu.visible) {
                    if (sortFilterModel.count)
                        return sortFilterModel
                    else
                        return noMatchesModel
                }

                return null
            }
            clip: true
            implicitHeight: contentHeight
            spacing: 8
            ScrollIndicator.vertical: ScrollIndicator {}
        }

        background: Rectangle {
            color: control.style.popupBackground
            border.color: control.style.popupOutline
            radius: control.style.popupRadius
        }
        onClosed: {
            searchControl.focus = false
        }
    }

    property var sortModel:  ListModel {
        id: sourceModelSort
        ListElement { name: "Banana" }
        ListElement { name: "Apple" }
        ListElement { name: "Coconut" }
    }
    // use inline component for keeping module clean

    SortFilterModel {
        id: sortFilterModel
        model: control.sortModel
        filterAcceptsItem: function(item) {
            return item.name.toLowerCase().includes(searchControl.text.toLowerCase())
        }

        lessThan: function(left, right) {
            var leftVal = left.name;
            var rightVal = right.name;
            return leftVal < rightVal ? -1 : 1;
        }
        delegate: Component {
            id: buttonDelegate

            T.ItemDelegate {
                id: dropdownDelegateButton

                required property var model
                required property int index
                required property string name

                // property for holding the state
                property string currentState: dropdownDelegateButton.getDropState()

                width: ListView.view.width
                height: 24

                //more hacks
                enabled: {
                    if (popupMenu.visible) {
                        if (sortFilterModel.count)
                            return true
                        else
                            return false
                    }
                }

                checkable: false

                onClicked: control.moveToTags(index)

                background: Rectangle {
                    id: buttonBackground
                    anchors.fill: parent
                    color: {
                        if (dropdownDelegateButton.currentState === "idle") // idle state
                            return control.style.delegateBackgroundIdle
                        else if (dropdownDelegateButton.currentState === "hover") // hover state
                            return control.style.delegateBackgroundHover
                        else if (dropdownDelegateButton.currentState === "active") // active state
                            return control.style.delegateBackgroundActive
                        else if (dropdownDelegateButton.currentState === "disable") // disabled state
                            return control.style.delegateBackgroundDisable
                        else console.error("error with styles")
                        return "red"
                    }

                    border.color: {
                        if (dropdownDelegateButton.currentState === "idle") // idle state
                            return control.style.delegateBorderIdle
                        else if (dropdownDelegateButton.currentState === "hover") // hover state
                            return control.style.delegateBorderHover
                        else if (dropdownDelegateButton.currentState === "active") // active state
                            return control.style.delegateBorderActive
                        else if (dropdownDelegateButton.currentState === "disable") // disabled state
                            return control.style.delegateBorderDisable
                        else console.error("error with styles")
                        return "red" //error with styles
                    }

                    border.width: 1
                    radius: control.style.radius
                }

                contentItem: Item {
                    anchors.left: dropdownDelegateButton.left
                    anchors.leftMargin: control.style.paddingHorizontal
                    anchors.right: dropdownDelegateButton.right
                    anchors.rightMargin: control.style.paddingHorizontal

                    Row {
                        id: textIconPositioner
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: control.style.gapHorizontal
                        layoutDirection: Qt.RightToLeft

                        Text {
                            id: textContent
                            //bind to the model text
                            text: name

                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight

                            // use variable weight inter font from font interface
                            font.family: Fonts.FontInterface.interFont.font.family
                            // use variable weight definitions from tokens
                            font.variableAxes: {
                                "wght": control.style.fontWeightLarge
                            }
                            font.pixelSize: control.style.fontSize

                            color: {
                                if (dropdownDelegateButton.currentState === "idle") // idle state
                                    return control.style.textIdle
                                else if (dropdownDelegateButton.currentState === "hover") // hover state
                                    return control.style.textHover
                                else if (dropdownDelegateButton.currentState === "active") // active state
                                    return control.style.textActive
                                else if (dropdownDelegateButton.currentState === "disable") // disabled state
                                    return control.style.textDisable
                                else console.error("error with styles")
                                return "red" //error with styles
                            }
                        }

                        Item {
                            id: iconPositioner
                            width: 16
                            height: 16
                            visible: false //not needed in multi search menu

                            Text {
                                id: buttonIcon
                                anchors.verticalCenter: parent.verticalCenter
                                visible: dropdownDelegateButton.checked
                                text: Fonts.FontInterface.icons.tickMark_16
                                font.family: Fonts.FontInterface.iconFont.font.family
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: control.style.iconSize

                                color: {
                                    if (dropdownDelegateButton.currentState === "idle") // idle state
                                        return control.style.iconIdle
                                    else if (dropdownDelegateButton.currentState === "hover") // hover state
                                        return control.style.iconHover
                                    else if (dropdownDelegateButton.currentState === "active") // active state
                                        return control.style.iconActive
                                    else if (dropdownDelegateButton.currentState === "disable") // disabled state
                                        return control.style.iconDisable
                                    else console.error("error with styles")
                                    return "red" //error with styles
                                }
                            }
                        }
                    }
                }

                //do cursor changes over the control depending on state
                HoverHandler {
                    id: delegateCursorHandler
                    cursorShape: Qt.PointingHandCursor
                }

                //get the control state
                function getDropState() {
                    if (!dropdownDelegateButton.pressed && !dropdownDelegateButton.checked && !dropdownDelegateButton.hovered && dropdownDelegateButton.enabled) // idle state
                        return "idle"
                    else if (!dropdownDelegateButton.checked && dropdownDelegateButton.hovered && dropdownDelegateButton.enabled) // hover state
                        return "hover"
                    else if (dropdownDelegateButton.checked && dropdownDelegateButton.enabled) // active state
                        return "active"
                    else if (!dropdownDelegateButton.enabled) // disabled state
                        return "disable"
                    else
                        return console.error("not in a state") //error with states
                }
            }
        }
    }

    DelegateModel {
        id: noMatchesModel

        model: ListModel {
            ListElement { name: "No matches" }
        }

        delegate: buttonDelegate
    }

    property var tagNameModel: ListModel {} // Model for selected tags

    DelegateModel {
        id: tagModel

        model: tagNameModel

        delegate: Controls.Tag {
            dismissible: true
            sizeVariant: Controls.TagStyle.SizeVariant.Large
            text: name
            onDismiss: moveToButtons(index) // Move back on dismiss

        }
        onModelUpdated: {
            control.sortPos()
            //console.log("fired", popupMenu.y)
        }
    }

    function sortPos() {
        //console.log("test")
        if (tagNameModel.count > 0) {
            //console.log("passed")
            popupMenu.y = tagPopup.height + control.height + 8
        }
        else {
            //console.log("fail")
            popupMenu.y = control.height + 4
        }
    }

    function moveToTags(index) {
        var item = control.sortModel.get(index); // Get the item
        control.tagNameModel.append({ name: item.name }); // Add to tag model
        control.sortModel.remove(index); // Remove from button model
    }

    function moveToButtons(index) {
        var item = control.tagNameModel.get(index); // Get the item
        control.sortModel.append({ name: item.name }); // Add back to button model
        control.tagNameModel.remove(index); // Remove from tag model
    }
}
