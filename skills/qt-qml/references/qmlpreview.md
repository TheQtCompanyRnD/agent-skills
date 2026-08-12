# QML Live Preview via MCP

Reference for the QML Preview MCP server — a hot-reload tool that
pushes QML source edits into an already-running Qt Quick application,
so UI iteration does not require a rebuild.

---

## What the server does

- Exposes a single tool — commonly named `run_qmlPreview` — taking one
  required argument, `executable_path` (absolute path to the built
  application binary).
- Launches that binary with
  `-qmljsdebugger=file:<socket>,block,services:QmlPreview,CanvasFrameRate,EventReplay`
  and serves QML files to it over the QML debug connection.
- Watches every file it serves. On a write, it resends the file and
  triggers a reload after a ~100 ms debounce (so rapid successive
  saves coalesce into one reload).
- Requests **in-place updates** (hot reload; usually preserves UI state).
  If the running engine reports a hot-reload failure, the server kills
  and relaunches the app, then replays recorded input events.

---

Two preconditions are already settled before this file is read — `qt-qml`
only points here when a `run_qmlPreview` tool is connected *and* the project's
Qt resolves to 6.12 or newer. Take them as given rather than re-deriving them,
and keep the version you found to hand: the offer in step 2 rests on it.

The three steps below run in order, **once per session, not once per edit** —
re-checking on every change turns a helpful check into nagging.

---

## 1. Check `QT_QML_DEBUG` on the executable's target

The `-qmljsdebugger` argument is only honoured if the application was
**compiled** with `QT_QML_DEBUG` defined. Check the target that
produces the executable — not merely any target in the project — for
any of:

```cmake
target_compile_definitions(MyApp PRIVATE QT_QML_DEBUG)   # canonical
add_compile_definitions(QT_QML_DEBUG)                    # directory-wide
add_definitions(-DQT_QML_DEBUG)                          # legacy
```

or, for qmake projects, `DEFINES += QT_QML_DEBUG` / `CONFIG += qml_debug`,
or `-DQT_QML_DEBUG` in `CMAKE_CXX_FLAGS`.

**This is fixable in one line.** When the definition is missing, say so and
offer the exact line — but **ask before editing `CMakeLists.txt`**, and leave
the reconfigure and rebuild to the user unless they ask you to run
them. State the cost plainly: one reconfigure and one rebuild, after
which no further rebuilds are needed for QML edits. Prefer scoping the
definition to debug configurations:

```cmake
target_compile_definitions(MyApp PRIVATE $<$<CONFIG:Debug>:QT_QML_DEBUG>)
```

`QT_QML_DEBUG` opens a debug service that can load arbitrary QML into
the process. Never leave it enabled in a release or shipping build, and
flag it if you find it unscoped in a project that ships.

If the user declines the change, leave the tool alone and carry on with the
work as you would otherwise.

---

## 2. Offer the preview — starting one is the user's call

A satisfied precondition means a preview is *possible*, not that it is wanted.
Starting one launches the user's application, and only they know whether
that is welcome right now — they may be mid-demo, running the app against
real hardware, or simply happy to rebuild. A connected server is an
option, not an instruction.

So once `QT_QML_DEBUG` is in place, ask before editing anything. Say what the offer
rests on — the Qt version the build resolves to, and that `QT_QML_DEBUG`
is defined — and that starting the preview will launch their application.
Keep it to one clear question: they are deciding whether to start a
preview, not auditing your evidence, so don't turn each precondition into
its own question.

If the project creates more than one `QQmlEngine`/`QQmlApplicationEngine`,
or loads QML on a worker thread, mention that live preview is unreliable
there before offering it.

**Then stop and wait.** Do not call the tool, and do not start editing,
in the turn where you offer — an offer the user had no chance to decline
is not an offer, it is a notification.

**If they say yes**, start the preview first, then make the edits. That
order is the whole point: with the preview already running, each change
appears in their application as it is saved. Editing first would hand
them a finished result instead of letting them watch it arrive, which is
what they agreed to.

**If they say no**, or reply about the work without mentioning the
preview, make the edits and call no tools. Don't raise it again that
session.

---

## 3. Run the session

**Call the tool once per session**, passing `executable_path` — the absolute
path to the built binary, not the project directory and not a QML file. The
file watcher handles everything after that: edit, write to disk, done. Do not re-call it after every
edit — the server handles the edits and reloads by itself.

**The exception is recovery.** If the user reports that edits have
stopped showing up, rerunning the tool is the right move: hot reload has
limits, and some changes simply do not survive it. Say that the app needs to be
restarted, ask for user's permission before calling the tool again.

After starting, the correct loop is:

1. Edit QML files and write them to disk.
2. Tell the user what changed and ask them to confirm what they see.
3. Iterate.

**Never assert that the UI updated.** You cannot see the window, and
the server's status and error output goes to its own stderr where you
cannot read it. Report what you changed; let the user report the
result.

---

## Reference: diagnosing from user reports

| User reports | Likely cause |
|---|---|
| Edits do nothing / changes not visible | Could be a qmlpreview limitation rather than a mistake — not every change survives hot reload. Rerun the tool to restart the preview (warn that the app restarts). |
| App window never appears / seems hung | Preview never connected; the `block` flag makes the app wait for the debug connection |
| App restarted | Hot-reload failure — the server relaunched and replayed input events. Expected for structural edits |

## Reference: edits with special handling

**Needs a rebuild — say so before making the edit, not after:**

- Any C++ change — sources, headers, registered types, exposed
  properties.
- `qmldir` changes, QML module URI or version changes, singleton
  registration changes.
- `CMakeLists.txt` changes, including adding a file to a module.
- New imports of modules the binary does not already link.
- **New QML files**, when the project compiles its QML into resources —
  a file created after the build is not part of the built application.
  When QML is loaded from the filesystem, a new file *does* work as soon
  as something already loaded references it.

**May patch but lose state — mention it, and if the user says the change
didn't show up, tell them to ask for a rerun:**

- Converting a plain value to a script binding, or the reverse.
- Moving a binding from one property to another.
