---
name: qt-figma-component-generation
description: >
  Extract component metadata from a Figma design system and generate production-ready QML controls. Use this skill whenever someone wants to turn Figma components into QML files — whether they say "generate components from Figma", "create QML controls based on a design system", "convert Figma components to QML", "build the component library", "extract button/input/checkbox from Figma", or anything similar. Requires design-tokens.json and QML design system singletons to already exist (from the token extraction skill). Uses Figma MCP to inspect components one at a time and maps variants, states, sizing, and token usage to idiomatic Qt Quick Controls 2 patterns. Trigger this skill at the component generation step of any QML design-system workflow.
license: LicenseRef-Qt-Commercial OR BSD-3-Clause
compatibility: Works with Claude Code, Codex, and GitHub Copilot. Requires Figma MCP and design-tokens.json from qt-figma-token-extraction.
metadata:
  author: qt-ai-skills
  version: "1.0"
  qt-version: "6.x"
  category: process
---

# Figma Component Generation Skill

This skill reads component definitions from a Figma file via MCP and generates production-ready QML control files that consume the design-system singletons produced by the token-extraction skill.

---

## Prerequisites

Before generating any components, confirm all of the following exist in the project:

1. **`design-tokens.json`** — the merged token file from the token-extraction skill
2. **QML design system singletons** — `Primitives.qml`, `Theme.qml`, `Spacing.qml`, `FontInterface.qml` in a `design-system/` folder

If either is missing, stop and run the token-extraction skill first (`qt-figma-token-extraction`).

**Verify Figma MCP is connected** — confirm that `get_metadata` and `get_design_context` are available in the tool list. If not, tell the user:
> "The Figma MCP connector isn't connected yet. Connect it via your MCP configuration, then come back and we can start."

Do not proceed until the connection is confirmed.

---

## Step 1 — Component Discovery

Use `get_metadata` to fetch the file structure and identify which pages and frames contain components:

```
Tool: get_metadata
Input: { "fileKey": "<file key>" }
```

From the response, note all pages and frames or component sets named as component groups (e.g. "Button", "Text Field", "Checkbox").

Ask the user:
> "I can see the following component groups in the Figma file: [list]. Which ones should I generate QML files for? Or should I do all of them?"

Build a single component inventory table and keep it updated throughout the entire workflow — do not create a second table later:

| Figma component name | Node ID | QML file | Status |
|---|---|---|---|
| Button | 67:139 | Button.qml | pending |
| Text Field | ... | TextField.qml | pending |

Status values: `pending` → `extracting` → `mapping` → `done` / `blocked`

---

## Step 2 — Pattern Selection

Ask the user to choose an implementation pattern before reading any assets or writing any code. If the **AskUserQuestion tool** is available, use it:

```
tool: AskUserQuestion
question: "Which code style should the generated components use?"
options:
  - "Pattern A — Inline (self-contained file, all state logic inside the component)"
  - "Pattern B — Style singleton (ComponentStyle.qml + Component.qml, supports multiple themes)"
  - "I'm not sure — recommend one"
```

If the tool is not available (e.g. in Claude Code, Codex, or Copilot), ask the question in plain text and wait for a reply before proceeding.

If the user selects "I'm not sure", recommend **Pattern A** for most projects — it is simpler, self-contained, and easier to debug. Only recommend Pattern B if the project already has a `Qt.Themes` / `TokenInterface` layer or needs to support multiple swappable themes.

> **Pattern B uses integer enum variants, not strings.** Pattern A uses `property string variant: "primary"`. Pattern B uses `property int typeVariant: ButtonStyle.TypeVariant.Primary`. Do not mix the two approaches — pick one and use it consistently throughout all components.

---

## Step 3 — Prepare the Chosen Pattern

Before extracting or writing anything, make sure the structure for the chosen pattern is in front of you. Pattern B is read from the bundled assets; Pattern A is built from the inline snippets in Step 5.

### Pattern A assets — `references/`

This folder contains Figma-verified Pattern A controls. Each is a self-contained file where all state logic lives inside the component using conditional expressions on `readonly property` values.

| Reference file | Output file | Demonstrates |
|---|---|---|
| `references/Button.qml` | `Button.qml` | AbstractButton, multi-variant state machine, size helpers, accent family mapping |
| `references/TextField.qml` | `TextField.qml` | TextInput wrapped in ColumnLayout, label + error + helper text, clear button |
| `references/Checkbox.qml` | `Checkbox.qml` | CheckBox indicator, Canvas tick mark, indeterminate state |
| `references/Toggle.qml` | `Toggle.qml` | Switch track + animated thumb, NumberAnimation |
| `references/Select.qml` | `Select.qml` | Custom Item with Popup, ListView delegate, chevron |

**Read the file that most closely matches the component being generated before writing any code.** If a QML coding skill (`qt-development-skills:qt-qml`) is available, use it while writing so the output follows idiomatic Qt 6 patterns.

### Pattern B assets — `assets/qt-controls/`

This folder contains QML pairs from a production Qt controls library. Each component is split across two files:

