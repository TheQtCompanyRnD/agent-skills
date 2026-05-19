// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component Type: QtObject {
        property color background
        property color highlight
        property color selection
        property color text
        property color icon
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
        Primary
    }

    property Type primary: Type {
        background: Themes.TokenInterface.semantics.background_muted
        highlight: Themes.TokenInterface.semantics.foreground_muted
        text: Themes.TokenInterface.semantics.text_default
        icon: Themes.TokenInterface.semantics.text_default
    }

    enum SizeVariant {
        Base
    }

    property Size base: Size {
        radius: 4
        borderWidth: 1

        fontSize: 12
        fontWeight: Themes.Primitives.sizes.vf_400
        iconSize: 16
        lineHeight: 12

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingS
        verticalPadding: Themes.Primitives.sizes.verticalPaddingXS
        spacing: Themes.Primitives.sizes.horizontalGapXS
    }
}
