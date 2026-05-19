// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component StateStyle: QtObject {
        property color background
        property color border
    }

    component Type: QtObject {
        property StateStyle idle: StateStyle {}
    }

    component Size: QtObject {
        property int borderWidth
        property int spacing
    }

    enum TypeVariant {
        Primary
    }

    property Type primary: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.transparent
            border: Themes.TokenInterface.semantics.stroke_subtle
        }
    }

    enum SizeVariant {
        Base
    }

    property Size base: Size {
        borderWidth: 1
        spacing: Themes.Primitives.sizes.horizontalGapXS
    }
}
