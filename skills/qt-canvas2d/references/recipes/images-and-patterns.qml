// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

// Images and patterns: loading, drawing, tiling, tinting.
//
// Demonstrates:
//   - loadImage() before any drawImage(), and repainting from onImageLoaded
//   - sourceSize on loadImage() so SVGs rasterize at their display size
//   - all three drawImage() overloads
//   - imagepattern2d as a fillStyle, with setImageSize/setTintColor/setRotation
//   - isImageLoaded()/isImageError() guards, since a missing image draws nothing
//   - unloadImage() on teardown

import QtQuick
import QtCanvas2D

Canvas2D {
    id: canvas

    readonly property url logoUrl: "qtlogo.png"
    readonly property url tileUrl: "pattern.png"
    readonly property url iconUrl: "face-smile.png"

    property imagepattern2d tilePattern
    property real spin: 0

    implicitWidth: 620
    implicitHeight: 300

    fillColor: "#14181d"
    alphaBlending: false

    Component.onCompleted: {
        // Rasterize vectors at their display size; raster images can be
        // down-scaled here too, to avoid decoding at full resolution.
        loadImage(logoUrl, Qt.size(160, 114));
        loadImage(tileUrl, Qt.size(64, 64));
        loadImage(iconUrl);
        requestPaint();
    }

    // Without this the first frames silently draw nothing.
    onImageLoaded: requestPaint()

    Component.onDestruction: {
        unloadImage(logoUrl);
        unloadImage(tileUrl);
        unloadImage(iconUrl);
    }

    FrameAnimation {
        running: true
        paused: !canvas.visible
        onTriggered: {
            canvas.spin = elapsedTime;
            canvas.requestPaint();
        }
    }

    onPaint: {
        const ctx = getContext("2d");

        // Tiled, rotated, tinted background pattern.
        if (isImageLoaded(tileUrl)) {
            tilePattern = ctx.createPattern(tileUrl, "repeat");
            tilePattern.setImageSize(48, 48);
            tilePattern.setStartPosition(0, 0);
            tilePattern.setRotation(spin * 0.12);          // radians
            tilePattern.setTintColor("#3a4c5e");           // multiplied in the shader
            ctx.fillStyle = tilePattern;
            ctx.beginPath();
            ctx.roundRect(16, 16, width - 32, height - 32, 12);
            ctx.fill();
        }

        if (isImageError(logoUrl)) {
            ctx.fillStyle = "#E02020";
            ctx.font = "14px sans-serif";
            ctx.textAlign = "left";
            ctx.textBaseline = "top";
            ctx.fillText(qsTr("Image failed to load"), 32, 32);
            return;
        }
        if (!isImageLoaded(logoUrl))
            return;   // still loading; onImageLoaded will repaint

        // 1. Natural size at a position.
        ctx.drawImage(logoUrl, 40, 40);

        // 2. Scaled into a destination rectangle.
        ctx.drawImage(logoUrl, 230, 40, 120, 86);

        // 3. Source sub-rectangle into a destination rectangle (sprite atlas).
        ctx.drawImage(logoUrl, 0, 0, 80, 57, 390, 40, 160, 114);

        // Images ignore ctx.antialias but honour globalAlpha and the colour
        // effects, so a fade or a tint pass works the usual way.
        if (isImageLoaded(iconUrl)) {
            ctx.save();
            ctx.globalAlpha = 0.5 + 0.5 * Math.sin(spin * 2);
            ctx.globalSaturation = 1.6;
            const s = 48;
            for (let i = 0; i < 6; ++i)
                ctx.drawImage(iconUrl, 48 + i * 90,
                              height - 90 + 18 * Math.sin(spin * 2 + i),
                              s, s);
            ctx.restore();
        }
    }
}
