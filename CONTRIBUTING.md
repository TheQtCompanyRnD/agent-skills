# Contributing to Qt AI Skills

Welcome! Whether this is your first time contributing to an
open-source project or you have been doing it for years, we are
glad you are here.

This guide walks you through everything you need to create a new
skill, from the first empty folder to a finished product that
works across all major AI coding platforms. You do not need to
support every platform on day one -- start with the core skill,
and add platform support when you are ready.

If anything in this guide is unclear, please open an issue.
Improving this document is a valid contribution too.


## Table of contents

- [What is a skill?](#what-is-a-skill)
- [Quick start](#quick-start)
- [Skill anatomy](#skill-anatomy)
  - [Directory layout](#directory-layout)
  - [SKILL.md frontmatter](#skillmd-frontmatter)
  - [SKILL.md body](#skillmd-body)
  - [References and supporting files](#references-and-supporting-files)
  - [Scripts](#scripts)
- [Writing good skill instructions](#writing-good-skill-instructions)
- [Making your skill work everywhere](#making-your-skill-work-everywhere)
  - [Platform overview](#platform-overview)
  - [Tier 1 -- Full skill directories](#tier-1----full-skill-directories)
  - [Tier 2 -- Single file with imports](#tier-2----single-file-with-imports)
  - [Tier 3 -- Self-contained compact file](#tier-3----self-contained-compact-file)
  - [Platform files reference](#platform-files-reference)
  - [Installing and testing with your platform](#installing-and-testing-with-your-platform)
- [Testing your skill](#testing-your-skill)
- [Submitting your contribution](#submitting-your-contribution)
- [Skill checklist](#skill-checklist)
- [Getting help](#getting-help)


## What is a skill?

A skill is a set of instructions that teaches an AI coding
assistant how to perform a specific task. Think of it as a
detailed guide written for a very capable colleague who has
broad programming knowledge but does not know your team's
particular tools, conventions, or domain.

Skills in this repository focus on Qt development. Each one
covers a specific area -- QML code review, C++/QML integration,
build systems, UI design, and so on.


## Quick start

The fastest way to get started:

```bash
# 1. Create a directory for your skill
mkdir skills/qt-my-topic

# 2. Create the main skill file
touch skills/qt-my-topic/SKILL.md

# 3. Add frontmatter and instructions (see below)

# 4. Create a references directory if you need supporting docs
mkdir skills/qt-my-topic/references
```

That is it. A skill is a directory with a `SKILL.md` file. Everything
else is optional.


## Skill anatomy

### Directory layout

Here is what a complete skill directory looks like. Only `SKILL.md`
is required -- add the other pieces as your skill grows.

```
skills/qt-my-topic/
  SKILL.md                         # Required. The main skill file.
  references/                      # Optional. Detailed reference docs.
    checklist.md                   #   Checklists, rule libraries, etc.
    api-patterns.md                #   Detailed examples and patterns.
    lint-scripts/                  #   Linter or validation scripts.
      my_linter.py
  platforms/                       # Optional. Platform-specific variants.
    copilot.prompt.md              #   GitHub Copilot agent version.
    windsurf.md                    #   Compact version for Windsurf.
  agents/                          # Optional. Platform metadata files.
    openai.yaml                    #   Codex CLI skill metadata.
```

**Naming rules:**

- Directory name must be lowercase, using hyphens to separate
  words: `qt-qml-review`, not `QtQmlReview` or `qt_qml_review`
- Directory name must match the `name` field in your frontmatter
- Maximum 64 characters
- Prefix with `qt-` for Qt-specific skills


### SKILL.md frontmatter

Every `SKILL.md` starts with a YAML frontmatter block between
`---` markers. This metadata tells AI tools what your skill does
and when to activate it.

```yaml
---
name: qt-my-topic
description: >-
  A clear explanation of what this skill does and when an AI
  agent should use it. Write this in third person. Be specific
  about trigger words and scenarios. Maximum 1024 characters,
  but front-load the most important information in the first
  250 characters -- some platforms truncate at that point.
license: LicenseRef-Qt-Commercial OR BSD-3-Clause
compatibility: >-
  Designed for Claude Code, GitHub Copilot, and similar agents.
metadata:
  author: qt-ai-skills
  version: "1.0"
  qt-version: "6.x"
  category: conceptual
---
```

**Required fields:**

| Field | What to write |
|-------|--------------|
| `name` | Must match the directory name exactly. |
| `description` | When should an AI use this skill? Write it so that an agent reading just this text can decide "yes, this is relevant" or "no, skip this." Include trigger words the user might say. |
| `license` | Use `LicenseRef-Qt-Commercial OR BSD-3-Clause` unless you have a specific reason not to. |

**Recommended fields:**

| Field | What to write |
|-------|--------------|
| `compatibility` | Which AI tools this skill is designed for. |
| `metadata.author` | Your name or `qt-ai-skills` for team work. |
| `metadata.version` | Start at `"1.0"` and increment as you make changes. |
| `metadata.qt-version` | Which Qt version(s) the skill targets. |
| `metadata.category` | One of: `process`, `conceptual`, `tool`, `review`. |

**A note on the `description` field:** This is the single most
important piece of text in your skill. On most platforms, the AI
agent reads *only* this description to decide whether to load
your skill. A vague description means the skill never gets used.
A good description answers two questions: "What does this do?"
and "When should I use it?"

Some platforms (including Claude Code) truncate the description
to around 250 characters in their skill listings. Put the most
important information first -- what the skill does and the key
trigger words. Save secondary details for later in the string.

Good example:
```yaml
description: >-
  Reviews Qt6 QML code for correctness and best practices. Use
  when the user asks to review, check, audit, or look over QML
  files, or before committing QML changes.
```

Weak example:
```yaml
description: >-
  Helps with QML code.
```


### SKILL.md body

After the frontmatter, write your instructions in Markdown. This
is the heart of your skill -- the actual guidance the AI will
follow.

**Keep `SKILL.md` under 500 lines.** This is not an arbitrary
rule. AI coding tools have limited context windows, and your
skill shares that space with the user's code, conversation
history, and other active skills. A 500-line skill leaves room
for everything else. If your skill needs more detail, move it
to `references/` files (see next section).

Structure your instructions clearly:

```markdown
# Qt My Topic

Brief overview of what this skill does.

## When to use this skill

- Bullet list of trigger scenarios
- Words or phrases the user might say

## Instructions

Step-by-step guidance for the AI agent.

## Common mistakes

Things the AI should watch out for.

## References

- For detailed patterns, see [patterns.md](references/patterns.md)
- For the full checklist, see [checklist.md](references/checklist.md)
```

**Tips for writing instructions:**

- Write as if you are explaining to a knowledgeable developer
  who is new to Qt. The AI has broad programming knowledge but
  may not know Qt-specific idioms.
- Use numbered steps for sequential workflows.
- Use bullet lists for collections of rules or checks.
- Include short code examples to show correct patterns. Three
  lines of example code is worth a paragraph of explanation.
- Mention common mistakes explicitly. AI models learn from
  patterns in training data, and some Qt anti-patterns are
  common enough to appear frequently in that data.


### References and supporting files

When your skill needs detailed checklists, rule libraries, or
extensive examples, put them in a `references/` directory:

```
references/
  checklist.md          # Detailed review checklist
  api-patterns.md       # Code examples and patterns
  lint-scripts/         # Linter or validation scripts
    my_linter.py
```

**How references work across platforms:**

- **Claude Code** and **Codex CLI** support references natively.
  The AI loads them on demand when it needs the detail.
- **Cursor** can pull in files using `@filename` syntax.
- **Other platforms** cannot access separate files. This is why
  the compact platform variants exist (see
  [Making your skill work everywhere](#making-your-skill-work-everywhere)).

**Link to references from SKILL.md** so the AI knows they exist:

```markdown
## References

For the complete list of 47 lint rules, see
[qt-qml-review-checklist.md](references/qt-qml-review-checklist.md).
```


### Scripts

Some skills include executable scripts -- linters, validators,
or helper tools. Place these in `references/lint-scripts/`
inside your skill directory.

Scripts should:
- Work cross-platform where possible (Python is a good choice)
- Include a brief comment at the top explaining what they do
- Not require external dependencies beyond the standard library
  (if dependencies are needed, document them)
- Be referenced from `SKILL.md` with clear instructions on how
  and when the AI should run them


## Writing good skill instructions

A few principles that make skills more effective, regardless
of which AI platform runs them.

**Be specific, not general.** Instead of "follow best practices,"
write "use `anchors.fill: parent` instead of setting x, y,
width, and height individually."

**Show, don't just tell.** A code example communicates faster
and more reliably than a paragraph of description, especially
when the instruction will be interpreted by an AI model.

```markdown
Weak:
  Use property aliases to expose nested properties.

Better:
  Use property aliases to expose nested properties:

  ```qml
  // Good -- exposes label text for parent components
  property alias text: label.text

  // Avoid -- requires binding through the component
  property string text
  Component.onCompleted: label.text = text
  ```
```

**State the "why," not just the "what."** When the AI
understands the reason behind a rule, it can apply the
principle to situations your instructions did not anticipate.

```markdown
Weak:
  Do not use JavaScript for animations.

Better:
  Do not use JavaScript for animations. The QML declarative
  animation system runs on the render thread, while JavaScript
  runs on the main thread. JavaScript animations cause visible
  stuttering because they block property updates.
```

**Think about what the AI gets wrong.** You are writing this
skill because the AI needs help in this area. Focus your
instructions on the specific mistakes you have seen, not on
things the AI already does well.


## Making your skill work everywhere

Different AI coding platforms handle skills differently. Some
can read multi-file skill directories; others need everything
in a single compact file. This section explains what each
platform supports and how to create variants when needed.

You do not need to support every platform right away. Start
with `SKILL.md` and the platforms you use. Add others later,
or another contributor can help.


### Platform overview

AI coding tools fall into three groups based on how they
consume skills:

| Tier | Platforms | How they work |
|------|-----------|---------------|
| **1** | Claude Code, Codex CLI | Read full skill directories with `SKILL.md` + `references/` + `scripts/`. Your skill works as-is. |
| **2** | Gemini CLI, Cursor | Read a single entry file but can import other files using `@file` syntax. Need a thin wrapper. |
| **3** | GitHub Copilot, Windsurf, Amazon Q, JetBrains AI | Need everything in one self-contained file. Need a condensed variant. |

Here is what that means in practice:


### Tier 1 -- Full skill directories

**Platforms:** Claude Code, Codex CLI

These platforms understand the full directory structure natively.
Your `SKILL.md` with `references/` and `scripts/` works without
any changes.

**Claude Code** loads skills from `.claude/skills/` directories.
The install script for this repository copies (or symlinks) each
skill into `~/.claude/skills/` so that Claude Code can find it.
Once installed, Claude Code reads `SKILL.md` when the skill is
invoked and follows links to reference files on demand.

**Codex CLI** uses a nearly identical model, loading skills from
a `skills/` directory (see the
[installation section](#installing-skills-into-each-platform)
for current paths). To add Codex-specific metadata (like implicit
invocation settings or MCP tool dependencies), create an
`agents/openai.yaml` file:

```yaml
# agents/openai.yaml
allow_implicit_invocation: true
dependencies:
  tools:
    - type: "mcp"
      value: "qt-docs"
```

This file is optional. Without it, the skill still works in
Codex -- it just will not auto-activate based on task context.

**What you need to do:** Nothing beyond creating a good
`SKILL.md`. These platforms are your primary target.


### Tier 2 -- Single file with imports

**Platforms:** Gemini CLI, Cursor

These platforms work from a single file but can pull in content
from other files.

**Gemini CLI** supports `@file.md` imports inside `GEMINI.md`
context files and `@{path}` injection in custom commands (TOML).
It can also be configured to read `AGENTS.md` as a context file.

**Cursor** supports `@filename` references in its rule files
(`.cursor/rules/*/RULE.md`), which pull the referenced file
into the AI's context.

**What you need to do:** For most skills, no separate file is
needed. The install script for each platform can generate a
thin wrapper that imports your existing `SKILL.md` and
references. If your skill has platform-specific behavior, you
can add a wrapper in `platforms/`:

```markdown
<!-- platforms/cursor-rule.md -->
<!-- Note: Cursor resolves @-imports relative to the workspace -->
<!-- root. Adjust paths to match your installation location.   -->
---
description: "Qt QML review -- linting and deep analysis"
globs: ["**/*.qml"]
alwaysApply: false
---
Review QML files using the Qt QML review skill guidelines.

@.cursor/rules/qt-qml-review/SKILL.md
@.cursor/rules/qt-qml-review/references/checklist.md
```


### Tier 3 -- Self-contained compact file

**Platforms:** GitHub Copilot, Windsurf, Amazon Q, JetBrains AI

These platforms need everything in a single markdown file and
cannot reference external files. Some have strict size limits:

| Platform | Size limit | Notes |
|----------|-----------|-------|
| **GitHub Copilot** | 4,000 chars (code review), 30,000 chars (agents) | Two different limits depending on feature |
| **Windsurf** | 6,000 chars per rule, 12,000 chars total | Hardest constraint -- silently drops rules that exceed the limit |
| **Amazon Q** | Not documented | All rules always load; no conditional activation |
| **JetBrains AI** | Not documented | Activation mode is configured in the IDE, not in the file |

**What you need to do:** Create a condensed variant in
`platforms/` that captures the essential guidance from your
skill in a single file. This is a curation task, not a
mechanical copy -- choose the highest-value rules and patterns
that fit within the size constraints.

```
platforms/
  copilot.prompt.md        # For GitHub Copilot (max 30K chars)
  windsurf.md              # Compact version (max 6K chars)
```

**Tips for condensing:**

- Lead with the rules that catch the most common mistakes
- Cut examples down to the minimum that communicates the point
- Remove step-by-step workflow instructions (those are
  agent-specific and most Tier 3 platforms use a different
  execution model anyway)
- Keep the "why" for each rule -- it helps the AI generalize
- For Windsurf, aim for under 5,000 characters to leave room
  for other active rules

**You do not have to create all variants.** A skill with only
`SKILL.md` is a complete, useful contribution. Platform
variants can be added later by you or another contributor.


### Platform files reference

Here is a quick reference for every platform-specific file you
might add, all optional:

| File | Platform | Format | Purpose |
|------|----------|--------|---------|
| `agents/openai.yaml` | Codex CLI | YAML | Implicit invocation config, MCP dependencies |
| `platforms/copilot.prompt.md` | GitHub Copilot | MD + YAML frontmatter | Self-contained agent prompt (max 30K chars) |
| `platforms/copilot-review.md` | GitHub Copilot | MD | Code review instructions (max 4K chars) |
| `platforms/cursor-rule.md` | Cursor | MD + YAML frontmatter | Rule with `@file` imports and `globs` |
| `platforms/windsurf.md` | Windsurf | MD + YAML frontmatter | Compact rule (max 6K chars) |
| `platforms/amazonq.md` | Amazon Q | Plain MD | Self-contained rule, no frontmatter |
| `platforms/jetbrains.md` | JetBrains AI | Plain MD | Self-contained rule (activation configured in IDE) |


### Installing and testing with your platform

For instructions on how to install skills into your AI coding
tool, see the [Installation section](README.md#installation) in
the README. Most platforms with native installers can consume
this repository directly.


## Testing your skill

Before submitting, test that your skill actually works. The
best way is to use it in a real coding session.

### Basic checks

1. **Frontmatter is valid.** Paste the YAML between your `---`
   markers into any YAML validator. Common mistakes: missing
   quotes around version numbers, incorrect indentation,
   special characters in the description that need escaping.

2. **Links work.** If your `SKILL.md` references files in
   `references/`, make sure those files exist and the relative
   paths are correct.

3. **Size is reasonable.** Run a quick check:
   ```bash
   wc -l skills/qt-my-topic/SKILL.md
   # Should be under 500 lines
   ```

4. **Platform variants fit.** If you created compact variants:
   ```bash
   # Character count (not byte count -- they differ for non-ASCII text)
   cat skills/qt-my-topic/platforms/windsurf.md | wc -m
   # Should be under 6000 characters for Windsurf
   ```

### Functional testing

Install the skill in the AI tool you use and try it on real
code. Good things to test:

- Does the AI activate the skill when you use the trigger
  words from your description?
- Does it follow the instructions correctly?
- Does it handle edge cases (empty files, very large files,
  mixed languages)?
- Does it produce output in the format you specified?

If you have access to multiple AI tools, testing across them is
valuable but not required. Note which tools you tested with in
your pull request description.


## Submitting your contribution

1. **Fork and branch.** Create a branch with a descriptive name:
   `add-qt-testing-skill` or `improve-qml-review-checklist`.

2. **One skill per pull request.** This makes review faster and
   keeps the git history useful. If you are updating an existing
   skill and adding a new one, use separate PRs.

3. **Write a clear PR description.** Explain:
   - What the skill does and why it is useful
   - Which platforms you tested on
   - Any design decisions you want reviewers to know about

4. **Be patient with review.** Skill quality matters because
   these instructions directly shape what the AI produces.
   Reviewers may ask you to restructure, condense, or reword
   sections. This is normal and means your work is being taken
   seriously.


## Skill checklist

Use this checklist before opening your pull request. Not every
item applies to every skill -- use your judgment.

### Required

- [ ] `SKILL.md` exists with valid YAML frontmatter
- [ ] `name` field matches the directory name
- [ ] `description` clearly states what the skill does and when
      to use it
- [ ] `license` field is set
- [ ] `SKILL.md` body is under 500 lines
- [ ] All referenced files exist and paths are correct

### Recommended

- [ ] `metadata.version`, `metadata.qt-version`, and
      `metadata.category` are set
- [ ] Instructions include code examples for key patterns
- [ ] Common mistakes section covers known AI failure modes
- [ ] Tested with at least one AI coding tool

### Optional platform support

- [ ] `agents/openai.yaml` for Codex CLI
- [ ] `platforms/copilot.prompt.md` (under 30K chars)
- [ ] `platforms/windsurf.md` (under 6K chars)
- [ ] Other platform variants as needed


## Getting help

- **Questions about this guide:** Open an issue with the label
  `question`.
- **Not sure if your skill idea fits:** Open an issue describing
  what you have in mind. We are happy to give feedback before
  you start writing.
- **Stuck on platform-specific details:** The platform
  comparison in this guide is current as of April 2026. If you
  find that something has changed, please let us know so we can
  update the guide.
- **Want to contribute but not sure where to start:** Look at
  the existing skills for examples, especially `qt-qml-review`
  and `qt-cpp-review` which demonstrate the full directory
  structure with references and lint scripts.

Thank you for helping make Qt development better for everyone
who uses AI coding tools.
