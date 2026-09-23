// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

// Oscilloscope / waveform: a long polyline rebuilt every frame.
//
// This is the case Canvas2D exists for: 1000+ segments, 60 fps, on the GPU.
// Demonstrates:
//   - a pre-allocated ring buffer, so no array churn in the hot loop
//   - one beginPath()/stroke() for the whole trace, never per-segment strokes
//   - a two-pass glow using ctx.antialias as a width in pixels
//   - a gridpattern2d graticule instead of a loop of grid lines
//   - a cached path2d for the static centre rules

import QtQuick
import QtCanvas2D

Canvas2D {
    id: scope

    property int traceLength: 1200
    property real amplitude: 0.42
    property color traceColor: "#2CDE85"
    property bool paused: false

    // Pre-allocated ring buffer. Filled by pushSample() from C++ or QML.
    // Mind the names: a sample counter here must NOT be called sampleCount.
    // That name is FINAL on QQuickRhiItem and the Canvas2D type will not load.
    property var samples: new Float64Array(1200)
    property int writeIndex: 0

    property path2d rulesPath
    property gridpattern2d graticule

    implicitWidth: 720
    implicitHeight: 280

    fillColor: "#0d1116"
    alphaBlending: false

    FrameAnimation {
        id: clockDriver
        running: !scope.paused
        paused: !scope.visible
        onTriggered: {
            // Stand-in signal source. Replace with real samples.
            scope.pushSample(Math.sin(elapsedTime * 14) * 0.7
                             + Math.sin(elapsedTime * 43.3) * 0.25
                             + (Math.random() - 0.5) * 0.06);
            scope.requestPaint();
        }
    }

    function pushSample(v) {
        samples[writeIndex] = v;
        writeIndex = (writeIndex + 1) % traceLength;
    }

    onWidthChanged: { rulesPath.clear(); requestPaint(); }
    onHeightChanged: { rulesPath.clear(); requestPaint(); }
    Component.onCompleted: requestPaint()

    function buildTrace(ctx, w, h) {
        const midY = h * 0.5;
        const scale = h * amplitude;
        const step = w / (traceLength - 1);
        const n = traceLength;
        const start = writeIndex;           // oldest sample
        ctx.beginPath();
        ctx.moveTo(0, midY - samples[start] * scale);
        for (let i = 1; i < n; ++i) {
            const v = samples[(start + i) % n];
            ctx.lineTo(i * step, midY - v * scale);
        }
    }

    onPaint: {
        const ctx = getContext("2d");
        const w = width;
        const h = height;
        if (w <= 0 || h <= 0)
            return;

        // Graticule: constant cost regardless of density.
        graticule.setStartPosition(0, h * 0.5);
        graticule.setCellSize(w / 10, h / 8);
        graticule.setLineColor("#1e2933");
        graticule.setBackgroundColor("#0d1116");
        graticule.setLineWidth(1);
        ctx.fillStyle = graticule;
        ctx.fillRect(0, 0, w, h);

        // Static centre rules, cached.
        if (rulesPath.isEmpty()) {
            rulesPath.moveTo(0, h * 0.5 + 0.5);
            rulesPath.lineTo(w, h * 0.5 + 0.5);
            rulesPath.moveTo(w * 0.5 + 0.5, 0);
            rulesPath.lineTo(w * 0.5 + 0.5, h);
        }
        ctx.strokeStyle = "#31404d";
        ctx.lineWidth = 1;
        ctx.antialias = 1;
        ctx.stroke(rulesPath, 0);

        ctx.lineJoin = "round";
        ctx.lineCap = "round";

        // Pass 1: wide, soft, low alpha -> phosphor glow.
        buildTrace(ctx, w, h);
        ctx.strokeStyle = Qt.rgba(traceColor.r, traceColor.g, traceColor.b, 0.30);
        ctx.lineWidth = 6;
        ctx.antialias = 9;
        ctx.stroke();

        // Pass 2: crisp trace.
        buildTrace(ctx, w, h);
        ctx.strokeStyle = traceColor;
        ctx.lineWidth = 1.6;
        ctx.antialias = 1;
        ctx.stroke();

        // Readout.
        ctx.font = "12px monospace";
        ctx.textAlign = "left";
        ctx.textBaseline = "top";
        ctx.fillStyle = "#5c6b78";
        ctx.fillText(traceLength + qsTr(" samples"), 8, 8);
    }
}
