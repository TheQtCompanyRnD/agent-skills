// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component StateStyle: QtObject {
        property color background
        property color indicator
        property color border
        property color text
    }

    component Type: QtObject {
        property StateStyle idle: StateStyle {}
        property StateStyle hover: StateStyle {}
        property StateStyle disable: StateStyle {}
    }

    component Size: QtObject {
        property int fontSize
        property int fontWeight
        property int lineHeight

        property int horizontalPadding
        property int verticalPadding
        property int spacing
    }

    enum TypeVariant {
        Subtle,
        Highlight
    }

    property Type subtle: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            indicator: Themes.TokenInterface.semantics.text_default
            border: Themes.TokenInterface.semantics.stroke_subtle
            text: Themes.TokenInterface.semantics.text_default
        }
        hover: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_muted
            indicator: Themes.TokenInterface.semantics.text_muted
            border: Themes.TokenInterface.semantics.stroke_subtle
            text: Themes.TokenInterface.semantics.text_default
        }
        disable: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            indicator: Themes.TokenInterface.semantics.text_subtle
            border: Themes.TokenInterface.semantics.foreground_subtle
            text: Themes.TokenInterface.semantics.text_subtle
        }
    }

    property Type highlight: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            indicator: Themes.TokenInterface.semantics.primary_default
            border: Themes.TokenInterface.semantics.stroke_subtle
            text: Themes.TokenInterface.semantics.text_default
        }
        hover: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_muted
            indicator: Themes.TokenInterface.semantics.primary_muted
            border: Themes.TokenInterface.semantics.stroke_subtle
            text: Themes.TokenInterface.semantics.text_default
        }
        disable: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            indicator: Themes.TokenInterface.semantics.text_subtle
            border: Themes.TokenInterface.semantics.foreground_subtle
            text: Themes.TokenInterface.semantics.text_subtle
        }
    }

    enum SizeVariant {
        Base
    }

    property Size base: Size {
        fontSize: 12
        fontWeight: Themes.Primitives.sizes.vf_500
        lineHeight: 16

        horizontalPadding: 0
        verticalPadding: 0
        spacing: Themes.Primitives.sizes.horizontalGapM
    }
}
