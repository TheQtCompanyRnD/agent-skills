---
name: qt-figma-token-extraction
description: >
  Extract design tokens, text styles, and variables from a Figma design system and produce a design-tokens.json plus ready-to-use QML singletons. Use this skill whenever someone wants to pull their design system out of Figma — whether they say "export tokens from Figma", "get design tokens", "set up my design system", "read our Figma design system", "get Figma variables into QML", "pull our color palette from Figma", "import design tokens", "extract colors/typography/spacing from Figma", or similar. Trigger this skill at the start of any design-system workflow that involves a Figma source.
license: LicenseRef-Qt-Commercial OR BSD-3-Clause
compatibility: Works with Claude Code, Codex, and GitHub Copilot.
disable-model-invocation: false
metadata:
  author: qt-ai-skills
  version: "1.0"
  qt-version: "6.x"
  category: process
---

# Figma Token Extraction Skill

This skill extracts design tokens from a Figma file, maps them to QML types, and generates a ready-to-use QML design system with a unified `Theme` singleton.

## Skill Structure

Supporting files are loaded alongside this SKILL.md:

```
qt-figma-token-extraction/
├── SKILL.md                        # this file — entry point
├── references/
│   └── token-mapping.md            # Figma variable type → QML type mapping rules
└── examples/
    ├── Primitives.qml      # primitive color palette template
    ├── Theme.qml           # semantic token template (references Primitives)
    ├── FontInterface.qml   # font loaders + icon index template
    ├── Spacing.qml         # spacing and radii template
    └── Typography.qml      # typography scale template
```

When reaching Step 4 (type mapping), read `references/token-mapping.md` before generating any QML.
When generating QML files in Step 6, use the files in `examples/` as structural templates — they reflect the real Qt Design Studio naming and organisation patterns.

---

## Step 0 — Check Qt Project Setup

**Always call the AskUserQuestion tool** — even if a project appears to be open. Never assume the currently open project is the intended target.

Before calling, read the context to personalise the question:
- If a project is already open (files visible, `CMakeLists.txt` present), name it in the first option so the user can confirm or redirect.
- If the user's request is an **update** ("update my colors", "re-extract tokens", "sync the design system"), omit the "create new project" option — updates always target an existing project.

**For an update request** — two options, no "create new":
```
tool: AskUserQuestion
question: "Which project should I update the design tokens in?"
options:
  - "This project — <detected project name or path> (currently open)"
  - "A different existing project — I'll give you the path"
```

**For an initial setup request** — all three options:
```
tool: AskUserQuestion
question: "Which Qt project should I set up the design system in?"
options:
  - "This project — <detected project name or path> (currently open)"
  - "A different existing project — I'll give you the path"
  - "Create a new project"
```

If no project is open yet, replace the first option with just `"An existing project — I'll give you the path"`.

**If the project exists (confirmed or path provided):** Note the project path. Continue to Step 1 — do not ask for Figma files yet.

**If a new project is needed:** Scaffold the folder structure and create `main.cpp` and `main.qml` now, then continue to Step 1:

```
my-project/
├── CMakeLists.txt      ← set up in Step 7
├── main.cpp            ← create now (template below)
├── main.qml            ← create now (template below)
└── design-system/      ← generated files go here
```

Create `main.cpp` with this exact content — use `QGuiApplication`, **not** `QApplication` (Widgets is not needed for Qt Quick):

```cpp
#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    engine.loadFromModule("<ProjectName>", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
```

Replace `<ProjectName>` with the URI used in `qt_add_qml_module()` — they must match exactly.

> **Do not use the old `QUrl url(u"qrc:/..."_qs)` pattern.** In Qt 6, `qt_add_qml_module` places files under `qrc:/qt/qml/<URI>/` — not `qrc:/<URI>/` as in Qt 5. Using the old path causes a silent load failure. `loadFromModule()` avoids this entirely and is the correct approach for Qt 6.5+.

Create `Main.qml` as a placeholder — **capital M, not lowercase**. `loadFromModule()` is case-sensitive and looks for a type named `Main`, which maps to `Main.qml`:

```qml
import QtQuick

Window {
    width:   640
    height:  480
    visible: true
    title:   "My Qt App"
}
```

> **CMake setup:** The full CMakeLists.txt — including singleton registration — is written in Step 7 once all QML files are known. Do not write it now. If the user encounters any build configuration issues, suggest the user check Qt's CMake documentation at https://doc.qt.io/qt-6/cmake-get-started.html rather than troubleshooting inline.

