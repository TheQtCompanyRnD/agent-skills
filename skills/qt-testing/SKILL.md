---
name: qt-testing
description: >-
  Guides Qt testing strategy and implementation — Qt Test
  framework, QML testing, Google Test integration, mocking
  patterns, and testing in specialized environments. Use when
  writing tests for Qt applications, setting up test
  infrastructure, or deciding what and how to test.
license: BSD-3-Clause
compatibility: >-
  Designed for Claude Code, GitHub Copilot, and similar agents.
disable-model-invocation: false
metadata:
  author: qt-ai-skills
  version: "0.1"
  qt-version: "6.x"
---

# Qt Testing

TODO: This skill is a placeholder. Content to be developed.

## Intended Scope

- **Test strategy** — what to unit test vs integration test in
  Qt apps, testing signal/slot connections
- **Qt Test (QTest)** — test macros, data-driven tests,
  benchmarking, GUI testing with QTest
- **QML testing** — TestCase, SignalSpy, creating test harnesses
  for QML components
- **Google Test** — integrating GTest with Qt projects,
  parameterized tests
- **Mocking** — mocking Qt classes, network replies, database
  access, time-dependent tests
- **Specialized environments** — testing on embedded targets,
  mobile devices, WebAssembly, and headless environments
- **Integration and system testing** — end-to-end test patterns
  for Qt applications across platform boundaries

Note: Build-level test execution (CTest, CI runners, headless
setup) is covered in the `qt-build-deploy` skill.
