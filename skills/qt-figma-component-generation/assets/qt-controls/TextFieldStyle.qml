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
        property color textPlaceholder
        property color textSelection
        property color textSelected
        property color icon
    }

    component Type: QtObject {
        property StateStyle idle: StateStyle {}
        property StateStyle hover: StateStyle {}
        property StateStyle active: StateStyle {}
        property StateStyle disable: StateStyle {}
        property StateStyle error: StateStyle {}
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

        property int cursorHeight

        property int borderWidth
    }

    enum TypeVariant {
        Primary
    }

    property Type primary: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.transparent
            border: Themes.TokenInterface.semantics.stroke_subtle
            text: Themes.TokenInterface.semantics.text_default
            textPlaceholder: Themes.TokenInterface.semantics.text_subtle
            textSelection: Themes.TokenInterface.semantics.primary_subtle
            textSelected: Themes.TokenInterface.semantics.text_default
            icon: Themes.TokenInterface.semantics.text_subtle
        }
        hover: StateStyle {
            background: Themes.TokenInterface.transparent
            border: Themes.TokenInterface.semantics.stroke_muted
            text: Themes.TokenInterface.semantics.text_default
            textPlaceholder: Themes.TokenInterface.semantics.text_subtle
            textSelection: Themes.TokenInterface.semantics.primary_subtle
            textSelected: Themes.TokenInterface.semantics.text_default
            icon: Themes.TokenInterface.semantics.text_subtle
        }
        active: StateStyle {
            background: Themes.TokenInterface.transparent
            border: Themes.TokenInterface.semantics.stroke_strong
            text: Themes.TokenInterface.semantics.text_default
            textPlaceholder: Themes.TokenInterface.semantics.text_subtle
            textSelection: Themes.TokenInterface.semantics.primary_subtle
            textSelected: Themes.TokenInterface.semantics.text_default
            icon: Themes.TokenInterface.semantics.text_subtle
        }
        disable: StateStyle {
            background: Themes.TokenInterface.transparent
            border: Themes.TokenInterface.semantics.stroke_subtle
            text: Themes.TokenInterface.semantics.text_subtle
            textPlaceholder: Themes.TokenInterface.semantics.text_subtle
            textSelection: Themes.TokenInterface.semantics.primary_subtle
            textSelected: Themes.TokenInterface.semantics.text_default
            icon: Themes.TokenInterface.semantics.text_subtle
        }
        error: StateStyle {
            background: Themes.TokenInterface.transparent
            border: Themes.TokenInterface.semantics.notification_danger_default
            text: Themes.TokenInterface.semantics.notification_danger_default
            textPlaceholder: Themes.TokenInterface.semantics.notification_danger_default
            textSelection: Themes.TokenInterface.semantics.primary_subtle
            textSelected: Themes.TokenInterface.semantics.text_default
            icon: Themes.TokenInterface.semantics.notification_danger_default
        }
    }

    enum SizeVariant {
        Small,
        Large
    }

    property Size small: Size {
        radius: 4

        fontSize: 10
        fontWeight: Themes.Primitives.sizes.vf_400
        iconSize: 16
        lineHeight: 12

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingM
        verticalPadding: Themes.Primitives.sizes.verticalPaddingS
        spacing: Themes.Primitives.sizes.horizontalGapM

        cursorHeight: 12

        borderWidth: Themes.Primitives.sizes.borderWidth
    }
    property Size large: Size {
        radius: 4

        fontSize: 12
        fontWeight: Themes.Primitives.sizes.vf_400
        iconSize: 16
        lineHeight: 20

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingM
        verticalPadding: Themes.Primitives.sizes.verticalPaddingS
        spacing: Themes.Primitives.sizes.horizontalGapM

        cursorHeight: 14

        borderWidth: Themes.Primitives.sizes.borderWidth
    }
}
