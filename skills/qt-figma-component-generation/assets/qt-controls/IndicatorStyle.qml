// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component StateStyle: QtObject {
        property color background
        property color icon
    }

    component Type: QtObject {
        property StateStyle idle: StateStyle {}
        property StateStyle hover: StateStyle {}
        property StateStyle active: StateStyle {}
        property StateStyle disable: StateStyle {}
    }

    component Size: QtObject {
        property int iconSize
    }

    enum TypeVariant {
        Primary
    }

    property Type primary: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.transparent
            icon: Themes.TokenInterface.semantics.stroke_muted
        }
        hover: StateStyle {
            background: Themes.TokenInterface.semantics.background_subtle
            icon: Themes.TokenInterface.semantics.stroke_strong
        }
        active: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_muted
            icon: Themes.TokenInterface.semantics.stroke_strong
        }
        disable: StateStyle {
            background: Themes.TokenInterface.transparent
            icon: Themes.TokenInterface.semantics.stroke_subtle
        }
    }

    enum SizeVariant {
        Small
    }

    property Size small: Size {
        iconSize: Themes.Primitives.sizes.iconSize
    }
}
