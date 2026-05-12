---
hide:
  - navigation
  - toc
---

<div class="qt-hero" markdown>

# Qt Agentic Tools

Official agentic skills — portable, version-controlled knowledge
packages that AI agents load on demand — plus MCP servers for Qt
documentation lookup. Designed for AI coding tools in 2026 and
beyond.

Tested with frontier LLMs from the Claude, Gemini, and GPT model
families. Built on the same brand bones as [doc.qt.io](https://doc.qt.io),
tuned for the way agents read and write code.

[Get started →](getting-started.md){ .md-button .md-button--primary } &nbsp;
[Browse skills →](skills/index.md){ .md-button } &nbsp;
[MCP tools →](mcp/index.md){ .md-button }

</div>

## Why Qt-official tools { #why-qt-official }

Generic AI coding assistants treat Qt like any other C++ or
JavaScript codebase. They guess at signal/slot syntax, miss
declarative-QML idioms, and hallucinate APIs that haven't existed
since Qt 5. These skills and MCP servers exist because Qt
deserves better than guesses.

<div class="qt-cards">

<a class="qt-card">
<strong>Qt-aware by design</strong>
Authored by The Qt Company against real Qt 6 codebases. Skills
encode Qt model-view contracts, parent-ownership rules, QML
binding semantics, and the C++/QML boundary — the things LLMs
get systematically wrong without help.
</a>

<a class="qt-card">
<strong>Always-fresh docs</strong>
Our hosted MCP server serves Qt 6.8.4 (LTS) and Qt 6.11.0
documentation directly to your agent — no stale training data,
no web search guesswork. Pinned to a
version when you need it.
</a>

<a class="qt-card">
<strong>Cross-tool, no lock-in</strong>
One source format (`SKILL.md`) runs natively in Claude Code,
Codex CLI, Gemini CLI, and GitHub Copilot. Skills are
open-source under BSD-3-Clause — installable from this repo,
the official MCP registry, or as a CLI plugin.
</a>

<a class="qt-card">
<strong>Tested across frontier LLMs</strong>
Validated against Claude, Gemini, and GPT model families.
Triggering descriptions, references, and progressive disclosure
are tuned so the skill activates when it should and stays out
of the way when it shouldn't.
</a>

</div>

## What's Here { #whats-here }

<div class="qt-cards">

<a class="qt-card" href="skills/">
<strong>Skills</strong>
Agentic skills for QML and C++ authoring, review, and
documentation — packaged so they work natively in Claude Code,
Codex CLI, and Gemini CLI.
</a>

<a class="qt-card" href="mcp/">
<strong>MCP Tools</strong>
Model Context Protocol servers that give agents first-class
access to Qt documentation across multiple Qt versions.
</a>

<a class="qt-card" href="contributing/">
<strong>Contributing</strong>
Packaging conventions and the cross-platform story for
publishing a new skill or MCP server in this repo.
</a>

</div>

## Part of Qt's AI-powered development tools { #qt-ai-tools }

This site documents the skills and MCP servers that any AI agent
can load. If you're working in Qt Creator, the commercial
**Qt AI Assistant** is also available, integrated into the IDE.
See [Qt's AI-powered development tools](https://www.qt.io/development/tools/ai-powered-development-tools)
for the other Qt AI offerings.

!!! warning "AI output requires review"
    These tools and skills depend on LLMs, which can make mistakes.
    Always double-check the output carefully.

    Before using the skills under Qt commercial licensing, make sure
    you have understood and agree to the
    [Qt AI Services Terms & Conditions](https://www.qt.io/terms-conditions/ai-services-2025-06).
