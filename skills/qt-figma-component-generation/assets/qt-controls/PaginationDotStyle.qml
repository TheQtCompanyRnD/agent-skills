// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component StateStyle: QtObject {
        property color background
        property color border
        property int borderWidth
    }

    component Type: QtObject {
        property StateStyle idle: StateStyle {}
        property StateStyle hover: StateStyle {}
        property StateStyle active: StateStyle {}
        property StateStyle activeHover: StateStyle {}
        property StateStyle disable: StateStyle {}
    }

    component Size: QtObject {
        property int dotSize
        property int spacing
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
            background: Themes.TokenInterface.semantics.foreground_muted
            border: Themes.TokenInterface.semantics.foreground_muted
            borderWidth: 0
        }
        hover: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_default
            border: Themes.TokenInterface.semantics.primary_default
            borderWidth: Themes.Primitives.sizes.borderWidth
        }
        active: StateStyle {
            background: Themes.TokenInterface.semantics.primary_default
            border: Themes.TokenInterface.semantics.primary_default
            borderWidth: 0
        }
        activeHover: StateStyle {
            background: Themes.TokenInterface.semantics.primary_muted
            border: Themes.TokenInterface.semantics.primary_muted
            borderWidth: 0
        }
        disable: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            border: Themes.TokenInterface.semantics.foreground_subtle
            borderWidth: 0
        }
    }

    property Size small: Size {
        dotSize: 6
        spacing: Themes.Primitives.sizes.horizontalGapS
    }

    property Size medium: Size {
        dotSize: 8
        spacing: Themes.Primitives.sizes.horizontalGapS
    }

    property Size large: Size {
        dotSize: 12
        spacing: Themes.Primitives.sizes.horizontalGapM
    }
}
