// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component StateStyle: QtObject {
        property color background
        property color indicator

        property int crossPadding // Gap between thumb edge and the side walls of the track
        property int mainPadding // Gap along the axis where the thumb travels
    }

    component Type: QtObject {
        property StateStyle idle: StateStyle {}
        property StateStyle hover: StateStyle {}
        property StateStyle active: StateStyle {}
        property StateStyle disable: StateStyle {}
    }

    component Size: QtObject {
        property int radius
        property int thickness
    }

    enum TypeVariant {
        Docked,
        Floating
    }

    property Type docked: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.semantics.background_subtle
            indicator: Themes.TokenInterface.semantics.foreground_default

            crossPadding: 1
            mainPadding: 1
        }
        hover: StateStyle {
            background: Themes.TokenInterface.semantics.background_subtle
            indicator: Themes.TokenInterface.semantics.foreground_default

            crossPadding: 1
            mainPadding: 1
        }
        active: StateStyle {
            background: Themes.TokenInterface.semantics.background_subtle
            indicator: Themes.TokenInterface.semantics.foreground_default

            crossPadding: 1
            mainPadding: 1
        }
        disable: StateStyle {
            background: Themes.TokenInterface.semantics.background_subtle
            indicator: Themes.TokenInterface.semantics.foreground_default

            crossPadding: 1
            mainPadding: 1
        }
    }
    property Type floating: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.semantics.background_subtle
            indicator: Themes.TokenInterface.semantics.foreground_default

            crossPadding: 1
            mainPadding: 0
        }
        hover: StateStyle {
            background: Themes.TokenInterface.semantics.background_subtle
            indicator: Themes.TokenInterface.semantics.foreground_default

            crossPadding: 1
            mainPadding: 0
        }
        active: StateStyle {
            background: Themes.TokenInterface.semantics.background_subtle
            indicator: Themes.TokenInterface.semantics.foreground_default

            crossPadding: 1
            mainPadding: 0
        }
        disable: StateStyle {
            background: Themes.TokenInterface.semantics.background_subtle
            indicator: Themes.TokenInterface.semantics.foreground_default

            crossPadding: 1
            mainPadding: 0
        }
    }

    enum SizeVariant {
        Small,
        Medium,
        Large
    }

    property Size small: Size {
        radius: Themes.Primitives.aliasTokens.xs
        thickness: Themes.Primitives.aliasTokens.xs
    }
    property Size medium: Size {
        radius: Themes.Primitives.aliasTokens.s
        thickness: Themes.Primitives.aliasTokens.s
    }
    property Size large: Size {
        radius: Themes.Primitives.aliasTokens.m
        thickness: Themes.Primitives.aliasTokens.m
    }
}
