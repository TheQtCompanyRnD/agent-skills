# MCP Tools

Model Context Protocol servers for Qt-aware AI tooling.

## Services

These are hosted by The Qt Company and don't require you to install a local binary.

### Qt Documentation

A Qt-hosted MCP documentation server. The goal is to reduce the time
agents spend researching context for a Qt development task or user
query, leading to higher-quality outcomes.

A shared instance is available with **Qt 6.8.4** and **Qt 6.11.0**
documentation loaded — no local build required.

**Endpoint:** `https://qt-docs-mcp.qt.io/mcp`

#### Setup

Two ways to wire it up:

- **[Via the qt-development-skills plugin](setup-plugin.md)** — easiest
  if you're already using the Claude Code plugin from this repo.
- **[Manual client setup](setup-manual.md)** — direct configuration for
  Claude Code, Claude Desktop, OpenAI Codex, or Google
  Antigravity.

#### Available tools

##### `qt_documentation_search`

Search Qt documentation with optional filters.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `query` | string | No\* | Search term (e.g., `"QTimer"`, `"signal slot"`) |
| `keywords` | array | No\* | Keywords for multi-term OR matching |
| `version` | string | No | Qt version (e.g., `"6.11.0"`). Defaults to latest |
| `intent` | string | No | Result priority: `api`, `tutorial`, `guide`, `concept`, `example`, `migration` |
| `module` | string | No | Limit to module: `qtcore`, `qtwidgets`, `qtqml`, `qtnetwork`, ... |
| `filter` | string | No | Filter by type: `all`, `class`, `qml`, `function`, `guide` |
| `max_results` | integer | No | Max results 1–10 (default 3) |

\*At least one of `query` or `keywords` is required.

**Examples:**

```json
{"query": "signal slot"}
{"query": "QTimer", "version": "6.8.4"}
{"keywords": ["button", "connect", "signal"], "intent": "tutorial"}
{"query": "network", "module": "qtnetwork"}
{"query": "animation", "filter": "qml"}
```

##### `qt_documentation_read`

Read the full content of a specific documentation page.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `file` | string | Yes | Filename from search results (e.g., `qobject.html`) |
| `version` | string | No | Qt version to read from. Defaults to latest |

## Local Servers

Nothing to see yet, stay tuned!
