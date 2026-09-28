// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

// Static, one-shot painting: primitives, fill rules, holes, balanced state.
//
// Demonstrates:
//   - a canvas that repaints only on completion and on resize (no frame loop)
//   - circle() / ellipse() / roundRect() / rect() as first-class primitives
//   - "nonzero" vs "evenodd" fill rules
//   - beginHoleSubPath() / beginSolidSubPath() for cut-outs
//   - save()/restore() discipline in helper functions

import QtQuick
import QtCanvas2D

Canvas2D {
    id: canvas

    implicitWidth: 640
    implicitHeight: 220

    // The canvas paints its own opaque backdrop, so the fast path applies:
    // opaque fillColor, no alpha blending.
    fillColor: "#1b1f24"
    alphaBlending: false

    // Every helper leaves the paint state exactly as it found it.
    function drawPrimitives(ctx, x, y, size) {
        ctx.save();
        ctx.translate(x, y);
        ctx.lineWidth = 3;
        ctx.strokeStyle = "#0e1013";
        ctx.fillStyle = "#2CDE85";

        ctx.beginPath();
        ctx.circle(size * 0.5, size * 0.5, size * 0.42);
        ctx.fill();
        ctx.stroke();

        ctx.translate(size * 1.2, 0);
        ctx.fillStyle = "#41CDDD";
        ctx.beginPath();
        // Centre + radii. Use ellipseRect(x, y, w, h) for the bounding-rect form.
        ctx.ellipse(size * 0.5, size * 0.5, size * 0.48, size * 0.3);
        ctx.fill();
        ctx.stroke();

        ctx.translate(size * 1.2, 0);
        ctx.fillStyle = "#DBEB00";
        ctx.beginPath();
        ctx.roundRect(size * 0.05, size * 0.1, size * 0.9, size * 0.8,
                      size * 0.35, size * 0.08, size * 0.35, size * 0.08);
        ctx.fill();
        ctx.stroke();

        ctx.restore();
    }

    function drawStar(ctx) {
        ctx.beginPath();
        ctx.moveTo(60, 0);
        for (let i = 1; i < 6; ++i)
            ctx.lineTo(60 * Math.cos(0.8 * i * Math.PI),
                       60 * Math.sin(0.8 * i * Math.PI));
        ctx.closePath();
    }

    function drawFillRules(ctx, x, y) {
        ctx.save();
        ctx.translate(x, y);
        ctx.lineWidth = 2;
        ctx.strokeStyle = "#f0f0f0";
        ctx.fillStyle = "#E0662C";

        ctx.fillRule = "nonzero";
        drawStar(ctx);
        ctx.fill();
        ctx.stroke();

        ctx.translate(150, 0);
        ctx.fillRule = "evenodd";
        drawStar(ctx);
        ctx.fill();
        ctx.stroke();

        ctx.restore();
    }

    // A donut with a square bite: outer solid, square hole, inner solid pip.
    function drawHoles(ctx, cx, cy, r) {
        ctx.save();
        ctx.lineWidth = 3;
        ctx.strokeStyle = "#f0f0f0";
        ctx.fillStyle = "#B23DEB";

        ctx.beginPath();
        ctx.circle(cx, cy, r);
        ctx.beginHoleSubPath();
        ctx.rect(cx - r * 0.55, cy - r * 0.55, r * 1.1, r * 1.1);
        ctx.beginSolidSubPath();
        ctx.circle(cx, cy, r * 0.22);
        ctx.fill();
        ctx.stroke();

        ctx.restore();
    }

    onPaint: {
        const ctx = getContext("2d");
        // No clearRect() — Canvas2D already cleared to fillColor this frame.

        drawPrimitives(ctx, 30, 40, 100);
        drawFillRules(ctx, 480, 110);
        drawHoles(ctx, 380, 110, 62);
    }
}
