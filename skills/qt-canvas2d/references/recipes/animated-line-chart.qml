// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

// Animated multi-series line chart with a grid-pattern backdrop.
//
// Demonstrates:
//   - FrameAnimation as the repaint driver, paused when not visible
//   - gridpattern2d instead of a loop of grid lines (constant cost)
//   - a cached path2d for the static axes, invalidated on resize
//   - reused lineargradient2d brush for the area fill
//   - two-pass stroking (wide soft glow, then crisp line) via ctx.antialias

import QtQuick
import QtCanvas2D

Canvas2D {
    id: canvas

    // Series data: array of arrays of y values in [0, 1].
    property var series: [[], []]
    readonly property var seriesColors: ["#2CDE85", "#41CDDD"]

    property real phase: 0

    // Persistent geometry and brushes: created once, mutated per frame.
    property path2d axesPath
    property lineargradient2d areaFill
    property gridpattern2d grid

    readonly property real marginLeft: 48
    readonly property real marginRight: 16
    readonly property real marginTop: 16
    readonly property real marginBottom: 28

    implicitWidth: 640
    implicitHeight: 320

    fillColor: "#14181d"
    alphaBlending: false

    FrameAnimation {
        id: frame
        running: true
        // A frame animation ticks even when the item is off-screen.
        paused: !canvas.visible || canvas.width <= 0
        onTriggered: {
            canvas.phase = elapsedTime;
            canvas.requestPaint();
        }
    }

    Component.onCompleted: {
        // Seed some data. In a real app this comes from a model or C++.
        for (let s = 0; s < series.length; ++s) {
            const row = [];
            for (let i = 0; i < 120; ++i)
                row.push(0.5);
            series[s] = row;
        }
        requestPaint();
    }

    onWidthChanged: { axesPath.clear(); requestPaint(); }
    onHeightChanged: { axesPath.clear(); requestPaint(); }

    function plotRect() {
        return {
            x: marginLeft,
            y: marginTop,
            w: width - marginLeft - marginRight,
            h: height - marginTop - marginBottom
        };
    }

    function drawBackdrop(ctx, r) {
        grid.setStartPosition(r.x, r.y + r.h);
        grid.setCellSize(r.w / 12, r.h / 6);
        grid.setLineColor("#2a3138");
        grid.setBackgroundColor("#1a1f25");
        grid.setLineWidth(1);
        ctx.fillStyle = grid;
        ctx.fillRect(r.x, r.y, r.w, r.h);
    }

    function drawAxes(ctx, r) {
        if (axesPath.isEmpty()) {
            axesPath.moveTo(r.x, r.y);
            axesPath.lineTo(r.x, r.y + r.h);
            axesPath.lineTo(r.x + r.w, r.y + r.h);
            for (let i = 0; i <= 6; ++i) {
                const y = r.y + r.h * (i / 6);
                axesPath.moveTo(r.x - 5, y);
                axesPath.lineTo(r.x, y);
            }
        }
        ctx.strokeStyle = "#7d8894";
        ctx.lineWidth = 1;
        ctx.antialias = 1;
        // Path group 0: static geometry, cached GPU-side across frames.
        ctx.stroke(axesPath, 0);

        ctx.fillStyle = "#7d8894";
        ctx.font = "12px sans-serif";
        ctx.textAlign = "right";
        ctx.textBaseline = "middle";
        for (let i = 0; i <= 6; ++i)
            ctx.fillText((100 - i * 100 / 6).toFixed(0),
                         r.x - 9, r.y + r.h * (i / 6));
    }

    function buildSeriesPath(ctx, values, r) {
        const step = r.w / (values.length - 1);
        ctx.beginPath();
        for (let i = 0; i < values.length; ++i) {
            const x = r.x + i * step;
            const y = r.y + r.h * (1 - values[i]);
            if (i === 0)
                ctx.moveTo(x, y);
            else
                ctx.lineTo(x, y);
        }
    }

    function drawSeries(ctx, values, color, r) {
        // Area under the line.
        buildSeriesPath(ctx, values, r);
        ctx.lineTo(r.x + r.w, r.y + r.h);
        ctx.lineTo(r.x, r.y + r.h);
        areaFill.setStartPosition(0, r.y);
        areaFill.setEndPosition(0, r.y + r.h);
        areaFill.addColorStop(0, Qt.rgba(color.r, color.g, color.b, 0.35));
        areaFill.addColorStop(1, Qt.rgba(color.r, color.g, color.b, 0.0));
        ctx.fillStyle = areaFill;
        ctx.fill();

        // Soft glow pass, then the crisp line.
        buildSeriesPath(ctx, values, r);
        ctx.strokeStyle = Qt.rgba(color.r, color.g, color.b, 0.35);
        ctx.lineWidth = 7;
        ctx.antialias = 8;
        ctx.stroke();

        ctx.strokeStyle = color;
        ctx.lineWidth = 2;
        ctx.antialias = 1;
        ctx.lineJoin = "round";
        ctx.lineCap = "round";
        ctx.stroke();
    }

    onPaint: {
        const ctx = getContext("2d");
        const r = plotRect();
        if (r.w <= 0 || r.h <= 0)
            return;

        // Advance the sample window. Real data would be appended here instead.
        for (let s = 0; s < series.length; ++s) {
            const row = series[s];
            for (let i = 0; i < row.length; ++i)
                row[i] = 0.5 + 0.35 * Math.sin(i * 0.12 + phase * (1 + s * 0.4) + s);
        }

        drawBackdrop(ctx, r);
        drawAxes(ctx, r);

        ctx.save();
        ctx.setClipRect(r.x, r.y, r.w, r.h);
        for (let s = 0; s < series.length; ++s)
            drawSeries(ctx, series[s], Qt.color(seriesColors[s]), r);
        ctx.resetClipping();
        ctx.restore();
    }
}
