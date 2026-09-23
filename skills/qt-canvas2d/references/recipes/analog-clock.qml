// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
// Analog watch face: cached dial, transformed hands, smooth sweep second.
//
// The canonical "watch UI" case. Demonstrates:
//   - a full dial (ticks + numerals) built once into cached path2d objects
//   - hands drawn in rotated local frames, unwound with resetTransform()
//   - one cache group per distinct path (groups share a vertex buffer)
//   - a shadowed bezel from createBoxShadow(), not shadowBlur
//   - a smooth, sub-second sweep hand driven by FrameAnimation
//   - the whole face scaling from a single `radius`, so it is resolution free

import QtQuick
import QtCanvas2D

Canvas2D {
    id: clock

    property date now: new Date()
    property bool sweepSeconds: true
    property color faceColor: "#181d23"
    property color accentColor: "#E0662C"

    // Static geometry, rebuilt only when the face size changes.
    property path2d minuteTicks
    property path2d hourTicks
    property path2d hourHandPath
    property path2d minuteHandPath

    readonly property int minuteTickGroup: 0
    readonly property int hourTickGroup: 1
    readonly property int hourHandGroup: 2
    readonly property int minuteHandGroup: 3

    readonly property real radius: Math.min(width, height) * 0.46
    readonly property real cx: width * 0.5
    readonly property real cy: height * 0.5

    implicitWidth: 320
    implicitHeight: 320

    fillColor: "transparent"
    alphaBlending: true

    Accessible.role: Accessible.Indicator
    Accessible.name: qsTr("Clock")

    FrameAnimation {
        running: true
        paused: !clock.visible
        onTriggered: {
            clock.now = new Date();
            clock.requestPaint();
        }
    }

    onWidthChanged: invalidateGeometry()
    onHeightChanged: invalidateGeometry()
    Component.onCompleted: requestPaint()

    function invalidateGeometry() {
        minuteTicks.clear();
        hourTicks.clear();
        hourHandPath.clear();
        minuteHandPath.clear();
        requestPaint();
    }

    function buildDial() {
        const r = radius;
        for (let i = 0; i < 60; ++i) {
            const a = (i / 60) * 2 * Math.PI;
            const sin = Math.sin(a);
            const cos = -Math.cos(a);
            const target = (i % 5 === 0) ? hourTicks : minuteTicks;
            const outer = r * 0.94;
            const inner = (i % 5 === 0) ? r * 0.80 : r * 0.88;
            target.moveTo(cx + sin * inner, cy + cos * inner);
            target.lineTo(cx + sin * outer, cy + cos * outer);
        }
    }

    function buildHands() {
        const r = radius;
        // Both hands point along -Y in their local frame, pivot at the origin.
        hourHandPath.roundRect(-r * 0.035, -r * 0.52, r * 0.07, r * 0.62, r * 0.035);
        minuteHandPath.roundRect(-r * 0.024, -r * 0.78, r * 0.048, r * 0.88, r * 0.024);
    }

    function drawHand(ctx, path, group, angle) {
        ctx.resetTransform();
        ctx.translate(cx, cy);
        ctx.rotate(angle);              // ctx.rotate() is RADIANS
        ctx.fill(path, group);
        ctx.resetTransform();
    }

    onPaint: {
        const ctx = getContext("2d");
        const r = radius;
        if (r <= 0)
            return;

        if (minuteTicks.isEmpty())
            buildDial();
        if (hourHandPath.isEmpty())
            buildHands();

        // Bezel shadow, then the face plate.
        const shadow = ctx.createBoxShadow(cx - r, cy - r + r * 0.03,
                                           r * 2, r * 2,
                                           r * 0.18, "#a0000000", r);
        ctx.drawBoxShadow(shadow);

        ctx.beginPath();
        ctx.circle(cx, cy, r);
        ctx.fillStyle = faceColor;
        ctx.fill();
        ctx.lineWidth = Math.max(1, r * 0.02);
        ctx.strokeStyle = "#2c343d";
        ctx.stroke();

        // Dial: two cached path groups, different stroke weights.
        ctx.lineCap = "round";
        ctx.strokeStyle = "#6b7784";
        ctx.lineWidth = Math.max(1, r * 0.012);
        ctx.stroke(minuteTicks, minuteTickGroup);
        ctx.strokeStyle = "#e6eaee";
        ctx.lineWidth = Math.max(1.5, r * 0.028);
        ctx.stroke(hourTicks, hourTickGroup);

        // Numerals, placed on the dial circle and kept upright.
        ctx.font = Math.round(r * 0.15) + "px sans-serif";
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";
        ctx.fillStyle = "#e6eaee";
        for (let h = 1; h <= 12; ++h) {
            const a = (h / 12) * 2 * Math.PI;
            ctx.fillText(h, cx + Math.sin(a) * r * 0.66,
                            cy - Math.cos(a) * r * 0.66);
        }

        const ms = now.getMilliseconds();
        const s = now.getSeconds() + (sweepSeconds ? ms / 1000 : 0);
        const m = now.getMinutes() + s / 60;
        const h12 = (now.getHours() % 12) + m / 60;

        ctx.fillStyle = "#e6eaee";
        drawHand(ctx, hourHandPath, hourHandGroup, (h12 / 12) * 2 * Math.PI);
        drawHand(ctx, minuteHandPath, minuteHandGroup, (m / 60) * 2 * Math.PI);

        // Second hand: thin enough that a live path beats a cached one.
        ctx.save();
        ctx.translate(cx, cy);
        ctx.rotate((s / 60) * 2 * Math.PI);
        ctx.strokeStyle = accentColor;
        ctx.lineWidth = Math.max(1, r * 0.016);
        ctx.beginPath();
        ctx.moveTo(0, r * 0.18);
        ctx.lineTo(0, -r * 0.84);
        ctx.stroke();
        ctx.restore();

        ctx.beginPath();
        ctx.circle(cx, cy, r * 0.045);
        ctx.fillStyle = accentColor;
        ctx.fill();
    }
}
