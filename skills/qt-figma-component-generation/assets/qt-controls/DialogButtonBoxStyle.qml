// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component Type: QtObject {
        property color background
        property color highlight
        property color border
        property color selection
        property color text
    }

    component Size: QtObject {
        property int radius
        property int borderWidth

        property int horizontalPadding
        property int verticalPadding
        property int spacing
    }

    enum TypeVariant {
        Primary
    }

    property Type primary: Type {
        background: Themes.TokenInterface.semantics.background_muted
        border: Themes.TokenInterface.semantics.stroke_subtle
        text: Themes.TokenInterface.semantics.text_default
    }

    enum SizeVariant {
        Base
    }

    property Size base: Size {
        radius: 4
        borderWidth: 1

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingXL
        verticalPadding: Themes.Primitives.sizes.verticalPaddingXL
        spacing: Themes.Primitives.sizes.horizontalGapXL
    }
}
