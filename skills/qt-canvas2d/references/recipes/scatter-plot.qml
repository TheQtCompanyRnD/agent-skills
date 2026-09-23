// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

// Scatter plot with thousands of points, using a cached marker path2d.
//
// Demonstrates:
//   - building a marker shape once into a `property path2d`
//   - instancing it with a path group (>= 0) so the vertex data is uploaded once
//   - resetTransform() + translate() per instance instead of rebuilding geometry
//   - a second, uncached path for the per-frame selection highlight
//   - removePathGroup() + cleanupResources() when the marker shape changes

import QtQuick
import QtCanvas2D

Canvas2D {
    id: canvas

    // Flat [x0, y0, x1, y1, ...] in normalized [0, 1] coordinates.
    property var points: []
    property int pointCount: 4000
    property real markerSize: 7
    property int selectedIndex: -1

    property path2d markerPath
    property path2d ringPath

    // One group per logical, independently changing path set.
    readonly property int markerGroup: 0
    readonly property int ringGroup: 1

    readonly property real margin: 24

    implicitWidth: 600
    implicitHeight: 420

    fillColor: "#14181d"
    alphaBlending: false

    Component.onCompleted: {
        const p = new Array(pointCount * 2);
        for (let i = 0; i < pointCount; ++i) {
            // Two correlated gaussians, cheaply.
            const u = (Math.random() + Math.random() + Math.random()) / 3;
            const v = (Math.random() + Math.random() + Math.random()) / 3;
            p[i * 2] = u;
            p[i * 2 + 1] = 0.25 + 0.5 * v + 0.25 * (u - 0.5);
        }
        points = p;
        requestPaint();
    }

    onMarkerSizeChanged: {
        // The cached vertex data is stale; drop both the path and its GPU group.
        markerPath.clear();
        const ctx = getContext("2d");
        if (ctx) {
            ctx.removePathGroup(markerGroup);
            ctx.cleanupResources();
        }
        requestPaint();
    }
    onPointsChanged: requestPaint()
    onSelectedIndexChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        const n = points.length / 2;
        if (n === 0)
            return;

        const plotW = width - 2 * margin;
        const plotH = height - 2 * margin;

        // Build the marker once, centred on the origin.
        if (markerPath.isEmpty())
            markerPath.circle(0, 0, markerSize * 0.5);
        if (ringPath.isEmpty())
            ringPath.circle(0, 0, markerSize * 1.6);

        ctx.fillStyle = Qt.rgba(0.17, 0.87, 0.52, 0.45);
        ctx.antialias = 1;

        // Instancing loop: geometry is cached in markerGroup and only the
        // transform changes. Qt.rgba() rather than a colour string in the loop.
        for (let i = 0; i < n; ++i) {
            const x = margin + points[i * 2] * plotW;
            const y = margin + (1 - points[i * 2 + 1]) * plotH;
            ctx.resetTransform();
            ctx.translate(x, y);
            ctx.fill(markerPath, markerGroup);
        }
        ctx.resetTransform();

        if (selectedIndex >= 0 && selectedIndex < n) {
            const sx = margin + points[selectedIndex * 2] * plotW;
            const sy = margin + (1 - points[selectedIndex * 2 + 1]) * plotH;
            ctx.translate(sx, sy);
            ctx.strokeStyle = "#DBEB00";
            ctx.lineWidth = 2;
            ctx.stroke(ringPath, ringGroup);
            ctx.resetTransform();
        }

        ctx.strokeStyle = "#39424c";
        ctx.lineWidth = 1;
        ctx.strokeRect(margin, margin, plotW, plotH);
    }

    TapHandler {
        onTapped: (eventPoint) => {
            // Nearest-point search in plot space; no isPointInPath() exists.
            const plotW = canvas.width - 2 * canvas.margin;
            const plotH = canvas.height - 2 * canvas.margin;
            const px = (eventPoint.position.x - canvas.margin) / plotW;
            const py = 1 - (eventPoint.position.y - canvas.margin) / plotH;
            let best = -1;
            let bestD = Infinity;
            const n = canvas.points.length / 2;
            for (let i = 0; i < n; ++i) {
                const dx = canvas.points[i * 2] - px;
                const dy = canvas.points[i * 2 + 1] - py;
                const d = dx * dx + dy * dy;
                if (d < bestD) {
                    bestD = d;
                    best = i;
                }
            }
            canvas.selectedIndex = bestD < 0.0004 ? best : -1;
        }
    }
}
