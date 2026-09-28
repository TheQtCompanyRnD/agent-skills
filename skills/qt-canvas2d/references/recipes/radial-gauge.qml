// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

// Radial gauge / dial: sweep arc, cached tick ring, needle, drop shadow.
//
// Demonstrates:
//   - conicalgradient2d for the value sweep (clockwise, radians)
//   - a cached tick-mark path2d built with transform maths, invalidated on resize
//   - createBoxShadow()/drawBoxShadow() for the bezel instead of shadowBlur
//   - round line caps on an arc for a capsule-shaped track
//   - Behavior-driven value so the needle eases between readings

import QtQuick
import QtCanvas2D

Canvas2D {
    id: canvas

    property real value: 0.0        // 0 .. 1
    property real minValue: 0
    property real maxValue: 240
    property string units: qsTr("km/h")

    // Sweep runs from 135 deg to 405 deg (i.e. bottom-left round to bottom-right).
    readonly property real startAngle: Math.PI * 0.75
    readonly property real sweepAngle: Math.PI * 1.5

    property path2d ticksPath
    property conicalgradient2d sweepBrush

    implicitWidth: 300
    implicitHeight: 300

    fillColor: "#14181d"
    alphaBlending: false

    Behavior on value {
        NumberAnimation { duration: 420; easing.type: Easing.OutCubic }
    }
    onValueChanged: requestPaint()
    onWidthChanged: { ticksPath.clear(); requestPaint(); }
    onHeightChanged: { ticksPath.clear(); requestPaint(); }

    function buildTicks(cx, cy, r) {
        const major = 12;
        const minorPerMajor = 4;
        const total = major * minorPerMajor;
        for (let i = 0; i <= total; ++i) {
            const a = startAngle + sweepAngle * (i / total);
            const isMajor = (i % minorPerMajor) === 0;
            const outer = r;
            const inner = r - (isMajor ? r * 0.13 : r * 0.07);
            ticksPath.moveTo(cx + Math.cos(a) * inner, cy + Math.sin(a) * inner);
            ticksPath.lineTo(cx + Math.cos(a) * outer, cy + Math.sin(a) * outer);
        }
    }

    onPaint: {
        const ctx = getContext("2d");
        const cx = width * 0.5;
        const cy = height * 0.5;
        const r = Math.min(width, height) * 0.42;
        if (r <= 0)
            return;

        // Bezel: shadow first, then the plate on top of it.
        const shadow = ctx.createBoxShadow(cx - r - 6, cy - r - 2,
                                           (r + 6) * 2, (r + 6) * 2,
                                           r * 0.22, "#c0000000", r + 6);
        ctx.drawBoxShadow(shadow);

        ctx.beginPath();
        ctx.circle(cx, cy, r + 6);
        ctx.fillStyle = "#1d232a";
        ctx.fill();

        // Track.
        ctx.lineCap = "round";
        ctx.lineWidth = r * 0.16;
        ctx.strokeStyle = "#262d35";
        ctx.beginPath();
        ctx.arc(cx, cy, r * 0.82, startAngle, startAngle + sweepAngle);
        ctx.stroke();

        // Value sweep, coloured by a conical gradient anchored at the start.
        const clamped = Math.max(0, Math.min(1, value));
        if (clamped > 0.001) {
            sweepBrush.setCenterPosition(cx, cy);
            sweepBrush.setStartAngle(startAngle);
            sweepBrush.addColorStop(0.00, "#2CDE85");
            sweepBrush.addColorStop(0.55, "#DBEB00");
            sweepBrush.addColorStop(0.80, "#E0662C");
            sweepBrush.addColorStop(1.00, "#E02020");
            ctx.strokeStyle = sweepBrush;
            ctx.beginPath();
            ctx.arc(cx, cy, r * 0.82, startAngle, startAngle + sweepAngle * clamped);
            ctx.stroke();
        }

        // Ticks: static geometry, cached in path group 0.
        if (ticksPath.isEmpty())
            buildTicks(cx, cy, r * 0.66);
        ctx.lineCap = "butt";
        ctx.lineWidth = Math.max(1, r * 0.012);
        ctx.strokeStyle = "#5d6773";
        ctx.stroke(ticksPath, 0);

        // Needle: drawn in a rotated local frame, then unwound.
        const needleAngle = startAngle + sweepAngle * clamped;
        ctx.save();
        ctx.translate(cx, cy);
        ctx.rotate(needleAngle);          // radians on the context
        ctx.beginPath();
        ctx.moveTo(-r * 0.10, -r * 0.035);
        ctx.lineTo(r * 0.70, 0);
        ctx.lineTo(-r * 0.10, r * 0.035);
        ctx.closePath();
        ctx.fillStyle = "#f0f2f4";
        ctx.fill();
        ctx.restore();

        ctx.beginPath();
        ctx.circle(cx, cy, r * 0.09);
        ctx.fillStyle = "#39424c";
        ctx.fill();

        // Readout.
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";
        ctx.fillStyle = "#f0f2f4";
        ctx.font = Math.round(r * 0.30) + "px sans-serif";
        ctx.fillText(Math.round(minValue + (maxValue - minValue) * clamped),
                     cx, cy + r * 0.44);
        ctx.font = Math.round(r * 0.12) + "px sans-serif";
        ctx.fillStyle = "#8b96a2";
        ctx.fillText(units, cx, cy + r * 0.66);
    }
}
