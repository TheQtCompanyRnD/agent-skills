// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
pragma Singleton
import QtQuick
import Qt.Themes as Themes

QtObject {
    // TODO: Call it Intent in the future
    component Type: QtObject {
        property color background
        property color border
        property color label
    }

    component Size: QtObject {
        property int radius

        property int fontSize
        property int fontWeight
        property int iconSize
        property int lineHeight

        property int horizontalPadding
        property int verticalPadding
        property int spacing

        property int borderWidth
    }

    enum TypeVariant {
        Neutral,
        Info,
        Alert,
        Success,
        Danger
    }

    property Type neutral: Type {
        background: Themes.TokenInterface.semantics.foreground_muted
        border: Themes.TokenInterface.semantics.foreground_muted
        label: Themes.TokenInterface.semantics.text_default
    }
    property Type info: Type {
        background: Themes.TokenInterface.semantics.notification_info_muted
        border: Themes.TokenInterface.semantics.notification_info_muted
        label: Themes.TokenInterface.semantics.text_default
    }
    property Type alert: Type {
        background: Themes.TokenInterface.semantics.notification_alert_muted
        border: Themes.TokenInterface.semantics.notification_alert_muted
        label: Themes.TokenInterface.semantics.text_default
    }
    property Type success: Type {
        background: Themes.TokenInterface.semantics.notification_success_muted
        border: Themes.TokenInterface.semantics.notification_success_muted
        label: Themes.TokenInterface.semantics.text_default
    }
    property Type danger: Type {
        background: Themes.TokenInterface.semantics.notification_danger_muted
        border: Themes.TokenInterface.semantics.notification_danger_muted
        label: Themes.TokenInterface.semantics.text_default
    }

    enum SizeVariant {
        Small,
        Medium,
        Large
    }

    property Size small: Size {
        radius: 4

        fontSize: 10
        fontWeight: Themes.Primitives.sizes.vf_600
        iconSize: 16
        lineHeight: 12

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingXS
        verticalPadding: Themes.Primitives.sizes.verticalPaddingXXS
        spacing: Themes.Primitives.sizes.horizontalGapXXS

        borderWidth: Themes.Primitives.sizes.borderWidth
    }
    property Size medium: Size {
        radius: 4

        fontSize: 10
        fontWeight: Themes.Primitives.sizes.vf_500
        iconSize: 16
        lineHeight: 16

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingXS
        verticalPadding: Themes.Primitives.sizes.verticalPaddingXS
        spacing: Themes.Primitives.sizes.horizontalGapXXS

        borderWidth: Themes.Primitives.sizes.borderWidth
    }
    property Size large: Size {
        radius: 4

        fontSize: 12
        fontWeight: Themes.Primitives.sizes.vf_500
        iconSize: 16
        lineHeight: 16

        horizontalPadding: Themes.Primitives.sizes.horizontalPaddingS
        verticalPadding: Themes.Primitives.sizes.verticalPaddingM
        spacing: Themes.Primitives.sizes.horizontalGapXXS

        borderWidth: Themes.Primitives.sizes.borderWidth
    }

    enum AppearanceVariant {
        Filled,
        Outline
    }
}
