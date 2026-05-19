// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component StateStyle: QtObject {
        property color background
        property color highlight
        property color border
        property color icon
        property color popup
        property color popupBorder
        property color selection
        property color text
    }

    component Type: QtObject {
        property StateStyle idle: StateStyle {}
        property StateStyle hover: StateStyle {}
        property StateStyle active: StateStyle {}
        property StateStyle disable: StateStyle {}
    }

    component Size: QtObject {
        property int radius
        property int borderWidth

        property int fontSize
        property int fontWeight
        property int iconSize
        property int lineHeight

        property int padding
        property int horizontalPadding
        property int verticalPadding
        property int popupGap
        property int spacing
    }

    enum TypeVariant {
        Primary,
        Ghost
    }

    property Type primary: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.semantics.background_muted
            highlight: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.semantics.stroke_subtle
            icon: Themes.TokenInterface.semantics.text_muted
            popup: Themes.TokenInterface.semantics.background_muted
            popupBorder: Themes.TokenInterface.semantics.stroke_subtle
            selection: Themes.TokenInterface.semantics.foreground_muted
            text: Themes.TokenInterface.semantics.text_default
        }
        hover: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            highlight: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.semantics.stroke_subtle
            icon: Themes.TokenInterface.semantics.text_default
            popup: Themes.TokenInterface.semantics.background_muted
            popupBorder: Themes.TokenInterface.semantics.stroke_subtle
            selection: Themes.TokenInterface.semantics.foreground_muted
            text: Themes.TokenInterface.semantics.text_default
        }
        active: StateStyle {
            background: Themes.TokenInterface.semantics.background_muted
            highlight: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.semantics.stroke_subtle
            icon: Themes.TokenInterface.semantics.text_default
            popup: Themes.TokenInterface.semantics.background_muted
            popupBorder: Themes.TokenInterface.semantics.stroke_subtle
            selection: Themes.TokenInterface.semantics.foreground_muted
            text: Themes.TokenInterface.semantics.text_default
        }
        disable: StateStyle {
            background: Themes.TokenInterface.semantics.background_muted
            highlight: Themes.TokenInterface.transparent
            border: Themes.TokenInterface.semantics.stroke_subtle
            icon: Themes.TokenInterface.semantics.text_subtle
            popup: Themes.TokenInterface.semantics.background_muted
            popupBorder: Themes.TokenInterface.semantics.stroke_subtle
            selection: Themes.TokenInterface.semantics.foreground_muted
            text: Themes.TokenInterface.semantics.text_subtle
        }
    }

    property Type ghost: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.transparent
            highlight: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.transparent
            icon: Themes.TokenInterface.semantics.text_muted
            popup: Themes.TokenInterface.semantics.background_muted
            popupBorder: Themes.TokenInterface.semantics.stroke_subtle
            selection: Themes.TokenInterface.semantics.foreground_muted
            text: Themes.TokenInterface.semantics.text_muted
        }
        hover: StateStyle {
            background: Themes.TokenInterface.transparent
            highlight: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.transparent
            icon: Themes.TokenInterface.semantics.text_muted
            popup: Themes.TokenInterface.semantics.background_muted
            popupBorder: Themes.TokenInterface.semantics.stroke_subtle
            selection: Themes.TokenInterface.semantics.foreground_muted
            text: Themes.TokenInterface.semantics.text_default
        }
        active: StateStyle {
            background: Themes.TokenInterface.transparent
            highlight: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.transparent
            icon: Themes.TokenInterface.semantics.text_default
            popup: Themes.TokenInterface.semantics.background_muted
            popupBorder: Themes.TokenInterface.semantics.stroke_subtle
            selection: Themes.TokenInterface.semantics.foreground_muted
            text: Themes.TokenInterface.semantics.text_default
        }
        disable: StateStyle {
            background: Themes.TokenInterface.semantics.background_muted
            highlight: Themes.TokenInterface.transparent
            border: Themes.TokenInterface.transparent
            icon: Themes.TokenInterface.semantics.text_subtle
            popup: Themes.TokenInterface.semantics.background_muted
            popupBorder: Themes.TokenInterface.semantics.stroke_subtle
            selection: Themes.TokenInterface.semantics.foreground_muted
            text: Themes.TokenInterface.semantics.text_subtle
        }
    }

    enum SizeVariant {
        Small,
        Large
    }

    property Size small: Size {
        radius: 4
        borderWidth: Themes.Primitives.sizes.borderWidth

        fontSize: 12
        fontWeight: Themes.Primitives.sizes.vf_400
        iconSize: 16
        lineHeight: 12

        padding: Themes.Primitives.sizes.horizontalPaddingXS
        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingM
        verticalPadding: Themes.Primitives.sizes.verticalPaddingS
        popupGap: Themes.Primitives.sizes.horizontalGapXS
        spacing: Themes.Primitives.sizes.horizontalGapM
    }

    property Size large: Size {
        radius: 4
        borderWidth: Themes.Primitives.sizes.borderWidth

        fontSize: 12
        fontWeight: Themes.Primitives.sizes.vf_500
        iconSize: 16
        lineHeight: 16

        padding: Themes.Primitives.sizes.horizontalPaddingS
        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingM
        verticalPadding: Themes.Primitives.sizes.verticalPaddingM
        popupGap: Themes.Primitives.sizes.horizontalGapXS
        spacing: Themes.Primitives.sizes.horizontalGapM
    }
}
