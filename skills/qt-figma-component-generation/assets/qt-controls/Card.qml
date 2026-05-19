// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import Qt.Controls as Controls
import Qt.Fonts as Fonts

Item {
    id: control

    //properties to mimic the button
    property bool enabled: true
    property string text: qsTr("Card Title")

    //signals
    //main card button
    signal clicked()
    // download
    signal downloadClicked()
    //cancel
    signal cancelClicked()
    //update
    signal updateClicked()
    //finished
    signal downloadFinished()

    //fake button-fu must only use handlers, no mouse areas allowed
    TapHandler {
        id: controlTap
        onTapped: () => control.clicked()

        //used when either no project is downloaded or one is downloading to block the click event until a project is downloaded.
        enabled: {
            if (control.styleVariant === Card.StyleVariant.SecondaryExample)
                if ((control.isDownloading || control.isUpdating) || !control.wasDownloaded)
                    return false
                else
                    return true
            else
                return true
        }
    }

    HoverHandler {
        id: controlArea

        //used when either no project is downloaded or one is downloading to indicate that you can't open a project you have not downloaded.
        cursorShape: {
            if (control.styleVariant === Card.StyleVariant.SecondaryExample)
                if ((control.isDownloading || control.isUpdating) || !control.wasDownloaded)
                    return Qt.ForbiddenCursor
                else
                    return
            else
                return Qt.PointingHandCursor
        }
    }

    // aliases
    // need alias list, project name, description, etc

    property string thumbnail
    property bool hasBadge: true
    property string badgeText: "Badge"
    property string subText: "This is a description"
    property string description:"Card Descritption is a maximum of 500 charecters"

    // variant style properties
    enum StyleVariant {
        PrimaryLarge,
        PrimarySmall,
        SecondaryRecent,
        SecondaryExample,
        SecondaryTutorial,
        SecondaryTour
    }

    //enum for variant stlyes
    property int styleVariant: Card.StyleVariant.PrimaryLarge

    // property for holding the state
    property string currentState: control.getState()

    // integration properties io - used for controls embedded inside each other
    property bool hoverSend:  (controlArea.hovered || linkHoverHandler.hovered || tag.hovered || maskHandler.hovered)
    property bool hoverRecieve: (download.hovered || cancel.hovered || update.hovered || linkHoverHandler.hovered || tag.hovered || maskHandler.hovered)
    property bool activeSend:   controlTap.pressed
    property bool activeRecieve: false

    CardStyle {
        id: cardStyle
    }

    property CardStyle.CardClass style: {
        switch (control.styleVariant) {
        case Card.StyleVariant.PrimaryLarge: return cardStyle.primaryLarge
        case Card.StyleVariant.PrimarySmall: return cardStyle.primarySmall
        case Card.StyleVariant.SecondaryRecent: return cardStyle.secondaryRecent
        case Card.StyleVariant.SecondaryExample: return cardStyle.secondaryExample
        case Card.StyleVariant.SecondaryTutorial: return cardStyle.secondaryTutorial
        case Card.StyleVariant.SecondaryTour: return cardStyle.secondaryTour
        default: return cardStyle.primaryLarge
        }
    }

    implicitWidth: control.style.defaultWidth
    implicitHeight: control.style.defaultHeight

    // Control Implementation

    Rectangle {
        id: cardBackground
        anchors.fill: parent
        color: {
            if (control.currentState === "idle") // idle state
                return control.style.backgroundIdle
            else if (control.currentState === "hover") // hover state
                return control.style.backgroundHover
            else if (control.currentState === "active") // active state
                return control.style.backgroundActive
            else if (control.currentState === "disable") // disabled state
                return control.style.backgroundDisable
            else console.error("error with styles")
            return "red"
        }
        border.color: {
            if (control.currentState === "idle") // idle state
                return control.style.borderIdle
            else if (control.currentState === "hover") // hover state
                return control.style.borderHover
            else if (control.currentState === "active") // active state
                return control.style.borderActive
            else if (control.currentState === "disable") // disabled state
                return control.style.borderDisable
            else console.error("error with styles")
            return "red" //error with styles
        }
        border.width: {
            if (control.currentState === "idle") // idle state
                return control.style.borderWidthIdle
            else if (control.currentState === "hover") // hover state
                return control.style.borderWidthHover
            else if (control.currentState === "active") // active state
                return control.style.borderWidthActive
            else if (control.currentState === "disable") // disabled state
                return control.style.borderWidthDisable
            else console.error("error with styles")
            return 1 //error with styles
        }
        radius: control.style.radius
    }

    Rectangle {
        id: thumbnailFrame
        height: 162
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: control.style.framePaddingHorizontal
        anchors.rightMargin: control.style.framePaddingHorizontal
        anchors.topMargin: control.style.framePaddingVertical
        color: {
            if (control.currentState === "idle") // idle state
                return control.style.backgroundIdle
            else if (control.currentState === "hover") // hover state
                return control.style.backgroundHover
            else if (control.currentState === "active") // active state
                return control.style.backgroundActive
            else if (control.currentState === "disable") // disabled state
                return control.style.backgroundDisable
            else console.error("error with styles")
            return "red"
        }
        border.color: {
            if (control.currentState === "idle") // idle state
                return control.style.borderIdle
            else if (control.currentState === "hover") // hover state
                return control.style.borderHover
            else if (control.currentState === "active") // active state
                return control.style.borderActive
            else if (control.currentState === "disable") // disabled state
                return control.style.borderDisable
            else console.error("error with styles")
            return "red" //error with styles
        }
        border.width: control.style.borderWidthIdle
        radius: control.style.radius

        Image {
            id: thumbnail
            visible: !maskHandler.hovered
            anchors.fill: parent
            anchors.margins: 1 //needs a pixel offset to account for the clipped corners, best solution i found so far
            source: control.thumbnail
            z: 1
            fillMode: Image.PreserveAspectCrop // maybe we want fit here
        }
/*
        MultiEffect {
            id: hoverBlur
            visible: maskHandler.hovered
            source: thumbnail
            anchors.fill: thumbnail
            blurEnabled: true
            blurMax: 64
            blur: 0.5
            clip: true //clipping doesn't really work on small images with round corners, the edge pixels are always there.
            z: 1 // z fighting with multieffect
        }
*/
        HoverHandler {
            id: maskHandler
            cursorShape: {
                if (control.styleVariant === Card.StyleVariant.SecondaryExample)
                    if ((control.isDownloading || control.isUpdating) || !control.wasDownloaded)
                        return  Qt.ForbiddenCursor //Qt.WhatsThisCursor // this is not working
                    else
                        return Qt.PointingHandCursor
                    else
                        return Qt.PointingHandCursor
            }
        }
    }

    Rectangle {
        id: opactityMask
        visible: maskHandler.hovered
        anchors.fill: control
        anchors.margins: 1
        color: control.style.backgroundHover
        opacity: 0.8
        radius: 4
        z: 1 // z fighting with multieffect
    }

    Text {
        id: description
        anchors.fill: thumbnailFrame
        visible: { //this is broken
            if (maskHandler.hovered)
                return true
            else if (!controlArea.hovered)
                return false
            else
                return false
        }
        anchors.margins: 20
        text: control.description
        // use variable weight inter font from font interface
        font.family: Fonts.FontInterface.interFont.font.family
        // use variable weight definitions from tokens
        font.variableAxes: {
            "wght": control.style.fontWeightSmall
        }
        font.pixelSize: control.style.fontSizeSmall
        color: control.style.textIdle
        //wrapping for the block
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        lineHeightMode: Text.FixedHeight
        lineHeight: 12
        z: 10 // z fighting with multieffect
    }

    //adding props here for wip

    property bool isDownloading: false
    property bool wasDownloaded: false
    property bool isUpdating: false
    property bool wasSuccess: false

    //
    property int currentProgress: 100

    // Mock Download Logic
    function startDownload() {
        if (!control.isDownloading && !control.wasDownloaded) {
            control.isDownloading = true
            control.currentProgress = 0
            progressAnimator.start()
        }
    }

    function cancelDownload() {
        if (control.isDownloading || control.isUpdating) {
            control.isDownloading = false
            control.isUpdating = false
            progressAnimator.stop()
            control.currentProgress = 0
        }
    }

    function startUpdate() {
        if (wasDownloaded && !isUpdating) {
            control.isUpdating = true
            control.currentProgress = 0
            progressAnimator.start()
        }
    }

    // Progress Animation
    NumberAnimation on currentProgress {
        id: progressAnimator
        duration: 3000
        from: 0
        to: 100
        running: false
        onStopped: {
            if (control.currentProgress >= 100) {
                control.isDownloading = false
                control.isUpdating = false
                control.wasDownloaded = true
                control.downloadFinished()
                control.wasSuccess = true
                successTimer.start()
            }
        }
    }

    Timer {
        id: successTimer
        interval: 1000 // Show success icon for 1 second
        repeat: false
        onTriggered: {
            control.wasSuccess = false
        }
    }

    // Test signal for animation completion
    onDownloadFinished: {
        console.log("Download completed!")
    }

    //test
    onClicked: console.log("card clicked")
    onDownloadClicked: {
        control.startDownload()
        console.log("download clicked")
    }
    onCancelClicked: {
        control.cancelDownload()
        console.log("cancel clicked")
    }
    onUpdateClicked: {
        control.startUpdate()
        console.log("update clicked")
    }

    Text {
        id: cardTitle
        anchors.left: parent.left
        anchors.top: thumbnailFrame.bottom
        anchors.right: iconButtonRow.left
        anchors.leftMargin: control.style.framePaddingHorizontal
        anchors.topMargin: control.style.contentVerticalGap
        anchors.rightMargin: 20 //needs design definition
        text: {
            if (update.hovered)
                return "Overwrite Local File?"
            else if (download.hovered)
                return "Download Example?"
            else
                return control.text
        }
        height: download.height //hacky
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
            if (update.hovered)
                return control.style.textWarning
            else if (download.hovered)
                return control.style.textNotification
            else
                return control.style.textIdle
        }
        z: 2
    }

    Row {
        id: iconButtonRow
        visible: {
            if (control.styleVariant === Card.StyleVariant.SecondaryExample)
                return true
            else
                return false
            }
        z: 2
        anchors.right: parent.right
        anchors.top: thumbnailFrame.bottom
        anchors.rightMargin: control.style.framePaddingHorizontal
        anchors.topMargin: control.style.contentVerticalGap

        // needs icon per action and custom signal
        Controls.IconButton {
            id: download
            sizeVariant: IconButtonStyle.SizeVariant.Small16
            iconGlyph: Fonts.FontInterface.icons.download_16
            visible: !(control.isDownloading || control.isUpdating || control.wasDownloaded) // needs to be state dependent
            onClicked: () => control.downloadClicked()
            onCheck: console.log(download.hovered)
            hoverRecieve: control.hoverSend
        }

        Text {
            id: success
            width: download.width
            height: download.height

            anchors.verticalCenter: parent.verticalCenter

            visible: control.wasSuccess //this is shown for one second after a succesfull download

            text: Fonts.FontInterface.icons.apply_16
            font.family: Fonts.FontInterface.iconFont.font.family
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: control.style.iconSize
            color: control.style.progressBar
        }

        Controls.IconButton {
            id: cancel
            sizeVariant: IconButtonStyle.SizeVariant.Small16
            visible: (control.isDownloading || control.isUpdating) // needs to be state dependent
            iconGlyph: Fonts.FontInterface.icons.remove_16
            onClicked: () => control.cancelClicked()
            hoverRecieve: control.hoverSend

        }
        Controls.IconButton {
            id: update
            sizeVariant: IconButtonStyle.SizeVariant.Small16
            visible: !(control.isDownloading || control.isUpdating || control.wasSuccess) && control.wasDownloaded // needs to be state dependent
            iconGlyph: Fonts.FontInterface.icons.update_16
            onClicked: () => control.updateClicked()
            hoverRecieve: control.hoverSend
        }
    }

    Item {
        id: progress
        visible: (control.isDownloading || control.isUpdating)
        anchors.left: parent.left
        anchors.top: iconButtonRow.bottom
        anchors.right: parent.right
        anchors.leftMargin: control.style.framePaddingHorizontal
        anchors.topMargin: control.style.contentVerticalGap
        anchors.rightMargin: control.style.framePaddingHorizontal

        Rectangle {
            id: progressBarTrack
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 4
            radius: progressBarTrack.height / 2
            color: control.style.progressBarTrack
        }

        Rectangle {
            id: progressBar
            anchors.top: parent.top
            anchors.left: parent.left
            height: 4
            width: (control.currentProgress / 100) * progressBarTrack.width
            radius: progressBarTrack.height / 2
            color: control.style.progressBar
        }

        Text {
            id: downloadLabel
            visible: (control.isDownloading || control.isUpdating)
            anchors.left: parent.left
            anchors.top: progressBarTrack.bottom
            anchors.topMargin: control.style.contentVerticalGap
            text: "Downloading..."
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight

            // use variable weight inter font from font interface
            font.family: Fonts.FontInterface.interFont.font.family
            // use variable weight definitions from tokens
            font.variableAxes: {
                "wght": control.style.fontWeightSmall
            }
            font.pixelSize: control.style.fontSizeSmall
            color: control.style.textActive
            z: 2

        }

        Text {
            id: downloadPercent
            visible: (control.isDownloading || control.isUpdating)
            anchors.right: parent.right
            anchors.top: progressBarTrack.bottom
            anchors.topMargin: control.style.contentVerticalGap
            text: control.currentProgress + "%"
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignRight

            // use variable weight inter font from font interface
            font.family: Fonts.FontInterface.interFont.font.family
            // use variable weight definitions from tokens
            font.variableAxes: {
                "wght": control.style.fontWeightSmall
            }
            font.pixelSize: control.style.fontSizeSmall
            color: control.style.textActive
            z: 2
        }
    }

    Text {
        id: cardSubtitle
        visible: !(control.isDownloading || control.isUpdating)
        anchors.left: parent.left
        anchors.top: iconButtonRow.bottom
        anchors.leftMargin: control.style.framePaddingHorizontal
        anchors.topMargin: control.style.contentVerticalGap
        anchors.rightMargin: control.style.framePaddingHorizontal
        text: control.subText
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight

        //link stuff
        textFormat: Text.StyledText
        onLinkActivated: (link)=> console.log(link + " link activated")
        linkColor: control.style.linkTextColor

        // use variable weight inter font from font interface
        font.family: Fonts.FontInterface.interFont.font.family
        // use variable weight definitions from tokens
        font.variableAxes: {
            "wght": control.style.fontWeightSmall
        }
        font.pixelSize: control.style.fontSizeSmall
        color: control.style.textActive

        TextMetrics {
        id: subLableMetrics
        //elide when required, hug when not
        //TODO
        }

        HoverHandler {
            id: linkHoverHandler
            cursorShape: {
                //this allows you to click documentation links when there is no downloaded example
                if (control.styleVariant === Card.StyleVariant.SecondaryExample)
                    return Qt.PointingHandCursor
                else
                    return
            }
        }
        z: 2 // z fighting with multieffect
    }

    Rectangle {
        id: div
        visible: !(control.isDownloading || control.isUpdating)
        height: 1
        anchors.left: parent.left
        anchors.top: cardSubtitle.bottom
        anchors.right: parent.right
        anchors.leftMargin: control.style.framePaddingHorizontal
        anchors.topMargin: control.style.contentVerticalGap
        anchors.rightMargin: control.style.framePaddingHorizontal
        color: {
            if (control.currentState === "idle") // idle state
                return control.style.borderIdle
            else if (control.currentState === "hover") // hover state
                return control.style.borderHover
            else if (control.currentState === "active") // active state
                return control.style.borderActive
            else if (control.currentState === "disable") // disabled state
                return control.style.borderDisable
            else console.error("error with styles")
            return "red" //error with styles
        }
        z: 2 // z fighting with multieffect
    }

    Row {
        visible: !(control.isDownloading || control.isUpdating)
        anchors.left: parent.left
        anchors.top: div.bottom
        anchors.right: parent.right
        anchors.leftMargin: control.style.framePaddingHorizontal
        anchors.topMargin: control.style.contentVerticalGap
        anchors.rightMargin: control.style.framePaddingHorizontal
        z: 2 // z fighting with multieffect

        Text {
            id: tagLabel
            height: tag.height //hacky
            text: "Tags:"
            // use variable weight inter font from font interface
            font.family: Fonts.FontInterface.interFont.font.family
            verticalAlignment: Text.AlignVCenter
            // use variable weight definitions from tokens
            font.variableAxes: {
                "wght": control.style.fontWeightSmall
            }
            font.pixelSize: control.style.fontSizeSmall
            color: control.style.textActive
        }

        //Repeater {
        //wrapping in this repeater breaks the height, which i don't understand but think means this whole section is shit.
            Controls.Tag {
                id: tag
                sizeVariant: Controls.TagStyle.SizeVariant.Small
                //readOnlyTag: true //for demoing non clickable tags
                text: "My Tag"
                onClicked: console.log("tag clicked")
            }
        //}
    }

    Controls.BadgeLabel {
        id: cardBadge
        visible: control.hasBadge
        text: control.badgeText
        z: 2 // z fighting with multieffect
    }

    //get the control state
    function getState() {
        if (!controlTap.pressed  && !controlArea.hovered &&  !control.hoverRecieve && control.enabled) // idle state
            return "idle"
        else if (!controlTap.pressed && (controlArea.hovered || control.hoverRecieve) && control.enabled) // hover state
            return "hover"
        else if (controlTap.pressed && control.enabled) // active state
            return "active"
        else if (control.enabled) // disabled state
            return "disable"
        else {
            console.error("not in a state")
            return "idle"
        }
    }
}
