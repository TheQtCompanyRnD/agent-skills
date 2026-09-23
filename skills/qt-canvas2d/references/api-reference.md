# Qt Canvas2D — complete API reference

Module: **Qt Canvas Painter** (commercial or GPLv3). Import: `import QtCanvas2D`.
Introduced in **Qt 6.12**.

CMake: `find_package(Qt6 REQUIRED COMPONENTS Quick CanvasPainter)` and link
`Qt6::CanvasPainter`.

This file is the authoritative API surface. If a method or property is not here,
it does not exist in Canvas2D.

Types: `Canvas2D` (item), `Canvas2DContext` (object), and the value types
`path2d`, `transform2d`, `lineargradient2d`, `radialgradient2d`,
`conicalgradient2d`, `boxgradient2d`, `boxshadow2d`, `gridpattern2d`,
`imagepattern2d`.

---

## Canvas2D (QML item)

Inherits `QCanvasPainterItem` → `QQuickRhiItem` → `Item`.

### Properties

| Property | Type | Notes |
|---|---|---|
| `available` | `bool` | Read-only. True when the canvas can provide a drawing context. |
| `context` | `object` | Read-only. The active drawing context, or `null`. |
| `contextType` | `string` | Name of the active context type. Setting it makes the canvas create that context once available. Only `"2d"` is supported. |
| `fillColor` | `color` | Background the canvas is cleared to each frame. **Default `black`.** Set to `"transparent"` (with `alphaBlending: true`) for no background. |
| `alphaBlending` | `bool` | **Default `false`**, for performance. Set `true` when `fillColor` is semi-transparent or when using composite modes. |
| `debug` | `var` | Read-only key/value map of render statistics. Only collected when the environment variable `QCPAINTER_DEBUG_COLLECT` is non-zero. |

`fillColor` and `alphaBlending` are inherited and are not listed on the
published `Canvas2D` QML page, but they are documented on the type, exported in
`QtCanvas2D/plugins.qmltypes`, and used by the upstream examples.

### Other inherited properties (from `QQuickRhiItem`)

Rarely needed, but available and occasionally decisive:

| Property | Type | Notes |
|---|---|---|
| `sampleCount` | `int` | MSAA sample count for the item's colour buffer (`1`, `4`, `8`). Raising it smooths edges that `ctx.antialias` cannot. Costs memory and fill rate. **Final** — do not shadow this name with your own property. |
| `mirrorVertically` | `bool` | Flips the rendered content vertically. |
| `colorBufferFormat` | `enum` | Colour buffer format of the offscreen target. |
| `fixedColorBufferWidth` / `fixedColorBufferHeight` | `int` | Render at a fixed resolution independent of item size — useful for deliberately low-res or super-sampled canvases. |
| `effectiveColorBufferSize` | `size` | Read-only actual buffer size in pixels. |

`QQuickRhiItem` declares several of its properties `FINAL`; a QML property of the
same name on your `Canvas2D` is an error. `sampleCount` in particular is an easy
name to collide with.

### Signals

| Signal | Handler | Notes |
|---|---|---|
| `paint(rect region)` | `onPaint` | Emitted when `region` needs rendering. Triggered by `markDirty()`, `requestPaint()`, or a canvas window change. |
| `painted()` | `onPainted` | Emitted after all context painting commands have executed and the canvas has been rendered. |
| `imageLoaded()` | `onImageLoaded` | Emitted when an image passed to `loadImage()` has finished loading. |

### Methods

```
object getContext(string contextId, ... args)   // extra args ignored; "2d" only
void   requestPaint()                            // redraw the entire visible region
void   markDirty()                               // mark dirty; triggers paint
int    requestAnimationFrame(callback)           // invoke callback before scene composition
void   cancelRequestAnimationFrame(int handle)

void   loadImage(url image, size sourceSize)     // sourceSize optional; async
void   unloadImage(url image)
bool   isImageLoaded(url image)
bool   isImageLoading(url image)
bool   isImageError(url image)
```

`getContext()` returns the same object for repeated calls with the same
`contextId`, and `null` if the type is unsupported or incompatible with an
earlier request.

`loadImage()` with `sourceSize` scales during loading — the right way to load
SVGs at their display size. Only loaded images can be painted.

### Minimal example

