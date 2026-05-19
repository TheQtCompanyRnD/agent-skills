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
    }

    component Type: QtObject {
        property StateStyle idle: StateStyle {}
        property StateStyle hover: StateStyle {}
        property StateStyle active: StateStyle {}
        property StateStyle activeHover: StateStyle {}
        property StateStyle disable: StateStyle {}
    }

    component Size: QtObject {
        property int radius

        property int fontSize
        property int fontWeight
        property int lineHeight

        property int horizontalPadding
        property int verticalPadding
        property int spacing

        property int borderWidth
    }

    enum TypeVariant {
        Primary
    }

    enum SizeVariant {
        Small,
        Medium,
        Large
    }

    property Type primary: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.semantics.background_muted
            border: Themes.TokenInterface.semantics.stroke_subtle
            text: Themes.TokenInterface.semantics.text_muted
        }
        hover: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.semantics.stroke_subtle
            text: Themes.TokenInterface.semantics.text_default
        }
        active: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_muted
            border: Themes.TokenInterface.semantics.stroke_muted
            text: Themes.TokenInterface.semantics.text_default
        }
        activeHover: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.semantics.stroke_muted
            text: Themes.TokenInterface.semantics.text_default
        }
        disable: StateStyle {
            background: Themes.TokenInterface.semantics.background_muted
            border: Themes.TokenInterface.semantics.stroke_subtle
            text: Themes.TokenInterface.semantics.text_subtle
        }
    }

    property Size small: Size {
        radius: 4

        fontSize: 10
        fontWeight: Themes.Primitives.sizes.vf_600
        lineHeight: 12

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingXXS // TODO
        verticalPadding: Themes.Primitives.sizes.verticalPaddingXXS
        spacing: Themes.Primitives.sizes.horizontalGapXS

        borderWidth: Themes.Primitives.sizes.borderWidth
    }

    property Size medium: Size {
        radius: 4

        fontSize: 12
        fontWeight: Themes.Primitives.sizes.vf_500
        lineHeight: 16

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingXS // TODO
        verticalPadding: Themes.Primitives.sizes.verticalPaddingXS
        spacing: Themes.Primitives.sizes.horizontalGapXS

        borderWidth: Themes.Primitives.sizes.borderWidth
    }

    property Size large: Size {
        radius: 4

        fontSize: 14
        fontWeight: Themes.Primitives.sizes.vf_600
        lineHeight: 16

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingM // TODO
        verticalPadding: Themes.Primitives.sizes.verticalPaddingM
        spacing: Themes.Primitives.sizes.horizontalGapXS

        borderWidth: Themes.Primitives.sizes.borderWidth
    }

    enum AppearanceVariant {
        Default,
        Outline
    }
}
