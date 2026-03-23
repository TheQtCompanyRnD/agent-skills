---
name: qt-qml
description: >-
  Corrects common LLM mistakes with the QML language and runtime —
  binding preservation, declarative vs imperative patterns, scoping
  rules, module system, JavaScript integration, and type coercion.
  Use when writing or reviewing QML code, working with .qml files,
  or debugging QML runtime behaviour.
license: LicenseRef-Qt-Commercial OR BSD-3-Clause
compatibility: >-
  Designed for Claude Code, GitHub Copilot, and similar agents.
disable-model-invocation: false
metadata:
  author: qt-ai-skills
  version: "0.1"
  qt-version: "6.x"
  category: conceptual
---

# Qt QML

TODO: This skill is a placeholder. Content to be developed.

## Intended Scope

Core mental model corrections for LLMs working with QML:

- **Declarative over imperative** — prefer property bindings,
  avoid `Component.onCompleted` for state setup
- **Binding preservation** — never break bindings with imperative
  `=` assignment unless intentional; use `Qt.binding()` to restore
- **Scoping rules** — QML context scope, component scope, id
  resolution, attached properties
- **Module system** — QML imports, versioning, singleton pragmas,
  qualified imports, directory imports
- **JavaScript integration** — inline JS expressions, `.js`
  library imports, WorkerScript, type coercion between JS and
  QML/C++ types
- **Type system** — basic types, object types, value types,
  var properties, type assertions
- **State machines** — use `State`/`Transition` instead of
  if/else chains for UI state
- **Component patterns** — correct use of Loader, Repeater,
  delegates, inline vs file components
- **Object ownership** — QML parent-child lifecycle, JS-created
  object pitfalls
- **Context properties vs singletons** — prefer
  `pragma Singleton` or `QML_SINGLETON`, context properties
  are deprecated
