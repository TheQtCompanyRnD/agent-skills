# Qt AI Skills

Official agentic skills for Qt software development
and quality assurance, designed for use with AI coding tools
such as Claude Code, Codex CLI, Gemini CLI, and
GitHub Copilot.

Skills have been tested with frontier LLMs from the Claude,
Gemini, and GPT model families.

There is no settled industry standard for AI skill packaging.
Each platform has its own conventions. Our canonical format
uses `SKILL.md` with YAML frontmatter in a directory-based
structure — this works natively on Claude Code and Codex CLI,
and can be adapted to other platforms through condensed
variants. See [CONTRIBUTING.md](CONTRIBUTING.md) for the full
cross-platform story.

> These agentic development skills use AI and can make mistakes.
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
| `qt-cpp-docs` | Process | Generates Markdown reference documentation for Qt/C++ source files — classes, modules, utilities, headers, and entry points. |
| `qt-qml-profiler` | Tool | Runs `qmlprofiler` on a 2D QML / Qt Quick application, parses the `.qtd` trace, and analyzes hotspots against the source code with frame-time, memory, and pixmap-cache summaries. Does not cover Qt Quick 3D. |

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
  qt-qml-review/
  qt-qml/
  qt-qml-docs/
  qt-cpp-docs/
  qt-qml-profiler/
.claude-plugin/                   # Claude Code CLI & Copilot CLI plugin config
gemini-extension.json             # Gemini CLI extension manifest
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
name: qt-qml-review
description: >-
  Reviews QML source files for correctness, performance, and
  maintainability. Deterministic linting (47+ rules) plus
  parallel deep-analysis agents for bindings, layout, loaders,
  delegates, states, and performance.
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
| **Claude Code CLI** | `~/.claude/skills/` | SKILL.md + references (native) | Full directory model with progressive loading |
| **Codex CLI** | `~/.codex/skills/` | SKILL.md + references (native) | Full directory model; registered in `~/.codex/config.toml` |
| **Gemini CLI** | Extension `skills/` | SKILL.md + references (native) | Installed via `gemini extensions install`; `@file.md` imports |
| **GitHub Copilot** | `.github/agents/` | Markdown agent profiles | Self-contained; also installable as plugin via `.claude-plugin/` |

### When platform-specific variants are needed

Most skills work across tools without changes. When a skill
needs to reach platforms that cannot read multi-file directories
(e.g. Copilot), create variants in a `platforms/` directory:

```
skills/qt-qml-review/
├── SKILL.md                       # Core skill (tool-agnostic)
├── references/
│   ├── qml-lint-rules.md
│   └── qml-review-checklist.md
└── platforms/                     # Platform-specific variants
    └── copilot.prompt.md          #   Self-contained Copilot agent
```

The `platforms/` directory is a convention for this repository.
See [CONTRIBUTING.md](CONTRIBUTING.md) for full details on
creating platform variants.

## Installation

Most AI coding tools can install skills directly from this
GitHub repository. Choose the method for your platform below.

### Claude Code CLI

Install as a plugin using the Claude Code CLI plugin system:

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

### GitHub Copilot CLI
Register as a marketplace first, then install by name:

```
copilot plugin marketplace add TheQtCompanyRnD/agent-skills
copilot plugin install qt-development-skills@qt-skills-and-tools
```

Or copy platform variants into your repository:

```bash
# As a custom agent (invoked with @qt-qml-review in chat)
cp skills/qt-qml-review/platforms/copilot.prompt.md \
   .github/agents/qt-qml-review.agent.md
```

### VSCode Agents (Copilot and others)

Run `Chat: Install Plugin From Source` from the Command Palette.
Enter `https://github.com/TheQtCompanyRnD/agent-skills` (this repo) to clone and install

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

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines
on authoring new skills, including:

- Naming conventions and frontmatter requirements
- How to structure progressive disclosure
- Testing skills across AI coding tools
- When and how to create platform-specific variants

## License

BSD-3-Clause — see [LICENSE](LICENSE) for details.
