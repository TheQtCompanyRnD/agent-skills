---
name: qt-cpp-review
description: >-
  Invoke when the user asks to review, check, audit, or look
  over Qt6 C++ code — or suggest before committing. Runs
  deterministic linting (60+ rules) then deep-analysis agents
  (scaled to the size of the change) covering model
  contracts, ownership, threading, API correctness, error
  handling, and performance. Optionally runs clang-tidy and
  clazy from the Qt installation. Reports only high-confidence
  issues (>80/100) with structured mitigations. Read-only —
  never modifies code.
license: LicenseRef-Qt-Commercial OR BSD-3-Clause
compatibility: Designed for Claude Code, GitHub Copilot, and similar agents.
disable-model-invocation: false
metadata:
  author: qt-ai-skills
  version: "3.1"
  qt-version: "6.x"
  category: review
argument-hint: "[framework] [analyse]"
---

# Qt Code Review

Read-only review of Qt6 C++ code: a deterministic Python linter
first, then agent-driven deep analysis across six rule domains,
then one consolidated report.

## When to use this skill

- Review-related requests: "review", "check", "audit", "look over",
  "code review", "sanity check"
- Suggest it **before committing** code

## Arguments

- `/qt-cpp-review` — universal Qt6 C++ rules
- `/qt-cpp-review framework` — also apply Qt framework/module rules
  (binary compatibility, exports, d-pointers, qdoc, QML versioning)
- `/qt-cpp-review analyse` — also run clang-tidy and clazy; combines
  with `framework`

## Framework mode

Enable when `$ARGUMENTS` contains "framework". Otherwise, if the
lint run or a quick Grep shows **two or more** of these signals,
suggest framework mode to the user but do not enable it yourself:
`QT_BEGIN_NAMESPACE`, any `Q_*_EXPORT` macro, `<QtModule/private/*_p.h>`
includes, `Q_DECLARE_PRIVATE`/`Q_D()`/`Q_Q()`, `qt_internal_add_module`
in CMakeLists.txt, `sync.profile` or `.qmake.conf` at the repo root.

When enabled: pass `--framework` to the linter, and name
`references/qt-framework-checklist.md` in the prompts of the agents
covering A2 or A4 (they apply it as mapped at the end of
`agent-rules.md`). In diff scope, also check the commit message
against the FW-CMT rules yourself; load only that section with
`sed -n '/^## Commit Message/,$p' references/qt-framework-checklist.md`.

## Scope detection

**Diff scope** — "this commit", "these changes", "the diff", "what
I changed", "staged changes", "before I commit". The range is `HEAD`
(working tree plus index), `--cached` for staged changes only, or
`HEAD~1..HEAD` for "this commit". Do not load the diff itself: the
linter's `--diff` mode (Phase 1) lists the changed files with their
changed-line counts and reports only findings on changed lines.

**Codebase scope** — "review the codebase", "audit src/", or an
explicit path with no commit language. Glob `*.cpp`, `*.h`, `*.hpp`
under the path.

## Token budget rules

These rules exist to keep the review cheap. Follow them.

1. **Do not load the reference files into the main context.** Agents
   read `references/agent-rules.md` themselves; you pass its absolute
   path and the section IDs. Only an inline run (Phase 2) reads it
   in the main context. Lint messages are self-describing; the
   checklists are for humans.
2. **Pass lint results in `--summary` form** (grouped by rule, paths
   relative to a root printed once), never the raw per-line listing.
3. **Point agents at content, never paste it.** Every token you write
   into a prompt is output on the orchestrating model, the most
   expensive tokens in the review. Prompts carry paths, commands and
   section IDs; the agents load the rules, the files and the diff.
   In diff scope an agent gets the `git diff -U50 <range> -- <files>`
   command instead of the hunks, and reads other files only to trace
   a specific symbol.
4. **Scale the agent count to the scope** (see Phase 2). Launch no
   agents for a small scope and split a large one into shards of about
   equal line count.
5. **Use the dedicated review agent where the harness has one.** If the
   `cpp-review-agent` definition (listed as
   `qt-development-skills:cpp-review-agent` when installed with the
   plugin, plain `cpp-review-agent` when copied by hand) is available,
   launch the agents with it (read-only, tools limited to Read, Grep,
   Glob and read-only Bash); otherwise
   use the harness's general-purpose agent. The definition lives in the
   plugin's `agents/` directory, outside this skill, so it is missing
   when the skill was copied on its own or the harness does not install
   `agents/`. Then add one line to each prompt: read-only (Bash only for
   `cat`, `grep`, `awk`, `git diff`, `git show`); take `file:line` from
   the printed numbers; in diff scope do not re-read the files; Grep
   or Read other files only to trace a symbol; prefer few confirmed
   findings over many guesses.

