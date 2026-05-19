// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component Type: QtObject {
        property color background
        property color border
        property color text
    }

    component Size: QtObject {
        property int radius
        property int borderWidth
        property int arrowSize
        property int arrowRadius

        property int fontSize
        property int fontWeight
        property int titleWeight
        property int bodyLineHeight
        property int titleLineHeight

        property int horizontalPadding
        property int verticalPadding
        property int spacing
        property int popupGap
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
        Small,
        Large
    }

    property Size small: Size {
        radius: 4
        borderWidth: 1
        arrowSize: 7
        arrowRadius: 2

        fontSize: 12
        bodyLineHeight: 20
        titleLineHeight: 14
        fontWeight: Themes.Primitives.sizes.vf_400
        titleWeight: Themes.Primitives.sizes.vf_600

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingM
        verticalPadding: Themes.Primitives.sizes.verticalPaddingM
        spacing: Themes.Primitives.sizes.verticalGapS
        popupGap: Themes.Primitives.sizes.verticalGapXS
    }

    property Size large: Size {
        radius: 4
        borderWidth: 1
        arrowSize: 10
        arrowRadius: 2

        fontSize: 12
        bodyLineHeight: 20
        titleLineHeight: 14
        fontWeight: Themes.Primitives.sizes.vf_400
        titleWeight: Themes.Primitives.sizes.vf_600

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingM
        verticalPadding: Themes.Primitives.sizes.verticalPaddingM
        spacing: Themes.Primitives.sizes.verticalGapM
        popupGap: Themes.Primitives.sizes.verticalGapXS
    }
}
