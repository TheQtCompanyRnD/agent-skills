// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component StateStyle: QtObject {
        // Track (groove)
        property color track
        property color trackBorder
        property int trackBorderWidth

        // Fill portion of track
        property color fill

        // Handle (thumb)
        property color handle
        property color handleBorder
        property int handleBorderWidth
    }

    component Type: QtObject {
        property StateStyle idle: StateStyle {}
        property StateStyle hover: StateStyle {}
        property StateStyle active: StateStyle {}
        property StateStyle disable: StateStyle {}
    }

    component Size: QtObject {
        property int padding

        property int handleSize
        property int handleRadius

        property int trackThickness
        property int trackRadius
    }

    enum TypeVariant {
        Primary
    }

    enum SizeVariant {
        Small,
        Large
    }

    property Type primary: Type {
        idle: StateStyle {
            track: Themes.TokenInterface.semantics.foreground_default
            trackBorder: Themes.TokenInterface.semantics.foreground_default
            trackBorderWidth: Themes.Primitives.sizes.borderWidth

            fill: Themes.TokenInterface.semantics.primary_default

            handle: Themes.TokenInterface.semantics.primary_default
            handleBorder: Themes.TokenInterface.semantics.primary_default
            handleBorderWidth: Themes.Primitives.sizes.borderWidth
        }
        hover: StateStyle {
            track: Themes.TokenInterface.semantics.foreground_default
            trackBorder: Themes.TokenInterface.semantics.foreground_default
            trackBorderWidth: Themes.Primitives.sizes.borderWidth

            fill: Themes.TokenInterface.semantics.primary_muted

            handle: Themes.TokenInterface.semantics.primary_muted
            handleBorder: Themes.TokenInterface.semantics.primary_muted
            handleBorderWidth: Themes.Primitives.sizes.borderWidth
        }
        active: StateStyle {
            track: Themes.TokenInterface.semantics.foreground_default
            trackBorder: Themes.TokenInterface.semantics.foreground_default
            trackBorderWidth: Themes.Primitives.sizes.borderWidth

            fill: Themes.TokenInterface.semantics.primary_subtle

            handle: Themes.TokenInterface.semantics.primary_subtle
            handleBorder: Themes.TokenInterface.semantics.primary_subtle
            handleBorderWidth: Themes.Primitives.sizes.borderWidth
        }
        disable: StateStyle {
            track: Themes.TokenInterface.semantics.foreground_subtle
            trackBorder: Themes.TokenInterface.semantics.foreground_subtle
            trackBorderWidth: Themes.Primitives.sizes.borderWidth

            fill: Themes.TokenInterface.semantics.text_subtle

            handle: Themes.TokenInterface.semantics.text_subtle
            handleBorder: Themes.TokenInterface.semantics.text_subtle
            handleBorderWidth: Themes.Primitives.sizes.borderWidth
        }
    }

    property Size small: Size {
        padding: Themes.Primitives.aliasTokens.xs
        handleSize: Themes.Primitives.aliasTokens.l
        handleRadius: Themes.Primitives.aliasTokens.s
        trackThickness: Themes.Primitives.aliasTokens.xs
        trackRadius: Themes.Primitives.aliasTokens.xxs
    }

    property Size large: Size {
        padding: Themes.Primitives.aliasTokens.m
        handleSize: Themes.Primitives.aliasTokens.xl
        handleRadius: Themes.Primitives.aliasTokens.l
        trackThickness: Themes.Primitives.aliasTokens.s
        trackRadius: 3 // TODO create half versions of the primitives
    }
}
