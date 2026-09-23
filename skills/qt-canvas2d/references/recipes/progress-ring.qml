// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

// Circular progress ring with determinate and indeterminate modes.
//
// Demonstrates:
//   - an animated arc with round caps
//   - switching between a Behavior-eased value and a FrameAnimation spinner
//   - the frame driver paused when the item is not effectively visible
//   - a reused lineargradient2d for the ring, mutated instead of recreated
//   - Accessible.role/name, since a canvas is opaque to screen readers

import QtQuick
import QtCanvas2D

Canvas2D {
    id: canvas

    property real value: 0.0            // 0 .. 1, used when !indeterminate
    property bool indeterminate: false
    property real thickness: 0.14       // fraction of the radius
    property real spin: 0

    property lineargradient2d ringBrush

    implicitWidth: 160
    implicitHeight: 160

    fillColor: "transparent"
    alphaBlending: true                 // required: the background shows through

    Accessible.role: Accessible.ProgressBar
    Accessible.name: qsTr("Progress")
    Accessible.description: indeterminate ? qsTr("Working")
                                          : Math.round(value * 100) + "%"

    Behavior on value {
        enabled: !canvas.indeterminate
        NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
    }

    FrameAnimation {
        running: canvas.indeterminate
        paused: !canvas.visible
        onTriggered: {
            canvas.spin = elapsedTime;
            canvas.requestPaint();
        }
    }

    onValueChanged: requestPaint()
    onIndeterminateChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    Component.onCompleted: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        const cx = width * 0.5;
        const cy = height * 0.5;
        const lineW = Math.min(width, height) * 0.5 * thickness;
        const r = Math.min(width, height) * 0.5 - lineW * 0.5 - 1;
        if (r <= 0)
            return;

        ctx.lineCap = "round";
        ctx.lineWidth = lineW;

        // Track.
        ctx.strokeStyle = "#26303a";
        ctx.beginPath();
        ctx.circle(cx, cy, r);
        ctx.stroke();

        ringBrush.setStartPosition(cx - r, cy - r);
        ringBrush.setEndPosition(cx + r, cy + r);
        ringBrush.addColorStop(0.0, "#41CDDD");
        ringBrush.addColorStop(1.0, "#2CDE85");
        ctx.strokeStyle = ringBrush;

        const clamped = Math.max(0, Math.min(1, value));
        if (indeterminate) {
            // Sweep length breathes while the whole arc rotates.
            const head = spin * 3.0;
            const len = Math.PI * (0.35 + 0.45 * (0.5 + 0.5 * Math.sin(spin * 1.7)));
            ctx.beginPath();
            ctx.arc(cx, cy, r, head, head + len);
            ctx.stroke();
        } else if (clamped > 0.0005) {
            const start = -Math.PI / 2;
            ctx.beginPath();
            ctx.arc(cx, cy, r, start, start + 2 * Math.PI * clamped);
            ctx.stroke();
        }

        if (!indeterminate) {
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";
            ctx.fillStyle = "#f0f2f4";
            ctx.font = Math.round(r * 0.5) + "px sans-serif";
            ctx.fillText(Math.round(clamped * 100) + "%", cx, cy);
        }
    }
}
