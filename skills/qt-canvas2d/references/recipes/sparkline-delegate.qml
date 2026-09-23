// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

// Sparklines inside a reusing ListView — and when NOT to do it this way.
//
// IMPORTANT TRADEOFF: Canvas2D derives from QQuickRhiItem, so every instance
// owns an offscreen colour buffer. One canvas per delegate therefore costs one
// render target per visible row. That is fine for tens of rows; for hundreds,
// or for rows smaller than roughly 80x24, draw every sparkline into a SINGLE
// canvas behind the view and offset by contentY instead (sketched at the
// bottom of this file).
//
// Demonstrates:
//   - ListView.reuseItems with onReused/onPooled driving repaint and animation
//   - required properties feeding the painter
//   - why a per-delegate path2d cache is the wrong call here
//   - repainting on data change, never on a timer

import QtQuick
import QtCanvas2D

ListView {
    id: list

    implicitWidth: 420
    implicitHeight: 360

    clip: true
    spacing: 1
    reuseItems: true

    model: ListModel {
        id: rows
        Component.onCompleted: {
            for (let i = 0; i < 200; ++i) {
                const pts = [];
                for (let s = 0; s < 40; ++s)
                    pts.push(0.5 + 0.45 * Math.sin(s * 0.35 + i) * Math.cos(s * 0.11));
                append({ name: "sensor-" + i, series: pts, trend: (i % 3) - 1 });
            }
        }
    }

    delegate: Rectangle {
        id: row

        required property string name
        required property var series
        required property int trend

        width: ListView.view.width
        height: 44
        color: "#171c22"

        Text {
            id: label
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 120
            elide: Text.ElideRight
            text: row.name
            color: "#cfd6dd"
            font.pixelSize: 13
        }

        Canvas2D {
            id: spark
            anchors.left: label.right
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            height: 28

            // The row's own background shows through, so keep it transparent.
            fillColor: "transparent"
            alphaBlending: true

            // No cached path2d here on purpose: the geometry changes on every
            // reuse, so a path group would be invalidated more often than it
            // is read. Caching only pays for geometry that outlives frames.
            onPaint: {
                const ctx = getContext("2d");
                const pts = row.series;
                const n = pts ? pts.length : 0;
                if (n < 2 || width <= 0)
                    return;

                const step = width / (n - 1);
                const pad = 3;
                const h = height - pad * 2;

                ctx.beginPath();
                ctx.moveTo(0, pad + (1 - pts[0]) * h);
                for (let i = 1; i < n; ++i)
                    ctx.lineTo(i * step, pad + (1 - pts[i]) * h);

                ctx.strokeStyle = row.trend > 0 ? "#2CDE85"
                                : row.trend < 0 ? "#E0662C" : "#41CDDD";
                ctx.lineWidth = 1.5;
                ctx.lineJoin = "round";
                ctx.lineCap = "round";
                ctx.antialias = 1;
                ctx.stroke();

                // Last-value dot.
                ctx.beginPath();
                ctx.circle((n - 1) * step - 1.5, pad + (1 - pts[n - 1]) * h, 2.5);
                ctx.fillStyle = ctx.strokeStyle;
                ctx.fill();
            }

            // A pooled delegate keeps its canvas; repaint when it comes back
            // with new data, and never paint while pooled.
            ListView.onReused: requestPaint()
            Component.onCompleted: requestPaint()
        }

        // Data can change while the row is live.
        onSeriesChanged: spark.requestPaint()
        onTrendChanged: spark.requestPaint()
    }

    // ---------------------------------------------------------------------
    // Single-canvas alternative, for large or dense lists.
    //
    // Item {
    //     Canvas2D {
    //         id: allSparks
    //         anchors.fill: parent
    //         fillColor: "#171c22"
    //         onPaint: {
    //             const ctx = getContext("2d");
    //             const first = Math.floor(view.contentY / rowHeight);
    //             const last  = Math.min(model.count - 1,
    //                                    first + Math.ceil(height / rowHeight));
    //             for (let i = first; i <= last; ++i) {
    //                 const y = i * rowHeight - view.contentY;
    //                 drawSpark(ctx, sparkX, y + 8, sparkW, 28, model.get(i).series);
    //             }
    //         }
    //     }
    //     // ListView on top, transparent delegates, repaint on contentY change:
    //     //   onContentYChanged: allSparks.requestPaint()
    // }
    //
    // One render target and one paint pass for the whole list, at the cost of
    // keeping the scroll offset in sync by hand.
}
