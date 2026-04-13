# Qt AI Skills

Official agentic engineering skills for Qt software development
and quality assurance, designed for use with AI coding tools
such as Claude Code, Codex CLI, Gemini CLI, GitHub Copilot,
Cursor, and others.

Skills have been tested with frontier LLMs from the Claude,
Gemini, and GPT model families.

There is no settled industry standard for AI skill packaging.
Each platform has its own conventions. Our canonical format
uses `SKILL.md` with YAML frontmatter in a directory-based
structure — this works natively on Claude Code and Codex CLI,
and can be adapted to other platforms through condensed
variants. See [CONTRIBUTING.md](CONTRIBUTING.md) for the full
cross-platform story.

> These agentic engineering skills use AI and can make mistakes.
> Always double-check the output carefully.
>
> Before using the skills under Qt commercial licensing, make
> sure you have understood and agree to the
> [Qt AI Services Terms & Conditions](https://www.qt.io/terms-conditions/ai-services-2025-06).
> By using the skills or MCP tools, you accept these terms &
> conditions and that you have the right to do so on behalf of
> your employer.

## Skills

| Skill | Type | Description |
|-------|------|-------------|
| `qt-cpp-review` | Review | Deterministic linting + 6 parallel deep-analysis agents for Qt C++ code. Covers model rule compliance, memory ownership, thread safety, correctness, error handling, and performance. |
| `qt-qml-review` | Review | Deterministic QML linting (47+ rules) + parallel deep-analysis agents for bindings, layout, loaders, delegates, states, and performance. |
| `qt-qml` | Conceptual | QML best practices for writing, reviewing, fixing, and refactoring. Corrects systematic LLM pre-training biases around bindings, scoping, modules, JS interop, and types. |
| `qt-qml-docs` | Process | Generates Markdown reference documentation for QML components and applications from .qml source files. |

### Skill types

- **Review** — structured code review workflows combining
  deterministic linters with deep AI analysis
- **Process** — workflows and decision frameworks
  (architecture, build, test, documentation)
- **Conceptual** — mental model corrections for areas where
  LLMs consistently fail (declarative QML, C++/QML boundary,
  Widgets patterns, UI design)
- **Tool** — guidance on Qt CLI tools and testing solutions

## Repository Structure

```
skills/                           # All skills live here
  qt-cpp-review/                  #   Each skill is a directory
    SKILL.md                      #   with a SKILL.md entry point
    references/                   #   and optional reference docs
      lint-scripts/
      qt-review-checklist.md
    platforms/                    #   Platform-specific variants
    agents/                       #   Platform metadata
  qt-qml-review/
  qt-qml/
  ...
tooling/                          # Per-tool installation helpers
CONTRIBUTING.md
LICENSE
README.md
```

## Skill Format

Every skill is a directory containing a `SKILL.md` file with
YAML frontmatter. This format aligns with what Claude Code and
Codex CLI support natively:

```yaml
---
name: qt-ui
description: >-
  Designs Qt Quick/QML user interfaces following Qt design
  guidelines. Use when creating or modifying QML UIs, layouts,
  styling, or visual components.
license: LicenseRef-Qt-Commercial OR BSD-3-Clause
compatibility: >-
  Designed for Claude Code, GitHub Copilot, and similar agents.
metadata:
  author: qt-ai-skills
  version: "1.0"
  qt-version: "6.x"
---
```

### Key conventions

- **`name`** must be lowercase alphanumeric + hyphens, max
  64 chars, and must match the directory name
- **`description`** must describe what the skill does AND when
  to use it — front-load the key information in the first 250
  characters, as some platforms truncate beyond that point
- **SKILL.md body** should stay under 500 lines — move detailed
  content to `references/` files
- **Progressive disclosure**: agents load only
  `name`/`description` at startup, read `SKILL.md` body on
  activation, and pull `references/` files only when needed

## Multi-Tool Support

Skills are authored to be tool-agnostic wherever possible.
However, different AI coding tools consume skills in different
ways:

| Tool | Skill Location | Format | Notes |
|------|---------------|--------|-------|
| **Claude Code** | `~/.claude/skills/` | SKILL.md + references (native) | Full directory model with progressive loading |
| **Codex CLI** | `.agents/skills/` | SKILL.md + references (native) | Full directory model; optional `agents/openai.yaml` for metadata |
| **Gemini CLI** | `.gemini/commands/` | TOML commands, `GEMINI.md` context | Supports `@file.md` imports for references |
| **GitHub Copilot** | `.github/prompts/`, `.github/agents/` | Markdown prompts / agent profiles | Self-contained; 4K chars (review), 30K chars (agents) |
| **Cursor** | `.cursor/rules/` | Markdown rules with YAML frontmatter | Supports `@file` imports; ~500 lines recommended |
| **Windsurf** | `.windsurf/rules/` | Markdown rules with YAML frontmatter | Self-contained; 6K chars per rule, 12K total |
| **Amazon Q** | `.amazonq/rules/` | Plain Markdown | Self-contained; all rules always loaded |
| **JetBrains AI** | `.aiassistant/rules/` | Plain Markdown | Activation configured in IDE settings |

### When platform-specific variants are needed

Most skills work across tools without changes. When a skill
needs to reach platforms that cannot read multi-file directories
(Copilot, Windsurf, Amazon Q, JetBrains AI), or needs
platform-specific metadata (Codex `openai.yaml`), create
variants in a `platforms/` directory:

```
skills/qt-build-deploy/
├── SKILL.md                       # Core skill (tool-agnostic)
├── references/
│   ├── cmake-patterns.md
│   └── cross-compile.md
├── platforms/                     # Platform-specific variants
│   ├── copilot.prompt.md          #   Self-contained Copilot agent
│   └── windsurf.md                #   Compact version (under 6K chars)
└── agents/                        # Platform metadata
    └── openai.yaml                #   Codex CLI skill config
```

The `platforms/` and `agents/` directories are conventions for
this repository.
See [CONTRIBUTING.md](CONTRIBUTING.md) for full details on
creating platform variants.

## Installation

Most AI coding tools can install skills directly from this
GitHub repository. Choose the method for your platform below.

### Claude Code

Install as a plugin using the Claude Code plugin system:

```
/plugin marketplace add TheQtCompanyRnD/agent-skills
/plugin install qt-development-skills
```

Or install individual skills manually:

```bash
# Symlink a skill into your personal skills directory
ln -s "$(pwd)/skills/qt-qml-review" ~/.claude/skills/qt-qml-review

# Or copy into a project for team use
cp -r skills/qt-qml-review .claude/skills/qt-qml-review
```

Claude Code auto-discovers skills — no restart needed.

### Codex CLI

Use Vercel's cross-platform skill installer:

```bash
npx skills add TheQtCompanyRnD/agent-skills
```

Or copy skills manually:

```bash
cp -r skills/qt-qml-review ~/.codex/skills/qt-qml-review
```

Restart Codex after adding skills.

> **Note:** Codex is evolving rapidly. If `~/.codex/skills/`
> does not work, try `~/.agents/skills/` or `.agents/skills/`
> in your project root.

### GitHub Copilot

Install as a plugin:

```
copilot plugin install qt-development-skills@TheQtCompanyRnD/agent-skills
```

Or copy platform variants into your repository:

```bash
# As a custom agent (invoked with @qt-qml-review in chat)
cp skills/qt-qml-review/platforms/copilot.prompt.md \
   .github/agents/qt-qml-review.agent.md

# As code review instructions (auto-applied to matching files)
cp skills/qt-qml-review/platforms/copilot-review.md \
   .github/instructions/qt-qml-review.instructions.md
```

### Gemini CLI

Install as an extension:

```bash
gemini extensions install https://github.com/TheQtCompanyRnD/agent-skills
```

Or import skills into your project's context file:

```bash
# Add to GEMINI.md (loaded automatically)
echo '@skills/qt-qml-review/SKILL.md' >> GEMINI.md
```

### Cursor

Install from the Cursor marketplace (search for
"Qt AI Skills"), or copy skills into your project:

```bash
mkdir -p .cursor/rules/qt-qml-review
cp skills/qt-qml-review/platforms/cursor-rule.md \
   .cursor/rules/qt-qml-review/RULE.md
```

Cursor auto-discovers rules — no restart needed.

### Windsurf

Copy the compact platform variant into your project:

```bash
mkdir -p .windsurf/rules
cp skills/qt-qml-review/platforms/windsurf.md \
   .windsurf/rules/qt-qml-review.md
```

Restart Windsurf after adding rules. Rules must be under 6,000
characters each, 12,000 characters total.

### Amazon Q

```bash
mkdir -p .amazonq/rules
cp skills/qt-qml-review/platforms/amazonq.md \
   .amazonq/rules/qt-qml-review.md
```

All rules auto-load on next interaction.

### JetBrains AI Assistant

```bash
mkdir -p .aiassistant/rules
cp skills/qt-qml-review/platforms/jetbrains.md \
   .aiassistant/rules/qt-qml-review.md
```

Then configure activation in **Settings > Tools > AI Assistant
> Rules** (JetBrains does not auto-discover rule files).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines
on authoring new skills, including:

- Naming conventions and frontmatter requirements
- How to structure progressive disclosure
- Testing skills across AI coding tools
- When and how to create platform-specific variants

## License

BSD-3-Clause — see [LICENSE](LICENSE) for details.
