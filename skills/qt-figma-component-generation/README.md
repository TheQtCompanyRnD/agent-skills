# qt-figma-component-generation
<!-- SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause -->

Reads component definitions from a Figma design system via MCP and generates production-ready QML control files that consume the design-system singletons from the token-extraction skill.

---

## What it does

- Inspects Figma components one at a time using `get_design_context`
- Extracts variants, states, sizing, color tokens, typography, borders, and icon slots
- Maps Figma component types to the correct Qt Quick Controls 2 base types
- Generates one QML file per component in the project's `components/` folder
- Validates all token references against the actual singleton files before writing
- Produces a summary of generated components and any missing tokens (TODOs)

---

## When to trigger

Use this skill when someone says any of:

- "Generate components from Figma"
- "Create QML controls based on a design system"
- "Convert Figma components to QML"
- "Build the component library"
- "Turn the design system into QML files"

---

## Prerequisites

Before this skill can run, the following must already exist:

1. **`design-tokens.json`** — produced by `qt-figma-token-extraction`
2. **QML design system singletons** — `Primitives.qml`, `Theme.qml`, `Spacing.qml`, `FontInterface.qml` in `design-system/`
3. **Figma MCP connected** — the skill uses `get_metadata` and `get_design_context`

If prerequisites are missing, run `qt-figma-token-extraction` first.

---

## What it produces

One `.qml` file per component in `components/`, named in PascalCase after the Figma component:

| Figma component | Generated file |
|---|---|
| Button | `Button.qml` |
| Text Field | `TextField.qml` |
| Checkbox | `Checkbox.qml` |
| Toggle / Switch | `Toggle.qml` |
| Select / Dropdown | `Select.qml` |
| … | `<ComponentName>.qml` |

Each file includes a header documenting the Figma node ID, variant properties, states, and sizes inspected.

---

## Implementation patterns

The skill supports two patterns — the user is asked to choose upfront:

**Pattern A — Inline** (recommended for most projects)
All state logic lives inside the component file using conditional expressions on `readonly property` values. Self-contained and easy to debug.

**Pattern B — Style singleton**
Component logic in `Component.qml` + a companion `ComponentStyle.qml` pragma singleton defining typed `component` objects for each variant. Uses integer enums, not strings. Best for projects with multiple swappable themes.

---

## Folder structure

```
qt-figma-component-generation/
├── SKILL.md                            # Skill workflow and instructions
├── README.md                           # This file
└── assets/
    ├── Button-reference.qml          # Pattern A: self-contained inline component
    ├── Checkbox-reference.qml        # Pattern A: CheckBox with indeterminate state
    ├── Select-reference.qml          # Pattern A: custom Item + Popup dropdown
    ├── TextField-reference.qml       # Pattern A: TextInput in ColumnLayout
    ├── Toggle-reference.qml          # Pattern A: Switch with animated thumb
    └── qt-controls/                    # Pattern B: production QML pairs
        ├── Button.qml + ButtonStyle.qml
        ├── CheckBox.qml + CheckBoxStyle.qml
        ├── Switch.qml + SwitchStyle.qml
        └── TextField.qml + TextFieldStyle.qml
```

---

## Key rules

- Always call `get_design_context` on an **individual main component node**, not the parent component set
- Always read `Theme.qml`, `Primitives.qml`, `Spacing.qml`, `FontInterface.qml` before writing any token references — do not copy names from reference assets
- Every interactive component must have a focus ring and a `HoverHandler` with a cursor shape
- Add `Behavior on color { ColorAnimation { duration: Theme.duration_fast } }` on interactive color properties (hover, press) — use a token for duration, skip for disabled state
- Use `MultiEffect` from `QtQuick.Effects` for visual effects — never `Qt5Compat.GraphicalEffects`
- Do not add `import QtQuick.Window` — `Window` is part of `QtQuick` in Qt 6

---

## After generation

Add the generated files to `qt_add_qml_module QML_FILES` in `CMakeLists.txt` and smoke-test in a component gallery.
