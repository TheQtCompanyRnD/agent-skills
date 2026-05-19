// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component Type: QtObject {
        property color background
        property color border
    }

    component Size: QtObject {
        property int radius

        property int horizontalPadding
        property int verticalPadding
        property int spacing

        property int borderWidth
    }

    enum TypeVariant {
        Primary
    }

    property Type primary: Type {
        background: Themes.TokenInterface.semantics.background_muted
        border: Themes.TokenInterface.semantics.stroke_subtle
    }

    enum SizeVariant {
        Base
    }

    property Size base: Size {
        radius: 12

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingM
        verticalPadding: Themes.Primitives.sizes.verticalPaddingM
        spacing: Themes.Primitives.sizes.horizontalGapM

        borderWidth: 1
    }
}
