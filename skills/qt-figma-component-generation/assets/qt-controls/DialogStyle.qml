// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component Type: QtObject {
        property color background
        property color border
        property color title
        property color text
        property color icon
    }

    component Size: QtObject {
        property int radius
        property int borderWidth

        property int iconSize
        property int fontSize
        property int fontWeight
        property int titleSize
        property int titleWeight
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
        border: Themes.TokenInterface.semantics.stroke_subtle
        title: Themes.TokenInterface.semantics.text_default
        text: Themes.TokenInterface.semantics.text_default
        icon: Themes.TokenInterface.semantics.text_default
    }

    enum SizeVariant {
        Large,
        Small
    }

    property Size large: Size {
        radius: 4
        borderWidth: 1

        iconSize: 40
        fontSize: 14
        fontWeight: Themes.Primitives.sizes.vf_400
        titleSize: 16
        titleWeight:Themes.Primitives.sizes.vf_600
        lineHeight: 20

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingXL
        verticalPadding: Themes.Primitives.sizes.verticalPaddingXL
        spacing: Themes.Primitives.sizes.verticalGapXL
    }
    property Size small: Size {
        radius: 4
        borderWidth: 1

        iconSize: 32
        fontSize: 12
        fontWeight: Themes.Primitives.sizes.vf_400
        titleSize: 14
        titleWeight:Themes.Primitives.sizes.vf_600
        lineHeight: 16

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingL
        verticalPadding: Themes.Primitives.sizes.verticalPaddingL
        spacing: Themes.Primitives.sizes.verticalGapL
    }
}
