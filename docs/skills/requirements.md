# Skills: requirements and platform support

The [skills overview](index.md) lists what each skill does. This
page lists what each skill needs on your machine, and which AI
tools can run it in full.

## Requirements

| Skill | Requirements |
|-------|--------------|
| `qt-cpp-review` | Python 3.6+ for the linter script. No external Python packages. |
| `qt-qml-review` | Python 3.6+ for the linter script. No external Python packages. Optional: `qmllint` from a Qt 6 installation for type checks. |
| `qt-qml-profiler` | A Qt 6 installation containing `bin/qmlprofiler`. CMake and a C++ toolchain (profiling mode only, to build with `-DQT_QML_DEBUG`). Python 3 for the trace parser. |
| `qt-qml-test` | Qt 6: the generated tests use unversioned `import QtQuick` and `import QtTest`. Existing QML components to test; the skill does not scaffold a project from nothing. |
| `qt-qml-test-run` | A Qt 6 installation containing `bin/qmltestrunner`. A CMake-based project (qmake is not supported). CMake 3.21 or newer and a C++ toolchain when building. Python 3 for the JUnit XML parser. |
| `qt-cmake-project` | Qt 6.8 or newer is a soft requirement: the skill's defaults assume the Qt 6.8 API. No script dependencies. |
| `qt-figma-token-extraction` | A Figma file with variables or text styles. The Figma MCP server, or a Figma Personal Access Token for REST API extraction. An existing CMake-based Qt 6 project, or agreement to create one. |
| `qt-figma-component-generation` | The Figma MCP server. `design-tokens.json` and the QML design-system singletons produced by `qt-figma-token-extraction`. |
| `qt-cpp-docs`, `qt-qml-docs`, `qt-ui-design` | No external dependencies. |

For background on what `qmlprofiler` measures and how each event
type is interpreted, see
[Profiling QML applications](https://doc.qt.io/qtcreator/creator-qml-performance-monitor.html)
in the Qt Creator documentation.

## Platform support

The review skills (`qt-cpp-review`, `qt-qml-review`) combine a
Python linter with parallel subagents. The full workflow runs on
Claude Code and Codex CLI. GitHub Copilot reads the same skill
directory, but it cannot run the linter or launch subagents, so
only the static guidance loads.

The condensed `platforms/windsurf.md` variants (for
`qt-cpp-review`, `qt-qml-review`, `qt-qml-docs` and `qt-qml`)
carry the highest-priority rules only. Expect less thorough
results than from the full skill.

`qt-qml-profiler` and `qt-qml-test-run` build and run binaries,
execute Python scripts and write report files. They need an agent
with shell access, such as Claude Code or Codex CLI. There are no
condensed variants, and GitHub Copilot and in-IDE assistants
without a build environment are not supported.

See [Installation](https://github.com/TheQtCompanyRnD/agent-skills#installation)
for where each tool expects the skill files.

## Report accumulation in qt-qml-test-run

Every normal run writes a timestamped
`build/tests/reports/test-report-*.md` and
`build/tests/reports/junit/qmltests-*.xml`. The skill never
rotates or deletes them, because later runs use the JUnit XML as
their prior-run baseline. Over time `build/tests/reports/` grows.

To limit this, pass `--no-report` on iterative runs. That skips
the Markdown report but keeps the small JUnit XML files, so the
baseline still works. You can also delete old reports by hand.
