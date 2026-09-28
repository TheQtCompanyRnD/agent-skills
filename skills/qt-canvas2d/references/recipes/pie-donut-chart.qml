// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

// Pie / donut chart with a real hole and an inline legend.
//
// Demonstrates:
//   - wedges from arc() + lineTo(), closed with closePath()
//   - a donut hole from an annular sector, so wedges never over-paint it
//   - conicalgradient2d sweep variant, ring cut with beginHoleSubPath()
//   - centred summary text with textAlign/textBaseline
//   - hit testing by angle and radius (there is no isPointInPath())

import QtQuick
import QtCanvas2D

Item {
    id: root

    implicitWidth: 460
    implicitHeight: 300

    property var slices: [
        { label: qsTr("Render"),  value: 42, color: "#2CDE85" },
        { label: qsTr("Layout"),  value: 23, color: "#41CDDD" },
        { label: qsTr("Script"),  value: 18, color: "#DBEB00" },
        { label: qsTr("Idle"),    value: 17, color: "#E0662C" }
    ]
    property int hoveredIndex: -1
    // Draw the ring as one conical sweep instead of discrete wedges.
    property bool continuousSweep: false

    readonly property real total: {
        let t = 0;
        for (let i = 0; i < slices.length; ++i)
            t += slices[i].value;
        return t;
    }

    Canvas2D {
        id: canvas
        anchors.fill: parent

        fillColor: "#14181d"
        alphaBlending: false

        readonly property real cx: width * 0.34
        readonly property real cy: height * 0.5
        readonly property real outerR: Math.min(width * 0.32, height * 0.42)
        readonly property real innerR: outerR * 0.58

        function drawWedge(ctx, from, to, explode) {
            const mid = (from + to) * 0.5;
            const ox = cx + Math.cos(mid) * explode;
            const oy = cy + Math.sin(mid) * explode;
            // Annular sector: out along `from`, round the outer arc, back in
            // along `to`, then the inner arc reversed. A circle() hole would
            // spill outside the wedge, and the spill fills instead of cutting.
            ctx.beginPath();
            ctx.moveTo(ox + Math.cos(from) * innerR, oy + Math.sin(from) * innerR);
            ctx.lineTo(ox + Math.cos(from) * outerR, oy + Math.sin(from) * outerR);
            ctx.arc(ox, oy, outerR, from, to);
            ctx.lineTo(ox + Math.cos(to) * innerR, oy + Math.sin(to) * innerR);
            ctx.arc(ox, oy, innerR, to, from, true);
            ctx.closePath();
            ctx.fill();
            ctx.stroke();
        }

        // Conical gradients sweep CLOCKWISE from the start angle, so -PI/2
        // lines the colours up with the wedges' 12 o'clock origin. Stops sit at
        // each slice's midpoint so neighbours blend across the boundary; the
        // first colour is repeated at both ends to close the loop.
        function sweepGradient(ctx) {
            const g = ctx.createConicalGradient(cx, cy, -Math.PI / 2);
            g.addColorStop(0, root.slices[0].color);
            let acc = 0;
            for (let i = 0; i < root.slices.length; ++i) {
                const frac = root.slices[i].value / root.total;
                g.addColorStop(acc + frac * 0.5, root.slices[i].color);
                acc += frac;
            }
            g.addColorStop(1, root.slices[0].color);
            return g;
        }

        // One ring, one fill. The hole is concentric with the outer circle, so
        // it is fully enclosed by the solid it subtracts from and cuts cleanly.
        function drawSweepRing(ctx) {
            ctx.beginPath();
            ctx.circle(cx, cy, outerR);
            ctx.beginHoleSubPath();
            ctx.circle(cx, cy, innerR);
            ctx.fillStyle = sweepGradient(ctx);
            ctx.fill();
            ctx.stroke();
        }

        onPaint: {
            const ctx = getContext("2d");
            if (root.total <= 0)
                return;

            ctx.lineWidth = 2;
            ctx.strokeStyle = "#14181d";
            ctx.lineJoin = "round";

            if (root.continuousSweep) {
                drawSweepRing(ctx);
            } else {
                let angle = -Math.PI / 2;   // start at 12 o'clock
                for (let i = 0; i < root.slices.length; ++i) {
                    const sweep = (root.slices[i].value / root.total) * 2 * Math.PI;
                    ctx.fillStyle = root.slices[i].color;
                    drawWedge(ctx, angle, angle + sweep,
                              i === root.hoveredIndex ? outerR * 0.06 : 0);
                    angle += sweep;
                }
            }

            // Centre summary.
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";
            ctx.fillStyle = "#f0f2f4";
            ctx.font = "26px sans-serif";
            const headline = root.hoveredIndex >= 0
                ? Math.round(root.slices[root.hoveredIndex].value / root.total * 100) + "%"
                : root.total.toFixed(0);
            ctx.fillText(headline, cx, cy - 8);
            ctx.font = "12px sans-serif";
            ctx.fillStyle = "#8b96a2";
            ctx.fillText(root.hoveredIndex >= 0
                         ? root.slices[root.hoveredIndex].label
                         : qsTr("total ms"), cx, cy + 16);

            // Legend.
            const lx = width * 0.66;
            let ly = cy - root.slices.length * 13;
            ctx.textAlign = "left";
            ctx.font = "13px sans-serif";
            for (let i = 0; i < root.slices.length; ++i) {
                ctx.fillStyle = root.slices[i].color;
                ctx.beginPath();
                ctx.roundRect(lx, ly - 6, 12, 12, 3);
                ctx.fill();
                ctx.fillStyle = i === root.hoveredIndex ? "#f0f2f4" : "#8b96a2";
                ctx.fillText(root.slices[i].label + "  " + root.slices[i].value,
                             lx + 20, ly);
                ly += 26;
            }
        }
    }

    // Hit testing: Canvas2D has no isPointInPath(), so convert the pointer
    // position to polar coordinates and compare against the same angles the
    // painter used.
    HoverHandler {
        id: hover
        onPointChanged: {
            const dx = point.position.x - canvas.cx;
            const dy = point.position.y - canvas.cy;
            const dist = Math.sqrt(dx * dx + dy * dy);
            if (dist < canvas.innerR || dist > canvas.outerR) {
                root.hoveredIndex = -1;
                return;
            }
            let a = Math.atan2(dy, dx) + Math.PI / 2;
            if (a < 0)
                a += 2 * Math.PI;
            let acc = 0;
            for (let i = 0; i < root.slices.length; ++i) {
                acc += (root.slices[i].value / root.total) * 2 * Math.PI;
                if (a <= acc) {
                    root.hoveredIndex = i;
                    return;
                }
            }
            root.hoveredIndex = -1;
        }
        onHoveredChanged: if (!hovered) root.hoveredIndex = -1
    }

    onHoveredIndexChanged: canvas.requestPaint()
    onContinuousSweepChanged: canvas.requestPaint()
}
