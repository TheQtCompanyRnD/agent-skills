---
name: qt-qml-docs
description: >-
  Guides QML API documentation using QDoc — writing QDoc comments
  for QML types, properties, signals, and methods, creating
  module documentation, and including code examples. Use when
  writing or improving documentation for QML components or APIs.
license: LicenseRef-Qt-Commercial OR BSD-3-Clause
compatibility: >-
  Designed for Claude Code, GitHub Copilot, and similar agents.
disable-model-invocation: false
metadata:
  author: qt-ai-skills
  version: "0.1"
  qt-version: "6.x"
  category: process
---

# Qt QML Docs

TODO: This skill is a placeholder. Content to be developed.

## Intended Scope

QDoc documentation patterns for QML APIs:

- **QDoc comment syntax** — `/*! */` blocks, `\qmltype`,
  `\qmlproperty`, `\qmlsignal`, `\qmlmethod` commands
- **Type documentation** — `\brief`, `\since`, `\inqmlmodule`,
  inherits/instantiates, detailed descriptions
- **Property documentation** — default values, valid ranges,
  binding behaviour, related properties
- **Signal documentation** — parameter descriptions, when
  emitted, handler naming conventions
- **Method documentation** — parameter/return documentation,
  usage examples, error conditions
- **Code examples** — `\snippet`, `\code`/`\endcode`, inline
  examples, example project structure
- **Module documentation** — `\qmlmodule`, module-level
  overview pages, import statements
- **Cross-references** — linking between types, linking to
  C++ counterparts, `\sa` (see also)
- **Documentation style** — Qt documentation conventions,
  active voice, present tense, audience awareness
- **Common LLM mistakes** — using Doxygen syntax instead of
  QDoc, missing `\qmltype` declarations, wrong module
  references, undocumented signals