---

## Step 1 — Routing Questions

Call the **AskUserQuestion tool** for each question below — one at a time. If the AskUserQuestion tool is not available in the current interface, ask the same question as plain text and wait for the answer before continuing. Do not ask for any Figma links yet.

**Call 1 — Modes:**
```
tool: AskUserQuestion
question: "Does your Figma design system use multiple variable modes?"
options:
  - "Yes — for example Light and Dark themes"
  - "No — single mode only"
  - "I'm not sure"
```

Wait for the answer, then ask:

**Call 2 — Terminal:**
```
tool: AskUserQuestion
question: "Are you comfortable running a short command in a terminal on your own computer?"
options:
  - "Yes, I can use a terminal"
  - "No, I prefer not to use a terminal"
```

| Answer combination | Which method to use (internal) |
|---|---|
| Single mode / Not sure + any terminal answer | **MCP method** — check for modes during extraction and adapt if needed |
| Multiple modes + comfortable with terminal | **curl method** — fetches all modes in one command |
| Multiple modes + not comfortable with terminal | **MCP method** with manual mode switching |

If the user answered "I'm not sure" on modes, proceed with MCP and check for modes during extraction. Explain what you find then, not upfront.

> **Do not ask whether the file uses Variables or Styles.** Auto-detect this after receiving the Figma file URL in Step 2 — call `get_variable_defs` or inspect the file and report what you find. Use Variables extraction if variables exist, Styles extraction if only styles exist, both if both are present.

---

## Step 2 — Collect All Figma File Links

Now that you know the extraction approach, ask for all Figma file URLs in one go — before starting any extraction. This avoids interrupting the workflow later.

Ask the user:

> "Please share the URL(s) for all Figma files that contain your design tokens. If your tokens are spread across multiple files or pages (e.g. colours in one file, typography in another), share all of them now and tell me what each file contains."

Wait for all URLs before proceeding. Extract the file key from each URL — the alphanumeric string between `/design/` and the next `/`. Note what token types each file/page contains.

> **Community files note:** If any URL is from a Figma community file the user has not duplicated to their account, warn them now: the extraction tools cannot access community files directly. Ask them to duplicate the file to their drafts in Figma first (open the file → **Duplicate to your drafts**), then share the new URL.

---

## MCP Method — Extraction via Figma MCP

*(Use when: single-mode system, or user is not comfortable with a terminal)*

**Requires:** Figma MCP connected. No personal access token or local setup needed.

**Note:** This method reads only the currently active variable mode in Figma. If the design system has multiple modes (e.g. Light/Dark) the user will need to switch modes in Figma between reads — workable but more steps. Don't mention this limitation upfront; only explain it if multiple modes are discovered during extraction.

### Step 1a — Verify Figma MCP is connected

Before doing anything else, confirm that Figma MCP tools are available. Look for tools whose names suggest variable extraction, design context reading, or file metadata — different Figma MCP servers may use different exact names (e.g. `get_variable_defs`, `getVariableDefinitions`, `figma_get_variables`). Treat the tool names in this skill as examples, not fixed contracts — match by purpose, not exact string.

If no Figma tools are available at all, tell the user:
> "The Figma MCP connector isn't connected yet. Connect it in your Claude interface (Settings → Connectors or MCP configuration), then come back and we can start."

Do not proceed until the connection is confirmed.

### Step 1b — Check for modes

Call `get_variable_defs` with the file node ID to see what collections and modes exist:

```
Tool: get_variable_defs
Input: { "nodeId": "<root node id or specific variable group node id>" }
```

If the response shows multiple modes and the user wants all of them, explain that you'll need them to switch modes in Figma between reads, and proceed.

### Step 1c — Extract variables

Call `get_variable_defs` on the relevant nodes. Work through token categories one collection at a time — colors, typography, spacing, radii, shadows. For each collection, read the active mode's values.

**If multiple modes need to be captured:**
- Extract and record all values for the current mode
- Ask the user to switch the active mode in Figma (View menu → Variable Modes, or the mode switcher on the canvas)
- Call `get_variable_defs` again and record values for the new mode
- Repeat for each mode
- Merge into a single token file with mode keys (see output format in Step 5)

### Step 1d — Resolve aliases

If any variable value references another variable (an alias), resolve it to its final value. Do not write unresolved alias references into the output file — flag any that cannot be resolved and ask the user.

---

## curl Method — Extraction from the user's local machine

*(Use when: multiple variable modes, and user is comfortable with a terminal)*

