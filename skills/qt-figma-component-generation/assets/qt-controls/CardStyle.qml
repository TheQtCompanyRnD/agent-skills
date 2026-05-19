// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import Qt.Themes as Themes

QtObject {

    // BASE CLASS DEFINES THE FULL CONTROL INTERFACE

    component CardClass: QtObject {
        //base style is Primary Large
        //colors
        //background
        //move states to objects ??
        property color backgroundIdle: Themes.TokenInterface.semantics.background_muted
        property color backgroundHover: Themes.TokenInterface.semantics.background_subtle
        property color backgroundActive: Themes.TokenInterface.semantics.foreground_muted
        property color backgroundDisable: Themes.TokenInterface.semantics.foreground_subtle
        //border
        property color borderIdle: Themes.TokenInterface.semantics.stroke_subtle
        property color borderHover: Themes.TokenInterface.semantics.stroke_subtle
        property color borderActive: Themes.TokenInterface.semantics.stroke_muted
        property color borderDisable: Themes.TokenInterface.semantics.foreground_subtle
        //text
        property color textIdle: Themes.TokenInterface.semantics.text_default
        property color textHover: Themes.TokenInterface.semantics.base_white
        property color textActive: Themes.TokenInterface.semantics.text_muted
        property color textDisable: Themes.TokenInterface.semantics.text_subtle
        //Link
        property color linkTextColor: Themes.TokenInterface.semantics.text_accent
        //warning
        property color textWarning: Themes.TokenInterface.semantics.notification_alert_default
        //notification
        property color textNotification: Themes.TokenInterface.semantics.notification_success_default
        //icon
        property color iconIdle: Themes.TokenInterface.semantics.base_white
        property color iconHover: Themes.TokenInterface.semantics.base_white
        property color iconActive: Themes.TokenInterface.semantics.base_white
        property color iconDisable: Themes.TokenInterface.semantics.text_subtle

        property color progressBarTrack: Themes.TokenInterface.semantics.foreground_muted
        property color progressBar: Themes.TokenInterface.semantics.primary_default
        //sizes
        //control
        property int defaultHeight: 271
        property int defaultWidth: 252
        property int borderWidthIdle: Themes.Primitives.sizes.borderWidth
        property int borderWidthHover: Themes.Primitives.sizes.borderWidth
        property int borderWidthActive: Themes.Primitives.sizes.borderWidth
        property int borderWidthDisable: Themes.Primitives.sizes.borderWidth
        property int radius: Themes.Primitives.sizes.controlRadius
        //text
        property int fontSize:  Themes.Primitives.sizes.fontSize
        property int fontWeightLarge: Themes.Primitives.sizes.vf_600
        property int fontSizeSmall:  Themes.Primitives.sizes.fontSizeSmall
        property int fontWeightSmall: Themes.Primitives.sizes.vf_400
        //icon
        property int iconSize: Themes.Primitives.sizes.iconSize
        //paddings & gaps
        property int paddingVertical: Themes.Primitives.sizes.verticalPaddingS
        property int paddingHorizontal: Themes.Primitives.sizes.horizontalPaddingS
        property int gapHorizontal: Themes.Primitives.sizes.horizontalPaddingXXS

        //thumbnail specifics
        property int framePaddingHorizontal: Themes.Primitives.sizes.horizontalPaddingS
        property int framePaddingVertical: Themes.Primitives.sizes.verticalPaddingL

        //content specifics
        property int contentVerticalGap: Themes.Primitives.sizes.verticalGapL
    }
    property CardClass cardBaseStyle: CardClass {}


    //variant components
    //primary
    component PrimaryLarge: CardClass {}
    property PrimaryLarge primaryLarge: PrimaryLarge {}

    component PrimarySmall: CardClass {}
    property PrimarySmall primarySmall: PrimarySmall {}

    //secondary
    component SecondaryRecent: CardClass {
    }
    property SecondaryRecent secondaryRecent: SecondaryRecent {}

    component SecondaryExample: CardClass {
    }
    property SecondaryExample secondaryExample: SecondaryExample {}

    //tertiary
    component SecondaryTutorial: CardClass {
    }
    property SecondaryTutorial secondaryTutorial: SecondaryTutorial {}

    component SecondaryTour: CardClass {
    }
    property SecondaryTour secondaryTour: SecondaryTour {}
}
