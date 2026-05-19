// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component StateStyle: QtObject {
        property color background
        property color backgroundChecked
        property color icon
        property color iconChecked
        property color indicator
        property color text
    }

    component Type: QtObject {
        property StateStyle idle: StateStyle {}
        property StateStyle hover: StateStyle {}
        property StateStyle active: StateStyle {}
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
        Primary
    }

    property Type primary: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_muted
            backgroundChecked: Themes.TokenInterface.semantics.primary_default
            icon: Themes.TokenInterface.semantics.stroke_muted
            iconChecked: Themes.TokenInterface.semantics.base_white
            indicator: Themes.TokenInterface.semantics.text_on_accent
            text: Themes.TokenInterface.semantics.text_default
        }
        hover: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_default
            backgroundChecked: Themes.TokenInterface.semantics.primary_muted
            icon: Themes.TokenInterface.semantics.stroke_muted
            iconChecked: Themes.TokenInterface.semantics.base_white
            indicator: Themes.TokenInterface.semantics.text_on_accent
            text: Themes.TokenInterface.semantics.text_default
        }
        active: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_muted
            backgroundChecked: Themes.TokenInterface.semantics.primary_subtle
            icon: Themes.TokenInterface.semantics.stroke_muted
            iconChecked: Themes.TokenInterface.semantics.base_white
            indicator: Themes.TokenInterface.semantics.text_on_accent
            text: Themes.TokenInterface.semantics.text_default
        }
        disable: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            backgroundChecked: Themes.TokenInterface.semantics.foreground_subtle
            icon: Themes.TokenInterface.semantics.stroke_subtle
            iconChecked: Themes.TokenInterface.semantics.base_white
            indicator: Themes.TokenInterface.semantics.text_subtle
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
