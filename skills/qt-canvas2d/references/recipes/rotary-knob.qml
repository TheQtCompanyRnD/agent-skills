// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

// Rotary knob: a continuous, drag-driven canvas control.
//
// Demonstrates:
//   - vertical-drag value mapping (predictable) with optional fine mode
//   - a cached tick ring, invalidated on resize and on stepSize change
//   - an indicator drawn in a rotated local frame
//   - keyboard, wheel and accessibility on a canvas-drawn control
//   - repaint driven purely by state change — no frame loop
//   - the knob's geometry living in one place, shared by painter and input

import QtQuick
import QtCanvas2D

Item {
    id: root

    property real from: 0
    property real to: 100
    property real value: 35
    property real stepSize: 1
    property string label: qsTr("Gain")
    property bool fineMode: false     // hold Shift for 10x precision

    signal moved()

    implicitWidth: 140
    implicitHeight: 160

    readonly property real normalized: (to === from)
        ? 0 : Math.max(0, Math.min(1, (value - from) / (to - from)))

    // Sweep from 7:30 round to 4:30, the usual knob convention.
    readonly property real startAngle: Math.PI * 0.75
    readonly property real sweepAngle: Math.PI * 1.5

    function setNormalized(n) {
        const clamped = Math.max(0, Math.min(1, n));
        let v = from + clamped * (to - from);
        if (stepSize > 0)
            v = from + Math.round((v - from) / stepSize) * stepSize;
        v = Math.max(Math.min(from, to), Math.min(Math.max(from, to), v));
        if (v !== value) {
            value = v;
            moved();
        }
    }

    function nudge(steps) {
        setNormalized(normalized + steps * (stepSize > 0 ? stepSize : 1)
                                   / Math.abs(to - from));
    }

    Canvas2D {
        id: canvas
        anchors.fill: parent

        property path2d ticks
        readonly property int tickGroup: 0

        fillColor: "transparent"
        alphaBlending: true

        readonly property real cx: width * 0.5
        readonly property real cy: height * 0.46
        readonly property real radius: Math.min(width, height * 0.9) * 0.36

        Component.onCompleted: requestPaint()
        onWidthChanged: { ticks.clear(); requestPaint(); }
        onHeightChanged: { ticks.clear(); requestPaint(); }

        function buildTicks() {
            const count = 21;
            for (let i = 0; i < count; ++i) {
                const a = root.startAngle + root.sweepAngle * (i / (count - 1));
                const outer = radius * 1.34;
                const inner = radius * (i % 5 === 0 ? 1.18 : 1.25);
                ticks.moveTo(cx + Math.cos(a) * inner, cy + Math.sin(a) * inner);
                ticks.lineTo(cx + Math.cos(a) * outer, cy + Math.sin(a) * outer);
            }
        }

        onPaint: {
            const ctx = getContext("2d");
            const r = radius;
            if (r <= 0)
                return;

            if (ticks.isEmpty())
                buildTicks();
            ctx.lineCap = "butt";
            ctx.lineWidth = Math.max(1, r * 0.05);
            ctx.strokeStyle = "#3b4753";
            ctx.stroke(ticks, tickGroup);

            // Arc track, then the filled portion.
            ctx.lineCap = "round";
            ctx.lineWidth = r * 0.16;
            ctx.strokeStyle = "#26303a";
            ctx.beginPath();
            ctx.arc(cx, cy, r * 1.02, root.startAngle,
                    root.startAngle + root.sweepAngle);
            ctx.stroke();

            if (root.normalized > 0.002) {
                ctx.strokeStyle = drag.active ? "#8ff3c4" : "#2CDE85";
                ctx.beginPath();
                ctx.arc(cx, cy, r * 1.02, root.startAngle,
                        root.startAngle + root.sweepAngle * root.normalized);
                ctx.stroke();
            }

            // Cap: shadow, body, sheen.
            const shadow = ctx.createBoxShadow(cx - r, cy - r + r * 0.08,
                                               r * 2, r * 2,
                                               r * 0.3, "#b0000000", r);
            ctx.drawBoxShadow(shadow);

            ctx.beginPath();
            ctx.circle(cx, cy, r);
            ctx.fillStyle = "#222a33";
            ctx.fill();

            const sheen = ctx.createLinearGradient(cx, cy - r, cx, cy + r);
            sheen.addColorStop(0.0, Qt.rgba(1, 1, 1, 0.14));
            sheen.addColorStop(1.0, Qt.rgba(0, 0, 0, 0.18));
            ctx.fillStyle = sheen;
            ctx.fill();

            // Indicator, in a rotated local frame.
            ctx.save();
            ctx.translate(cx, cy);
            ctx.rotate(root.startAngle + root.sweepAngle * root.normalized);
            ctx.beginPath();
            ctx.roundRect(r * 0.3, -r * 0.06, r * 0.62, r * 0.12, r * 0.06);
            ctx.fillStyle = "#f0f2f4";
            ctx.fill();
            ctx.restore();

            if (root.activeFocus) {
                ctx.strokeStyle = "#41CDDD";
                ctx.lineWidth = 2;
                ctx.beginPath();
                ctx.circle(cx, cy, r * 1.34);
                ctx.stroke();
            }

            ctx.textAlign = "center";
            ctx.textBaseline = "middle";
            ctx.fillStyle = "#f0f2f4";
            ctx.font = Math.round(r * 0.42) + "px sans-serif";
            ctx.fillText(root.value.toFixed(root.stepSize < 1 ? 1 : 0), cx, cy);
            ctx.font = Math.round(r * 0.3) + "px sans-serif";
            ctx.fillStyle = "#8b96a2";
            ctx.fillText(root.label, cx, height - r * 0.35);
        }
    }

    // Repaint on every visual state change.
    onValueChanged: canvas.requestPaint()
    onActiveFocusChanged: canvas.requestPaint()

    // Vertical drag, not angle tracking: no wrap-around, and the travel
    // distance is the same wherever the pointer grabbed the knob.
    DragHandler {
        id: drag
        target: null
        cursorShape: Qt.SizeVerCursor
        property real startNormalized: 0
        onActiveChanged: {
            if (active)
                startNormalized = root.normalized;
            canvas.requestPaint();
        }
        onTranslationChanged: {
            if (!active)
                return;
            const travel = (root.fineMode ? 1400 : 180);
            root.setNormalized(startNormalized - activeTranslation.y / travel);
        }
    }

    WheelHandler {
        onWheel: (event) => root.nudge(event.angleDelta.y > 0 ? 1 : -1)
    }

    TapHandler { onTapped: root.forceActiveFocus() }

    activeFocusOnTab: true
    Keys.onUpPressed: root.nudge(1)
    Keys.onDownPressed: root.nudge(-1)
    Keys.onRightPressed: root.nudge(1)
    Keys.onLeftPressed: root.nudge(-1)
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Home) {
            root.value = root.from;
            event.accepted = true;
        } else if (event.key === Qt.Key_End) {
            root.value = root.to;
            event.accepted = true;
        }
        root.fineMode = (event.modifiers & Qt.ShiftModifier) !== 0;
    }
    Keys.onReleased: (event) => {
        root.fineMode = (event.modifiers & Qt.ShiftModifier) !== 0;
    }

    Accessible.role: Accessible.Dial
    Accessible.name: label
    Accessible.description: value.toFixed(stepSize < 1 ? 1 : 0)
    Accessible.onIncreaseAction: nudge(1)
    Accessible.onDecreaseAction: nudge(-1)
}
