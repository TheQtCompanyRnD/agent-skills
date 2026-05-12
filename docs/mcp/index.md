# MCP Tools

Model Context Protocol servers that give your AI agent first-class
access to Qt documentation.

## What is MCP?

The **Model Context Protocol** is an open standard that lets an
AI agent call external tools and read external resources during a
conversation. The agent stays in place and skips its training
data. Each tool is a typed function the model can invoke. Each
call returns structured results that flow back into the agent's
reasoning.

Think of an MCP server as the *back end* for an agent. Where a
plain LLM has to guess from its training data, an MCP-enabled
agent can ask a server for the authoritative answer in real time.

## Why a Qt MCP server?

The Qt Framework has thousands of classes and multiple modules that
change with each release. With wiring an MCP server to your agent,
your agent can produce much better results, because the agent relies
on real Qt 6 documentation instead of trained data that didn't have
information about future Qt releases. Your agent no longer relies on
guessing or web searches that can return outdated solutions.

A Qt-hosted MCP documentation server reduces the time agents
spend researching context for Qt development tasks. The result is
higher-quality answers and fewer hallucinations.

| | Generic LLM | Web search tool | **Qt Documentation MCP** |
|---|---|---|---|
| Version-pinned | No | No | **Yes (6.8.4, 6.11.0)** |
| Always up to date | No | Sort of | **Yes** |
| Structured results | No | No | **Yes (typed tools)** |
| Zero local setup | Yes | Yes | **Yes (hosted)** |
| Official source | No | No | **Yes** |

If you're already running the `qt-development-skills` plugin, the
MCP server is wired up automatically. If you want to point a
different client at the hosted instance, see [Manual setup](setup-manual.md).

## Setting up the Qt MCP server

A shared instance hosted by The Qt Company is available with
**Qt 6.8.4** and **Qt 6.11.0** documentation loaded — no local
binary required.

**Endpoint:** `https://qt-docs-mcp.qt.io/mcp`

### Setup

Two ways to wire it up:

- **[Via the qt-development-skills plugin](setup-plugin.md)** —
  easiest if you're using the Claude Code plugin from this repo.
- **[Manual client setup](setup-manual.md)** — direct configuration
  for Claude Code, Claude Desktop, OpenAI Codex, or Google
  Antigravity.

### Tools exposed

| Tool | Purpose |
|---|---|
| `qt_documentation_search` | Search Qt docs with optional version, module, intent, and type filters. |
| `qt_documentation_read` | Fetch the full content of a specific documentation page. |

See [Tool reference](tool-reference.md) for parameters and
examples.

### Verifying it works

After setup, see [Verifying MCP](verifying.md) for per-client
checks and common failure modes.
