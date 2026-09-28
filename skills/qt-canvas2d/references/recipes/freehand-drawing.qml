// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

// Freehand drawing surface with undo.
//
// Canvas2D clears every frame, so "ink" must live in retained geometry and be
// redrawn. Demonstrates:
//   - committed strokes accumulated into one persistent path2d, cached in a group
//   - the in-progress stroke kept uncached (it changes every frame)
//   - clear() + removePathGroup() to invalidate the cache after undo
//   - PointerHandler input rather than reimplementing mouse handling
//   - simple distance-based point thinning to keep paths small

import QtQuick
import QtCanvas2D

Canvas2D {
    id: canvas

    property color inkColor: "#f0f2f4"
    property real inkWidth: 3

    // Committed strokes, flattened into one cached path.
    property path2d committed
    // The stroke currently under the pointer; rebuilt every frame.
    property var livePoints: []
    // Undo stack: one entry per stroke, each a flat [x0, y0, x1, y1, ...].
    property var strokes: []

    readonly property int committedGroup: 0
    readonly property real minStep: 1.5

    implicitWidth: 640
    implicitHeight: 420

    fillColor: "#14181d"
    alphaBlending: false

    function beginStroke(x, y) {
        livePoints = [x, y];
        requestPaint();
    }

    function extendStroke(x, y) {
        const n = livePoints.length;
        const dx = x - livePoints[n - 2];
        const dy = y - livePoints[n - 1];
        if (dx * dx + dy * dy < minStep * minStep)
            return;
        livePoints.push(x, y);
        requestPaint();
    }

    function endStroke() {
        if (livePoints.length >= 4) {
            strokes.push(livePoints);
            appendToCommitted(livePoints);
        }
        livePoints = [];
        requestPaint();
    }

    function appendToCommitted(pts) {
        committed.moveTo(pts[0], pts[1]);
        for (let i = 2; i < pts.length; i += 2)
            committed.lineTo(pts[i], pts[i + 1]);
    }

    function undo() {
        if (strokes.length === 0)
            return;
        strokes.pop();
        rebuildCommitted();
    }

    function clearAll() {
        strokes = [];
        rebuildCommitted();
    }

    function rebuildCommitted() {
        committed.clear();
        for (let s = 0; s < strokes.length; ++s)
            appendToCommitted(strokes[s]);
        // The GPU-side buffer for this group is stale; drop it so the next
        // stroke() regenerates it at the (usually smaller) new size.
        const ctx = getContext("2d");
        if (ctx) {
            ctx.removePathGroup(committedGroup);
            ctx.cleanupResources();
        }
        requestPaint();
    }

    function strokeLive(ctx) {
        if (livePoints.length < 4)
            return;
        ctx.beginPath();
        ctx.moveTo(livePoints[0], livePoints[1]);
        for (let i = 2; i < livePoints.length; i += 2)
            ctx.lineTo(livePoints[i], livePoints[i + 1]);
        ctx.stroke();
    }

    onPaint: {
        const ctx = getContext("2d");

        ctx.strokeStyle = inkColor;
        ctx.lineWidth = inkWidth;
        ctx.lineCap = "round";
        ctx.lineJoin = "round";
        ctx.antialias = 1.5;

        if (!committed.isEmpty())
            ctx.stroke(committed, committedGroup);   // cached
        strokeLive(ctx);                              // uncached, per-frame
    }

    PointHandler {
        id: pen
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchScreen
                         | PointerDevice.Stylus
        onActiveChanged: {
            if (active)
                canvas.beginStroke(point.position.x, point.position.y);
            else
                canvas.endStroke();
        }
        onPointChanged: if (active)
            canvas.extendStroke(point.position.x, point.position.y)
    }

    Keys.onPressed: (event) => {
        if (event.matches(StandardKey.Undo)) {
            undo();
            event.accepted = true;
        }
    }
    focus: true

    Accessible.role: Accessible.Canvas
    Accessible.name: qsTr("Drawing area")
}
