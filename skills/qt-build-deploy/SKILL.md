---
name: qt-build-deploy
description: >-
  Guides Qt build system configuration and deployment workflows —
  CMake setup, cross-compilation, platform-specific packaging,
  CI integration, and installer creation. Use when configuring
  CMakeLists.txt for Qt projects, setting up cross-compilation,
  integrating static analysis, or packaging applications for
  distribution.
license: BSD-3-Clause
compatibility: >-
  Designed for Claude Code, GitHub Copilot, and similar agents.
disable-model-invocation: false
metadata:
  author: qt-ai-skills
  version: "0.1"
  qt-version: "6.x"
---

# Qt Build & Deploy

TODO: This skill is a placeholder. Content to be developed.

## Intended Scope

- **CMake for Qt 6** — `qt_add_executable`,
  `qt_add_qml_module`, `qt_add_resources`, target properties
- **Cross-compilation** — Android (Gradle + CMake), iOS,
  WebAssembly (Emscripten), toolchain files
- **Dependency management** — Qt module dependencies,
  third-party library integration
- **Desktop packaging** — `windeployqt`, `macdeployqt`,
  `linuxdeployqt`, AppImage, DMG, MSI
- **Mobile deployment** — APK/AAB signing, iOS provisioning,
  platform-specific manifests
- **WebAssembly** — Emscripten toolchain, Qt for WebAssembly
  specifics, asset loading
- **CI integration** — integrating linters, static analyzers
  (clang-tidy, clazy), and automated checks into build
  pipelines
- **Test execution** — CTest integration, headless test runs,
  platform-specific test considerations