```qml
import QtQuick
import QtCanvas2D

Canvas2D {
    id: mycanvas
    width: 100
    height: 200
    onPaint: {
        var ctx = getContext("2d");
        ctx.fillStyle = Qt.rgba(1, 0, 0, 1);
        ctx.fillRect(0, 0, width, height);
    }
}
```

---

## Canvas2DContext

Obtained via `canvas.getContext("2d")`. Implements the W3C Canvas 2D Context
API with the omissions and additions listed in SKILL.md.

### Properties

| Property | Type | Default | Notes |
|---|---|---|---|
| `canvas` | `Canvas2D` | — | Read-only. The item being painted. |
| `fillStyle` | `variant` | `'#000000'` | CSS colour string, QML colour, or a canvas brush object. Invalid values ignored. |
| `strokeStyle` | `variant` | `'#000000'` | Same accepted values as `fillStyle`. |
| `fillRule` | `string` | `"nonzero"` | `"nonzero"` (a.k.a. `"WindingFill"`) or `"evenodd"` (a.k.a. `"OddEvenFill"`). Applies to later `fill()` calls. |
| `lineWidth` | `real` | `1.0` | With antialiasing on, sub-pixel widths fade opacity instead of disappearing. |
| `lineCap` | `string` | `"butt"` | `"butt"`, `"round"`, `"square"`. |
| `lineJoin` | `string` | `"miter"` | `"miter"`, `"bevel"`, `"round"`. |
| `miterLimit` | `real` | `10.0` | Corner length past which a miter join becomes a bevel. Only affects `"miter"`. |
| `antialias` | `real` | `1.0` | Antialiasing **width in pixels**, max `10.0`. Fills and strokes only, not images or text. Settable per path. |
| `highQualityStroking` | `bool` | `false` | More correct rendering where semi-transparent strokes self-overlap. Costs more. |
| `windingEnforce` | `bool` | `true` | When `false`, raw point order decides solid vs hole instead of `setPathWinding()`. Faster. |
| `globalAlpha` | `real` | `1.0` | `0.0`–`1.0`, applied to all rendering. |
| `globalBrightness` | `real` | `1.0` | `0` = black. May exceed `1.0`. |
| `globalContrast` | `real` | `1.0` | `0` = flat grey (0.5, 0.5, 0.5). May exceed `1.0`. |
| `globalSaturation` | `real` | `1.0` | `0` = greyscale. May exceed `1.0`. |
| `globalCompositeOperation` | `string` | `"source-over"` | Only `"source-over"`, `"source-atop"`, `"destination-out"`. Requires `alphaBlending: true` and a transparent canvas background to work properly. |
| `font` | `string` | `"10px sans-serif"` | `[style] [variant] [weight] size family`. `font-size` (`Npx`/`Npt`) and `font-family` are mandatory and must appear in that order. Quote families with spaces. Style: `normal\|italic\|oblique`; variant: `normal\|small-caps`; weight: `normal\|bold\|1…1000`. |
| `textAlign` | `string` | `"start"` | `"start"`, `"end"`, `"left"`, `"right"`, `"center"`. |
| `textBaseline` | `string` | `"alphabetic"` | `"top"`, `"hanging"`, `"middle"`, `"alphabetic"`, `"bottom"`. |
| `textWrapMode` | `string` | `"nowrap"` | `"nowrap"`, `"wrap"`, `"wordwrap"`, `"wrapanywhere"`. |
| `textLineHeight` | `real` | `0` | Line-height adjustment in pixels; may be negative. |
| `textAntialias` | `real` | `1.0` | Multiplier on normal text antialiasing; `0.0` disables. SDF-based, so the usable maximum is limited and affects small text less. |
| `direction` | `string` | `"inherit"` | `"inherit"` (from `QGuiApplication::layoutDirection`), `"ltr"`, `"rtl"`, `"auto"` (detect from the string). |

`fillStyle` / `strokeStyle` accept: `'rgb(r,g,b)'`, `'rgba(r,g,b,a)'` (numbers or
percentages), `'hsl(...)'`, `'hsla(...)'`, `'#RRGGBB'`, `'#AARRGGBB'`, SVG colour
names, `Qt.rgba(r, g, b, a)`, `Qt.hsla(h, s, l, a)`.
**In loops prefer `Qt.rgba()`** — it is already a valid `QColor` and skips parsing.