**Requires:** Terminal access (curl is built into macOS and Linux; available on Windows 10+), and a Figma Personal Access Token (viewer scope is enough).

**Important:** Complete all steps in this section — especially PAT setup and verification — before running any curl commands. Running curl with an invalid token will create broken output files.

> **Community files are not supported.** The curl commands only work on Figma files that are in your own account (files you own or have been invited to). Community files you are viewing but have not duplicated will return a 403 error. If the user is working from a community file, ask them to duplicate it to their account first: in Figma, open the community file → click **Duplicate to your drafts** → use the duplicated file's URL instead.

### Step 1a — Set up a Figma Personal Access Token

Do this before anything else. Ask the user:

> "Before we run the extraction command, you'll need a Figma Personal Access Token. Do you already have one?"

If yes: proceed to verification (Step 1b).

If no, guide them through creating one:
> 1. Open Figma in your browser or desktop app
> 2. Click your avatar (top-left) → **Settings**
> 3. Go to the **Security** tab
> 4. Scroll to **Personal access tokens** → click **Generate new token**
> 5. Give it any name (e.g. "Claude token export"), set scope to **Viewer**
> 6. Copy the token immediately — Figma only shows it once

### Step 1b — Verify the PAT works before proceeding

If the PAT was recently verified (within the last 90 days), the user can skip this step. Otherwise, ask the user to run this verification command in their terminal:

```bash
curl -H "X-Figma-Token: YOUR_TOKEN" "https://api.figma.com/v1/me"
```

Expected result: a JSON response containing their Figma account email (e.g. `"email": "name@example.com"`).

If the response contains `"status": 403` or `"Invalid token"`: the token is wrong or expired. Ask the user to generate a new one and try again. **Do not proceed to extraction until the verification succeeds.**

### Step 1c — Run the variables extraction

Ask the user to run in their terminal:

```bash
curl -H "X-Figma-Token: YOUR_TOKEN" "https://api.figma.com/v1/files/FILE_KEY/variables/local" -o design-tokens-raw.json
```

This saves the complete raw variable export — all collections, all modes, all values — to `design-tokens-raw.json`.

### Step 1d — Share the result

Once the command completes, ask the user to either:
- Upload `design-tokens-raw.json` to the conversation, or
- Paste its contents into the conversation

Then continue to Step 2 (Text Styles) below.

---

## Extract Styles

> **Note:** Figma Styles (text, color, effect) live separately from Variables and need their own extraction step. If the user's design system uses Styles as the primary token source (not Variables), this step becomes the main extraction — not a secondary one. If the design system uses both Variables and Styles, complete Step 1 first then do this step.

> **Page-by-page approach:** Figma files often spread token types across multiple pages (e.g. Colors on one page, Typography on another). Do not try to extract everything at once. Ask the user which page contains which token type, then extract one page at a time. Confirm what was found after each page before moving to the next.

### MCP method — Text Styles

Use `get_design_context` on a text frame or component that uses the design system's text styles. Ask the user to select a frame in Figma that contains representative text elements — headings, body text, labels — and read it:

```
Tool: get_design_context
Input: { "fileKey": "<key>", "nodeId": "<selected text frame node id>" }
```

From the response, extract for each text style: the style name, font family, font size, font weight, line height, and letter spacing. Work through all text roles (H1–H6, body, label, caption, code). If not all are visible in one frame, ask the user to select additional frames.

### curl method — Text Styles

Text styles require two curl calls — one to get the style list with node IDs, then one to fetch the actual property values for those nodes. The PAT from Step 1a is already verified, so proceed directly:

```bash
curl -H "X-Figma-Token: YOUR_TOKEN" "https://api.figma.com/v1/files/FILE_KEY/styles" -o text-styles-list.json
```

Then extract the `node_id` values from `text-styles-list.json`, join them with commas, and run:

```bash
curl -H "X-Figma-Token: YOUR_TOKEN" "https://api.figma.com/v1/files/FILE_KEY/nodes?ids=NODE_IDS" -o text-styles-nodes.json
```

From `text-styles-nodes.json`, extract for each text style: font family, font size, font weight, line height, letter spacing, and any text decoration or text transform applied.

Ask the user to upload or paste both files into the conversation once the commands complete.

### Merging text styles into the token file

Text styles merge into the `typography` section of `design-tokens.json`. Mark them with `"source": "textStyle"` to distinguish from variable-based typography tokens:

