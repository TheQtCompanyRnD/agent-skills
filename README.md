# Qt AI Skills

A collection of
[Agent Skills](https://agentskills.io/specification) for Qt
development, designed for use with agentic AI coding tools such
as Claude Code, GitHub Copilot, Codex, Cursor, and others.

Skills are designed to be tool-agnostic and LLM-agnostic wherever
possible, following the agentskills.io specification.

Each skill provides specialized knowledge and workflows for a
specific aspect of Qt development — from UI/UX through to build
systems, architecture, and testing.

## Repository Structure

```
qtaiskills/
├── skills/                       # All skills live here
│   ├── qt-architecture/          # Architecture, project structure,
│   │   └── SKILL.md              #   tech choices, library selection
│   ├── qt-qml/                   # QML language — bindings, scoping,
│   │   └── SKILL.md              #   modules, JS interop, types
│   ├── qt-qml-docs/              # QDoc for QML — API docs,
│   │   └── SKILL.md              #   comments, examples
│   ├── qt-ui/                    # UI design — layout, a11y,
│   │   └── SKILL.md              #   theming, platform conventions
│   ├── qt-widgets/               # QWidget patterns — subclassing,
│   │   └── SKILL.md              #   QSS, .ui files, model/view
│   ├── qt-cpp-qml-bridge/       # C++/QML integration patterns
│   │   └── SKILL.md
│   ├── qt-build-deploy/          # Build, packaging, CI,
│   │   └── SKILL.md              #   cross-compilation
│   ├── qt-testing/               # Test strategy, Qt Test,
│   │   └── SKILL.md              #   QML Test, GTest
│   ├── qt-code-review/           # Review checklists, anti-patterns
│   │   └── SKILL.md
│   └── .../                      # More skills added over time
│
├── tooling/                      # Per-tool installation helpers
│   ├── claude-code/
│   │   └── install.sh
│   ├── codex/
│   │   └── install.sh
│   └── cursor/
│       └── install.sh
│
├── docs/
│   └── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Skill Format (agentskills.io)

Every skill follows the
[Agent Skills specification](https://agentskills.io/specification).
The minimum requirement is a directory containing a `SKILL.md`
file with YAML frontmatter:

```markdown
---
name: qt-ui
description: >-
  Designs Qt Quick/QML user interfaces following Qt design
  guidelines. Use when creating or modifying QML UIs, layouts,
  styling, or visual components.
license: BSD-3-Clause
compatibility: >-
  Designed for Claude Code, GitHub Copilot, and similar agents.
metadata:
  author: qt-ai-skills
  version: "1.0"
  qt-version: "6.x"
---

# Qt UI

## When to use this skill
...

## Instructions
...
```

### Key rules from the spec

- **`name`** must be lowercase alphanumeric + hyphens, max
  64 chars, and must match the directory name
- **`description`** must describe what the skill does AND when
  to use it (max 1024 chars, third person)
- **SKILL.md body** should stay under 500 lines — move detailed
  content to `references/` files
- **Progressive disclosure**: agents load only
  `name`/`description` at startup, read `SKILL.md` body on
  activation, and pull `references/` files only when needed
- **File references** should be one level deep from SKILL.md

## Planned Skill Domains

### Skill Types

Skills in this repo fall into three categories:

- **Process** — workflows and decision frameworks
  (architecture, build, test, review, documentation)
- **Conceptual** — mental model corrections for areas where
  LLMs consistently fail (declarative QML, C++/QML boundary,
  Widgets patterns, UI design)
- **Tool** — guidance on Qt CLI tools (qmllinter, balsam,
  qml.exe, etc.)

### Skills

| Skill | Type | Description |
|-------|------|-------------|
| `qt-architecture` | Process | Architecture decisions, project structure, module decomposition, library selection |
| `qt-qml` | Conceptual | QML language — bindings, scoping, modules, JS interop, type system |
| `qt-qml-docs` | Process | QDoc for QML — API documentation, comments, examples, documentation conventions |
| `qt-ui` | Conceptual | UI design — layout, accessibility, theming, responsive design, platform conventions |
| `qt-widgets` | Conceptual | QWidget patterns — subclassing, QSS, .ui files, model/view, widget lifecycle |
| `qt-cpp-qml-bridge` | Conceptual | C++/QML integration — type registration, Q_PROPERTY, ownership across the boundary |
| `qt-build-deploy` | Process | CMake setup, cross-compilation, CI integration, platform packaging, deployment |
| `qt-testing` | Process | Test strategy, Qt Test, QML Test, Google Test, specialized environments |
| `qt-code-review` | Process | Review checklists, Qt anti-patterns, performance pitfalls, API misuse |

## Multi-Tool Support

Skills are authored to be tool-agnostic wherever possible,
following the agentskills.io spec. However, different AI coding
tools may consume skills differently:

| Tool | Skill Location | Format | Notes |
|------|---------------|--------|-------|
| **Claude Code** | `~/.claude/skills/` | SKILL.md (native) | Full spec support including `allowed-tools` |
| **GitHub Copilot** | `.github/copilot/` | Markdown prompts | Via custom instructions |
| **Codex** | Project config | Markdown prompts | May need adapted instructions |
| **Cursor** | `.cursor/rules/` | `.mdc` rule files | Requires format conversion |

### When tool-specific variants are needed

Most skills work across tools without changes. When a skill
genuinely requires different instructions per tool (e.g.,
different tool names, execution models, or permission patterns),
create tool-specific overlays:

```
skills/qt-build-deploy/
├── SKILL.md                       # Core skill (tool-agnostic)
├── references/
│   ├── cmake-patterns.md
│   └── cross-compile.md
└── overlays/                      # Tool-specific adaptations
    ├── claude-code.md
    └── codex.md
```

The `overlays/` directory is not part of the agentskills.io
spec — it is a convention for this repository. The core
SKILL.md should reference overlays only when running under a
specific tool.

## Installation

### Claude Code

```bash
# From the repo root
bash tooling/claude-code/install.sh
```

This symlinks (or copies) each skill directory into
`~/.claude/skills/`.

### Other Tools

See `tooling/<tool>/install.sh` for tool-specific installation
instructions.

## Contributing

See [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines
on authoring new skills, including:

- Naming conventions and frontmatter requirements
- How to structure progressive disclosure
- Testing skills across models (Haiku, Sonnet, Opus)
- When and how to create tool-specific overlays

## Validating Skills

Use the
[skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref)
reference library to validate:

```bash
skills-ref validate ./skills/qt-ui
```

## License

BSD-3-Clause — see [LICENSE](LICENSE) for details.
