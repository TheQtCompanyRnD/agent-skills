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
        property color textSelection
        property color textSelected
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
        property int lineHeight

        property int horizontalPadding
        property int verticalPadding
        property int popupGap
        property int spacing

        property int cursorHeight
    }

    enum TypeVariant {
        Primary
    }

    property Type primary: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.transparent
            border: Themes.TokenInterface.semantics.stroke_subtle
            text: Themes.TokenInterface.semantics.text_default
            textSelection: Themes.TokenInterface.semantics.primary_subtle
            textSelected: Themes.TokenInterface.semantics.text_default
        }
        hover: StateStyle {
            background: Themes.TokenInterface.transparent
            border: Themes.TokenInterface.semantics.stroke_muted
            text: Themes.TokenInterface.semantics.text_default
            textSelection: Themes.TokenInterface.semantics.primary_subtle
            textSelected: Themes.TokenInterface.semantics.text_default
        }
        active: StateStyle {
            background: Themes.TokenInterface.transparent
            border: Themes.TokenInterface.semantics.stroke_strong
            text: Themes.TokenInterface.semantics.text_default
            textSelection: Themes.TokenInterface.semantics.primary_subtle
            textSelected: Themes.TokenInterface.semantics.text_default
        }
        disable: StateStyle {
            background: Themes.TokenInterface.transparent
            border: Themes.TokenInterface.semantics.stroke_subtle
            text: Themes.TokenInterface.semantics.text_subtle
            textSelection: Themes.TokenInterface.semantics.primary_subtle
            textSelected: Themes.TokenInterface.semantics.text_default
        }
    }

    enum SizeVariant {
        Small,
        Large
    }

    property Size small: Size {
        radius: 4
        borderWidth: Themes.Primitives.sizes.borderWidth

        fontSize: 10
        fontWeight: Themes.Primitives.sizes.vf_400
        lineHeight: 12

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingM
        verticalPadding: Themes.Primitives.sizes.verticalPaddingS
        popupGap: Themes.Primitives.sizes.horizontalGapXS
        spacing: Themes.Primitives.sizes.horizontalGapM

        cursorHeight: 12
    }
    property Size large: Size {
        radius: 4
        borderWidth: Themes.Primitives.sizes.borderWidth

        fontSize: 12
        fontWeight: Themes.Primitives.sizes.vf_400
        lineHeight: 20

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingM
        verticalPadding: Themes.Primitives.sizes.verticalPaddingS
        popupGap: Themes.Primitives.sizes.horizontalGapXS
        spacing: Themes.Primitives.sizes.horizontalGapM

        cursorHeight: 14
    }
}