```json
"typography": {
  "fontFamilyHeading": { "value": "Titillium Web", "figmaName": "Font/Heading", "type": "STRING", "source": "variable" },
  "h1Size":            { "value": 36,  "unit": "px", "figmaName": "H1/Size",    "type": "FLOAT",  "source": "variable" },
  "h1":  {
    "figmaName": "Heading/H1",
    "source": "textStyle",
    "fontFamily":    "Titillium Web",
    "fontSize":      36,
    "fontWeight":    600,
    "lineHeight":    54,
    "letterSpacing": 0
  },
  "bodyDefault": {
    "figmaName": "Body/Default",
    "source": "textStyle",
    "fontFamily":    "Inter",
    "fontSize":      14,
    "fontWeight":    400,
    "lineHeight":    22,
    "letterSpacing": 0
  }
}
```

If the design system defines typography entirely through text styles (and has no typography variables), the `source: "variable"` entries won't exist — that's fine, text styles alone are sufficient.

---

## Step 3 — Review the Raw Output

Whichever method was used, review the raw token data with the user before applying naming conventions:

- **All files extracted:** Confirm every file the user mentioned has been extracted. Do not proceed if any are missing.
- **Collections present:** Do the collection names match what the user expects from each file?
- **Modes captured:** If multi-mode, confirm all modes appear with correct values.
- **Color values:** Spot-check a few hex values against the Figma file.
- **Alias resolution:** Semantic tokens that reference primitives should have resolved values. If an alias could not be resolved, it almost certainly means the referenced primitive lives in a file that hasn't been extracted yet — go back and extract that file before continuing.
- **Missing collections:** If something expected is absent, ask the user which Figma file it lives in and add it to the inventory.

---

## Step 4 — Map Token Types and Apply Naming Conventions

**Before generating any QML, read `references/token-mapping.md`** to determine the correct QML type for each Figma variable type (COLOR → `color`, FLOAT → `int` or `real`, STRING → `string`, etc.). Apply this mapping consistently across all generated files.

Ask the user if they have an existing naming convention. If not, use the Qt Design Studio convention below and confirm:

| Token type | Convention | Example |
|---|---|---|
| Primitive colors | `{family}_{scale}` | `neutral_900`, `neon_500` |
| Primitive groups | nested `QtObject` per family | `Primitives.neutrals.neutral_900` |
| Semantic colors | `{role}_{variant}` | `background_default`, `text_muted` |
| Semantic groups | flat on Theme singleton | `Theme.background_default` |
| Semantic variants | `_default` / `_muted` / `_subtle` | `stroke_strong`, `stroke_muted`, `stroke_subtle` |
| Notification tokens | `notification_{type}_{variant}` | `notification_alert_default`, `notification_danger_muted` |
| Spacing steps | `x{multiplier}` | `x4` (= 8 px), `x8` (= 16 px) |
| Corner radii | `radius_{size}` | `radius_s`, `radius_m`, `radius_full` |
| Font loaders | descriptive component name | `interFont`, `titilliumSemiBold`, `inconsolata` |
| Icon names | `{icon_name}_{size}` | `close_16`, `settings_fill_16` |

All names use `snake_case`. The original Figma name is always preserved in a `figmaName` field in `design-tokens.json`.

> **JSON vs QML naming:** These conventions apply to the generated QML output. `design-tokens.json` stores token keys in camelCase (e.g. `backgroundPrimary`, `cornerRadiusM`) for JSON compatibility — the conversion to snake_case happens when generating QML in Step 6.

---

## Step 5 — Write design-tokens.json

Write a single merged `design-tokens.json` combining all extracted files. Primitive tokens and semantic tokens from separate Figma files are kept in distinct sections — this preserves the two-tier structure and makes it clear which layer each token belongs to. Single-mode tokens use a flat `value` field; multi-mode tokens nest values under `modes`:

