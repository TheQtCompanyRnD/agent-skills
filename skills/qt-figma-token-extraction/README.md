# qt-figma-token-extraction
<!-- SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause -->

Extracts design tokens and text styles from a Figma design system file and generates production-ready QML singleton files for a Qt 6 project.

---

## What it does

- Reads color variables, spacing, typography, radii, and shadows from a Figma file (via MCP or REST API)
- Maps Figma tokens to QML property types using snake_case naming conventions
- Generates four QML singleton files: `Primitives.qml`, `Theme.qml`, `Spacing.qml`, `FontInterface.qml`
- Produces a `design-tokens.json` intermediate file used by the component generation skill
- Updates `CMakeLists.txt` to register all singletons with `qt_add_qml_module`

---

## When the skill is triggered

This skill is used when someone refers to something like:

- "Export tokens from Figma"
- "Get design tokens"
- "Read our Figma design system"
- "Extract colors / typography / spacing from Figma"
- "Set up the design system singletons"
- "Convert Figma variables to QML"

---

## Prerequisites

- A Figma file containing a design system with variables or text styles
- Figma MCP connected **or** a Figma Personal Access Token (PAT) for REST API extraction
- An existing Qt 6 project (CMake-based), or agreement to create one

> The skill asks about Qt project status and extraction method before doing any work.

---

## What it produces

| File | Purpose |
|---|---|
| `design-tokens.json` | Merged token file — input for the component generation skill |
| `design-system/Primitives.qml` | Raw color values grouped by family (neutrals, accents) |
| `design-system/Theme.qml` | Semantic tokens referencing Primitives (background_default, text_muted, etc.) |
| `design-system/Spacing.qml` | Spacing scale (x1–x24) and corner radii (radius_s–radius_full) |
| `design-system/FontInterface.qml` | Font loaders and icon unicode index |

All QML files use `pragma Singleton` and are registered as singleton types in CMakeLists.txt.

---

## Extraction paths

**MCP path** — no terminal required. Best for single-mode (light or dark only) systems. Uses `get_variable_defs` and `get_design_context`.

**REST API path** — uses a `curl` command run locally in a terminal. Required for multi-mode systems (Light + Dark) because the REST API returns all variable modes in one response.

The skill routes to the correct path based on questions it asks upfront.

---

## Folder structure

```
qt-figma-token-extraction/
├── SKILL.md                        # Skill workflow and instructions
├── README.md                       # This file
├── assets/
│   ├── Primitives-example.qml      # Reference: raw value singleton
│   ├── Theme-example.qml           # Reference: semantic token singleton
│   ├── Spacing-example.qml         # Reference: spacing singleton
│   └── FontInterface-example.qml   # Reference: font loader singleton
└── references/
    └── token-mapping.md            # Figma type → QML property type mapping table
```

---

## Token naming conventions

Uses snake_case throughout:

- Colors: `background_default`, `text_muted`, `stroke_subtle`, `neutral_900`
- Spacing: `x4` (8 px), `x8` (16 px), `radius_m`, `radius_full`
- Typography: loaded via `FontLoader` components in `FontInterface.qml`
