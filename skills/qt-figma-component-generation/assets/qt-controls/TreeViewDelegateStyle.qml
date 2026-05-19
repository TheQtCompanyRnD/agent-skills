// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    component StateStyle: QtObject {
        property color background
        property color text
        property color caretIcon
        property color nodeIcon
    }

    component Type: QtObject {
        property StateStyle idle: StateStyle {}
        property StateStyle hover: StateStyle {}
        property StateStyle active: StateStyle {}
        property StateStyle activeHover: StateStyle {}
        property StateStyle disable: StateStyle {}
    }

    component Size: QtObject {
        property int fontSize
        property int fontWeight
        property int iconSize
        property int lineHeight

        property int horizontalPadding
        property int verticalPadding
        property int spacing
    }

    enum TypeVariant {
        Primary
    }

    property Type primary: Type {
        idle: StateStyle {
            background: Themes.TokenInterface.transparent
            text: Themes.TokenInterface.semantics.text_muted
            caretIcon: Themes.TokenInterface.semantics.text_muted
            nodeIcon: Themes.TokenInterface.semantics.text_muted
        }
        hover: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            text: Themes.TokenInterface.semantics.text_default
            caretIcon: Themes.TokenInterface.semantics.text_muted
            nodeIcon: Themes.TokenInterface.semantics.text_default
        }
        active: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_muted
            text: Themes.TokenInterface.semantics.text_default
            caretIcon: Themes.TokenInterface.semantics.text_default
            nodeIcon: Themes.TokenInterface.semantics.text_default
        }
        activeHover: StateStyle {
            background: Themes.TokenInterface.semantics.foreground_subtle
            text: Themes.TokenInterface.semantics.text_default
            caretIcon: Themes.TokenInterface.semantics.text_default
            nodeIcon: Themes.TokenInterface.semantics.text_default
        }
        disable: StateStyle {
            background: Themes.TokenInterface.transparent
            text: Themes.TokenInterface.semantics.text_subtle
            caretIcon: Themes.TokenInterface.semantics.text_subtle
            nodeIcon: Themes.TokenInterface.semantics.text_subtle
        }
    }

    enum SizeVariant {
        Base
    }

    property Size base: Size {
        fontSize: 12
        fontWeight: Themes.Primitives.sizes.vf_600
        iconSize: 16
        lineHeight: 16

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingS
        verticalPadding: Themes.Primitives.sizes.verticalPaddingXS
        spacing: Themes.Primitives.sizes.horizontalGapXS
    }
}
