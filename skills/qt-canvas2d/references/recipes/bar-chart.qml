// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

// Bar chart: batched path, box-gradient bars, measured labels.
//
// Demonstrates:
//   - one rect()/roundRect() path for all bars, then a single fill()
//   - boxgradient2d, which follows the rounded-rect shape
//   - measureText() for label placement and collision avoidance
//   - a separate cached path2d for the static baseline

import QtQuick
import QtCanvas2D

Canvas2D {
    id: canvas

    // [{ label: "Mon", value: 0.62 }, ...] with value in [0, 1].
    property var bars: [
        { label: qsTr("Mon"), value: 0.62 },
        { label: qsTr("Tue"), value: 0.81 },
        { label: qsTr("Wed"), value: 0.44 },
        { label: qsTr("Thu"), value: 0.93 },
        { label: qsTr("Fri"), value: 0.57 },
        { label: qsTr("Sat"), value: 0.28 },
        { label: qsTr("Sun"), value: 0.35 }
    ]
    property real growth: 0   // 0 -> 1 entry animation

    property path2d baselinePath
    property boxgradient2d barFill

    readonly property real marginTop: 28
    readonly property real marginBottom: 34
    readonly property real marginSide: 20

    implicitWidth: 560
    implicitHeight: 300

    fillColor: "#14181d"
    alphaBlending: false

    NumberAnimation on growth {
        from: 0; to: 1
        duration: 700
        easing.type: Easing.OutCubic
        running: true
    }
    onGrowthChanged: requestPaint()
    onBarsChanged: requestPaint()
    onWidthChanged: { baselinePath.clear(); requestPaint(); }
    onHeightChanged: { baselinePath.clear(); requestPaint(); }

    onPaint: {
        const ctx = getContext("2d");
        const count = bars.length;
        if (count === 0 || width <= 0)
            return;

        const plotW = width - 2 * marginSide;
        const plotH = height - marginTop - marginBottom;
        const baseY = marginTop + plotH;
        const slot = plotW / count;
        const barW = slot * 0.62;
        const radius = Math.min(8, barW * 0.25);

        // Static baseline, cached in path group 0.
        if (baselinePath.isEmpty()) {
            baselinePath.moveTo(marginSide, baseY + 0.5);
            baselinePath.lineTo(marginSide + plotW, baseY + 0.5);
        }
        ctx.strokeStyle = "#39424c";
        ctx.lineWidth = 1;
        ctx.stroke(baselinePath, 0);

        // All bars in one path, one fill. Far cheaper than N fillRect() calls.
        ctx.beginPath();
        for (let i = 0; i < count; ++i) {
            const h = Math.max(1, plotH * bars[i].value * growth);
            const x = marginSide + i * slot + (slot - barW) * 0.5;
            ctx.roundRect(x, baseY - h, barW, h, radius, radius, 0, 0);
        }
        barFill.setRect(marginSide, marginTop, plotW, plotH);
        barFill.setFeather(plotH * 0.6);
        barFill.setRadius(radius);
        barFill.addColorStop(0.0, "#2CDE85");
        barFill.addColorStop(1.0, "#00414A");
        ctx.fillStyle = barFill;
        ctx.fill();

        // Labels. Only draw the value when it fits inside the bar.
        ctx.font = "12px sans-serif";
        ctx.textAlign = "center";
        for (let i = 0; i < count; ++i) {
            const cx = marginSide + i * slot + slot * 0.5;
            const h = plotH * bars[i].value * growth;
            const valueText = Math.round(bars[i].value * 100) + "%";

            ctx.fillStyle = "#8b96a2";
            ctx.textBaseline = "top";
            ctx.fillText(bars[i].label, cx, baseY + 8);

            if (ctx.measureText(valueText).width < barW - 6 && h > 26) {
                ctx.fillStyle = "#0e1013";
                ctx.textBaseline = "top";
                ctx.fillText(valueText, cx, baseY - h + 7);
            } else if (h > 4) {
                ctx.fillStyle = "#8b96a2";
                ctx.textBaseline = "bottom";
                ctx.fillText(valueText, cx, baseY - h - 5);
            }
        }
    }
}
