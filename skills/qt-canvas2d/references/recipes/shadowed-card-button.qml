// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

// A canvas-drawn card / button with elevation, hover and press states.
//
// Demonstrates:
//   - createBoxShadow()/drawBoxShadow() as the replacement for shadowBlur
//   - layered light + dark shadows for a neumorphic lift
//   - per-corner roundRect() radii
//   - state-driven repaint (no frame loop) with Behavior-eased elevation
//   - hit testing and accessibility through a real QML input layer
//   - boxgradient2d for the inner sheen

import QtQuick
import QtCanvas2D

Item {
    id: root

    property alias text: label.text
    property bool down: tap.pressed
    property bool hovered: hover.hovered
    property real elevation: down ? 0.35 : (hovered ? 1.0 : 0.7)

    signal clicked()

    implicitWidth: 240
    implicitHeight: 84

    Behavior on elevation {
        NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
    }

    Canvas2D {
        id: canvas
        anchors.fill: parent

        // The card floats over whatever is behind it, so the canvas itself
        // must be transparent — which requires BOTH of these.
        fillColor: "transparent"
        alphaBlending: true

        readonly property real inset: 14
        readonly property real radius: 16

        Component.onCompleted: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        function drawShadows(ctx, x, y, w, h) {
            const lift = root.elevation;
            const blur = 18 * lift + 4;
            const offset = 6 * lift;

            // Dark shadow below.
            let dark = ctx.createBoxShadow(x, y + offset, w, h,
                                           blur, "#90000000", radius);
            dark.setSpread(-2);
            ctx.drawBoxShadow(dark);

            // Faint light shadow above, for the raised edge.
            ctx.save();
            ctx.globalAlpha = 0.18 * lift;
            let light = ctx.createBoxShadow(x, y - offset * 0.6, w, h,
                                            blur * 0.8, "#ffffff", radius);
            ctx.drawBoxShadow(light);
            ctx.restore();
        }

        function drawPlate(ctx, x, y, w, h) {
            ctx.beginPath();
            // Per-corner radii: rounded left, squarer right.
            ctx.roundRect(x, y, w, h, radius, radius * 0.4, radius * 0.4, radius);
            ctx.fillStyle = root.down ? "#1d8f58"
                                      : (root.hovered ? "#33e692" : "#2CDE85");
            ctx.fill();
            ctx.lineWidth = 1;
            ctx.strokeStyle = "#0f4d30";
            ctx.stroke();
        }

        function drawSheen(ctx, x, y, w, h) {
            const sheen = ctx.createBoxGradient(x, y, w, h, h * 0.75, radius);
            sheen.addColorStop(0.0, Qt.rgba(1, 1, 1, 0.22));
            sheen.addColorStop(1.0, Qt.rgba(1, 1, 1, 0.0));
            ctx.fillStyle = sheen;
            ctx.beginPath();
            ctx.roundRect(x, y, w, h, radius, radius * 0.4, radius * 0.4, radius);
            ctx.fill();
        }

        onPaint: {
            const ctx = getContext("2d");
            const x = inset;
            const y = inset;
            const w = width - inset * 2;
            const h = height - inset * 2;
            if (w <= 0 || h <= 0)
                return;

            drawShadows(ctx, x, y, w, h);
            drawPlate(ctx, x, y, w, h);
            drawSheen(ctx, x, y, w, h);
        }
    }

    // Repaint on every visual state change; no frame animation needed.
    onElevationChanged: canvas.requestPaint()
    onDownChanged: canvas.requestPaint()
    onHoveredChanged: canvas.requestPaint()

    // Canvas pixels are invisible to a screen reader — use a real Text item
    // for the label so it is accessible and translatable, or set
    // Accessible.name on the root when drawing the label on the canvas.
    Text {
        id: label
        anchors.centerIn: parent
        text: qsTr("Continue")
        color: "#0c2a1c"
        font.pixelSize: 18
        font.bold: true
    }

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    TapHandler { id: tap; onTapped: root.clicked() }

    Accessible.role: Accessible.Button
    Accessible.name: label.text
    Accessible.onPressAction: root.clicked()
    activeFocusOnTab: true
    Keys.onReturnPressed: root.clicked()
    Keys.onSpacePressed: root.clicked()
}