## Execution order

Never skip a phase.

### Phase 1: Deterministic linting

```bash
# codebase scope
python3 <skill>/references/lint-scripts/qt_review_lint.py --summary [--framework] [--analyse] <files...>
# diff scope, run inside the repository; no file arguments
python3 <skill>/references/lint-scripts/qt_review_lint.py --summary [--framework] [--analyse] --diff=<range>
# fall back to `python` if python3 is not found
```

Python 3.7+, no dependencies. If Python is unavailable, warn and
continue (in diff scope, take the file list from
`git diff --stat <range>`). The linter is authoritative; do not second-guess its
output. Rule families: INC, DEP, PAT, MDL, ERR, LCY, API, ENM, TMO,
CND, VAL, HDR, TRN, VAR (60+ checks). Exit code 1 simply means
findings exist; 2 means a usage or git error.

In diff scope, line numbers refer to the end of the range. If a
`diff: ... working tree differs` status line is printed, copy it into
the report header, and read those files only through
`git diff -U50 <range>`, never from disk.

When `$ARGUMENTS` contains "analyse", add `--analyse` (and
`--build-dir=<dir>` if the user named one). It runs the Qt
installation's clang-tidy and clazy-standalone over the translation
units in scope, using a `compile_commands.json` it finds itself, and
merges their diagnostics as `CT:<check>` / `CZ:<check>` rows. Copy the
printed `clang-tidy:` / `clazy:` status lines into the report header
verbatim, never shortened; do not look for the tools or configure a
build yourself. If they say `skipped (no compile_commands.json; ...)`,
add one line below the header: to enable the analysers, either build
the project once in Qt Creator or configure it with CMake using
`-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` and build it, then re-run with
`analyse`; name the build folder with `--build-dir` if it is
elsewhere. The analysers are authoritative for type-level findings,
the linter for Qt policy
rules; the linter drops its rules they supersede on files they
covered and lists them in the `superseded` status line. Otherwise,
if `compile_commands.json` exists in the repo root, below `build*/`
or in a sibling `<repo>-build`/`<repo>_build`, suggest `analyse` to
the user in one line.

### Phase 2: Deep analysis (inline, or one agent per shard)

The six sections of `references/agent-rules.md` are the analysis.
Agents read it themselves; read it yourself only when running inline:

| Section | Mission |
|---|---|
| A1 | Model Contracts |
| A2 | Ownership & Lifecycle |
| A3 | Thread Safety |
| A4 | API, Naming & C++ Correctness |
| A5 | Error Handling & Validation |
| A6 | Performance & Code Quality |

Choose the fan-out from the scope size. Count the lines of the files
in scope (the changed lines in diff scope), taken from the lint
summary or `wc -l`. A block is about 2,500 lines; the line count
alone decides the split, never the number of files.

| Scope | Agents |
|---|---|
| Up to 2,500 lines | 0 (inline) |
| More than 2,500 lines | one per shard, `ceil(lines / 2500)` shards |

**Inline.** A small scope does not repay the cost of agents, which
each rebuild the context and roughly double the review's token cost
for the same findings. Do the analysis yourself: read
`references/agent-rules.md` and the files (or the diff) with the one
Bash call shown under the agent prompt below, and apply A1-A6 in a
single pass under the same rules, confidence thresholds and output
format. Do not re-report lint rows, and do not run inline above the
limit because the code looks simple. Report `Agents: 0 (inline)`.

**Shards.** Cut the files, in directory order, into
n = `ceil(lines / 2500)` shards of about `lines / n` lines each; how
many files a shard holds does not matter. Keep a directory in one
shard where it fits, so that a class's header and source, and the
models and views that reference each other, land together; split a
larger directory by file. A file larger than a shard gets a shard to
itself. Each shard agent applies all
six sections to its shard only and may Grep the whole scope to trace
a symbol. Run up to six shard agents at a time and the rest in a
second wave. Cross-shard checks (ownership, model contracts,
duplicated logic) are then best effort; say so in the report header.

Launch the agents in parallel, named after their shard
(e.g. "Review shard 2/6: src/models"). Keep each prompt short; it contains
only:

1. The absolute path of `references/agent-rules.md` and the section
   IDs to apply (A1-A6), plus the absolute path
   of `references/qt-framework-checklist.md` for A2 and A4 agents in
   framework mode
2. The root directory from the lint summary, the files in scope
   relative to it and, in diff scope, the
   `git diff -U50 <range> -- <files>` command for them, plus the
   files the `diff:` status line names, if printed, with the
   instruction to take their line numbers only from the diff