```json
{
  "meta": {
    "extractedAt": "<ISO 8601 timestamp>",
    "namingConvention": "camelCase (JSON) / snake_case (QML)",
    "extractionMethod": "MCP | curl",
    "sources": [
      { "figmaFileName": "Global Tokens", "url": "<Figma URL>", "tier": "primitive" },
      { "figmaFileName": "Design Tokens", "url": "<Figma URL>", "tier": "semantic"  }
    ]
  },

  "_comment_primitives": "Raw values from the Global Tokens file — the building blocks",
  "colors": {
    "neutral000": { "value": "#ffffff", "figmaName": "Neutral/000", "type": "COLOR" },
    "neon600":    { "value": "#1f9b5d", "figmaName": "Neon/600",    "type": "COLOR" }
  },

  "_comment_semantic": "Semantic values from the Design Tokens file — reference primitives via resolvedFrom",
  "semanticColors": {
    "backgroundPrimary": {
      "figmaName": "Background/Primary", "type": "COLOR",
      "resolvedFrom": "neutral000",
      "modes": {
        "Light": { "value": "#ffffff" },
        "Dark":  { "value": "#181818" }
      }
    }
  },
  "typography": {
    "fontFamilyHeading": { "value": "Titillium Web", "figmaName": "Font/Heading", "type": "STRING" },
    "h1Size":            { "value": 36, "unit": "px", "figmaName": "H1/Size",      "type": "FLOAT" },
    "h1Weight":          { "value": 600,               "figmaName": "H1/Weight",    "type": "FLOAT" },
    "h1LineHeight":      { "value": 54, "unit": "px", "figmaName": "H1/LineHeight", "type": "FLOAT" }
  },
  "spacing": {
    "x4": { "value": 8,  "unit": "px", "figmaName": "Spacing/X4", "type": "FLOAT" },
    "x8": { "value": 16, "unit": "px", "figmaName": "Spacing/X8", "type": "FLOAT" }
  },
  "radii": {
    "cornerRadiusS":    { "value": 4,    "unit": "px", "figmaName": "Radius/Small", "type": "FLOAT" },
    "cornerRadiusFull": { "value": 9999, "unit": "px", "figmaName": "Radius/Full",  "type": "FLOAT" }
  },
  "shadows": {
    "shadowLow": {
      "offsetX": 0, "offsetY": 1, "blur": 3, "spread": 0,
      "color": "rgba(0,0,0,0.12)", "figmaName": "Shadow/Low"
    }
  }
}
```

Save to the root of the design system project folder. Confirm the path with the user.

---

## Step 6 — Generate QML Files

Using the completed `design-tokens.json` as the source of truth, generate QML singleton files. Place all files in a `design-system/` folder at the root of the Qt project.

### Read the asset templates first

Before writing any QML, read the asset file that matches each output file. These are the authoritative templates — they define the exact structure, naming, grouping, and section order to follow:

| Output file | Example to read | What it shows |
|---|---|---|
| `Primitives.qml` | `examples/Primitives.qml` | Nested `QtObject` per color family, `{family}_{scale}` naming |
| `Theme.qml` | `examples/Theme.qml` | Flat semantic tokens referencing Primitives, grouped by role |
| `Spacing.qml` | `examples/Spacing.qml` | `x{n}` spacing steps, `radius_{size}` corner radii |
| `FontInterface.qml` | `examples/FontInterface.qml` | Inline `component` font loaders, `Icons` QtObject with unicode mappings |
| `Typography.qml` | `examples/Typography.qml` | Font weight constants and type scale size/weight pairs |

Read each asset file immediately before generating that file — do not rely on memory of a previously read asset.

### Folder structure

```
design-system/
├── Primitives.qml      ← raw color palette (nested by family: neutrals, accents)
├── Theme.qml           ← semantic color tokens (references Primitives)
├── Spacing.qml         ← spacing steps and corner radii
└── FontInterface.qml   ← font loaders + icon unicode index
```

Generate in this order: Primitives first (it has no dependencies), then Spacing and FontInterface (independent), then Theme last (it references Primitives).

> **No hand-written qmldir.** Module registration is handled by `qt_add_qml_module()` in CMakeLists.txt. Singleton registration uses `set_source_files_properties` — updated in Step 7.

### Generation rules

- Every value comes from `design-tokens.json` — never hardcode values not in the token file
- Use `snake_case` throughout — `background_default`, `neutral_900`, `x4`, `radius_m`
- `Primitives.qml` holds raw values only — no semantic meaning. `Theme.qml` holds semantic tokens only — always referencing `Primitives`, never raw hex values
- Apply type mapping from `references/token-mapping.md` — `readonly property color` for colors, `readonly property int` for sizes, `readonly property string` for font names
- Include the source comment and CMake note at the top of every file
- Group related properties with section comments (`// ── Section name ─────`)
- If a token is missing from the JSON, leave a `// TODO: <figmaName>` placeholder rather than guessing a value
- **Imports:** Use `import QtQuick` — `import QtQuick.Window` is redundant in Qt 6 (Window is already included) but not an error if added
- **Effects and gradients:** Use `MultiEffect` from `import QtQuick.Effects` (available from Qt 6.5). Never use `Qt5Compat.GraphicalEffects` — it requires an extra compatibility module and is not available in all Qt 6 configurations
- **QML coding skill:** If the `qt-development-skills:qt-qml` skill is available, use it when generating QML files to ensure correct Qt 6 patterns are applied

