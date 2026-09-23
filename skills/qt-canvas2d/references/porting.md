# Porting to Canvas2D

Three source directions: Qt Quick `Canvas`, HTML5 `<canvas>`, and the
`QCanvasPainter` C++ API.

---

## 1. Qt Quick `Canvas` → `Canvas2D`

The APIs are almost fully compatible. The nominal change is two lines.

```qml
// Before
import QtQuick

Canvas {
    onPaint: { var ctx = getContext("2d"); paintEverything(ctx); }
}
```

```qml
// After
import QtQuick
import QtCanvas2D

Canvas2D {
    onPaint: { var ctx = getContext("2d"); paintEverything(ctx); }
}
```

The upstream `canvas2dtester` example relies on exactly this: one set of
JavaScript painting functions is called for both a `Canvas` and a `Canvas2D`
item.

### What actually changes

| | Qt Quick `Canvas` | `Canvas2D` |
|---|---|---|
| Painting backend | `QPainter` (CPU) into a `QImage`, uploaded as a texture | Qt Canvas Painter on the GPU via QRhi |
| Render targets | `Canvas.Image` (`FramebufferObject` ignored since Qt 6.0) | Renders directly into the scene graph via QRhi; no render-target property |
| Animated / large canvases | Documentation warns against them, due to per-update texture uploads | The primary use case |
| Contents between frames | Retained; you call `clearRect()` yourself | Cleared each frame; `fillColor` defines the background |
| Path caching | No | Yes, via `path2d` + path groups |
| Clipping | `clip()` to an arbitrary path (potentially costly) | `setClipRect()`, rectangle only |
| Dashed strokes | Yes (`setLineDash`) | Not available |
| Shadows | `shadowBlur` / `shadowColor` | Fast SDF box shadows for rounded rects; adjustable antialiasing for other shapes |
| Pixel operations | `getImageData()` / `putImageData()` | Not available |
| Antialiasing | Fixed | Adjustable per stroke/fill and for text |
| Extra brushes | — | Box gradient, grid pattern, tinted images |
| Colour effects | `globalAlpha` | `globalAlpha`, `globalBrightness`, `globalContrast`, `globalSaturation` |

Reported benchmark on the author's laptop with all tests rendering 16 times:
4 FPS (`Canvas`) vs 165 FPS (`Canvas2D`) — over 40× — with byte-identical
JavaScript. The difference is entirely that Canvas2D is optimized for animated
content.

### Port checklist

1. Add `import QtCanvas2D`; rename `Canvas` → `Canvas2D`.
2. Add `Qt6::CanvasPainter` to `target_link_libraries` and
   `find_package(Qt6 REQUIRED COMPONENTS Quick CanvasPainter)`;
   `qt_standard_project_setup(REQUIRES 6.12)`.
3. Delete the leading `clearRect(0, 0, width, height)` from `onPaint`.
4. Set `fillColor` and `alphaBlending`. Quick `Canvas` is transparent by
   default; `Canvas2D` clears to **opaque black**. For the old behaviour:
   `fillColor: "transparent"; alphaBlending: true`.
5. Remove `renderTarget` / `renderStrategy`.
6. **`ellipse()`**: Quick `Canvas` takes a bounding rectangle; Canvas2D takes
   centre + radii. Rename to `ellipseRect(x, y, w, h)` for a mechanical port, or
   convert to `ellipse(cx, cy, rx, ry)`.
7. **Conical gradients** sweep clockwise in Canvas2D and counter-clockwise in
   Quick `Canvas`. Reverse the colour stops, and negate the start angle.
8. Replace `clip()` with `setClipRect()` + `resetClipping()`, or restructure.
9. Replace `setLineDash()` with a `gridpattern2d` `strokeStyle` or manual
   segmentation.
10. Replace `shadowBlur`/`shadowColor` with `createBoxShadow()` +
    `drawBoxShadow()`.
11. Remove `getImageData()`/`putImageData()` round-trips.
12. Reduce `globalCompositeOperation` to `source-over`, `source-atop` or
    `destination-out`.
13. Swap the repaint driver: `Timer` → `FrameAnimation`.
14. Now optimize: move static geometry into `property path2d` objects filled or
    stroked with a path group `≥ 0`.

If the code depends on a Quick `Canvas` feature Canvas2D lacks and it performs
acceptably, keeping `Canvas` is a legitimate answer — it is still available.

---

## 2. HTML5 `<canvas>` → `Canvas2D`

