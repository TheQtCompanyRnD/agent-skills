// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

// Text rendering: fonts, alignment, baselines, wrapping, measurement, RTL.
//
// Demonstrates:
//   - the mandatory `font` shorthand order and quoting of family names
//   - textAlign / textBaseline pairs, including the "center" + "middle" idiom
//   - the 5-argument fillText(text, x, y, width, height) box-wrapping overload
//   - textWrapMode and textLineHeight
//   - measureText() for a hand-laid-out label and separator rule
//   - textAntialias, and the fact that there is no strokeText()
//   - qsTr() on every user-visible string

import QtQuick
import QtCanvas2D

Canvas2D {
    id: canvas

    readonly property string title: qsTr("Qt Canvas Painter")
    readonly property string body: qsTr(
        "Canvas2D paints on the GPU through QRhi, so repainting every frame " +
        "is the normal case rather than something to avoid.")

    implicitWidth: 640
    implicitHeight: 360

    fillColor: "#14181d"
    alphaBlending: false

    function drawTitleWithRule(ctx, x, y) {
        // font: [style] [variant] [weight] size family — size and family are
        // mandatory and must come in that order. Quote families with spaces.
        ctx.font = "bold 22px sans-serif";
        ctx.textAlign = "left";
        ctx.textBaseline = "alphabetic";
        ctx.fillStyle = "#f0f2f4";
        ctx.fillText(title, x, y);

        // measureText() gives width only — enough to underline exactly.
        const w = ctx.measureText(title).width;
        ctx.strokeStyle = "#2CDE85";
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.moveTo(x, y + 7);
        ctx.lineTo(x + w, y + 7);
        ctx.stroke();
        return w;
    }

    function drawAlignments(ctx, x, y) {
        ctx.save();
        ctx.font = "14px sans-serif";
        ctx.textBaseline = "middle";

        // Reference line every label is aligned against.
        ctx.fillStyle = "#3b4753";
        ctx.fillRect(x, y - 10, 1, 120);

        const modes = ["start", "end", "left", "center", "right"];
        ctx.fillStyle = "#cfd6dd";
        for (let i = 0; i < modes.length; ++i) {
            ctx.textAlign = modes[i];
            ctx.fillText(qsTr("align: %1").arg(modes[i]), x, y + i * 24);
        }
        ctx.restore();
    }

    function drawBaselines(ctx, x, y) {
        ctx.save();
        ctx.font = "14px sans-serif";
        ctx.textAlign = "left";
        const modes = ["top", "hanging", "middle", "alphabetic", "bottom"];
        for (let i = 0; i < modes.length; ++i) {
            const ly = y + i * 24;
            ctx.fillStyle = "#3b4753";
            ctx.fillRect(x, ly, 150, 1);
            ctx.fillStyle = "#cfd6dd";
            ctx.textBaseline = modes[i];
            ctx.fillText(modes[i], x + 4, ly);
        }
        ctx.restore();
    }

    function drawWrappedBox(ctx, x, y, w, h) {
        ctx.save();
        ctx.strokeStyle = "#3b4753";
        ctx.lineWidth = 1;
        ctx.strokeRect(x, y, w, h);

        ctx.font = "14px sans-serif";
        ctx.fillStyle = "#cfd6dd";
        // For the boxed overload, "top" or "middle" is almost always right.
        ctx.textAlign = "left";
        ctx.textBaseline = "top";
        ctx.textWrapMode = "wordwrap";     // nowrap | wrap | wordwrap | wrapanywhere
        ctx.textLineHeight = 3;            // pixels of extra leading
        ctx.fillText(body, x + 8, y + 8, w - 16, h - 16);

        // Reset the sticky text state for whatever draws next.
        ctx.textWrapMode = "nowrap";
        ctx.textLineHeight = 0;
        ctx.restore();
    }

    function drawAntialiasScale(ctx, x, y) {
        ctx.save();
        ctx.font = "18px sans-serif";
        ctx.textAlign = "left";
        ctx.textBaseline = "middle";
        ctx.fillStyle = "#cfd6dd";
        // There is no strokeText(); textAntialias is the only softness control.
        for (let i = 0; i < 3; ++i) {
            ctx.textAntialias = 1.0 + i;
            ctx.fillText(qsTr("textAntialias %1").arg((1.0 + i).toFixed(1)),
                         x, y + i * 26);
        }
        ctx.textAntialias = 1.0;
        ctx.restore();
    }

    function drawDirection(ctx, x, y) {
        ctx.save();
        ctx.font = "16px sans-serif";
        ctx.textAlign = "start";
        ctx.textBaseline = "middle";
        ctx.fillStyle = "#8b96a2";
        ctx.direction = "ltr";
        ctx.fillText(qsTr("direction: ltr"), x, y);
        ctx.direction = "rtl";
        ctx.fillText(qsTr("direction: rtl"), x, y + 24);
        ctx.direction = "inherit";       // back to QGuiApplication's setting
        ctx.restore();
    }

    onPaint: {
        const ctx = getContext("2d");

        drawTitleWithRule(ctx, 24, 40);
        drawAlignments(ctx, 150, 80);
        drawBaselines(ctx, 300, 80);
        drawWrappedBox(ctx, 24, 200, 260, 120);
        drawAntialiasScale(ctx, 320, 215);
        drawDirection(ctx, 320, 296);
    }
}
