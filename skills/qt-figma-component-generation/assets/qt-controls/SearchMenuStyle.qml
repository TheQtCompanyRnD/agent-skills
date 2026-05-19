// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import Qt.Themes as Themes

QtObject {

    // BASE CLASS DEFINES THE FULL CONTROL INTERFACE

    component SearchMenuClass: QtObject {
        //base style is Primary Large
        //colors

        // dropdown control
        //background Control
        property color backgroundIdle: Themes.TokenInterface.semantics.background_muted
        property color backgroundHover: Themes.TokenInterface.semantics.background_muted
        property color backgroundActive: Themes.TokenInterface.semantics.background_muted
        property color backgroundDisable: Themes.TokenInterface.semantics.background_muted
        //border Control
        property color borderIdle: Themes.TokenInterface.semantics.stroke_subtle
        property color borderHover: Themes.TokenInterface.semantics.stroke_muted
        property color borderActive: Themes.TokenInterface.semantics.stroke_subtle
        property color borderDisable: Themes.TokenInterface.transparent
        //text Control
        property color textIdle: Themes.TokenInterface.semantics.text_muted
        property color textHover: Themes.TokenInterface.semantics.text_muted
        property color textActive: Themes.TokenInterface.semantics.text_default
        property color textDisable: Themes.TokenInterface.semantics.text_subtle
        //icon Handle
        property color iconIdle: Themes.TokenInterface.semantics.text_muted
        property color iconHover: Themes.TokenInterface.semantics.text_muted
        property color iconActive: Themes.TokenInterface.semantics.text_default
        property color iconDisable: Themes.TokenInterface.semantics.text_subtle

        // delegate button
        //background Control
        property color delegateBackgroundIdle: Themes.TokenInterface.transparent
        property color delegateBackgroundHover: Themes.TokenInterface.semantics.foreground_subtle
        property color delegateBackgroundActive: Themes.TokenInterface.semantics.foreground_muted
        property color delegateBackgroundDisable: Themes.TokenInterface.transparent
        //border Control
        property color delegateBorderIdle: Themes.TokenInterface.transparent
        property color delegateBorderHover: Themes.TokenInterface.semantics.foreground_subtle
        property color delegateBorderActive: Themes.TokenInterface.semantics.foreground_muted
        property color delegateBorderDisable: Themes.TokenInterface.transparent
        //text Control
        property color delegateTextIdle: Themes.TokenInterface.semantics.text_default
        property color delegateTextHover: Themes.TokenInterface.semantics.text_default
        property color delegateTextActive: Themes.TokenInterface.semantics.text_default
        property color delegateTextDisable: Themes.TokenInterface.semantics.text_subtle
        //icon Handle
        property color delegateIconIdle: Themes.TokenInterface.semantics.text_muted
        property color delegateIconHover: Themes.TokenInterface.semantics.text_muted
        property color delegateIconActive: Themes.TokenInterface.semantics.text_default
        property color delegateIconDisable: Themes.TokenInterface.semantics.text_subtle

        //popup

        property color popupBackground: Themes.TokenInterface.semantics.background_muted
        property color popupOutline: Themes.TokenInterface.semantics.stroke_subtle
        property int popupRadius: 4


        //sizes
        //control
        property int defaultHeight: Themes.Primitives.sizes.controlHeightLarge
        property int defaultWidth: Themes.Primitives.sizes.buttonWidthLarge
        property int borderWidthIdle: Themes.Primitives.sizes.borderWidth
        property int borderWidthHover: Themes.Primitives.sizes.borderWidth
        property int borderWidthActive: Themes.Primitives.sizes.borderWidth
        property int borderWidthDisable: Themes.Primitives.sizes.borderWidth
        property int radius: Themes.Primitives.sizes.controlRadius
        //text
        property int fontSize:  Themes.Primitives.sizes.fontSize
        property int fontWeightLarge: Themes.Primitives.sizes.vf_500
        //icon
        property int iconSize: Themes.Primitives.sizes.iconSize
        //paddings & gaps
        property int paddingVertical: Themes.Primitives.sizes.verticalPaddingS
        property int paddingHorizontal: Themes.Primitives.sizes.horizontalPaddingXS
        property int gapHorizontal: Themes.Primitives.sizes.horizontalPaddingXXS
    }
    property  SearchMenuClass searchMenuBaseStyle: SearchMenuClass{}

    //variant components
    //primary large
    component PrimaryLarge: SearchMenuClass {}
    property PrimaryLarge primaryLarge: PrimaryLarge{}
}
