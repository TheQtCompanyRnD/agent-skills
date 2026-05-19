// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component StateStyle: QtObject {
        property color barIndicator
        property color track
    }

    component Type: QtObject {
        property StateStyle active: StateStyle {}
        property StateStyle success: StateStyle {}
        property StateStyle error: StateStyle {}
    }

    component Size: QtObject {
        property int radius
        property int height
    }

    enum TypeVariant {
        Primary
    }

    property Type primary: Type {
        active: StateStyle {
            barIndicator: Themes.TokenInterface.semantics.text_muted
            track: Themes.TokenInterface.semantics.foreground_default
        }
        success: StateStyle {
            barIndicator: Themes.TokenInterface.semantics.notification_success_default
            track: Themes.TokenInterface.semantics.foreground_default
        }
        error: StateStyle {
            barIndicator: Themes.TokenInterface.semantics.notification_danger_default
            track: Themes.TokenInterface.semantics.foreground_default
        }
    }

    enum SizeVariant {
        Small,
        Large
    }

    property Size small: Size {
        radius: Themes.Primitives.aliasTokens.xs * 0.5
        height: Themes.Primitives.aliasTokens.xs
    }
    property Size large: Size {
        radius: Themes.Primitives.aliasTokens.s * 0.5
        height: Themes.Primitives.aliasTokens.s
    }
}
