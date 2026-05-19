// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component StateStyle: QtObject {
        property color background
        property color border
        property color text
        property color icon

        property int borderWidth
    }

    component Type: QtObject {
        property StateStyle idle: StateStyle {}
        property StateStyle hover: StateStyle {}
        property StateStyle active: StateStyle {}
        property StateStyle disable: StateStyle {}
    }

    component Size: QtObject {
        property int radius

        property int fontSize
        property int fontWeight
        property int iconSize
        property int lineHeight

        property int horizontalPadding
        property int verticalPadding
        property int spacing
    }

    enum TypeVariant {
        Underline,
        Fill
    }

    property Type underline: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.transparent
            border: Themes.TokenInterface.transparent
            text: Themes.TokenInterface.semantics.text_muted
            icon: Themes.TokenInterface.semantics.text_muted

            borderWidth: 0
        }
        hover: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.semantics.stroke_subtle
            text: Themes.TokenInterface.semantics.text_muted
            icon: Themes.TokenInterface.semantics.text_muted

            borderWidth: 3
        }
        active: StateStyle {
            background: Themes.TokenInterface.transparent
            border: Themes.TokenInterface.semantics.primary_default
            text: Themes.TokenInterface.semantics.text_default
            icon: Themes.TokenInterface.semantics.text_default

            borderWidth: 3
        }
        disable: StateStyle {
            background: Themes.TokenInterface.transparent
            border: Themes.TokenInterface.transparent
            text: Themes.TokenInterface.semantics.text_subtle
            icon: Themes.TokenInterface.semantics.text_subtle

            borderWidth: 0
        }
    }
    property Type fill: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.transparent
            border: Themes.TokenInterface.transparent
            text: Themes.TokenInterface.semantics.text_muted
            icon: Themes.TokenInterface.semantics.text_muted

            borderWidth: 0
        }
        hover: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.transparent
            text: Themes.TokenInterface.semantics.text_muted
            icon: Themes.TokenInterface.semantics.text_muted

            borderWidth: 0
        }
        active: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_muted
            border: Themes.TokenInterface.transparent
            text: Themes.TokenInterface.semantics.text_default
            icon: Themes.TokenInterface.semantics.text_default

            borderWidth: 0
        }
        disable: StateStyle {
            background: Themes.TokenInterface.transparent
            border: Themes.TokenInterface.transparent
            text: Themes.TokenInterface.semantics.text_subtle
            icon: Themes.TokenInterface.semantics.text_subtle

            borderWidth: 0
        }
    }

    enum SizeVariant {
        Small,
        Large
    }

    property Size small: Size {
        radius: 4

        fontSize: 12
        fontWeight: Themes.Primitives.sizes.vf_500
        iconSize: 16
        lineHeight: 16

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingM
        verticalPadding: Themes.Primitives.sizes.verticalPaddingS
        spacing: Themes.Primitives.sizes.horizontalGapXS
    }
    property Size large: Size {
        radius: 4

        fontSize: 14
        fontWeight: Themes.Primitives.sizes.vf_600
        iconSize: 16
        lineHeight: 16

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingL
        verticalPadding: Themes.Primitives.sizes.verticalPaddingM
        spacing: Themes.Primitives.sizes.horizontalGapXS
    }
}
