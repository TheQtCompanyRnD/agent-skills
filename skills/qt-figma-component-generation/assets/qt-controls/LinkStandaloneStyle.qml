// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component StateStyle: QtObject {
        property color text
        property color icon
    }

    component Type: QtObject {
        property StateStyle idle: StateStyle {}
        property StateStyle hover: StateStyle {}
        property StateStyle active: StateStyle {}
        property StateStyle disable: StateStyle {}
    }

    component Size: QtObject {
        property int fontSize
        property int fontWeight
        property int iconSize
        property int lineHeight
    }

    enum TypeVariant {
        Primary
    }

    property Type primary: Type {
        idle: StateStyle {
            text: Themes.TokenInterface.semantics.primary_default
            icon: Themes.TokenInterface.semantics.primary_default
        }
        hover: StateStyle {
            text: Themes.TokenInterface.semantics.primary_muted
            icon: Themes.TokenInterface.semantics.primary_muted
        }
        active: StateStyle {
            text: Themes.TokenInterface.semantics.primary_subtle
            icon: Themes.TokenInterface.semantics.primary_subtle
        }
        disable: StateStyle {
            text: Themes.TokenInterface.semantics.text_subtle
            icon: Themes.TokenInterface.semantics.text_subtle
        }
    }

    enum SizeVariant {
        Small
    }

    property Size small: Size {
        fontSize: 12
        fontWeight: Themes.Primitives.sizes.vf_500
        iconSize: 16
        lineHeight: 16
    }
}