### Path construction

```
void beginPath()
void closePath()
void moveTo(real x, real y)
void lineTo(real x, real y)
void arc(real x, real y, real radius, real startAngle, real endAngle, bool anticlockwise)
void arcTo(real x1, real y1, real x2, real y2, real radius)
void bezierCurveTo(real cp1x, real cp1y, real cp2x, real cp2y, real x, real y)
void quadraticCurveTo(real cpx, real cpy, real x, real y)
void rect(real x, real y, real width, real height)
void roundRect(real x, real y, real width, real height, real radius)
void roundRect(real x, real y, real width, real height,
               real radiusTopLeft, real radiusTopRight,
               real radiusBottomRight, real radiusBottomLeft)
void circle(real centerX, real centerY, real radius)
void ellipse(real centerX, real centerY, real radiusX, real radiusY)
void ellipseRect(real x, real y, real width, real height)
void addPath(path2d path, transform2d transform)
void addPath(path2d path, int start, int count, transform2d transform)
```

Angles are in **radians**. `arc()` default direction is clockwise.

`circle()` and `ellipse()` do **not** add a connecting line from the current
point, unlike `arc()`. Prefer them for closed primitives.

`ellipse()` takes a **centre and radii**. `ellipseRect()` takes a bounding
rectangle and matches `QtQuick::Context2D::ellipse()`.

`addPath()` with no transform (or an identity one) is very fast — it reuses the
path data. The `start`/`count` overload adds a sub-range of path commands and is
range-checked; call `moveTo()` first if the range should not continue from the
current point.

### Sub-path winding (holes)

```
void beginHoleSubPath()      // == setPathWinding("clockwise")
void beginSolidSubPath()     // == setPathWinding("counterclockwise")
void setPathWinding(string winding)   // "counterclockwise" (default) | "clockwise"
```

```js
ctx.beginPath();
ctx.circle(100, 100, 80);
ctx.beginHoleSubPath();
ctx.rect(60, 60, 80, 80);
ctx.beginSolidSubPath();
ctx.circle(100, 100, 20);
ctx.fill();
ctx.stroke();
```

### Painting

```
void fill()
void fill(string fillRule)
void fill(path2d path, int pathGroup)
void fill(path2d path, string fillRule, int pathGroup)
void stroke()
void stroke(path2d path, int pathGroup)
void fillRect(real x, real y, real width, real height)
void strokeRect(real x, real y, real width, real height)
void clearRect(real x, real y, real width, real height)
void drawBoxShadow(boxshadow2d shadow)
```

`pathGroup` defaults to `-1` = **not cached**. Pass `≥ 0` to cache the path's
vertex data GPU-side; paths in the same group share one buffer. `beginPath()` is
not required before the `path2d` overloads or before `drawBoxShadow()`.

`clearRect()` fills with transparent black; it does not blend, so it is faster
than `fillRect()`. `fillRect()`/`strokeRect()` are conveniences — for more than
one rectangle, build a path with `rect()`.

### Text

```
void   fillText(text, x, y, maxWidth)          // maxWidth optional, default 0
void   fillText(text, x, y, width, height)     // boxed + wrapped; width is maxWidth
object measureText(text)                       // -> { width }
```

`measureText().width` equals `QFontMetricsF::horizontalAdvance()` for the current
font. With the boxed overload, set `textBaseline` to `"top"` or `"middle"`.
There is no `strokeText()`.

### Transforms

```
void       translate(real x, real y)
void       rotate(real angle)                 // radians, clockwise
void       scale(real scale)
void       scale(real sx, real sy)
void       skew(real angleX, real angleY)     // radians; angleY defaults to 0
void       transform(transform2d transform)
void       transform(real a, real b, real c, real d, real e, real f)
void       setTransform(transform2d transform)
void       setTransform(real a, real b, real c, real d, real e, real f)
void       resetTransform()                   // == setTransform(1, 0, 0, 1, 0, 0)
transform2d getTransform()
transform2d createTransform2D()               // identity
```

Matrix layout: `a` x-scale, `b` y-skew, `c` x-skew, `d` y-scale, `e` x-translate,
`f` y-translate. `transform()` multiplies; `setTransform()` replaces.

