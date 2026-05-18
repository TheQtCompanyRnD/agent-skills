# Getting started


This article explains how to install the Qt skills into your AI tool of
choice, invoke the skills, and verify that the skills are actually used.

## 1. Install

To install agent skills to your AI tool:

=== "Claude Code"

    ```
    /plugin marketplace add TheQtCompanyRnD/agent-skills
    /plugin install qt-development-skills
    ```

    Claude Code automatically discovers the skills, so no restart needed.
    The Claude Code plugin install also wires up the Qt Documentation
    MCP server in the same step.

=== "Codex CLI"

    ```bash
    npx skills add TheQtCompanyRnD/agent-skills
    ```

    Restart Codex after installation. MCP setup is separate —
    see [Manual setup](mcp/setup-manual.md#openai-codex).

=== "Gemini CLI"

    ```bash
    gemini extensions install https://github.com/TheQtCompanyRnD/agent-skills
    ```

=== "GitHub Copilot CLI"

    ```
    copilot plugin marketplace add TheQtCompanyRnD/agent-skills
    copilot plugin install qt-development-skills@qt-skills-and-tools
    ```

See the project
[README](https://github.com/TheQtCompanyRnD/agent-skills#installation)
for manual install, VSCode agents setup, and per-skill symlinking options.

## 2. Invoke your first skill

Open a project containing Qt code, then ask the agent to do
something a skill is designed for. Trigger phrases are
defined in each skill's `description` — the agent matches your
request against them.

Examples to try (substitute a real file path):

> "Review my QML changes in `Main.qml` before I commit."

> "Document this class — `src/network/RequestQueue.h`."

> "Profile this app and find what's making the UI feel laggy:
> `build/myapp.exe`"

The agent will load the matching skill, follow its workflow, and
report back.

## 3. Verify it actually fired

Skills load on demand. A request that *sounds* relevant doesn't
guarantee activation. Look for these signals:

- **Claude Code** — a `Skill` tool invocation appears in the
  transcript with the skill name, for example
  `qt-development-skills:qt-qml-review`. Without it, the model
  answered from general knowledge.
- **Codex CLI** — the skill appears in the loaded-skills list at
  session start, and the agent quotes its workflow steps.
- **Gemini CLI** — the extension is listed under
  `gemini extensions list` and the agent references `@SKILL.md`
  context.

If the right skill didn't fire, see
[Why a skill didn't activate](skills/concepts.md#troubleshooting).

## 4. Verify the MCP server

Ask the agent something only fresh Qt 6.11 documentation can
answer:

> "Using the Qt 6.11 docs, what's the default value of
> `QQuickWindow::persistentGraphics`?"

A working MCP server returns a `qt_documentation_search` tool
call and a precise answer with a doc link. A missing server
results in either a hedged guess or a refusal to consult docs.

Per-client troubleshooting lives in
[MCP → Verifying](mcp/verifying.md).

## Next steps

- [How skills are triggered and what they look like inside](skills/concepts.md)
- [What MCP is and why our server exists](mcp/index.md)
- [Contributing a new skill](https://codereview.qt-project.org/plugins/gitiles/qtai/qtaiskills/+/refs/heads/dev/CONTRIBUTING.md)
