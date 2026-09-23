// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

// Colour effects, composite modes and clipping.
//
// Demonstrates:
//   - globalAlpha / globalBrightness / globalContrast / globalSaturation
//   - the three supported composite modes and what they need to work
//   - setClipRect() + resetClipping() as the only clipping available
//   - clipping interacting with the current transform
//   - save()/restore() around every effect so nothing leaks to the next draw
//   - clearRect() used for its real purpose: punching a transparent hole

import QtQuick
import QtCanvas2D

Canvas2D {
    id: canvas

    property real t: 0

    implicitWidth: 720
    implicitHeight: 380

    // Composite modes and clearRect() holes both require a transparent
    // background AND alpha blending. Without these they silently do nothing.
    fillColor: "transparent"
    alphaBlending: true

    FrameAnimation {
        running: true
        paused: !canvas.visible
        onTriggered: {
            canvas.t = elapsedTime;
            canvas.requestPaint();
        }
    }

    Component.onCompleted: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    // A small reusable subject so every effect is applied to the same pixels.
    function drawSwatch(ctx, x, y, w, h, label) {
        const g = ctx.createLinearGradient(x, y, x + w, y + h);
        g.addColorStop(0.0, "#41CDDD");
        g.addColorStop(0.5, "#DBEB00");
        g.addColorStop(1.0, "#E0662C");
        ctx.beginPath();
        ctx.roundRect(x, y, w, h, 10);
        ctx.fillStyle = g;
        ctx.fill();

        ctx.font = "12px sans-serif";
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";
        ctx.fillStyle = "#101418";
        ctx.fillText(label, x + w * 0.5, y + h * 0.5);
    }

    function drawEffects(ctx, x, y) {
        const w = 104;
        const h = 64;
        const gap = 12;
        const pulse = 0.5 + 0.5 * Math.sin(t * 1.6);

        // Each effect is wrapped so it cannot leak into the next swatch.
        ctx.save();
        drawSwatch(ctx, x, y, w, h, qsTr("none"));
        ctx.restore();

        ctx.save();
        ctx.globalAlpha = 0.25 + 0.75 * pulse;
        drawSwatch(ctx, x + (w + gap), y, w, h, qsTr("alpha"));
        ctx.restore();

        ctx.save();
        ctx.globalBrightness = 0.4 + 1.6 * pulse;     // 0 = black, >1 brighter
        drawSwatch(ctx, x + 2 * (w + gap), y, w, h, qsTr("brightness"));
        ctx.restore();

        ctx.save();
        ctx.globalContrast = 0.2 + 2.4 * pulse;       // 0 = flat grey
        drawSwatch(ctx, x + 3 * (w + gap), y, w, h, qsTr("contrast"));
        ctx.restore();

        ctx.save();
        ctx.globalSaturation = 3.0 * pulse;           // 0 = greyscale
        drawSwatch(ctx, x + 4 * (w + gap), y, w, h, qsTr("saturation"));
        ctx.restore();

        ctx.save();
        ctx.globalAlpha = 0.4 + 0.6 * pulse;
        ctx.globalSaturation = 3 - 3 * pulse;
        ctx.globalContrast = 2 * pulse;
        drawSwatch(ctx, x + 5 * (w + gap), y, w, h, qsTr("combined"));
        ctx.restore();
    }

    function drawComposite(ctx, x, y, w, h, mode) {
        ctx.save();

        // Destination.
        ctx.globalCompositeOperation = "source-over";
        ctx.beginPath();
        ctx.roundRect(x, y, w, h * 0.7, 10);
        ctx.fillStyle = "#DFD0B8";
        ctx.fill();
        ctx.lineWidth = 3;
        ctx.strokeStyle = "#ffffff";
        ctx.stroke();

        // Source, composited against it. Only these three modes exist.
        ctx.globalCompositeOperation = mode;
        const cx = x + w * 0.5;
        const cy = y + h * (0.55 + 0.35 * (0.5 + 0.5 * Math.sin(t * 1.3)));
        const cr = h * 0.34;
        ctx.beginPath();
        ctx.circle(cx, cy, cr);
        const rg = ctx.createRadialGradient(cx, cy, 0, cr);
        rg.addColorStop(0, "#ff8080");
        rg.addColorStop(1, "#401010");
        ctx.fillStyle = rg;
        ctx.fill();

        ctx.globalCompositeOperation = "source-over";
        ctx.font = "12px sans-serif";
        ctx.textAlign = "center";
        ctx.textBaseline = "top";
        ctx.fillStyle = "#8b96a2";
        ctx.fillText(mode, x + w * 0.5, y + h + 4);

        ctx.restore();
    }

    function drawClipping(ctx, x, y, w, h) {
        ctx.save();

        // The scissor rect is transformed by the current transform, so rotate
        // first to get a rotated window.
        ctx.translate(x + w * 0.5, y + h * 0.5);
        ctx.rotate(0.12 * Math.sin(t));
        ctx.translate(-(x + w * 0.5), -(y + h * 0.5));

        ctx.setClipRect(x, y, w, h);
        ctx.beginPath();
        for (let i = 0; i < 14; ++i)
            ctx.circle(x + w * 0.5 + 40 * Math.cos(t + i),
                       y + h * 0.5 + 30 * Math.sin(t * 1.4 + i),
                       10 + i * 5);
        ctx.fillStyle = Qt.rgba(0.17, 0.87, 0.52, 0.35);
        ctx.fill();
        ctx.resetClipping();

        ctx.strokeStyle = "#5c6b78";
        ctx.lineWidth = 1;
        ctx.strokeRect(x, y, w, h);

        ctx.restore();
    }

    onPaint: {
        const ctx = getContext("2d");

        drawEffects(ctx, 20, 24);

        const cw = 150;
        const ch = 110;
        drawComposite(ctx, 20, 140, cw, ch, "source-over");
        drawComposite(ctx, 20 + (cw + 24), 140, cw, ch, "source-atop");
        drawComposite(ctx, 20 + 2 * (cw + 24), 140, cw, ch, "destination-out");

        drawClipping(ctx, 540, 140, 160, 130);

        // clearRect() punches a transparent hole in what has been drawn.
        // This is its only real use here — the frame was already cleared.
        ctx.clearRect(20, 300, 60, 40);
    }
}