### State and clipping

```
void save()             // push paint state (NOT the current path)
void restore()          // pop; no-op on an empty stack
void reset()            // restore default paint state WITHOUT clearing pixels
void setClipRect(real x, real y, real width, real height)   // transformed by current transform
void resetClipping()
void cleanupResources()             // drop unused textures / shrink caches
void removePathGroup(int pathGroup) // free a cached path group's buffer
```

Clipping is rectangle-only and has a real cost. `reset()` differs from HTML
canvas `reset()` in that it does not clear the canvas buffers.

### Brush factories

```
lineargradient2d  createLinearGradient(real x0, real y0, real x1, real y1)
radialgradient2d  createRadialGradient(real x0, real y0, real r0, real x1, real y1, real r1)
radialgradient2d  createRadialGradient(real x, real y, real r0, real r1)   // concentric
conicalgradient2d createConicalGradient(real x, real y, real angle)        // radians, clockwise
boxgradient2d     createBoxGradient(real x, real y, real width, real height,
                                    real feather, real radius)
boxshadow2d       createBoxShadow(real x, real y, real width, real height)
boxshadow2d       createBoxShadow(real x, real y, real width, real height,
                                  real blur, string color, real radius)
boxshadow2d       createBoxShadow(real x, real y, real width, real height,
                                  real blur, string color,
                                  real radiusTopLeft, real radiusTopRight,
                                  real radiusBottomRight, real radiusBottomLeft)
gridpattern2d     createGridPattern(real x, real y, real width, real height,
                                    string lineColor, string backgroundColor,
                                    real lineWidth, real feather, real angle)
imagepattern2d    createPattern(Image image, string repetition)
path2d            createPath2D()
path2d            createPath2D(path2d path)
path2d            createPath2D(string svgPath)
```

Gradients need two or more colour stops. `createPattern()` accepts an `Image`
item or a loaded image URL; it throws `INVALID_STATE_ERR` if there is no image
data. `repetition`: `"repeat"` (default when empty/null), `"repeat-x"`,
`"repeat-y"`, `"no-repeat"`.

### Images

```
void drawImage(variant image, real dx, real dy)
void drawImage(variant image, real dx, real dy, real dw, real dh)
void drawImage(variant image, real sx, real sy, real sw, real sh,
               real dx, real dy, real dw, real dh)
```

`image` is an `Image` item or an image URL. An `Image` item that is not fully
loaded draws nothing; a URL must first be passed to `Canvas2D::loadImage()`.
Subject to the current clip.

---

## path2d (value type)

A painter-path container matching `QCanvasPath`. Declarable as a QML property:
`property path2d myPath`.

```
void addPath(path2d path, transform2d transform)
void addPath(string svgPath, transform2d transform)
void addPath(path2d path, int start, int count, transform2d transform)
void arc(real x, real y, real radius, real startAngle, real endAngle, bool counterClockWise)
void arcTo(real x1, real y1, real x2, real y2, real radius)
void beginHoleSubPath()
void beginSolidSubPath()
void bezierCurveTo(real cp1x, real cp1y, real cp2x, real cp2y, real x, real y)
void circle(real x, real y, real radius)
void clear()
void closePath()
void ellipse(real x, real y, real radiusX, real radiusY)
void ellipseRect(real x, real y, real width, real height)
bool isEmpty()
void lineTo(real x, real y)
void moveTo(real x, real y)
void quadraticCurveTo(real cpx, real cpy, real x, real y)
void rect(real x, real y, real width, real height)
void roundRect(real x, real y, real width, real height, real radius)
void roundRect(real x, real y, real width, real height,
               real radiusTopLeft, real radiusTopRight,
               real radiusBottomRight, real radiusBottomLeft)
void setPathWinding(string winding)   // "counterclockwise" (default) | "clockwise"
```

