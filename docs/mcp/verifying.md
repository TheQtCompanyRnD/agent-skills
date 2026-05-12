# Verifying MCP

After setup, confirm the Qt Documentation MCP server is
reachable from your agent. The signals differ per client.

## A universal smoke test

Ask the agent something only fresh, version-pinned Qt docs can
answer:

> "Using the Qt 6.11 docs, what is the default value of
> `QQuickWindow::persistentGraphics`? Quote the documentation."

A working server produces:

1. A visible `qt_documentation_search` tool call (or
   `qt_documentation_read`).
2. A precise answer.
3. A reference to the source page (filename or doc.qt.io link).

A broken or missing server produces a hedged answer, an
"I'm not sure" disclaimer, or an invented value. If the agent
doesn't reach for the tool at all, the server isn't connected.

## Per-client checks

### Claude Code

List registered MCP servers:

```
/mcp
```

You should see `qt-docs` (manual setup) or the plugin's bundled
server. Each listed server expands to show its tools — look for
`qt_documentation_search` and `qt_documentation_read`.

### Claude Desktop

Open the developer tools window (Settings → Developer →
Open Logs). On startup the log lines should show
`mcp-remote` connecting to `https://qt-docs-mcp.qt.io/mcp`. If
you see `npx` errors, install Node.js LTS or approve
`mcp-remote` at the first-use prompt.

### OpenAI Codex

Open Settings → MCP server. The `qt-docs` entry should be
present and show **Streamable HTTP** as its transport. Toggle
it off and back on to force a reconnect.

### Google Antigravity

In Agent Settings, the server entry should be listed under
`mcpServers`. The agent's tool palette for new conversations
includes `qt_documentation_search` once the entry resolves.

## Common failure modes

The table below maps symptoms to likely causes and fixes.

| Symptom | Likely cause | Fix |
|---|---|---|
| Agent never calls the tool | Server not registered | Re-run setup; restart the client |
| `mcp-remote` errors in Claude Desktop | Node.js missing | Install Node.js LTS; reopen the app |
| Tool call returns empty results | Query too broad or wrong version | Specify `version` and a `module` in the prompt |
| Tool call times out | Network policy blocks `qt-docs-mcp.qt.io` | Allowlist the host or run a local mirror |
| Outdated answers | Agent fell back to training data | Phrase the request to require the docs ("Quote the Qt 6.11 docs for…") |

## When to escalate

If the smoke test fails and the per-client check above doesn't
explain why, open an issue with:

- Your client and version, for example `claude --version`
- The exact `mcpServers` entry or `claude mcp list` output
- Whether `curl https://qt-docs-mcp.qt.io/mcp` from your machine
  succeeds

Issues: <https://github.com/TheQtCompanyRnD/agent-skills/issues>
