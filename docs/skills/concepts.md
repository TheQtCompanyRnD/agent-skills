# Skills: concepts and triggers

The [skills overview](index.md) is a generated table of what's
shipped. This page covers the *concepts* underneath: what a skill
is, how an agent decides to load one, the four categories we ship,
and how to tell a skill actually ran.

## What is an agentic skill?

An agentic skill is a directory containing a `SKILL.md` file with
YAML frontmatter plus optional reference material. The frontmatter
declares the skill's `name` and a `description` that tells the
agent **what the skill does and when to invoke it**. The body
contains the workflow the agent should follow once activated.

```
skills/qt-qml-review/
├── SKILL.md              # frontmatter + workflow
├── references/           # loaded on demand
│   ├── qml-lint-rules.md
│   └── qml-review-checklist.md
└── platforms/            # platform-specific variants
    └── copilot.prompt.md
```

This format is read natively by Claude Code and Codex CLI,
mapped onto Gemini extensions, and adapted to a single-file
prompt for GitHub Copilot.

## Progressive disclosure

Agents load skills in three stages so they don't overload the
model's context window:

1. **Discovery** — at session start the agent reads every skill's
   `name` and `description` only. This is the "menu."
2. **Activation** — when a user request matches a skill's
   trigger, the agent loads the full `SKILL.md` body.
3. **Deep dive** — references in `references/` load only when
   the workflow needs them. The QML lint rules table, for
   example, loads only during an actual review.

The practical consequence: a *good* skill description front-loads
its triggers in the first 250 characters because some platforms
truncate beyond that.

## The four skill types

| Type | What it does | Examples in this repo |
|---|---|---|
| **Review** | Structured audit. Deterministic linters paired with parallel deep-analysis agents. Read-only, never modifies code. | `qt-cpp-review`, `qt-qml-review` |
| **Process** | A workflow or decision framework — generating docs, scaffolding, structured outputs. | `qt-cpp-docs`, `qt-qml-docs` |
| **Conceptual** | Mental-model corrections for areas LLMs systematically get wrong (declarative QML, C++/QML boundary). Applies *while* you write code, not after. | `qt-qml` |
| **Tool** | Wraps a Qt CLI tool. The agent runs the tool, parses its output, and reasons about it against your source. | `qt-qml-profiler` |

## How triggering works

When you make a request, the agent compares your phrasing against
each skill's `description`. A trigger isn't a keyword match — it's
a semantic decision the model makes from the description text.
Here's what each skill in this repo recognizes:

### Review skills

- **qt-cpp-review** — "review", "check", "audit", "look over",
  "sanity check" applied to Qt6 C++. Also suggested *before
  committing* C++ changes.
- **qt-qml-review** — the same trigger family applied to QML
  files, before commits, or on PR review requests.

### Documentation skills

- **qt-cpp-docs** — "document this class", "write docs for my
  C++", "C++ API docs", or any time `.h` / `.cpp` files are
  provided and documentation is asked for. Does **not** trigger
  for QDoc output requests.
- **qt-qml-docs** — "document this QML", "QML API docs", "create
  reference docs" when `.qml` files are involved.

### Conceptual skill

- **qt-qml** — fires whenever QML code is the primary subject:
  writing, fixing, refactoring, optimizing, debugging. Does
  **not** fire for conversational questions like "explain how
  anchors work" where no code is produced.

### Tool skill

- **qt-qml-profiler** — performance investigations: explicit
  ("profile this app", "find hotspots") and implicit ("the UI
  feels laggy", "frames are dropping"). 2D Qt Quick only; not
  Qt Quick 3D.

## How to tell a skill activated

Skills load silently. To confirm activation:

**Claude Code** — look for a `Skill` tool call in the transcript
with the matching name, often namespaced as
`qt-development-skills:qt-qml-review`. The agent's plan should
quote workflow steps from the skill body.

**Codex CLI** — skills appear in the loaded-skills banner at
session start. During a run, the agent references workflow
sections by name.

**Gemini CLI** — the extension shows in `gemini extensions list`.
Loaded skills appear as `@skills/<name>/SKILL.md` references.

**Copilot CLI** — the agent profile is named in the chat header,
for example `@qt-qml-review`.

If you don't see any of those signals, the skill didn't fire and
the response is general-knowledge output.

## Troubleshooting

### Why a skill didn't activate

- **Phrasing too vague** — "look at this" matches nothing.
  "Review this QML file" matches `qt-qml-review`.
- **Wrong file context** — `qt-qml-review` won't activate on
  pure C++ changes even if you say "review."
- **Explicit anti-trigger** — `qt-cpp-docs` and `qt-qml-docs`
  refuse to fire when you ask for QDoc output. Ask for
  Markdown instead.
- **Skill not installed** — confirm with the discovery method
  for your CLI. See
  [Getting started](../getting-started.md#3-verify-it-actually-fired).

### How to force a skill

Most CLIs accept an explicit invocation. In Claude Code:

```
/qt-qml-review
```

In Gemini CLI, reference the SKILL.md directly:

```
@skills/qt-qml-review/SKILL.md review Main.qml
```

### How to suppress a skill

If a skill keeps firing when you don't want it, ask the agent
to skip skills for that turn ("answer directly without loading
skills") or uninstall the individual skill rather than the
whole plugin.

## Reading the per-skill pages

Each skill's generated page (linked from the
[overview](index.md)) carries:

- The `description` rendered as a "When to use" callout.
- A metadata table with `compatibility`, `license`, and Qt
  version.
- The full `SKILL.md` body — workflow, scope rules, references.
- A link back to the source on GitHub so you can audit or fork.

The pages are generated directly from each `SKILL.md` so what
you see in the docs is exactly what the agent loads.
