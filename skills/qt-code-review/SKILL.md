---
name: qt-code-review
description: >-
  Provides Qt-specific code review checklists and anti-pattern
  detection — common mistakes, performance pitfalls, API misuse,
  and quality gates. Use when reviewing Qt/QML/C++ code,
  performing pre-merge checks, or auditing existing Qt codebases.
license: BSD-3-Clause
compatibility: >-
  Designed for Claude Code, GitHub Copilot, and similar agents.
disable-model-invocation: false
metadata:
  author: qt-ai-skills
  version: "0.1"
  qt-version: "6.x"
---

# Qt Code Review

TODO: This skill is a placeholder. Content to be developed.

## Intended Scope

- **QML anti-patterns** — broken bindings, imperative overuse,
  anchor/layout mixing, deep nesting
- **C++ anti-patterns** — missing NOTIFY signals, wrong
  ownership, signal/slot connection errors
- **Performance checklist** — unnecessary re-evaluations, heavy
  delegates, missing shader caching
- **API misuse** — deprecated APIs, Qt 5 patterns in Qt 6 code,
  wrong thread usage
- **Memory & lifecycle** — parent-child ownership violations,
  leak patterns, QPointer usage
- **Security** — untrusted input in QML, SQL injection via
  Qt SQL, insecure network usage
