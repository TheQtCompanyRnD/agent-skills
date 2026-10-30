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
| `version` | string | No | Qt version, such as `"6.11.0"`, or a product version with `product`. Defaults to latest |
| `intent` | string | No | Result priority: `api`, `tutorial`, `guide`, `concept`, `example`, `migration` |
| `module` | string | No | Limit to module: `qtcore`, `qtwidgets`, `qtqml`, `qtnetwork`, ... |
| `product` | string | No | Limit to one documentation product: `qt`, `qtcreator`, `squish`, `qtformcus`, ... Omit to search all products. An unknown product is an error |
| `filter` | string | No | Filter by type: `all`, `class`, `qml`, `function`, `guide` |
| `max_results` | integer | No | Max results 1–10 (default 3) |

\*At least one of `query` or `keywords` is required.

### Prompt patterns that steer the search

The agent picks parameters from your phrasing. To steer the
search:

- **Pin a version**: "in Qt 6.11", "using the 6.8 LTS docs"
- **Restrict to a module**: "in qtnetwork", "the QML module"
- **Restrict to a product**: "in the Qt Creator docs",
  "according to the Squish manual"
- **Steer toward tutorials**: "show me an example of",
  "tutorial for"
- **API-only**: "the signature of", "the signals on"

### Products and versions

Product documentation is the released version published on
doc.qt.io. Each result names its product and version, such as
`(squish 9.3)`. A search for a version that is not served
returns an error listing every product and version available.

- **Pinning a product version**: pass `product` and `version`
  together, such as `squish` and `9.3`.
- **Products without a version**: some products state no version
  on doc.qt.io and show none. Pinning a version on them is an
  error; omit `version`.
- **Pre-release products**: a product in beta is labelled, such
  as `(clate 0.6 BETA)`, and its search results and pages carry
  a notice that features and behaviour may change.

## `qt_documentation_read`

Read a specific documentation page, or one member of it —
typically a follow-up after a search returned a relevant
filename.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `file` | string | Yes | Filename from search results, such as `qobject.html` |
| `version` | string | No | Qt version to read from. Defaults to latest |
| `symbol` | string | No | Return only this member instead of the whole page, such as `singleShot` |

### Reading one member

A class page can run to thousands of tokens when the question is
about one function. With `symbol`, the read returns only the
matching member documentation:

- **A name**, such as `singleShot`, `anchors.fill` or
  `onCompleted`, returns every overload plus any property of that
  name.
- **An enum constant**, such as `AlignLeft` or `Text.ElideLeft`,
  returns the enum or QML property it belongs to. **A property
  access function**, such as `setInterval`, returns the property.
- **An anchor**, shown as `{#anchor}` after each signature in the
  output (such as `singleShot-5`), returns that one block only.
- **An unknown name** returns the page's member list, so the
  agent can pick the right one.

Search results suggest a `symbol` value when a query word names a
member of the page.

### Typical flow

1. Agent calls `qt_documentation_search` with the user's query.
2. Picks the most promising result by relevance.
3. If the search snippet wasn't enough, calls
   `qt_documentation_read` on that filename — with `symbol` when
   the question is about one member.

You can short-circuit this if you already know the page:

> "Read `qquickwindow.html` from the Qt 6.11 docs and tell me
> the default value of `persistentGraphics`."

### Argument limits

Over-long arguments are rejected with an error that names the
limit:

| Argument | Limit |
|---|---|
| `query` | 500 characters |
| `keywords` | 20 entries, 100 characters each |
| `file` | 256 characters |
| `symbol` | 200 characters |
| `version`, `product`, `module`, `intent`, `filter` | 64 characters |
