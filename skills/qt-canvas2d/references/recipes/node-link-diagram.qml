// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

// Node/link diagram with dragging: bezier edges, instanced nodes, hit testing.
//
// Demonstrates:
//   - bezierCurveTo() edges batched into one path, one stroke
//   - a cached node shape instanced with translate() + a path group
//   - DragHandler/TapHandler over the canvas, since there is no isPointInPath()
//   - the hit test and the painter sharing one geometry source of truth
//   - repaint driven by state change only — no frame loop for a static graph

import QtQuick
import QtCanvas2D

Item {
    id: root

    implicitWidth: 640
    implicitHeight: 400

    readonly property real nodeRadius: 26

    property var nodes: [
        { id: "in",    x: 0.12, y: 0.50, label: qsTr("Input") },
        { id: "parse", x: 0.36, y: 0.24, label: qsTr("Parse") },
        { id: "calc",  x: 0.36, y: 0.76, label: qsTr("Calc") },
        { id: "merge", x: 0.62, y: 0.50, label: qsTr("Merge") },
        { id: "out",   x: 0.87, y: 0.50, label: qsTr("Output") }
    ]
    property var edges: [[0, 1], [0, 2], [1, 3], [2, 3], [3, 4]]

    property int draggedIndex: -1
    property int hoveredIndex: -1

    function nodeAt(px, py) {
        for (let i = nodes.length - 1; i >= 0; --i) {
            const dx = px - nodes[i].x * canvas.width;
            const dy = py - nodes[i].y * canvas.height;
            if (dx * dx + dy * dy <= nodeRadius * nodeRadius)
                return i;
        }
        return -1;
    }

    Canvas2D {
        id: canvas
        anchors.fill: parent

        property path2d nodePath
        readonly property int nodeGroup: 0

        fillColor: "#14181d"
        alphaBlending: false

        Component.onCompleted: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        function drawEdges(ctx) {
            ctx.beginPath();
            for (let e = 0; e < root.edges.length; ++e) {
                const a = root.nodes[root.edges[e][0]];
                const b = root.nodes[root.edges[e][1]];
                const ax = a.x * width;
                const ay = a.y * height;
                const bx = b.x * width;
                const by = b.y * height;
                const dx = (bx - ax) * 0.5;
                ctx.moveTo(ax, ay);
                ctx.bezierCurveTo(ax + dx, ay, bx - dx, by, bx, by);
            }
            ctx.strokeStyle = "#3b4753";
            ctx.lineWidth = 2;
            ctx.lineCap = "round";
            ctx.stroke();
        }

        function drawNodes(ctx) {
            if (nodePath.isEmpty())
                nodePath.circle(0, 0, root.nodeRadius);

            ctx.lineWidth = 2;
            ctx.font = "12px sans-serif";
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";

            for (let i = 0; i < root.nodes.length; ++i) {
                const n = root.nodes[i];
                const x = n.x * width;
                const y = n.y * height;
                const active = (i === root.hoveredIndex || i === root.draggedIndex);

                // Instance the cached circle: only the transform changes.
                ctx.resetTransform();
                ctx.translate(x, y);
                ctx.fillStyle = active ? "#2CDE85" : "#232c35";
                ctx.strokeStyle = active ? "#8ff3c4" : "#465361";
                ctx.fill(nodePath, nodeGroup);
                ctx.stroke(nodePath, nodeGroup);
                ctx.resetTransform();

                ctx.fillStyle = active ? "#0e1013" : "#cfd6dd";
                ctx.fillText(n.label, x, y);
            }
        }

        onPaint: {
            const ctx = getContext("2d");
            drawEdges(ctx);
            drawNodes(ctx);
        }
    }

    HoverHandler {
        onPointChanged: root.hoveredIndex = root.nodeAt(point.position.x,
                                                        point.position.y)
        onHoveredChanged: if (!hovered) root.hoveredIndex = -1
    }

    DragHandler {
        id: drag
        target: null
        onActiveChanged: {
            if (active)
                root.draggedIndex = root.nodeAt(centroid.position.x,
                                                centroid.position.y);
            else
                root.draggedIndex = -1;
        }
        onCentroidChanged: {
            if (root.draggedIndex < 0 || !active)
                return;
            const n = root.nodes[root.draggedIndex];
            n.x = Math.max(0.03, Math.min(0.97, centroid.position.x / canvas.width));
            n.y = Math.max(0.05, Math.min(0.95, centroid.position.y / canvas.height));
            canvas.requestPaint();
        }
    }

    onHoveredIndexChanged: canvas.requestPaint()
    onDraggedIndexChanged: canvas.requestPaint()
}
