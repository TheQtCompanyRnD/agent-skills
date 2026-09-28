// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

// Segmented level / VU meter with peak hold.
//
// A control, not a chart. Demonstrates:
//   - three batched rect() paths (one per colour zone), three fills, no per-cell draws
//   - a cached path2d for the unlit segment bed, invalidated only on resize
//   - peak-hold with time-based decay driven from FrameAnimation.frameTime
//     (frameTime, not a fixed per-tick step, so decay is frame-rate independent)
//   - a dB scale drawn once per frame alongside, sharing the item's geometry

import QtQuick
import QtCanvas2D

Canvas2D {
    id: meter

    // Channel levels in [0, 1]. Drive these from an audio backend.
    property var levels: [0.0, 0.0]
    property var peaks: [0.0, 0.0]

    property int segments: 24
    property real warnAt: 0.70       // amber above this
    property real clipAt: 0.90       // red above this
    property real peakDecayPerSecond: 0.55

    property path2d bed
    readonly property int bedGroup: 0

    readonly property real scaleWidth: 34
    readonly property real gutter: 10

    implicitWidth: 120
    implicitHeight: 300

    fillColor: "#11151a"
    alphaBlending: false

    FrameAnimation {
        running: true
        paused: !meter.visible
        onTriggered: {
            // Stand-in source; replace with real levels.
            const l = meter.levels;
            for (let c = 0; c < l.length; ++c)
                l[c] = Math.max(0, Math.min(1,
                    0.55 + 0.45 * Math.sin(elapsedTime * (3.1 + c * 0.7))
                         * Math.sin(elapsedTime * 0.9)));

            const p = meter.peaks;
            for (let c = 0; c < p.length; ++c) {
                p[c] = Math.max(l[c], p[c] - meter.peakDecayPerSecond * frameTime);
                p[c] = Math.max(0, p[c]);
            }
            meter.requestPaint();
        }
    }

    onWidthChanged: { bed.clear(); requestPaint(); }
    onHeightChanged: { bed.clear(); requestPaint(); }
    onSegmentsChanged: { bed.clear(); requestPaint(); }

    function channelRect(index, count) {
        const trackX = scaleWidth + gutter;
        const trackW = width - trackX - gutter;
        const chW = (trackW - gutter * (count - 1)) / count;
        return { x: trackX + index * (chW + gutter), w: chW };
    }

    function buildBed() {
        const count = levels.length;
        const top = gutter;
        const h = height - gutter * 2;
        const segH = h / segments;
        const pad = Math.min(2, segH * 0.18);
        for (let c = 0; c < count; ++c) {
            const r = channelRect(c, count);
            for (let s = 0; s < segments; ++s)
                bed.rect(r.x, top + s * segH, r.w, segH - pad);
        }
    }

    // Adds the lit segments of one channel to the current path, but only those
    // whose zone matches; returns nothing. Called once per colour zone.
    function addLitSegments(ctx, channel, count, level, fromFrac, toFrac) {
        const top = gutter;
        const h = height - gutter * 2;
        const segH = h / segments;
        const pad = Math.min(2, segH * 0.18);
        const r = channelRect(channel, count);
        const lit = Math.round(level * segments);
        for (let s = 0; s < lit; ++s) {
            const frac = (s + 1) / segments;
            if (frac <= fromFrac || frac > toFrac)
                continue;
            // Segment 0 is at the bottom.
            const y = top + (segments - 1 - s) * segH;
            ctx.rect(r.x, y, r.w, segH - pad);
        }
    }

    function drawZone(ctx, count, fromFrac, toFrac, color) {
        ctx.beginPath();
        for (let c = 0; c < count; ++c)
            addLitSegments(ctx, c, count, levels[c], fromFrac, toFrac);
        ctx.fillStyle = color;
        ctx.fill();
    }

    function drawScale(ctx) {
        const marks = [[1.00, "0"], [0.90, "-3"], [0.75, "-6"],
                       [0.55, "-12"], [0.35, "-24"], [0.0, "-∞"]];
        const top = gutter;
        const h = height - gutter * 2;
        ctx.font = "10px sans-serif";
        ctx.textBaseline = "middle";
        ctx.textAlign = "right";
        ctx.fillStyle = "#6b7784";
        ctx.strokeStyle = "#232c35";
        ctx.lineWidth = 1;
        for (let i = 0; i < marks.length; ++i) {
            const y = top + (1 - marks[i][0]) * h;
            ctx.fillText(marks[i][1], scaleWidth - 6, y);
            ctx.beginPath();
            ctx.moveTo(scaleWidth - 4, y + 0.5);
            ctx.lineTo(scaleWidth, y + 0.5);
            ctx.stroke();
        }
    }

    function drawPeaks(ctx, count) {
        const top = gutter;
        const h = height - gutter * 2;
        ctx.beginPath();
        for (let c = 0; c < count; ++c) {
            if (peaks[c] <= 0.001)
                continue;
            const r = channelRect(c, count);
            const y = top + (1 - peaks[c]) * h;
            ctx.rect(r.x, y - 1, r.w, 2);
        }
        ctx.fillStyle = "#f0f2f4";
        ctx.fill();
    }

    onPaint: {
        const ctx = getContext("2d");
        const count = levels.length;
        if (count === 0 || width <= scaleWidth + gutter * 2)
            return;

        if (bed.isEmpty())
            buildBed();

        // Unlit bed: one cached path, one fill.
        ctx.fillStyle = "#1a2129";
        ctx.fill(bed, bedGroup);

        // Lit segments: one batched path and one fill per colour zone.
        drawZone(ctx, count, 0.0, warnAt, "#2CDE85");
        drawZone(ctx, count, warnAt, clipAt, "#DBEB00");
        drawZone(ctx, count, clipAt, 1.0, "#E02020");

        drawPeaks(ctx, count);
        drawScale(ctx);
    }

    Accessible.role: Accessible.Indicator
    Accessible.name: qsTr("Level meter")
}
