# Canvas2D topic rules

Read the section that matches what the drawing actually does. The universal
rules — canvas lifecycle, paint state, geometry semantics and path caching —
are in `SKILL.md` and always apply.

## Brushes, gradients, patterns

| Rule | Detail |
|---|---|
| Reuse brushes as value-type properties across frames | `property lineargradient2d areaFill`, mutated via `setStartPosition()`/`setEndPosition()`. |
| `Qt.rgba()` inside loops, colour strings outside | A string is parsed to `QColor` on every assignment. |
| `createBoxShadow()` + `drawBoxShadow()` instead of a blurred shape | SDF-based, cheap, rounded-rect only. Per-corner radii; `-1` means "use `radius()`". |
| `createBoxGradient(x, y, w, h, feather, radius)` for rounded-rect glows | Follows the rounded-rect shape. |
| `createGridPattern()` for graph paper, rules and bars — never a loop of lines | Constant cost. `cellSize` width or height `0` gives bars; rotation gives hatching. |
| `createConicalGradient()` sweeps **clockwise** | Qt Quick `Canvas` sweeps the other way — reverse stops when porting. |
| `createRadialGradient(x, y, r0, r1)` when concentric | The 6-arg form gives independent centres. |
| `createPattern()` needs a loaded image | Tint with `setTintColor()`, scale with `setImageSize()`. |

## Text

| Rule | Detail |
|---|---|
| `font` needs size **then** family | `"24px 'Titillium Web'"`. Quote families with spaces. Default `"10px sans-serif"`. |
| Set `textAlign`/`textBaseline` explicitly | Defaults `"start"`/`"alphabetic"`; centred in a shape is `"center"` + `"middle"`. |
| `fillText(text, x, y, width, height)` for boxed text | With `textWrapMode` (default `"nowrap"`) and `textLineHeight`; use baseline `"top"` or `"middle"`. |
| `measureText(text).width` for layout | Width is the only field. |
| No `strokeText()` | Adjust `textAntialias` instead. |
| `qsTr()` every user-visible canvas string | Bind the translated string into a property read in `onPaint`. |

## Input and hit testing

| Rule | Detail |
|---|---|
| No `isPointInPath()`/`isPointInStroke()` | Hit testing is yours. |
| Layer real QML input handlers over the canvas | `TapHandler`, `HoverHandler`, `DragHandler`, `PointHandler`, `MouseArea` — hover, focus, keyboard and accessibility come free. |
| One geometry source of truth for painter and hit test | Otherwise they drift apart. |
| Repaint on interaction state change | |
| `Accessible.role`/`Accessible.name` on the canvas or its input layer | A canvas is an opaque pixmap to a screen reader; decorative ones get `Accessible.ignored: true`. |

## Images

| Rule | Detail |
|---|---|
| `loadImage()` before any `drawImage()` | An unloaded URL draws nothing, silently. |
| `onImageLoaded: canvas.requestPaint()` | Otherwise the first frames are missing images. |
| Pass `sourceSize` for SVG and oversized raster | `loadImage("logo.svg", Qt.size(32, 23))`. |
| Guard conditional draws with `isImageLoaded()`/`isImageError()` | |
| `unloadImage()` when a large image leaves the scene | |

## Performance

| Rule | Detail |
|---|---|
| Hoist invariants out of the draw loop | Property reads from JS are not free. |
| Batch into one path, then one `fill()`/`stroke()` | |
| Cache static geometry in a path group; leave dynamic geometry at `-1` | |
| `setClipRect()` only when needed; `resetClipping()` after | Rectangle only, transformed by the current transform, real cost. |
| `antialias` is a width in pixels (default `1.0`, max `10.0`), not a boolean | Low for hairlines, high for glow; settable per fill/stroke. |
| Leave `highQualityStroking: false` unless self-overlapping semi-transparent strokes look wrong | |
| Raise the inherited `sampleCount` for edge quality `antialias` cannot reach | MSAA; costs memory and fill rate. |
| `debug` render stats need `QCPAINTER_DEBUG_COLLECT=1` | |

---

