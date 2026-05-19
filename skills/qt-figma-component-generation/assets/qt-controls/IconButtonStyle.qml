// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component StateStyle: QtObject {
        property color background
        property color border
        property color icon
    }

    component Type: QtObject {
        property StateStyle idle: StateStyle {}
        property StateStyle hover: StateStyle {}
        property StateStyle active: StateStyle {}
        property StateStyle disable: StateStyle {}
    }

    component Size: QtObject {
        property int radius

        property int iconSize

        property int horizontalPadding
        property int verticalPadding

        property int borderWidth
    }

    enum TypeVariant {
        Subtle,
        Highlight
    }

    property Type subtle: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.semantics.background_muted
            border: Themes.TokenInterface.semantics.stroke_subtle
            icon: Themes.TokenInterface.semantics.text_muted
        }
        hover: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.semantics.stroke_subtle
            icon: Themes.TokenInterface.semantics.text_default
        }
        active: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_muted
            border: Themes.TokenInterface.semantics.stroke_muted
            icon: Themes.TokenInterface.semantics.text_default
        }
        disable: StateStyle {
            background: Themes.TokenInterface.semantics.background_muted
            border: Themes.TokenInterface.semantics.stroke_subtle
            icon: Themes.TokenInterface.semantics.text_subtle
        }
    }

    property Type highlight: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.semantics.background_muted
            border: Themes.TokenInterface.semantics.stroke_subtle
            icon: Themes.TokenInterface.semantics.text_muted
        }
        hover: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.semantics.stroke_subtle
            icon: Themes.TokenInterface.semantics.text_default
        }
        active: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_muted
            border: Themes.TokenInterface.semantics.stroke_muted
            icon: Themes.TokenInterface.semantics.text_accent
        }
        disable: StateStyle {
            background: Themes.TokenInterface.semantics.background_muted
            border: Themes.TokenInterface.semantics.stroke_subtle
            icon: Themes.TokenInterface.semantics.text_subtle
        }
    }

    enum SizeVariant {
        Small16,
        Medium16,
        Large16,

        Small24,
        Medium24,
        Large24
    }

    property Size small16: Size {
        radius: 4

        iconSize: 16

        horizontalPadding: 0//Themes.Primitives.sizes.horizontalPaddingXXS
        verticalPadding: 0//Themes.Primitives.sizes.verticalPaddingXXS

        borderWidth: Themes.Primitives.sizes.borderWidth
    }
    property Size medium16: Size {
        radius: 4

        iconSize: 16

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingXS
        verticalPadding: Themes.Primitives.sizes.verticalPaddingXS

        borderWidth: Themes.Primitives.sizes.borderWidth
    }
    property Size large16: Size {
        radius: 4

        iconSize: 16

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingM
        verticalPadding: Themes.Primitives.sizes.verticalPaddingM

        borderWidth: Themes.Primitives.sizes.borderWidth
    }

    property Size small24: Size {
        radius: 4

        iconSize: 24

        horizontalPadding: 0//Themes.Primitives.sizes.horizontalPaddingXXS
        verticalPadding: 0//Themes.Primitives.sizes.verticalPaddingXXS

        borderWidth: Themes.Primitives.sizes.borderWidth
    }
    property Size medium24: Size {
        radius: 4

        iconSize: 24

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingXS
        verticalPadding: Themes.Primitives.sizes.verticalPaddingXS

        borderWidth: Themes.Primitives.sizes.borderWidth
    }
    property Size large24: Size {
        radius: 4

        iconSize: 24

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingM
        verticalPadding: Themes.Primitives.sizes.verticalPaddingM

        borderWidth: Themes.Primitives.sizes.borderWidth
    }

    enum AppearanceVariant {
        Default,
        Outline
    }
}
