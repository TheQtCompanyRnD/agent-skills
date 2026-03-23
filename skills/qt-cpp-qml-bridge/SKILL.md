---
name: qt-cpp-qml-bridge
description: >-
  Guides correct C++ to QML integration patterns — type
  registration, Q_PROPERTY, Q_INVOKABLE, QML_ELEMENT, ownership
  across the boundary, and model exposure. Use when exposing C++
  classes to QML, creating backends for QML UIs, or debugging
  C++/QML integration issues.
license: BSD-3-Clause
compatibility: >-
  Designed for Claude Code, GitHub Copilot, and similar agents.
disable-model-invocation: false
metadata:
  author: qt-ai-skills
  version: "0.1"
  qt-version: "6.x"
---

# Qt C++/QML Bridge

TODO: This skill is a placeholder. Content to be developed.

## Intended Scope

Common LLM failure points when integrating C++ with QML:

- **Registration patterns** — `QML_ELEMENT` /
  `QML_NAMED_ELEMENT` (Qt 6) vs deprecated `qmlRegisterType`
- **Q_PROPERTY** — correct NOTIFY signals, READ/WRITE
  accessors, binding-friendly patterns
- **Q_INVOKABLE** — when to use vs signals/slots vs properties
- **Ownership semantics** — QML vs C++ ownership, preventing
  dangling pointers and double-deletes
- **Model exposure** — QAbstractListModel subclassing,
  roleNames, proper data change signals
- **Enum exposure** — Q_ENUM, QML_UNCREATABLE for enum-only
  types
- **Singleton patterns** — QML_SINGLETON vs engine singleton
  functions
- **CMake integration** — `qt_add_qml_module`, import paths,
  plugin targets
