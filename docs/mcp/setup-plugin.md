# Setup via the qt-development-skills plugin

The `qt-development-skills` plugin in this repo bundles the
`qt-documentation-mcp` server alongside the agentic skills, so a single
plugin install gives you both.

## Install

Follow the plugin install instructions in the project
[README](https://github.com/TheQtCompanyRnD/agent-skills#installation) for your AI tool of choice.
Once the plugin is installed, the MCP server is registered
automatically — no extra `claude mcp add` step is required.

## Verify

Ask the agent to search Qt documentation, e.g.:

> Look up `QTimer` in the Qt 6.11 docs.

If the tools are wired up, the agent will call
`qt_documentation_search` and return results from the MCP server.

## Switching to manual setup

If you prefer not to install the plugin — or you're using a client that
doesn't support plugins — see [Manual client setup](setup-manual.md).
