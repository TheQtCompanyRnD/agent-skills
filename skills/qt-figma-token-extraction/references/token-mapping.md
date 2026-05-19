# Figma Variable Type → QML Type Mapping

Read this file before generating any QML properties. Apply these rules to every token in `design-tokens.json`.

---

## Type Mapping Table

| Figma type | Token category | QML property type | Notes |
|---|---|---|---|
| `COLOR` | colors, semanticColors | `readonly property color` | Use hex string `"#rrggbb"` or `"#aarrggbb"` for alpha. Never use `Qt.rgba()` unless the value has a non-1.0 alpha. |
| `FLOAT` — whole pixel size | spacing, radii, icon sizes, border widths, font sizes | `readonly property int` | Use only when the value is truly whole. Round if Figma exports a near-integer. |
| `FLOAT` — fractional size | letter spacing, line height, `font.pointSize` | `readonly property real` | Keep the decimal. Rounding letter spacing or line height loses fidelity; rounding 0.5 px border doubles a hairline stroke. |
| `FLOAT` — font weight | typography | `readonly property int` | Standard values: 100, 200, 300, 400, 500, 600, 700, 800, 900. Map Figma weight names: Regular→400, Medium→500, SemiBold→600, Bold→700. |
| `FLOAT` — opacity / scale | effects | `readonly property real` | Keep as decimal (0.0–1.0). Do not convert to int. |
| `STRING` | font families, text content | `readonly property string` | Use double-quoted string literals. |
| `BOOLEAN` | feature flags, states | `readonly property bool` | `true` / `false`. |
| `EFFECT` — drop shadow | shadows | Multiple typed properties | Split into individual typed properties — see Shadow Tokens below. |

---

## Color Values

Always write color values as string literals — never as `color` function calls unless necessary:

```qml
// Correct
readonly property color background_primary: "#ffffff"
readonly property color overlay_dark: "#80000000"   // 50% black (ARGB format)

// Avoid unless alpha is a variable
readonly property color overlay_dark: Qt.rgba(0, 0, 0, 0.5)
```

For multi-mode (Light/Dark) semantic colors, use a ternary on `isDark`:

```qml
readonly property color background_primary: isDark ? "#1f1f1f" : "#ffffff"
```

---

## Spacing and Size Values

Use `int` only when the value is truly whole. Use `real` when the value can be fractional.

```qml
// Whole pixel values → int
readonly property int x4:              8     // spacing
readonly property int corner_radius_m: 8     // radius
readonly property int h1_size:         36    // font size (px)
readonly property int border_width:    1     // border (truly 1 px)

// Fractional values → real
readonly property real h1_line_height:   1.5   // line height multiplier
readonly property real h1_letter_spacing: 0.0  // letter spacing (px, often fractional)
```

If Figma exports a spacing or radius as a near-integer decimal (e.g. `8.0`), use `int`. If it is genuinely fractional (e.g. `0.5` border), keep it as `real` — do not round:

```qml
readonly property real border_width_subtle: 0.5  // Figma: 0.5px — keep as real
```

---

## Typography Values

Font families and font weight names map as follows:

```qml
// Font family — always a string
readonly property string font_family_heading: "Titillium Web"
readonly property string font_family_body:    "Inter"

// Font weight — always an int matching Qt.font weight values
readonly property int weight_thin:       100
readonly property int weight_light:      300
readonly property int weight_regular:    400
readonly property int weight_medium:     500
readonly property int weight_semi_bold:  600
readonly property int weight_bold:       700
readonly property int weight_extra_bold: 800
readonly property int weight_black:      900
```

In Theme.typography, refer to the named weight constants rather than raw numbers where possible:

```qml
readonly property int h1_weight: weight_semi_bold   // 600
```

---

## Shadow / Effect Tokens

Figma EFFECT tokens (drop shadows) have no direct QML equivalent. Store them as individual typed properties, then apply via `MultiEffect` from `import QtQuick.Effects`.

> **Never use `DropShadow` from `Qt5Compat.GraphicalEffects`.** That module is forbidden — use `MultiEffect` instead. Note: `MultiEffect` has no `spread` property and its `shadowBlur` is a 0.0–1.0 normalised value, not pixels. Store Figma's pixel blur as a token but normalise when binding.

```qml
// ── Shadow / Low ──────────────────────────────────────────────────────────
// Figma: Shadow/Low — offset(0,1), blur 3px, spread 0, rgba(0,0,0,0.12)
// Note: spread is not supported by MultiEffect — omit or approximate with size
readonly property int   shadow_low_offset_x: 0
readonly property int   shadow_low_offset_y: 1
readonly property real  shadow_low_blur:     0.1   // MultiEffect: 0.0–1.0 (Figma 3px ÷ 30 ≈ 0.1)
readonly property color shadow_low_color:    "#1f000000"  // 12% opacity black
```

Usage in a QML component:

```qml
import QtQuick.Effects

MultiEffect {
    source:                theItem
    shadowEnabled:         true
    shadowColor:           Theme.shadow_low_color
    shadowHorizontalOffset: Theme.shadow_low_offset_x
    shadowVerticalOffset:  Theme.shadow_low_offset_y
    shadowBlur:            Theme.shadow_low_blur
}
```

---

## What NOT to Do

- Do not use `var` — always use a typed property
- Do not use `property` without `readonly` for design tokens — tokens are immutable
- Do not mix types (e.g. assigning a hex string to an `int` property)
- Do not leave Figma internal alias names (e.g. `{Global/Neutral/000}`) as values — all aliases must be resolved to concrete values before writing QML
