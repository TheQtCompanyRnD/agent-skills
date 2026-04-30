# Qt Documentation MCP Tool

A hosted Model Context Protocol server that gives AI agents direct
access to Qt API documentation across the latest Qt release and
active LTS branches.

It is **bundled with the `qt-development-skills` plugin** for Claude
Code (registered via `.mcp.json` at the repo root) and is also
available standalone in the official MCP registry as
`io.qt/qt-documentation-mcp`.

## Endpoint

```
https://qt-docs-mcp.qt.io/mcp
```

- **Transport:** Streamable HTTP
- **Network:** requires outbound HTTPS to `qt-docs-mcp.qt.io`

## Setup

Detailed setup instructions live with the rest of the docs — pick
the appropriate path:

- **Plugin install** (Claude Code): see
  [`docs/mcp/setup-plugin.md`](../../docs/mcp/setup-plugin.md)
- **Manual client setup** (Claude Desktop, Cursor, OpenAI Codex,
  Google Antigravity): see
  [`docs/mcp/setup-manual.md`](../../docs/mcp/setup-manual.md)
- **Tool reference** (`qt_documentation_search`,
  `qt_documentation_read`): see
  [`docs/mcp/index.md`](../../docs/mcp/index.md)

The rendered version is published at
<https://doc.qt.io/agentictools/mcp/>.
