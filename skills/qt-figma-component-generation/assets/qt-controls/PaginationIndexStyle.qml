// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component Type: QtObject {
        property color index
        property color text
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

    enum SizeVariant {
        Small,
        Medium,
        Large
    }

    property Type primary: Type {
        index: Themes.TokenInterface.semantics.primary_default
        text: Themes.TokenInterface.semantics.text_subtle
    }

    property Size small: Size {
        fontSize: 10
        fontWeight: Themes.Primitives.sizes.vf_600
        lineHeight: 12

        horizontalPadding: 0
        verticalPadding: 0
        spacing: 0
    }

    property Size medium: Size {
        fontSize: 12
        fontWeight: Themes.Primitives.sizes.vf_500
        lineHeight: 16

        horizontalPadding: 0
        verticalPadding: 0
        spacing: 0
    }

    property Size large: Size {
        fontSize: 14
        fontWeight: Themes.Primitives.sizes.vf_600
        lineHeight: 16

        horizontalPadding: 0
        verticalPadding: 0
        spacing: Themes.Primitives.sizes.horizontalGapXXS
    }
}
