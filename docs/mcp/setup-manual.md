# Manual client setup

Direct configuration for clients that aren't using the
`qt-development-skills` plugin. The endpoint in every case is:

```
https://qt-docs-mcp.qt.io/mcp
```

## Claude Code

Register the server globally once:

```shell
claude mcp add --transport http qt-docs https://qt-docs-mcp.qt.io/mcp
```

The server is then available in any Claude Code session.

## Claude Desktop

Claude Desktop only supports stdio transports and cannot connect to
HTTP MCP servers directly. Use `mcp-remote` as a bridge (requires
Node.js).

Open `claude_desktop_config.json`:

- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "qt-docs": {
      "command": "npx",
      "args": ["mcp-remote", "https://qt-docs-mcp.qt.io/mcp"]
    }
  }
}
```

Restart Claude Desktop after editing. On first use you may be prompted
to install `mcp-remote` — confirm to proceed.

## OpenAI Codex

Via the UI: **Settings → MCP server → Add Server** → select
**Streamable HTTP** → paste the URL. Give it a name and save.

## Google Antigravity

In **Agent Settings**, add a server entry pointing at the URL:

```json
{
  "mcpServers": {
    "qt-docs": {
      "serverUrl": "https://qt-docs-mcp.qt.io/mcp",
      "headers": {
        "Content-Type": "application/json"
      }
    }
  }
}
```
