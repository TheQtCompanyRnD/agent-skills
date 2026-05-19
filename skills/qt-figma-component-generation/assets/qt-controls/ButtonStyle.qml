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

        property int horizontalLabelPadding
    }

    enum TypeVariant {
        Primary,
        Secondary,
        Tertiary,
        Ghost
    }

    property Type primary: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.semantics.primary_default
            border: Themes.TokenInterface.semantics.primary_default
            text: Themes.TokenInterface.semantics.text_on_accent
            icon: Themes.TokenInterface.semantics.text_on_accent
            borderWidth: Themes.Primitives.sizes.borderWidth
        }
        hover: StateStyle {
            background: Themes.TokenInterface.semantics.primary_muted
            border: Themes.TokenInterface.semantics.primary_muted
            text: Themes.TokenInterface.semantics.text_on_accent
            icon: Themes.TokenInterface.semantics.text_on_accent
            borderWidth: Themes.Primitives.sizes.borderWidth
        }
        active: StateStyle {
            background: Themes.TokenInterface.semantics.primary_subtle
            border: Themes.TokenInterface.semantics.primary_subtle
            text: Themes.TokenInterface.semantics.text_on_accent
            icon: Themes.TokenInterface.semantics.text_on_accent
            borderWidth: Themes.Primitives.sizes.borderWidth
        }
        disable: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.semantics.foreground_subtle
            text: Themes.TokenInterface.semantics.text_subtle
            icon: Themes.TokenInterface.semantics.text_subtle
            borderWidth: Themes.Primitives.sizes.borderWidth
        }
    }
    property Type secondary: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.semantics.background_muted
            border: Themes.TokenInterface.semantics.stroke_subtle
            text: Themes.TokenInterface.semantics.text_default
            icon: Themes.TokenInterface.semantics.text_default
            borderWidth: Themes.Primitives.sizes.borderWidth
        }
        hover: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.semantics.stroke_subtle
            text: Themes.TokenInterface.semantics.text_default
            icon: Themes.TokenInterface.semantics.text_default
            borderWidth: Themes.Primitives.sizes.borderWidth
        }
        active: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_muted
            border: Themes.TokenInterface.semantics.stroke_subtle
            text: Themes.TokenInterface.semantics.text_default
            icon: Themes.TokenInterface.semantics.text_default
            borderWidth: Themes.Primitives.sizes.borderWidth
        }
        disable: StateStyle {
            background: Themes.TokenInterface.semantics.background_muted
            border: Themes.TokenInterface.semantics.stroke_subtle
            text: Themes.TokenInterface.semantics.text_subtle
            icon: Themes.TokenInterface.semantics.text_subtle
            borderWidth: Themes.Primitives.sizes.borderWidth
        }
    }
    property Type tertiary: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.semantics.foreground_subtle
            text: Themes.TokenInterface.semantics.text_default
            icon: Themes.TokenInterface.semantics.text_default
            borderWidth: Themes.Primitives.sizes.borderWidth
        }
        hover: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_muted
            border: Themes.TokenInterface.semantics.foreground_muted
            text: Themes.TokenInterface.semantics.text_default
            icon: Themes.TokenInterface.semantics.text_default
            borderWidth: Themes.Primitives.sizes.borderWidth
        }
        active: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_default
            border: Themes.TokenInterface.semantics.foreground_default
            text: Themes.TokenInterface.semantics.text_default
            icon: Themes.TokenInterface.semantics.text_default
            borderWidth: Themes.Primitives.sizes.borderWidth
        }
        disable: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.semantics.foreground_subtle
            text: Themes.TokenInterface.semantics.text_subtle
            icon: Themes.TokenInterface.semantics.text_subtle
            borderWidth: Themes.Primitives.sizes.borderWidth
        }
    }
    property Type ghost: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.transparent
            border: Themes.TokenInterface.transparent
            text: Themes.TokenInterface.semantics.text_default
            icon: Themes.TokenInterface.semantics.text_default
            borderWidth: Themes.Primitives.sizes.borderWidth
        }
        hover: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.semantics.foreground_subtle
            text: Themes.TokenInterface.semantics.text_default
            icon: Themes.TokenInterface.semantics.text_default
            borderWidth: Themes.Primitives.sizes.borderWidth
        }
        active: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_muted
            border: Themes.TokenInterface.semantics.foreground_muted
            text: Themes.TokenInterface.semantics.text_default
            icon: Themes.TokenInterface.semantics.text_default
            borderWidth: Themes.Primitives.sizes.borderWidth
        }
        disable: StateStyle {
            background: Themes.TokenInterface.transparent
            border: Themes.TokenInterface.transparent
            text: Themes.TokenInterface.semantics.text_subtle
            icon: Themes.TokenInterface.semantics.text_subtle
            borderWidth: Themes.Primitives.sizes.borderWidth
        }
    }

    enum SizeVariant {
        Small,
        Medium,
        Large
    }

    property Size small: Size {
        radius: 4

        fontSize: 10
        fontWeight: Themes.Primitives.sizes.vf_700
        iconSize: 16
        lineHeight: 12

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingM
        verticalPadding: Themes.Primitives.sizes.verticalPaddingS
        spacing: Themes.Primitives.sizes.horizontalGapXS

        horizontalLabelPadding: 0
    }
    property Size medium: Size {
        radius: 4

        fontSize: 12
        fontWeight: Themes.Primitives.sizes.vf_700
        iconSize: 16
        lineHeight: 16

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingL
        verticalPadding: Themes.Primitives.sizes.verticalPaddingM
        spacing: Themes.Primitives.sizes.horizontalGapXS

        horizontalLabelPadding: Themes.Primitives.sizes.verticalPaddingXXS
    }
    property Size large: Size {
        radius: 4

        fontSize: 14
        fontWeight: Themes.Primitives.sizes.vf_600
        iconSize: 16
        lineHeight: 16

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingXL
        verticalPadding: Themes.Primitives.sizes.verticalPaddingL
        spacing: Themes.Primitives.sizes.horizontalGapXS

        horizontalLabelPadding: Themes.Primitives.sizes.verticalPaddingXXS
    }
}