- `Button.qml` — component logic, layout, base type, public API
- `ButtonStyle.qml` — `pragma Singleton` defining typed `component` objects for each state and size variant

**Read the asset pair for the component you are about to generate — before writing any code.** The generated file must follow the reference asset's structure, property ordering, and pattern choices. If the output deviates from the reference in a way that cannot be justified by the specific Figma component, ask yourself why and correct it. Do not invent a different structure when a reference exists.

Core pairs to read first (read the pair that matches the component being generated):
- `Button.qml` + `ButtonStyle.qml`
- `CheckBox.qml` + `CheckBoxStyle.qml`
- `ComboBox.qml` + `ComboBoxStyle.qml`
- `Switch.qml` + `SwitchStyle.qml`
- `TextField.qml` + `TextFieldStyle.qml`

---

## Step 4 — Per-Component Extraction

For each component in the inventory, extract its specification via MCP.

> **Always call `get_design_context` on an individual main component node — NOT the parent component set node.** Component sets return oversized JSON mixing all variants. Inspect the default/base variant first, then representative variants (Hover, Pressed, Disabled) individually.

```
Tool: get_design_context
Input: { "fileKey": "<key>", "nodeId": "<individual component node id>" }
```

If individual node IDs are not known yet, call `get_design_context` on the parent frame and scan for child component nodes, then re-call on each.

### What to extract per component

- **Variants / props** — Figma variant properties and allowed values → QML `property` declarations
- **States** — Default, Hover, Pressed, Disabled, Focus, Error → conditional expressions on `readonly property` values
- **Sizing** — height, padding (H + V), gap, font size, font weight, corner radius
- **Color tokens** — which semantic token appears in each state; record exact Figma name and resolved value from `design-tokens.json`
- **Typography** — font family, size, weight, line height per text element
- **Border** — stroke width, color token, which states it appears in
- **Icon / slot** — whether the component has an icon slot, its size, left/right/both position

Record all extracted data in a scratch note before writing any code.

---

## Step 5 — Figma → QML Mapping

> **Before writing any token reference, open `Theme.qml`, `Primitives.qml`, `Spacing.qml`, and `FontInterface.qml` and read the actual property names.** Do not copy token names from the reference assets — the project's token naming convention may differ from the examples. Every token name you write in a component must exist in the project's singletons.

### Base type selection

| Figma component | QML base type |
|---|---|
| Button (any style) | `AbstractButton` (from `QtQuick.Controls`) |
| Checkbox | `CheckBox` (from `QtQuick.Controls.Basic`) |
| Radio button | `RadioButton` (from `QtQuick.Controls.Basic`) |
| Toggle / switch | `Switch` (from `QtQuick.Controls.Basic`) |
| Text input / field | `ColumnLayout` wrapping a `Rectangle` + `TextInput` |
| Text area (multiline) | `ScrollView` wrapping `TextArea` (from `QtQuick.Controls.Basic`) — no reference asset yet; follow the TextField pattern but add `wrapMode: TextArea.Wrap` and remove fixed height |
| Select / dropdown | Custom `Item` with a `Popup` |
| Slider | `Slider` (from `QtQuick.Controls.Basic`) |
| Tab bar | `TabBar` + `TabButton` |
| Progress bar | `ProgressBar` (from `QtQuick.Controls.Basic`) |
| Spinner / spin box | `SpinBox` (from `QtQuick.Controls.Basic`) |
| Card / container | `Rectangle` or plain `Item` |
| Divider | `Rectangle` (1 px, fillWidth) |
| Badge | `Rectangle` wrapping a `Text` |
| Tooltip | `ToolTip` (from `QtQuick.Controls.Basic`) |

### Variant → property pattern (Pattern A)

```qml
property string variant: "primary"   // primary | secondary | ghost | tertiary | danger
property string size:    "medium"    // small | medium | large  (sm | md | lg accepted)
```

### Variant → enum pattern (Pattern B)

```qml
// Use integer enums, not strings — do not mix with Pattern A string variants
property int typeVariant: ButtonStyle.TypeVariant.Primary
```

### State → conditional expression pattern

```qml
readonly property color _bg: {
    if (!enabled) return Theme.background_muted
    return pressed ? Theme.accent_subtle
         : hovered ? Theme.accent_muted
         :            Theme.accent_default
}
```

### Icon slot pattern

```qml
// Icon slot — rendered via icon font glyph in a Text item
property string iconGlyph:     ""
property int    iconLayoutDir: Qt.LeftToRight   // Qt.LeftToRight | Qt.RightToLeft
                                                 // controls which side the icon appears on

contentItem: RowLayout {
    layoutDirection: root.iconLayoutDir
    spacing:         root._iconGap
    Text {
        text:        root.iconGlyph
        font.family: FontInterface.iconFont.name
        visible:     root.iconGlyph !== ""
    }
    Text {
        id:   _label
        text: root.label
        // ... font properties
    }
}
```

### Sizing — tokens first, literals as fallback

