// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component Type: QtObject {
        property color text
    }

    component Size: QtObject {
        property int fontSize
        property int fontWeight
        property int lineHeight
    }

    enum TypeVariant {
        Primary,
        Muted,
        Subtle
    }

    property Type primary: Type {
        text: Themes.TokenInterface.semantics.text_default
    }

    property Type muted: Type {
        text: Themes.TokenInterface.semantics.text_muted
    }

    property Type subtle: Type {
        text: Themes.TokenInterface.semantics.text_subtle
    }

    enum SizeVariant {
        Medium,
        Small,
        Caption
    }

    property Size medium: Size {
        fontSize: 12
        fontWeight: Themes.Primitives.sizes.vf_500
        lineHeight: 16
    }
    property Size small: Size {
        fontSize: 10
        fontWeight: Themes.Primitives.sizes.vf_600
        lineHeight: 12
    }
    property Size caption: Size {
        fontSize: 10
        fontWeight: Themes.Primitives.sizes.vf_400
        lineHeight: 12
    }
}
