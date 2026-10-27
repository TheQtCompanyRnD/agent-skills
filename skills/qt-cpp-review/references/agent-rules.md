# Qt6 C++ Review -- Deep-Analysis Agent Rules

Semantic checks that need symbol tracing, control-flow reasoning or
cross-file context and therefore cannot be expressed as linter
regexes. Grouped by review mission. Each agent loads this file itself,
in the same `cat` as its source files, and applies **only the
section(s) named in its prompt**. Agents must not load the checklists
other than `qt-framework-checklist.md` in framework mode.

Anything the linter already reports is deliberately absent here. Where
the linter catches only the single-line mechanical form of a rule, the
agent entry says so and covers the remaining forms. Agents receive the
lint summary and must not re-report those lines.

Rule IDs in parentheses refer to `qt-review-checklist.md`.

**Analysers.** When the prompt says the analysers ran, skip the parts
tagged `[CT:<check>]` (clang-tidy ran) or `[CZ:<check>]` (clazy ran),
except in the files the prompt lists as not analysed. Do not re-report
the tools' `CT:`/`CZ:` rows, and do not second-guess a tool's silence.

## Confidence and output format

Score every candidate 0-100. Report 80 and above as findings, 60-79
as investigation targets (the orchestrator keeps at most 10 in total),
and drop anything below 60.

- **80-100**: the defective code path is visible in the loaded source,
  or confirmed by a Grep anywhere under the root. Documented Qt API
  behaviour counts as confirmed. Running the code is never required,
  and "this is example code" or "the input may never occur" does not
  lower the score when the input is user, file or network data.
- **60-79**: whether it is a defect depends on something you cannot
  see: callers outside the root, QML, server behaviour, or intent.
- **Below 60**: a suspicion with no supporting code path. Return the blocks below verbatim so the
orchestrator can merge them without rewriting; use the mission name
of your section as the category. If you found nothing, say so in one
line.

```
#### [D-NNN] <Short title>
- **File**: `path/to/file.cpp:42`
- **Category**: <mission name>
- **Confidence**: NN/100
- **Finding**: <what is wrong>
- **Trace**: <symbols followed, what was checked>
- **Mitigation**: <what to do, in prose — no code patches>

#### [I-NNN] <Short title>
- **File**: `path/to/file.cpp:42`
- **Category**: <mission name>
- **Confidence**: NN/100
- **Finding**: <what is suspected>
- **Unverified because**: <what could not be confirmed>
- **How to verify**: <specific action for the reviewer>
```

---

## A1. Model Contracts (QAbstractItemModel)

- **Begin/end balance across code paths** (MDL-6). The linter counts
  begin/end pairs per function; the agent follows early returns,
  exceptions and conditional branches to find a path that emits one
  without the other, or performs a structural change with no signal
  at all. `layoutChanged` is not a substitute for insert/remove.
- **`roleNames()` versus `data()`** (MDL-8). Every role returned by
  `roleNames()` needs a case in `data()`; a missing case silently
  returns an invalid `QVariant`.
- **`setData()` returning true without `dataChanged`** (MDL-3), or
  emitting it with the wrong index or roles.
- **Proxy and filter models bypassing the source API** (MDL-9):
  reaching into raw structs or containers instead of `data()` and
  `index()`, or indexing filtered containers with source-model row
  numbers (wrong index space).
- **`roleNames()` rebuilt on every call** (MDL-10). Cache the hash
  in a static local or member.
- **Contract violations the linter cannot see**: `beginRemoveRows`
  with `first > last` on a multi-line call, `flags()` handing out
  `ItemIsEditable` for read-only node types, `index()` returning
  indexes for out-of-range rows.

## A2. Ownership & Lifecycle

- **Raw `new` with no owner**: no `delete`, `deleteLater()`, parent
  or smart pointer anywhere on the object's paths (Rule of Five). The
  linter flags `new QObject` without a parent argument on one line;
  the agent covers non-QObject types and ownership handed off later.
- **Polymorphic classes** (PLY-2 to PLY-6): missing virtual
  destructor `[CT:cppcoreguidelines-virtual-class-destructor]`,
  missing `Q_DISABLE_COPY_MOVE` `[CZ:copyable-polymorphic]`,
  overrides changing default arguments or access level, virtual
  marked by more than one of `virtual`/`override`/`final`
  `[CT:modernize-use-override]`.
- **RAII and special member functions** (RAI-2, RAI-3, SMF-1,
  SMF-6): copyable resource handles, move-assignment not via
  move-and-swap, copy or move constructors implemented through
  assignment.
- **`QObject::connect()` with a possibly null sender or receiver**
  outside a null guard (runtime warning, silent no-op).
- **Dangling tracking lists**: members such as "recently used"
  lists holding raw pointers to objects deleted elsewhere.
- **Destructor completeness** beyond the mechanical `qDeleteAll`
  check: grandchildren, detached workers, registered callbacks.
- **Abstract interfaces with a single implementation** (codebase
  scope only, YAGNI). Report as investigation target unless the
  whole codebase is in scope.

## A3. Thread Safety

- **QObject members written from `QtConcurrent::run()` or a
  `QThread` worker** without mutex, atomic or queued invocation
  (THR-1).
- **Signals emitted from worker threads with `Qt::DirectConnection`**
  or an explicitly non-queued connection to main-thread receivers
  (THR-2).
- **Model mutation from a background thread** (THR-3), including
  through helper methods called from a worker.
