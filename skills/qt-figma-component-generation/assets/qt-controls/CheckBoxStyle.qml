// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component StateStyle: QtObject {
        property color background
        property color backgroundChecked
        property color border
        property color borderChecked
        property color icon
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
            backgroundChecked: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.semantics.stroke_subtle
            borderChecked: Themes.TokenInterface.semantics.foreground_subtle
            icon: Themes.TokenInterface.semantics.text_default
            text: Themes.TokenInterface.semantics.text_default
        }
        hover: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_muted
            backgroundChecked: Themes.TokenInterface.semantics.foreground_muted
            border: Themes.TokenInterface.semantics.stroke_subtle
            borderChecked: Themes.TokenInterface.semantics.foreground_muted
            icon: Themes.TokenInterface.semantics.text_default
            text: Themes.TokenInterface.semantics.text_default
        }
        active: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_default
            backgroundChecked: Themes.TokenInterface.semantics.foreground_default
            border: Themes.TokenInterface.semantics.stroke_subtle
            borderChecked: Themes.TokenInterface.semantics.foreground_default
            icon: Themes.TokenInterface.semantics.text_on_accent
            text: Themes.TokenInterface.semantics.text_default
        }
        disable: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            backgroundChecked: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.semantics.foreground_subtle
            borderChecked: Themes.TokenInterface.semantics.foreground_subtle
            icon: Themes.TokenInterface.semantics.text_subtle
            text: Themes.TokenInterface.semantics.text_subtle
        }
    }

    property Type highlight: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            backgroundChecked: Themes.TokenInterface.semantics.primary_default
            border: Themes.TokenInterface.semantics.stroke_subtle
            borderChecked: Themes.TokenInterface.semantics.primary_default
            icon: Themes.TokenInterface.semantics.text_on_accent
            text: Themes.TokenInterface.semantics.text_default
        }
        hover: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_muted
            backgroundChecked: Themes.TokenInterface.semantics.primary_muted
            border: Themes.TokenInterface.semantics.stroke_subtle
            borderChecked: Themes.TokenInterface.semantics.primary_muted
            icon: Themes.TokenInterface.semantics.text_on_accent
            text: Themes.TokenInterface.semantics.text_default
        }
        active: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_default
            backgroundChecked: Themes.TokenInterface.semantics.primary_subtle
            border: Themes.TokenInterface.semantics.stroke_subtle
            borderChecked: Themes.TokenInterface.semantics.primary_subtle
            icon: Themes.TokenInterface.semantics.text_on_accent
            text: Themes.TokenInterface.semantics.text_default
        }
        disable: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            backgroundChecked: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.semantics.foreground_subtle
            borderChecked: Themes.TokenInterface.semantics.foreground_subtle
            icon: Themes.TokenInterface.semantics.text_subtle
            text: Themes.TokenInterface.semantics.text_subtle
        }
    }

    enum SizeVariant {
        Small,
        Large
    }

    property Size small: Size {
        iconSize: 16
        fontSize: 12
        fontWeight: Themes.Primitives.sizes.vf_500
        lineHeight: 16
        borderWidth: 1
        radius: 4

        horizontalPadding: 0
        verticalPadding: 0
        spacing: Themes.Primitives.sizes.horizontalGapM
    }

    property Size large: Size {
        iconSize: 24
        fontSize: 12
        fontWeight: Themes.Primitives.sizes.vf_500
        lineHeight: 16
        borderWidth: 1
        radius: 4

        horizontalPadding: 0
        verticalPadding: 0
        spacing: Themes.Primitives.sizes.horizontalGapM
    }
}