3. If the `superseded` status line is printed: the tools it names
   and the `not analysed` files in that agent's scope, with the
   instruction to skip those tools' `[CT:...]`/`[CZ:...]` tagged
   checks in the other files
4. The lint summary rows for that agent's own files only (a shard
   agent never needs the other shards' rows), with the instruction
   "do not re-report these lines"
5. The instruction to load everything with one Bash call before
   analysing, and to return findings in the format at the top of the
   rules file. Each tool call re-sends the agent's whole context, so
   one batched read instead of one Read per file is the single
   largest saving on large scopes. Both forms print per-file line
   numbers for the `file:line` locations (`cat -n` on several files
   numbers them as one run, and `git diff` has no line numbers):

   ```bash
   # codebase scope
   cd <root> && cat <rules> && for f in <files...>; do echo "== $f"; cat -n "$f"; done
   # diff scope; numbers context and added lines with the new-file line
   cd <root> && cat <rules> && git diff -U50 <range> -- <files> | awk '/^@@/{split($3,a,/[+,]/);n=a[2];h=1;print;next} /^diff /{h=0} h&&/^[ +]/{printf "%5d %s\n",n++,$0;next} {print}'
   ```

Agents are read-only and must never edit files. In tools without
agents, run each mission as whatever prompt chain or subprocess the
tool supports; the contract is the same.

### Phase 3: Consolidation

Merge lint and agent findings. Deduplicate on file+line+issue. When
duplicates disagree on confidence, keep the block with the highest
score and its trace; never average scores. An agent finding on the
same file and line as a `CT:`/`CZ:` row, about the same defect, is
dropped: the analyser wins. Write the report in the format below.

## Confidence scoring

| Confidence | Meaning | Action |
|---|---|---|
| 80-100 | Rule violation confirmed with a symbol trace | Finding |
| 60-79 | Likely, not fully verifiable (e.g. noexcept needing whole-program analysis, dead code with possible external callers) | Investigation target (max 10) |
| <60 | Suspicion only | Suppress |

## Output format

Use exactly this structure. Lint findings are grouped by rule with
one mitigation each; only deep-analysis findings get a full block.

```
## Qt Code Review Report

**Scope**: [diff: `git diff HEAD~1..HEAD` | files: <paths>]
**Files reviewed**: N
**Issues found**: N (M from lint (A from analysers), K from deep analysis)
**Agents**: N (shards ... | inline)
**Framework mode**: [on / off]
**Analysers**: [clang-tidy ran / skipped / not available / failed · clazy ...]

---

### Lint findings

| Rule | Count | Locations | Mitigation |
|---|---|---|---|
| LCY-2 QObject created with new but no parent | 3 | `main.cpp:12,40`, `widget.cpp:88` | Pass a parent or hold in a smart pointer. |
| CZ:old-style-connect (analyser) | 2 | `view.cpp:31,57` | Use the pointer-to-member connect syntax. |
| ... | | | |

---

### Deep analysis findings

#### [D-NNN] <Short title>
- **File**: `path/to/file.cpp:42`
- **Category**: <A1-A6 mission name>
- **Confidence**: NN/100
- **Finding**: <what is wrong>
- **Trace**: <symbols followed, what was checked>
- **Mitigation**: <what to do, in prose — no code patches>

---

### Investigation targets (human verification needed)

#### [I-NNN] <Short title>
- **File**: `path/to/file.cpp:42`
- **Category**: <A1-A6 mission name>
- **Confidence**: NN/100
- **Finding**: <what is suspected>
- **Unverified because**: <what could not be confirmed>
- **How to verify**: <specific action for the reviewer>

---

### Summary

| Category | Lint | Deep | Investigate | Total |
|---|---|---|---|---|
| ... | N | N | N | N |
| **Total** | **M** | **K** | **I** | **N** |

Findings below confidence 60 are suppressed.
```

## References

- `references/agent-rules.md` — agent missions A1-A6 and the agent
  output format (read by the agents, not the orchestrator)
- `references/qt-review-checklist.md` — universal rule IDs and
  rationale (human reference, not loaded during a review)
- `references/qt-framework-checklist.md` — framework rules (read by
  A2 and A4 agents in framework mode)
- `references/qt-deprecated-classes.md` — background for the DEP
  lint rules (human reference)
- `references/lint-scripts/qt_review_lint.py` — single-pass linter,
  `--summary` for grouped output, `--diff=<range>` for changed lines
  only, `--framework` for module rules, `--analyse` to merge
  clang-tidy and clazy (`references/lint-scripts/qt_analysers.py`,
  config in `references/analysers/`)
