// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

// Pan/zoom viewport: a world-to-screen camera over a large cached scene.
//
// The pattern behind maps, schematics, timelines and any surface larger than
// the item. Demonstrates:
//   - world coordinates cached once in path2d objects, never rebuilt on pan/zoom
//   - a transform2d built per frame as the camera, applied with setTransform()
//   - level of detail: the minor grid only appears past a zoom threshold
//   - setClipRect() applied BEFORE the camera transform, so it stays in screen space
//   - screen -> world inverse done by hand (transform2d has no point-mapping method)
//   - line widths divided by zoom so strokes keep a constant on-screen weight

import QtQuick
import QtCanvas2D

Canvas2D {
    id: view

    // Camera: world point (panX, panY) sits at the centre of the item.
    property real panX: 0
    property real panY: 0
    property real zoom: 1.0
    readonly property real minZoom: 0.15
    readonly property real maxZoom: 12.0

    // Scene geometry, in world coordinates. Built once, cached GPU-side.
    property path2d majorGrid
    property path2d minorGrid
    property path2d shapes
    readonly property int majorGroup: 0
    readonly property int minorGroup: 1
    readonly property int shapeGroup: 2

    readonly property real worldSize: 4000
    property int hoveredCell: -1

    implicitWidth: 720
    implicitHeight: 480

    fillColor: "#11151a"
    alphaBlending: false

    Component.onCompleted: requestPaint()
    // The scene is in world space, so a resize does NOT invalidate it.
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPanXChanged: requestPaint()
    onPanYChanged: requestPaint()
    onZoomChanged: requestPaint()
    onHoveredCellChanged: requestPaint()

    // --- camera -------------------------------------------------------------

    function cameraTransform(ctx) {
        const t = ctx.createTransform2D();
        t.translate(width * 0.5, height * 0.5);
        t.scale(zoom, zoom);
        t.translate(-panX, -panY);
        return t;
    }

    // transform2d exposes inverted() but no way to map a point through it from
    // QML, so invert this (translate/scale only) camera arithmetically.
    function toWorldX(sx) { return (sx - width * 0.5) / zoom + panX; }
    function toWorldY(sy) { return (sy - height * 0.5) / zoom + panY; }

    function zoomAt(sx, sy, factor) {
        const wx = toWorldX(sx);
        const wy = toWorldY(sy);
        zoom = Math.max(minZoom, Math.min(maxZoom, zoom * factor));
        // Keep the world point under the cursor pinned to the cursor.
        panX = wx - (sx - width * 0.5) / zoom;
        panY = wy - (sy - height * 0.5) / zoom;
    }

    // --- scene --------------------------------------------------------------

    function buildScene() {
        const s = worldSize;
        for (let x = -s; x <= s; x += 400) {
            majorGrid.moveTo(x, -s);
            majorGrid.lineTo(x, s);
            majorGrid.moveTo(-s, x);
            majorGrid.lineTo(s, x);
        }
        for (let x = -s; x <= s; x += 50) {
            if (x % 400 === 0)
                continue;
            minorGrid.moveTo(x, -s);
            minorGrid.lineTo(x, s);
            minorGrid.moveTo(-s, x);
            minorGrid.lineTo(s, x);
        }
        for (let i = 0; i < 120; ++i) {
            const a = i * 0.7;
            const r = 120 + i * 24;
            shapes.roundRect(Math.cos(a) * r - 60, Math.sin(a) * r - 40,
                             120, 80, 12);
        }
    }

    onPaint: {
        const ctx = getContext("2d");
        if (majorGrid.isEmpty())
            buildScene();

        // Clip in screen space, before the camera is applied.
        ctx.setClipRect(0, 0, width, height);

        const cam = cameraTransform(ctx);
        ctx.setTransform(cam);

        // Divide widths by zoom so they stay constant on screen.
        const px = 1 / zoom;

        // Level of detail: skip the minor grid when it would alias into mush.
        if (zoom > 0.6) {
            ctx.strokeStyle = "#1b232b";
            ctx.lineWidth = px;
            ctx.stroke(minorGrid, minorGroup);
        }
        ctx.strokeStyle = "#2b3742";
        ctx.lineWidth = px;
        ctx.stroke(majorGrid, majorGroup);

        ctx.fillStyle = "#1e2a35";
        ctx.strokeStyle = "#41CDDD";
        ctx.lineWidth = 2 * px;
        ctx.fill(shapes, shapeGroup);
        ctx.stroke(shapes, shapeGroup);

        // Labels only when they would be legible.
        if (zoom > 1.2) {
            ctx.fillStyle = "#8b96a2";
            ctx.font = Math.round(16) + "px sans-serif";
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";
            ctx.save();
            for (let i = 0; i < 120; i += 1) {
                const a = i * 0.7;
                const r = 120 + i * 24;
                // Counter-scale so text keeps a constant on-screen size.
                ctx.setTransform(cam);
                ctx.translate(Math.cos(a) * r, Math.sin(a) * r);
                ctx.scale(px, px);
                ctx.fillText("#" + i, 0, 0);
            }
            ctx.restore();
        }

        ctx.resetTransform();
        ctx.resetClipping();

        // HUD, drawn in screen space after the camera is unwound.
        ctx.fillStyle = "#5c6b78";
        ctx.font = "12px monospace";
        ctx.textAlign = "left";
        ctx.textBaseline = "top";
        ctx.fillText(qsTr("zoom %1x").arg(zoom.toFixed(2)), 10, 10);
    }

    DragHandler {
        target: null
        onTranslationChanged: (delta) => {
            view.panX -= delta.x / view.zoom;
            view.panY -= delta.y / view.zoom;
        }
    }

    WheelHandler {
        onWheel: (event) => {
            view.zoomAt(event.x, event.y,
                        event.angleDelta.y > 0 ? 1.12 : 1 / 1.12);
        }
    }

    PinchHandler {
        id: pinch
        target: null
        property real startZoom: 1
        onActiveChanged: if (active) startZoom = view.zoom
        onActiveScaleChanged: {
            if (!active)
                return;
            const target = Math.max(view.minZoom,
                                    Math.min(view.maxZoom, startZoom * activeScale));
            view.zoomAt(centroid.position.x, centroid.position.y,
                        target / view.zoom);
        }
    }
}
