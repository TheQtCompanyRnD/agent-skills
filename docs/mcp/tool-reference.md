# Qt Documentation MCP — tool reference

Parameter reference for the tools exposed by the Qt Documentation
MCP server. Agents call these automatically once the server is
registered — you usually don't invoke them by hand. The reference
exists so you can write better prompts — pinning a version,
restricting to a module, steering toward tutorials — and debug
when results aren't what you expect.

## `qt_documentation_search`

Search Qt documentation with optional filters.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `query` | string | No\* | Search term, such as `"QTimer"` or `"signal slot"` |
| `keywords` | array | No\* | Keywords for multi-term OR matching |
| `version` | string | No | Qt version, such as `"6.11.0"`. Defaults to latest |
| `intent` | string | No | Result priority: `api`, `tutorial`, `guide`, `concept`, `example`, `migration` |
| `module` | string | No | Limit to module: `qtcore`, `qtwidgets`, `qtqml`, `qtnetwork`, ... |
| `filter` | string | No | Filter by type: `all`, `class`, `qml`, `function`, `guide` |
| `max_results` | integer | No | Max results 1–10 (default 3) |

\*At least one of `query` or `keywords` is required.

### Prompt patterns that steer the search

The agent picks parameters from your phrasing. To steer the
search:

- **Pin a version**: "in Qt 6.11", "using the 6.8 LTS docs"
- **Restrict to a module**: "in qtnetwork", "the QML module"
- **Steer toward tutorials**: "show me an example of",
  "tutorial for"
- **API-only**: "the signature of", "the signals on"

## `qt_documentation_read`

Read the full content of a specific documentation page —
typically a follow-up after a search returned a relevant
filename.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `file` | string | Yes | Filename from search results, such as `qobject.html` |
| `version` | string | No | Qt version to read from. Defaults to latest |

### Typical flow

1. Agent calls `qt_documentation_search` with the user's query.
2. Picks the most promising result by relevance.
3. Calls `qt_documentation_read` on that filename for the full
   page, if the search snippet wasn't enough.

You can short-circuit this if you already know the page:

> "Read `qquickwindow.html` from the Qt 6.11 docs and tell me
> the default value of `persistentGraphics`."