`setPathWinding()` is a *command* in the stream, like `moveTo`: set it before the
commands it should apply to. `ellipse()` is centre + radii; `ellipseRect()` is
the bounding-rect form. Both ellipse forms start and finish at 0° (3 o'clock),
composed clockwise.

Idiom:

```qml
property path2d ticks

// in onPaint
if (ticks.isEmpty()) {
    for (let i = 0; i < 60; ++i) { /* build once */ }
}
ctx.stroke(ticks, 1);   // group 1 -> cached on the GPU
```

```qml
onWidthChanged: { ticks.clear(); canvas.requestPaint(); }
```

---

## transform2d (value type)

A 3x3 2D transformation matrix matching `QTransform`. Elements are `m11`…`m33`
in row/column order; defaults to identity. Declarable: `property transform2d t`.

```
real        m11()  m12()  m13()
real        m21()  m22()  m23()
real        m31()  m32()  m33()
real        determinant()
transform2d inverted()          // identity if not invertible
transform2d transposed()
transform2d times(real factor)
transform2d times(transform2d other)
void        reset()
void        rotate(real angle)          // DEGREES, counter-clockwise
void        rotateRadians(real angle)   // radians, counter-clockwise
void        scale(real scale)
void        scale(real sx, real sy)
void        shear(real sh, real sv)
void        translate(real dx, real dy)
void        setMatrix(real m11, real m12, real m21, real m22, real m31, real m32)
void        setMatrix(real m11, real m12, real m13, real m21, real m22, real m23,
                      real m31, real m32, real m33)
```

`m11` x-scale, `m12` y-shear, `m13` x-projection, `m21` x-shear, `m22` y-scale,
`m23` y-projection, `m31` x-translate, `m32` y-translate, `m33` division factor.

**`rotate()` here is degrees**, unlike `ctx.rotate()` which is radians. Use
`rotateRadians()` to keep one unit throughout a file.

---

## lineargradient2d

```
void  addColorStop(real offset, string color)   // offset 0.0 .. 1.0
point startPosition()
point endPosition()
void  setStartPosition(real x, real y)
void  setStartPosition(point start)
void  setEndPosition(real x, real y)
void  setEndPosition(point end)
```

## radialgradient2d

Paints along the cone between an inner circle and an outer circle.

```
void  addColorStop(real offset, string color)
point centerPosition()          // same as outerCenterPosition()
point innerCenterPosition()
point outerCenterPosition()
real  innerRadius()             // default 0.0
real  outerRadius()
void  setCenterPosition(real x, real y)       // sets BOTH centres -> symmetric
void  setCenterPosition(point center)
void  setInnerCenterPosition(real x, real y)
void  setInnerCenterPosition(point center)
void  setOuterCenterPosition(real x, real y)
void  setOuterCenterPosition(point center)
void  setInnerRadius(real radius)
void  setOuterRadius(real radius)
```

## conicalgradient2d

Interpolates around a centre point starting from `angle`, measured from the
horizontal-right line and proceeding **clockwise**.

```
void  addColorStop(real offset, string color)
point centerPosition()
real  startAngle()                       // radians
void  setCenterPosition(real x, real y)
void  setCenterPosition(point center)
void  setStartAngle(real angle)          // radians
```

## boxgradient2d

A gradient along the shape of a rounded rectangle.

```
void addColorStop(real offset, string color)
rect rect()
real feather()
real radius()
void setRect(x, y, width, height)
void setRect(rect)
void setFeather(real feather)
void setRadius(real radius)   // max = half the smaller of rect width/height
```

## boxshadow2d

CSS-style box shadow rendered with a signed-distance field — far cheaper than a
gaussian blur. Rounded rectangles only.

```
rect  rect()
rect  boundingRect()    // rect + blur + spread; use if not calling drawBoxShadow()
real  blur()            // default 0.0
real  spread()          // default 0.0
real  radius()          // default 0.0
color color()           // default opaque black
real  topLeftRadius()   topRightRadius()   bottomRightRadius()   bottomLeftRadius()
void  setRect(real x, real y, real width, real height)
void  setRect(rect shadowRect)
void  setBlur(real blur)
void  setSpread(real spread)
void  setRadius(real radius)
void  setColor(color shadowColor)
void  setTopLeftRadius(real radius)       // -1 (default) = use radius()
void  setTopRightRadius(real radius)
void  setBottomRightRadius(real radius)
void  setBottomLeftRadius(real radius)
```

## gridpattern2d

Dynamic grid and bar patterns at constant cost — use instead of a loop of lines.

```
size  cellSize()        // default (10, 10); width 0 -> no horizontal bars,
                        //                   height 0 -> no vertical bars
color lineColor()       // default white
color backgroundColor() // default black
real  lineWidth()       // default 1.0
real  feather()         // default 1.0 (one pixel of antialiasing)
real  rotation()        // radians, default 0.0, around startPosition()
point startPosition()   // top-left of the grid, default (0, 0)
void  setCellSize(real width, real height)
void  setCellSize(size cellSize)
void  setLineColor(color lineColor)
void  setBackgroundColor(color backgroundColor)
void  setLineWidth(real width)
void  setFeather(real feather)
void  setRotation(real rotation)
void  setStartPosition(real x, real y)
void  setStartPosition(point start)
```

## imagepattern2d

```
size  imageSize()
real  rotation()        // radians, default 0.0, around startPosition()
point startPosition()
color tintColor()       // default white = no tint; multiplied in the shader
void  setImageSize(real width, real height)
void  setImageSize(size imageSize)
void  setRotation(real rotation)
void  setStartPosition(real x, real y)
void  setStartPosition(point start)
void  setTintColor(color tintColor)
```

Set global transparency with `ctx.globalAlpha`, not through the tint colour.

---

## Worked examples from the official documentation

### Round button — shadow, rounded rect, centred text

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

### Simple graph — grid pattern, axes, glow stroke under a gradient stroke

```js
const grid = ctx.createGridPattern(0, 0, 10, 10, "#404040", "#202020");
const w = 200;
const h = 200;
ctx.fillStyle = grid;
ctx.fillRect(0, 0, w, h);

ctx.fillStyle = "white";
ctx.fillRect(0, 0.5 * h - 1, w, 2);
ctx.fillRect(0.5 * w - 1, 0, 2, h);

ctx.beginPath();
ctx.moveTo(20, h * 0.8);
ctx.bezierCurveTo(w * 0.2, h * 0.4, w * 0.5, h * 0.8, w - 20, h * 0.2);
ctx.antialias = 10;              // soft glow pass
ctx.lineWidth = 12;
ctx.strokeStyle = "#D0000000";
ctx.stroke();
ctx.antialias = 1;               // crisp pass
ctx.lineWidth = 6;
const lg = ctx.createLinearGradient(0, 0, 0, h);
lg.addColorStop(0, "red");
lg.addColorStop(1, "green");
ctx.strokeStyle = lg;
ctx.stroke();
```

### Per-path antialiasing

```js
ctx.lineWidth = 6;
for (let i = 1; i < 10; i++) {
    let y = i * 20;
    ctx.antialias = i;
    ctx.beginPath();
    ctx.moveTo(20, y);
    ctx.bezierCurveTo(80, y + 20, 120, y - 20, 180, y);
    ctx.stroke();
}
```

### Composite modes

```js
const modes = ["source-over", "source-atop", "destination-out"];
for (let i = 0; i < modes.length; i++) {
    ctx.globalCompositeOperation = "source-over";
    let y = 5 + i * 65;
    ctx.fillStyle = "#D9F720";
    ctx.fillRect(20, y, 140, 40);

    ctx.globalCompositeOperation = modes[i];
    ctx.beginPath();
    ctx.ellipse(130, y + 30, 60, 25);
    ctx.strokeStyle = "#00414A";
    ctx.fillStyle = "#2CDE85";
    ctx.fill();
    ctx.stroke();
}
```

### Holes without winding bookkeeping

```js
ctx.windingEnforce = false;
ctx.beginPath();
ctx.moveTo(20, 20);  ctx.lineTo(100, 180); ctx.lineTo(180, 20);  ctx.closePath();
ctx.moveTo(100, 40); ctx.lineTo(125, 90);  ctx.lineTo(75, 90);   ctx.closePath();
ctx.fill();
ctx.stroke();
```

### Cached path reuse with a transform

```js
// myPath is a `property path2d`
if (myPath.isEmpty())
    myPath.circle(60, 60, 40);
ctx.beginPath();
ctx.addPath(myPath);
let t = ctx.createTransform2D();
t.translate(80, 80);
ctx.addPath(myPath, t);
ctx.fill();
ctx.stroke();
```

### Text wrapped into a box

```js
ctx.strokeRect(50, 5, 100, 60);
let s = "This is a long string.";
ctx.textWrapMode = "wordwrap";
ctx.fillText(s, 50, 5, 100, 60);
```
