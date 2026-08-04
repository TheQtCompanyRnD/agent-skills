# QML Performance Anti-Pattern Reference

Use this reference when analyzing hotspots from a qmlprofiler trace.
Match the event type and code pattern to identify the root cause.

## Binding (frequent re-evaluation)

**Symptom:** A `Binding` event with high count and moderate total time.

**Common causes:**
- Binding depends on a property that changes every frame (e.g. animation
  progress, scroll position)
- Complex expression in a binding that could be simplified
- Binding on a property that triggers cascading changes to other bindings
- Using JavaScript expressions where simple property bindings suffice

**Fixes:**
- Use `Behavior` or `SmoothedAnimation` instead of re-evaluating each frame
- Cache computed values in a property and bind to that
- Break complex bindings into intermediate properties
- Use `readonly property` for values that don't change after creation

## Javascript (expensive execution)

**Symptom:** A `Javascript` event with high total time, often paired with
`HandlingSignal`.

**Common causes:**
- Heavy computation in a signal handler (e.g. rebuilding a model,
  recalculating layout)
- Array/object manipulation in JavaScript instead of C++
- Calling functions that trigger many property changes in sequence
- String concatenation or formatting in hot paths

**Fixes:**
- Move heavy computation to C++ (exposed via Q_INVOKABLE or properties)
- Batch property updates to avoid cascading re-evaluations
- Use WorkerScript for heavy async computation
- Cache results instead of recomputing

## HandlingSignal (expensive signal handlers)

**Symptom:** High time in `HandlingSignal`, often with matching `Javascript`
events at the same location.

**Common causes:**
- `onCompleted`, `onWidthChanged`, `onHeightChanged` doing too much work
- Signal handlers that modify many properties, triggering binding cascades
- Timer-driven handlers running expensive logic every tick

**Fixes:**
- Debounce frequent signals (e.g. resize) using a short Timer
- Move logic to C++ if it involves data processing
- Avoid modifying multiple properties individually — use a single state
  property that bindings read from

## Creating (slow component instantiation)

**Symptom:** High time in `Creating` events, especially during startup or
when navigating to new views.

**Common causes:**
- Large component trees created synchronously
- Components with many bindings evaluated at creation time
- Repeater/ListView delegates that are too complex
- Loading all views upfront instead of on demand

**Fixes:**
- Use `Loader` with `asynchronous: true` for heavy components
- Simplify delegates — extract sub-components, reduce binding count
- Use `StackView` for lazy loading of views
- Set `visible: false` does NOT prevent creation — use Loader instead

## Compiling (slow QML/JS compilation)

**Symptom:** High time in `Compiling` events, typically at startup.

**Common causes:**
- Large QML files compiled at first use
- Files not covered by ahead-of-time compilation (qmlcachegen)

**Fixes:**
- Ensure qmlcachegen/qmlsc is enabled in the build
- Split large QML files into smaller components (compiled separately)
- Preload critical components during splash screen

## SceneGraph / Painting / Animations (rendering bottlenecks)

**Symptom:** High time in `SceneGraph` render/sync phases or `Painting`.

**Common causes:**
- Too many nodes in the scene graph
- Frequent clip region changes
- Large or unoptimized images
- Overlapping semi-transparent layers causing over-draw
- Using Canvas/QPainter where scene graph items would suffice

**Fixes:**
- Reduce node count (combine elements, use `layer.enabled` sparingly)
- Use `sourceSize` on Image to load at display resolution
- Avoid `clip: true` on frequently changing items
- Replace Canvas with Shape or custom QQuickItem if possible
- Use `OpacityMask` instead of nested transparency

## Memory / PixmapCache

**Symptom:** High memory allocation events or pixmap cache misses.

**Common causes:**
- Loading full-resolution images when thumbnails suffice
- Creating and destroying many temporary objects
- Not setting `sourceSize` on Image elements
- Cache thrashing from too many unique images

**Fixes:**
- Set `sourceSize` to the display size on all Image elements
- Use `asynchronous: true` on Image for off-thread loading
- Reuse components via `reuseItems: true` in ListView
- Monitor with `QSG_RENDERER_DEBUG=render` environment variable

## Failed or cancelled image loads

**Symptom:** Non-zero `failed` in `pixmap_cache`, with a `pixmap_errors`
per-URL breakdown. `load_requests` exceeds `loaded` by `failed`, offset by
`unaccounted` where the trace window clipped a load's start or end. A count
above 1 for one URL is repeated attempts, not a retry loop: failures are
never cached, so every reference re-attempts.

**Common causes:**
- **Cancellation, not failure** — `source` changed or the item destroyed
  mid-load reports the same event. Usually the commonest cause (flicking
  views, `Loader` churn), and not a bug.
- Wrong, stale or mistyped path, or a file missing from the `.qrc` /
  the QML module's `RESOURCES`
- A custom `QQuickImageProvider` returning a null image — an
  `image://<provider>/…` scheme points here, not at the file system
- Provider query parameters (e.g. `?color=…`) not handled for every
  requested variant
- Unsupported format, or an image format plugin missing from a deployed
  build

**Fixes:**
- Read the app's stderr — `QQuickImageBase` prints the reason
  unconditionally, one `QML Image:` line per failure (`Cannot open:`,
  `Failed to get image from provider:`, …). Cancellations print nothing,
  so `QML Image:` lines short of the error count were cancelled loads.
- Verify the URL resolves, or test the provider's `requestImage()`
  directly for the failing IDs
- Handle `Image.status === Image.Error` so failures are visible during
  development instead of silent