---

## Step 7 — Review, Fix QML, and Update CMakeLists.txt

After generating all QML files, run a validation pass — do not skip any of these checks:

**QML validation:**
- Check for any `// TODO:` placeholders — flag these to the user and ask how to resolve them
- Verify every property type matches the `references/token-mapping.md` rules
- Confirm `pragma Singleton` and `import QtQuick` are present in every file
- Check that no values are hardcoded that should come from the token file

**CMakeLists.txt — mandatory update:**

Always update `CMakeLists.txt` as part of this step — do not leave it to the user. Open the file, find the `qt_add_qml_module()` block, and ensure all generated design-system files are listed under `QML_FILES` and registered with `set_source_files_properties`. This is the most common cause of singletons not being accessible in QML.

> **Naming rule:** The target name, URI, and `loadFromModule()` call in `main.cpp` must all use the **same** project name string. Use the actual project name from the `project()` CMake call — do not substitute `MyProject` literally.

```cmake
cmake_minimum_required(VERSION 3.16)
project(<ProjectName> VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Version pin must match qt_standard_project_setup REQUIRES below
find_package(Qt6 6.5 REQUIRED COMPONENTS Quick)
qt_standard_project_setup(REQUIRES 6.5)

# MACOSX_BUNDLE is required on macOS — without it, qt_add_qml_module creates
# a directory named <ProjectName>/ which collides with the linker output file
# (EISDIR error). MACOSX_BUNDLE makes the output MyQtApp.app, no collision.
qt_add_executable(<ProjectName> MACOSX_BUNDLE
    main.cpp
)

set_source_files_properties(
    design-system/Primitives.qml
    design-system/Theme.qml
    design-system/Spacing.qml
    design-system/FontInterface.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(<ProjectName>
    URI <ProjectName>
    VERSION 1.0
    QML_FILES
        Main.qml   # capital M — must match loadFromModule("<ProjectName>", "Main")
        design-system/Primitives.qml
        design-system/Theme.qml
        design-system/Spacing.qml
        design-system/FontInterface.qml
    # NOTE: do NOT add main.cpp here — it belongs only in qt_add_executable()
)

target_link_libraries(<ProjectName> PRIVATE Qt6::Quick)
```

Replace every `<ProjectName>` with the same string — e.g. `MyQtApp` — matching the `project()` call and the `loadFromModule("<ProjectName>", "Main")` call in `main.cpp`.

After updating CMakeLists.txt, confirm with the user that the file has been saved and show them how to use the singletons in `Main.qml`:

```qml
import QtQuick         // Window is part of QtQuick in Qt 6 — do NOT add import QtQuick.Window
import <ProjectName>   // imports all singletons from the module

Window {
    visible: true
    width: 640
    height: 480
    color: Theme.background_default
}
```

> **CMake issues:** If the user has build errors after updating CMakeLists.txt, suggest the user check Qt's CMake documentation at https://doc.qt.io/qt-6/cmake-get-started.html rather than troubleshooting inline.

---

## Step 8 — Summary

Give the user a brief summary and ask them to review the output:

- Total tokens extracted per category (colors, spacing, typography, radii)
- Modes and themes captured
- Any unresolved aliases or `// TODO:` placeholders that need attention
- Files produced: `design-tokens.json`, `Primitives.qml`, `Theme.qml`, `Spacing.qml`, `FontInterface.qml`
- Reminder that `set_source_files_properties(... QT_QML_SINGLETON_TYPE TRUE)` must be set in CMakeLists.txt for each singleton file
- Use the **Token Categories Checklist** at the end of this file to verify nothing was missed
- Confirmation that the design system foundation is ready — the component generation skill can now begin

---

## Token Categories Checklist

- [ ] Primitive color palette (all color families and scales)
- [ ] Semantic color tokens with all modes (if present)
- [ ] Font families (heading, body, mono)
- [ ] Font weights (numeric: 400/500/600/700)
- [ ] Type scale from variables (size + weight + line height per role, if defined as variables)
- [ ] Text styles (H1–H6, body, label, caption, code — font family, size, weight, line height, letter spacing)
- [ ] Spacing scale (base unit + all named steps)
- [ ] Corner radii (S, M, L, Full)
- [ ] Shadows / elevation levels (if present)
- [ ] Icon size tokens (if present)
- [ ] Animation / duration tokens (if present)