Check `Spacing.qml` and `FontInterface.qml` first. Only use a literal value when no token covers the dimension, and add a `// TODO: add to Spacing.qml` comment.

### Focus ring pattern

Focus rings apply only to `Control`-based components (`AbstractButton`, `CheckBox`, `Switch`, `Slider`, etc.). Text Field (`ColumnLayout` root) and Select (`Item` root) are not `Control` subclasses — use `activeFocus` and a fixed radius for those.

```qml
// For Control-based components (AbstractButton, CheckBox, Switch …)
Rectangle {
    anchors { fill: parent; margins: -2 }
    radius:       parent.radius + 2          // only valid when parent is a Rectangle
    color:        "transparent"
    border.color: Theme.stroke_focus         // use a token — never a literal color
    border.width: 2                          // TODO: promote to Spacing token if available
    visible:      root.visualFocus           // Control property — gives keyboard-only focus ring
}

// For non-Control roots (ColumnLayout, Item) — use activeFocus and fixed radius
Rectangle {
    anchors { fill: parent; margins: -2 }
    radius:       4                          // TODO: use Spacing token
    color:        "transparent"
    border.color: Theme.stroke_focus
    border.width: 2
    visible:      root.activeFocus
}
```

### Color animation pattern

Add `Behavior` blocks only on color properties that animate during interaction (hover, press). Skip them for the disabled state — a snap, not a fade, is usually correct there.

```qml
// On the Rectangle or contentItem that holds the interactive color:
Behavior on color        { ColorAnimation { duration: Theme.duration_fast } }
Behavior on border.color { ColorAnimation { duration: Theme.duration_fast } }
// If no duration token exists yet: duration: 100 — add a TODO to promote it
```

### Cursor pattern

```qml
HoverHandler { cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor }
```

---

## Step 6 — Write the QML File

Place each component in the project's `components/` folder. Use PascalCase matching the Figma component name (`Button.qml`, `TextField.qml`, etc.).

### File header

```qml
// ComponentName.qml — [Project] Design System — [component description]
// Maps to Figma: [file name] → [component name] (node [id])
//
// Figma variants (inspected via MCP, [date]):
//   Prop1: "value1" | "value2"
//   Prop2: "valueA" | "valueB"
// States: Default | Hover | Pressed | Disabled [| Error | Focus]
// Sizes:  "small" | "medium" | "large"
//
// Usage:
//   import MyProject
//   ComponentName { prop: "value"; onAction: doThing() }
```

### Public API section

```qml
// ── Public API ────────────────────────────────────────────────────────────
property string variant: "primary"
property string size:    "medium"
property string label:   "Button"

// ── Private helpers ───────────────────────────────────────────────────────
readonly property bool  _isSmall: size === "small" || size === "sm"
readonly property color _bg: ...
```

### Missing values

```qml
// TODO: add Spacing.buttonIconGapSm to Spacing.qml (Figma: 0px for small buttons)
readonly property int _iconGap: _isSmall ? 0 : Spacing.x4
```

After generating all components, summarise the full TODO list for the user.

---

## Step 7 — Post-Generation Review

After all components are written, run a consistency pass:

- Every `readonly property color` referencing a theme token must use a name that **actually exists** in `Theme.qml` or `Primitives.qml`. Flag any that don't.
- Every numeric size must come from `Spacing.qml` or `FontInterface.qml`. Collect any literals that should be promoted to tokens.
- Every interactive component has a focus ring.
- Every interactive component has a `HoverHandler` with a cursor shape.
- File headers document the node IDs that were inspected.
- Update the inventory table from Step 1 — mark all components `done` or `blocked`.

Present a brief summary to the user:
- Components generated (count and names)
- Components skipped or blocked (with reason)
- Full TODO list: tokens that need to be added to the design-system singletons
- Recommended next step: add components to `qt_add_qml_module QML_FILES` in CMakeLists.txt and smoke-test in a gallery

---

## Common Pitfalls

**Inspecting the component set instead of a main component.** Component sets return all variants stacked. Always drill down to an individual component node.

**Using token names from reference assets instead of the project.** The reference assets use example token names that may not match the project's singletons. Always read the actual singleton files first.

**Hardcoding a value that exists in a token.** Check `Spacing.qml` and `FontInterface.qml` before writing any literal number.

**Missing the indeterminate / partial state.** Checkbox and radio buttons often have a third state. Always check for `Qt.PartiallyChecked`.

**Not zeroing out AbstractButton default padding.** `AbstractButton` and other `Control` subclasses have default padding that inflates rendered height. Zero them explicitly when managing geometry yourself.

**Forgetting `Behavior` blocks.** Add `Behavior on color { ColorAnimation { duration: Theme.duration_fast } }` on color properties that animate during interaction (hover, press). Use a token for duration — not a hardcoded `100`. Skip Behaviors on the disabled state; a snap transition is usually correct there.

**Popup z-ordering.** `Popup` items need `parent: Overlay.overlay` if clipped by a parent container.

**Mixing Pattern A strings and Pattern B enums.** Choose one variant approach and use it consistently across all components.