`Canvas2DContext` implements the same W3C Canvas 2D Context API: `beginPath()`,
`moveTo()`, `lineTo()`, `bezierCurveTo()`, `fill()`, `stroke()`, and the state
properties `fillStyle`, `strokeStyle`, `lineWidth`, `lineCap`, `lineJoin`. Canvas
code from the web, a tutorial, or Stack Overflow often just runs.

Structural changes:

- Replace all DOM API calls with QML property bindings or `Canvas2D` methods.
- Replace all HTML event handlers with QML input handlers (`TapHandler`,
  `HoverHandler`, `DragHandler`) or `MouseArea`.
- Replace `setInterval` / `setTimeout` with `FrameAnimation` or
  `requestAnimationFrame()`.
- Put painting code in `onPaint`; trigger it with `requestPaint()` or
  `markDirty()`.
- Load images with `loadImage()` and repaint in `onImageLoaded`.
- Drop the leading `clearRect()` — the canvas is already cleared each frame.

API gaps to resolve: arbitrary-path `clip()`, `setLineDash()`,
`isPointInPath()`/`isPointInStroke()`, `strokeText()`, `filter`,
`shadowBlur` and friends, `getImageData()`/`putImageData()`, and all composite
modes except `source-over`, `source-atop`, `destination-out`.

Semantic gaps: `ellipse()` is centre + radii but takes **no** rotation or angle
arguments (use `ellipseRect()` for a bounding rect); `reset()` does not clear
the canvas buffers.

Worth adopting once running: `path2d` path groups, adjustable `antialias`,
`createBoxGradient()`, `createBoxShadow()`, `createGridPattern()`,
`globalBrightness`/`Contrast`/`Saturation`, hole subpaths, boxed
`fillText(text, x, y, w, h)` with `textWrapMode`, `circle()`/`ellipseRect()`,
and `transform2d` instead of juggling six floats or a `DOMMatrix`.

---

## 3. `QCanvasPainter` (C++) ⇄ `Canvas2DContext` (QML)

Two faces of the same painter. The C++ API uses setter methods and Qt value
types; the QML API uses properties and JavaScript-friendly arguments. Method
names, argument order and semantics match, so porting either way is close to
mechanical.

| C++ `QCanvasPainter` | QML `Canvas2DContext` |
|---|---|
| `p->setFillStyle("#ff0000")` | `ctx.fillStyle = "#ff0000"` |
| `p->setAntialias(10)` | `ctx.antialias = 10` |
| `p->setTextAlign(QCanvasPainter::TextAlign::Center)` | `ctx.textAlign = "center"` |
| `QCanvasLinearGradient lg(...)` | `let lg = ctx.createLinearGradient(...)` |
| `QCanvasPath` | `path2d` |
| `QRectF rect` argument | `x, y, width, height` arguments |

Same drawing, both languages:

```cpp
QRectF rect(40, 70, 120, 60);
QRectF shadowRect = rect.translated(2, 4);
QCanvasBoxShadow shadow(shadowRect);
shadow.setRadius(30);
shadow.setBlur(15);
shadow.setColor("#60373F26");
p->drawBoxShadow(shadow);

p->beginPath();
p->roundRect(rect, 30);
p->setFillStyle("#DBEB00");
p->fill();

p->setTextAlign(QCanvasPainter::TextAlign::Center);
p->setTextBaseline(QCanvasPainter::TextBaseline::Middle);
QFont font("Titillium Web", 18);
p->setFont(font);
p->setFillStyle("#373F26");
p->fillText("CLICK!", rect);
```

```js
let offsetX = 2;
let offsetY = 4;
let shadow = ctx.createBoxShadow(40 + offsetX, 70 + offsetY, 120, 60);
shadow.setRadius(30);
shadow.setBlur(15);
shadow.setColor("#60373F26");
ctx.drawBoxShadow(shadow);

ctx.beginPath();
ctx.roundRect(40, 70, 120, 60, 30);
ctx.fillStyle = "#DBEB00";
ctx.fill();

ctx.textAlign = "center";
ctx.textBaseline = "middle";
ctx.font = "24px 'Titillium Web'";
ctx.fillStyle = "#373F26";
ctx.fillText("CLICK!", 100, 100);
```

This unification is the practical payoff: prototype a visualization in QML where
the edit-run cycle is seconds, then — if profiling says the JavaScript is the
bottleneck, or the data lives on the C++ side — move the same drawing code into
a `QCanvasPainterItem` subclass with mostly search-and-replace. The rendering
engine does not change, only the language, so the output stays identical.