- **Shared containers protected inconsistently** (THR-4): locked on
  some paths, unlocked on others. Trace every access to the member.
- **Non-atomic shared counters** (THR-5): `++`, `--` or
  read-modify-write on plain integers touched by more than one thread.
- **QObject operations from a non-owner thread**: starting or
  stopping a `QTimer`, calling `setParent`, touching widgets.

## A4. API, Naming & C++ Correctness

- **Naming consistency with similar Qt classes** (API-3): `timeout`
  not `timeOut`, `size()` not `count()` for new API.
- **Non-const getters**, in particular `Q_PROPERTY READ` accessors
  (undefined behaviour through the meta-object system) and any method
  that does not modify state.
- **`const` method returning a mutable pointer** so callers mutate
  through a const accessor.
- **Move semantics** (MOV-1, MOV-2): missing `std::forward` on
  forwarding references, `const` locals that prevent implicit move on
  return, undocumented moved-from state. The linter only catches
  literal `return std::move(x)`.
- **`noexcept` correctness** (NXC-1 to NXC-3): a `noexcept` function
  with a visible throwing path (allocation, precondition-style
  `Q_ASSERT`, callee that throws). The linter flags `noexcept` plus
  `Q_ASSERT` on one line; anything needing a callee trace belongs
  here, and unclear precondition-versus-invariant cases are
  investigation targets.
- **Enum hygiene the linter cannot judge**: missing trailing comma
  (ENM-1), `switch` over an enum with a `default:` label outside
  `data()` (ENM-7), a project-owned vocabulary held in a `QString`
  such as `mode == "dark"` (ENM-8), a single `bool` parameter whose
  call site does not read (ENM-9, the linter handles two or more
  bools and bool literals), an enum duplicated per class instead of
  centralised in a `Q_NAMESPACE` (ENM-10).
- **Return paths** (RET-2): named and unnamed returns mixed in one
  function, defeating NRVO. Flag only when visible in the source.
- **Operators, lambdas, templates** (OPR-1 to OPR-3, LAM-1 to LAM-4,
  TPL-1, TPL-5): operators not hidden friends, equality and `qHash`
  out of step, fuzzy floating-point comparison in relational
  operators, unnamed non-trivial lambdas, explicitly specified
  deducible template arguments.
- **Properties and QObject layout** (PRP-1, PRP-3, QOB-1, QOB-4):
  missing `FINAL` on new `Q_PROPERTY`, property shadowing a
  meta-method name, missing `Q_OBJECT` `[CZ:missing-qobject-macro]`,
  non-idiomatic member order.
- **`const QMetaObject::Connection`** preventing later disconnect.
- **Duplicated validation logic** across classes.
- **Tests** (TST-1 to TST-3) when test files are in scope.

## A5. Error Handling & Validation

- **Multi-line forms of the mechanical checks**: `QFile::open()`,
  `QJsonDocument::fromJson()`, `QNetworkReply::error()` and
  `QXmlStreamWriter::hasError()` checked on a later line or not at
  all. The linter only sees the single-line pattern. A discarded
  `QFile::open()` result (and that of the other checked functions)
  `[CT:bugprone-unused-return-value]`; results stored and never
  checked, and the `fromJson()`/`error()`/`hasError()` forms stay
  here.
- **Negative values accepted where only positive are valid**
  (ERR-8): timer intervals, sizes, counts validated against zero only.
- **Imported or downloaded data used without schema or version
  validation** (ERR-10) and without length limits (ERR-11).
- **Success reported regardless of I/O outcome**: a save routine
  returning true after a failed write or flush.
- **Inconsistent error reporting** (ERR-12): one class mixing
  return-bool, error-member and signal patterns.
- **Swallowed errors**: empty catch blocks, ignored `[[nodiscard]]`
  results through a cast, logging without propagating.

## A6. Performance & Code Quality

- **Non-const `operator[]` on a shared `QHash` or `QMap` for a read**
  (PRF-4), which detaches. Use `value()`. `[CZ:detaching-member]`
- **Expensive work before a cheap early-exit check** (PRF-5).
- **Dead code** (PRF-6): unreachable branches given preconditions,
  methods with no callers in scope, members maintained but never
  read. Report as investigation target when callers may exist
  outside the reviewed scope.
- **Magic numbers** without named constants (PRF-7), where the value
  carries meaning.
- **Stale member caches** not invalidated when the underlying data
  changes (PRF-9).
- **Missing re-entrancy guard** on methods that emit signals which
  can call back into the same object (PRF-10).
- **`QMap`/`QHash` iteration order used to pick a "first" or "best"
  entry** without a deterministic tie-break.
- **Containers returned by value from hot paths** where a const
  reference or cached member would avoid the deep copy.
- **Setters with hidden side effects**: resetting unrelated state
  without a change signal, early returns that skip status or signal
  updates.
- **God classes and copy-pasted logic**: single-responsibility
  violations and near-identical code blocks across classes.

---

## Framework mode additions

When framework mode is active, the prompt names
`qt-framework-checklist.md` as well. Agents covering A2 or A4 load it
in the same `cat` and apply its sections as mapped here:

| Framework section | Append to |
|---|---|
| Value Classes, Polymorphic, QObject Subclasses, RAII, Special Member Functions | A2 |
| API Design, Public Headers, Includes, Variables, Methods, Properties, Documentation, Enums, Namespaces, Templates, Relational Operators, Conditional Compilation, QML Module Versioning | A4 |
| Commit Message | orchestrator only, diff scope |

---

Copyright (C) 2026 The Qt Company.
