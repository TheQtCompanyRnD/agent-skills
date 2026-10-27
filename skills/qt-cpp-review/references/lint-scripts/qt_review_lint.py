#!/usr/bin/env python3
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
"""
qt_review_lint.py — Data-driven single-pass Qt6 C++ linter.

Rules are defined as entries in typed tables (RULES_SIMPLE,
RULES_CONTEXT, RULES_FLAG) processed by a generic dispatch loop.
A small number of rules that require custom logic remain as
procedural code in scan_file().

Rule categories:
  INC  — Include ordering and usage
  DEP  — Deprecated class/pattern usage
  PAT  — Mechanical anti-pattern checks
  MDL  — QAbstractItemModel contract
  ERR  — Error handling and validation
  LCY  — Resource lifecycle
  API  — Naming conventions
  ENM  — Enum hygiene
  TMO  — Timeout types
  CND  — Conditional compilation
  VAL  — Value class conventions
  HDR  — Public header rules
  TRN  — Ternary operator

Usage:
    python qt_review_lint.py <file1.cpp> [file2.h ...]
    python qt_review_lint.py --files-from=- < filelist.txt
    python qt_review_lint.py --summary <files...>
    python qt_review_lint.py --summary --diff=HEAD~1..HEAD
    python qt_review_lint.py --summary --analyse [--build-dir=<dir>] <files...>

Output: FILE:LINE RULE-ID MESSAGE (one per line)
        With --summary: findings grouped by rule and message, with
        locations listed per file relative to a root printed once.
        Compact form intended for passing lint results to review agents.
        With --diff=<git diff args>: run inside a git repository; lints
        the C++ files changed by `git diff <args>` and reports only
        findings on added or modified lines. Takes no file arguments.
        The summary then also lists the changed files and line counts.
        Files are linted as they are at the end of the range, so line
        numbers match `git diff <args>` even when the working tree has
        changed since; the files that differ are named in a status line.
With --analyse (or --clang-tidy / --clazy for one tool): also runs
        clang-tidy and clazy-standalone from the Qt installation over the
        translation units in scope, using the compile_commands.json from
        --build-dir=<dir> or the usual build locations, and merges their
        diagnostics as CT:<check> and CZ:<check> rows. --clang-tidy=<path>,
        --clazy=<path>, --clang-tidy-config=<file> and
        --analyser-timeout=<seconds> tune that; the status of each tool
        is printed before the summary table. A missing tool or compile
        database is reported, not an error. Linter rules the tools
        supersede (qt_analysers.SUPERSEDED_RULES) are dropped on the
        files a tool analysed without failure. The tools compile the
        working tree, so with --diff their line numbers are mapped back
        to the end of the range, and diagnostics on lines edited since
        are dropped.
Exit code: 0 if no findings, 1 if findings found, 2 on usage or git
           errors.

Known limitations:
  - Interior lines of /* */ block comments that don't start with * are
    not skipped and will be linted as code.  A full tokenizer (or an
    in_block_comment state toggle) is needed to eliminate this class of
    false positives.
  - ERR-6 placeholder/arg-count checking only fires when both the
    placeholder (e.g. %2) and .arg() calls appear on the same source
    line.  Multi-line .arg() chains are not detected.
"""

from __future__ import annotations

import difflib
import os
import re
import shlex
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

import qt_analysers


# ---------------------------------------------------------------------------
# Data model
# ---------------------------------------------------------------------------

@dataclass
class Finding:
    file: str
    line: int
    rule: str
    message: str

    def __str__(self) -> str:
        return f"{self.file}:{self.line} {self.rule} {self.message}"


@dataclass
class Rule:
    """A single lint rule processed by the generic dispatch loop.

    Tier A (simple):  pattern + optional exclude, header_only
    Tier B (context): pattern + context_before/after + context_pattern
    Tier C (flag):    pattern + requires_flag / requires_no_flag
    """
    id: str
    pattern: re.Pattern[str]
    message: str
    exclude: re.Pattern[str] | None = None
    header_only: bool = False
    # Context checking (Tier B)
    context_before: int = 0
    context_after: int = 0
    context_pattern: re.Pattern[str] | None = None
    context_match_required: bool = True  # True = context pattern must be present to fire; False = must be absent
    scope_aware: bool = True  # Truncate context window at function-scope boundaries (column-0 closing brace)
    # File-level flag gating (Tier C)
    requires_flag: str | None = None
    requires_no_flag: str | None = None


# ---------------------------------------------------------------------------
# Compiled regex patterns
# ---------------------------------------------------------------------------

RE_COMMENT_LINE = re.compile(r"^\s*(//|/?\*)")
RE_SCOPE_BOUNDARY = re.compile(r"^}")

# INC
RE_INC6_QGLOBAL = re.compile(r'^\s*#\s*include\s+[<"].*qglobal\.h[>"]')
RE_INC1_BARE_QT = re.compile(r'^\s*#\s*include\s+<q[a-z].*\.h>')
RE_INC1_PREFIXED = re.compile(r'^\s*#\s*include\s+<Qt[A-Z]')
RE_INC3_QNN = re.compile(r'^\s*#\s*include\s+[<"]q(\d{2})([a-z][a-z_]*)')
RE_QT_INCLUDE = re.compile(r'^\s*#\s*include\s+<Qt')
RE_STD_INCLUDE = re.compile(
    r'^\s*#\s*include\s+<('
    r'algorithm|any|array|atomic|bitset|charconv|chrono|cmath|compare|complex|'
    r'concepts|condition_variable|coroutine|cstddef|cstdint|cstdio|cstdlib|'
    r'cstring|deque|exception|expected|filesystem|format|functional|future|'
    r'initializer_list|iomanip|ios|iosfwd|iostream|iterator|limits|list|'
    r'locale|map|memory|memory_resource|mutex|numeric|optional|ostream|'
    r'print|queue|random|ranges|ratio|regex|scoped_allocator|set|shared_mutex|'
    r'source_location|span|spanstream|sstream|stack|stacktrace|stdexcept|'
    r'string|string_view|syncstream|system_error|thread|tuple|type_traits|'
    r'typeindex|typeinfo|unordered_map|unordered_set|utility|valarray|'
    r'variant|vector|version)>'
)

# DEP
RE_DEP1_QSCOPED = re.compile(r'\bQScopedPointer\b')
RE_DEP2_QSHARED = re.compile(r'\bQSharedPointer\b')
RE_DEP2_EXCLUDE = re.compile(r'QSharedDataPointer')
RE_DEP3_QWEAK = re.compile(r'\bQWeakPointer\b')
RE_DEP4_FOREACH = re.compile(r'\b(Q_FOREACH|foreach)\s*\(')
RE_DEP5_QPAIR = re.compile(r'\bQPair\b')
RE_DEP6_QSDP = re.compile(r'\bQSharedDataPointer\b')
RE_DEP6_EXCLUDE = re.compile(r'QExplicitlySharedDataPointer')
RE_DEP7_QMINMAX = re.compile(r'\bq(Min|Max|Bound)\s*\(')
RE_DEP8_QPRINTF = re.compile(r'\bqv?s?n?printf\s*\(')
RE_DEP9_QATOMIC = re.compile(r'\b(QAtomicInt|QAtomicPointer)\b')
RE_DEP10_COUNT_LEN = re.compile(r'\.(count|length)\s*\(\s*\)')
RE_DEP10_EXCLUDE = re.compile(r'(QString|QByteArray|QStringView)')
RE_DEP11_DATETIME = re.compile(r'QDateTime\s*::\s*currentDateTime\s*\(')
RE_DEP11_EXCLUDE = re.compile(r'currentDateTimeUtc')
RE_DEP12_JAVA_ITER = re.compile(
    r'\bQ(List|Vector|Map|Hash|Set|LinkedList)(Mutable)?Iterator\b'
)
RE_DEP13_QCHAR = re.compile(r'(?<![:])\bQChar\s+[a-zA-Z_]')
RE_DEP13_EXCLUDE = re.compile(r'QChar::')

# PAT / HDR / API / ENM / TMO / CND / VAL / TRN
RE_HDR3_MINMAX = re.compile(r'std::(min|max)\s*\(')
RE_HDR3_MINMAX_SAFE = re.compile(r'\(std::(min|max)\)\s*\(')
RE_HDR3_LIMITS = re.compile(r'std::numeric_limits<[^>]+>::(min|max)\s*\(')
RE_HDR3_LIMITS_SAFE = re.compile(
    r'\(std::numeric_limits<[^>]+>::(min|max)\)\s*\('
)
RE_PAT1_OPT_VALUE = re.compile(r'\.value\s*\(\)')
RE_PAT1_OPT_CTX = re.compile(r'(optional|opt)')
RE_PAT2_OPT_DEFAULT = re.compile(
    r'std::optional<[^>]+>\s+[a-zA-Z_]\w*\s*;'
)
RE_PAT3_HOLDS_ALT = re.compile(r'std::holds_alternative')
RE_TRN3_BOOL = re.compile(
    r'\?\s*true\s*:\s*false|\?\s*false\s*:\s*true'
)
RE_PAT5_UNLIKELY = re.compile(r'Q_UNLIKELY.*q(Warning|Fatal|Critical)')
RE_TMO1_INT_TIMEOUT = re.compile(r'\b(int|qint64)\s+\w*([Tt]imeout|[Ii]nterval)')
RE_CND2_HASINC = re.compile(r'__has_include\s*\(\s*<[^Q]')
RE_VAL6_METATYPE = re.compile(r'Q_DECLARE_METATYPE\s*\(')
RE_PAT6_MAKEUNIQUE = re.compile(r'std::make_unique<\w+\[\]>')
RE_PAT7_QMAP = re.compile(r'(?<![a-zA-Z])QMap\s*<')
RE_PAT7_EXCLUDE = re.compile(r'QMultiMap')
RE_PAT8_QMAP_PTR = re.compile(r'(?<![a-zA-Z])QMap\s*<\s*\w+\s*\*')
RE_VAL5_QSWAP = re.compile(r'(?<![a-zA-Z])qSwap\s*\(')
RE_VAR3_DIRECT_INIT = re.compile(
    r'^\s*[a-zA-Z_][\w:]*\s+[a-zA-Z_]\w*\{'
)
RE_VAR3_COPY_INIT = re.compile(r'=\s*\{')
RE_VAR3_KEYWORDS = re.compile(
    r'\b(if|while|for|switch|return|class|struct|enum|namespace)\b'
)
RE_API5_GET = re.compile(
    r'\b(QString|int|bool|double|QVariant|QVariantMap|QStringList|'
    r'QList|QHash|QMap)\s+get[A-Z]\w*\s*\('
)
RE_API5_LEGIT = re.compile(
    r'(getColor|getFont|getDouble|getInt|getItem|getText|'
    r'getExisting|getOpen|getSave)'
)
RE_ENM2_UNSCOPED = re.compile(r'^\s*enum\s+[A-Z]\w*\s*\{')
RE_ENM2_CLASS = re.compile(r'enum\s+class')
RE_ENM2_TYPED = re.compile(r'enum\s+[A-Z]\w*\s*:')
RE_ENM9_BOOL_PARAMS = re.compile(
    r'\([^()]*\bbool\s+\w+[^()]*,[^()]*\bbool\s+\w+'
)
RE_ENM9_BOOL_ARGS = re.compile(
    r'[(,]\s*(?:true|false)\s*,\s*(?:true|false)\s*[),]'
)
RE_PAT9_QLIST_QSTR = re.compile(r'QList\s*<\s*QString\s*>')
RE_PAT10_RET_MOVE = re.compile(r'return\s+std::move\s*\(')
RE_PAT11_QREGEX = re.compile(r'QRegularExpression\s+[a-zA-Z_]')
RE_PAT12_NONCONST_REF = re.compile(
    r'for\s*\(\s*auto\s+\*\s*&|for\s*\(\s*auto\s*&[^&]'
)
RE_PAT14_SORT_STR = re.compile(r'std::sort.*QString')
RE_PAT14_SAFE = re.compile(
    r'(CaseInsensitive|localeAwareCompare|toLower|compare)'
)
RE_PAT15_NOEXCEPT = re.compile(r'\bnoexcept\b')
RE_QASSERT = re.compile(r'\bQ_ASSERT\b')

# MDL
RE_MDL2_EMPTY_ROLES = re.compile(
    r'dataChanged\s*\([^)]*,\s*\{\s*\}\s*\)'
)
RE_MDL4_BEGIN_REMOVE = re.compile(
    r'beginRemoveRows.*,\s*0\s*,\s*.*-\s*1'
)
RE_MDL5_EDITABLE = re.compile(r'ItemIsEditable')
RE_MDL5_CONDITIONAL = re.compile(r'(if|else|case|&&|\|\||\?)')
RE_LAYOUT_CHANGED = re.compile(r'layoutChanged\s*\(')
RE_BEGIN_INSERT = re.compile(r'beginInsertRows')
RE_END_INSERT = re.compile(r'endInsertRows')
RE_BEGIN_REMOVE = re.compile(r'beginRemoveRows')
RE_END_REMOVE = re.compile(r'endRemoveRows')
RE_BEGIN_MOVE = re.compile(r'beginMoveRows')
RE_END_MOVE = re.compile(r'endMoveRows')
RE_BEGIN_RESET = re.compile(r'beginResetModel')
RE_END_RESET = re.compile(r'endResetModel')
RE_ROLE_NAMES = re.compile(r'roleNames\s*\(')
RE_CASE_ROLE = re.compile(r'case\s+\w*Role')
RE_DEFAULT_CASE = re.compile(r'default\s*:')
RE_STRUCTURAL_MUT = re.compile(
    r'children\.(append|removeOne|removeAt|insert)|qDeleteAll|->children\.'
)

# ERR
RE_ERR1_OPEN = re.compile(r'(?:\.|->)open\s*\(')
RE_ERR1_IODEV = re.compile(
    r'QIODevice|ReadOnly|WriteOnly|ReadWrite|Append|Truncate'
)
# The call is a whole statement (file.open(...); d->file.open(...);), so
# nothing uses the result: not if/!, QVERIFY/QCOMPARE, assignment or return.
# A match inside parentheses is an if/for initializer: if (QFile f; f.open())
RE_ERR1_DISCARDED = re.compile(
    r'(?:^|;)\s*(?:[\w:]+(?:\([^()]*\))?\s*(?:\.|->)\s*)+open\s*\(')
RE_ERR2_FROMJSON = re.compile(r'QJsonDocument::fromJson')
RE_ERR2_VALID = re.compile(r'(isNull|isObject|isArray|isEmpty|\.error)')
RE_ERR3_READALL = re.compile(r'reply->readAll|reply->read\s*\(')
RE_ERR3_ERRCHECK = re.compile(
    r'(error\s*\(\)|NoError|isFinished|NetworkError)'
)
RE_ERR4_HTTP = re.compile(r'"http://[a-zA-Z]')
RE_ERR4_LOCAL = re.compile(r'(localhost|127\.0\.0\.1|::1|example\.test)')
RE_ERR6_MULTI_PH = re.compile(r'"%[^"]*%2')
RE_ERR6_ARG = re.compile(r'\.arg\s*\(')
RE_ERR6_PH = re.compile(r'%[0-9]+')
RE_ERR7_XML = re.compile(
    r'QXmlStreamWriter|xml\.writeStartDocument|xml\.writeEndDocument'
)
RE_ERR9_NAM = re.compile(r'QNetworkAccessManager')
RE_ERR5_REQ = re.compile(r'QNetworkRequest\s+[a-zA-Z_]')

# LCY
RE_LCY2_NEW_QOB = re.compile(
    r'new\s+(QTimer|QObject|QNetworkAccessManager)\s*\(\s*\)'
)
RE_LCY3_ASSERT_SIDE = re.compile(r'Q_ASSERT\s*\(')
RE_LCY3_EFFECTS = re.compile(
    r'(removeOne|removeAt|append|insert|erase|pop|push|'
    r'take|close|open|write|read|send|start|stop|abort)\s*\('
)
RE_LCY5_APPEND = re.compile(
    r'(m_\w+)\.(append|push_back|prepend)\s*\('
)
RE_LCY5_SHIFT = re.compile(r'm_(\w+)\s*<<')
RE_LCY6_QDELETEALL = re.compile(r'qDeleteAll\s*\(')
RE_DESTRUCTOR = re.compile(r'~[A-Z]\w*\s*\(')
RE_LCY4_ASSERT_PTR = re.compile(
    r'Q_ASSERT\s*\(\s*([a-zA-Z_]\w*)\s*\)'
)
RE_LOOP_CONSTRUCT = re.compile(r'(for\s*\(|while\s*\(|Q_FOREACH|foreach)')

# Pre-scan patterns for capped container detection (LCY-5)
RE_TRIM_CALL = re.compile(
    r'(m_\w+)\.(removeFirst|removeLast|removeAt|remove\s*\(|'
    r'takeLast|takeFirst|clear|resize)')
RE_SIZE_GUARD = re.compile(
    r'(m_\w+)\.(size|count|length)\s*\(\)\s*[><=]')


# ---------------------------------------------------------------------------
# Rule tables
# ---------------------------------------------------------------------------

# Tier A: Simple match + optional exclude.
RULES_SIMPLE: list[Rule] = [
    # --- DEP ---
    Rule("DEP-1", RE_DEP1_QSCOPED,
         "QScopedPointer \u2014 use std::unique_ptr (const unique_ptr for scoped)"),
    Rule("DEP-2", RE_DEP2_QSHARED,
         "QSharedPointer \u2014 use std::shared_ptr (QSP needs 2x atomic ops)",
         exclude=RE_DEP2_EXCLUDE),
    Rule("DEP-3", RE_DEP3_QWEAK,
         "QWeakPointer \u2014 use std::weak_ptr"),
    Rule("DEP-4", RE_DEP4_FOREACH,
         "Q_FOREACH/foreach \u2014 use range-based for loop"),
    Rule("DEP-5", RE_DEP5_QPAIR,
         "QPair \u2014 use std::pair (alias since Qt 6.0)"),
    Rule("DEP-6", RE_DEP6_QSDP,
         "QSharedDataPointer \u2014 use QExplicitlySharedDataPointer",
         exclude=RE_DEP6_EXCLUDE),
    Rule("DEP-7", RE_DEP7_QMINMAX,
         "qMin/qMax/qBound \u2014 use (std::min)()/(std::max)()/std::clamp()"),
    Rule("DEP-8", RE_DEP8_QPRINTF,
         "q(v)nprintf \u2014 use std::(v)snprintf() (#include <cstdio>)"),
    Rule("DEP-9", RE_DEP9_QATOMIC,
         "QAtomic* \u2014 use std::atomic"),
    Rule("DEP-10", RE_DEP10_COUNT_LEN,
         ".count()/.length() \u2014 prefer .size() for std consistency",
         exclude=RE_DEP10_EXCLUDE),
    Rule("DEP-11", RE_DEP11_DATETIME,
         "QDateTime::currentDateTime() \u2014 use currentDateTimeUtc() (100x faster, DST-stable)",
         exclude=RE_DEP11_EXCLUDE),
    Rule("DEP-12", RE_DEP12_JAVA_ITER,
         "Java-style iterator \u2014 use STL iterators"),
    Rule("DEP-13", RE_DEP13_QCHAR,
         "QChar as object type \u2014 use char16_t; QChar:: namespace is OK",
         exclude=RE_DEP13_EXCLUDE),
    # --- HDR ---
    Rule("HDR-3", RE_HDR3_MINMAX,
         "Unprotected std::min/max \u2014 use (std::min)(a,b) for Windows macro safety",
         exclude=RE_HDR3_MINMAX_SAFE),
    Rule("HDR-3", RE_HDR3_LIMITS,
         "Unprotected numeric_limits::min/max \u2014 use (std::numeric_limits<T>::min)()",
         exclude=RE_HDR3_LIMITS_SAFE),
    # --- PAT ---
    Rule("PAT-3", RE_PAT3_HOLDS_ALT,
         "std::holds_alternative \u2014 prefer std::get_if or std::visit"),
    Rule("TRN-3", RE_TRN3_BOOL,
         "Ternary to convert/invert bool \u2014 use direct cast or negation"),
    Rule("PAT-5", RE_PAT5_UNLIKELY,
         "Q_UNLIKELY before qWarning/qFatal \u2014 redundant (cold path is auto-unlikely)"),
    Rule("TMO-1", RE_TMO1_INT_TIMEOUT,
         "Integer timeout/interval parameter \u2014 use QDeadlineTimer or std::chrono"),
    Rule("PAT-7", RE_PAT7_QMAP,
         "QMap usage \u2014 verify copying is needed; std::map saves ~1.7KiB text",
         exclude=RE_PAT7_EXCLUDE),
    Rule("PAT-8", RE_PAT8_QMAP_PTR,
         "QMap with pointer keys \u2014 use QHash (pointer ordering unreliable)"),
    Rule("VAL-5", RE_VAL5_QSWAP,
         "qSwap() \u2014 use member swap, qt_ptr_swap, or std::swap"),
    Rule("PAT-9", RE_PAT9_QLIST_QSTR,
         "QList<QString> \u2014 use QStringList (idiomatic Qt, convenience methods)"),
    Rule("PAT-10", RE_PAT10_RET_MOVE,
         "return std::move() \u2014 pessimizes NRVO; use plain return"),
    Rule("PAT-12", RE_PAT12_NONCONST_REF,
         "Non-const range-for reference \u2014 may trigger COW detach; use const auto& if read-only"),
    Rule("PAT-14", RE_PAT14_SORT_STR,
         "std::sort on QStrings \u2014 likely case-sensitive; use Qt::CaseInsensitive",
         exclude=RE_PAT14_SAFE),
    Rule("API-5", RE_API5_GET,
         "get-prefix on getter \u2014 Qt reserves get for user interaction/decomposition",
         exclude=RE_API5_LEGIT),
    # --- ENM ---
    Rule("ENM-9", RE_ENM9_BOOL_PARAMS,
         "Two or more bool parameters \u2014 boolean trap; use named enums (f(x, LogRule::DontLog))"),
    Rule("ENM-9", RE_ENM9_BOOL_ARGS,
         "Non-intuitive bool literal arguments \u2014 confusing at call site; use named enums"),
    # --- MDL (line-level) ---
    Rule("MDL-2", RE_MDL2_EMPTY_ROLES,
         "dataChanged with empty roles {} \u2014 forces full refresh; pass specific roles"),
    Rule("MDL-4", RE_MDL4_BEGIN_REMOVE,
         "beginRemoveRows 0..count-1 \u2014 if count==0, first>last violates QAIM; add guard"),
    Rule("MDL-5", RE_MDL5_EDITABLE,
         "ItemIsEditable without conditional \u2014 verify all item types should be editable",
         exclude=RE_MDL5_CONDITIONAL),
    # --- ERR (line-level) ---
    Rule("ERR-4", RE_ERR4_HTTP,
         "Hardcoded http:// URL \u2014 use https://",
         exclude=RE_ERR4_LOCAL),
    # --- LCY (line-level) ---
    Rule("LCY-2", RE_LCY2_NEW_QOB,
         "QObject created with new but no parent \u2014 potential leak"),
]

# Tier A special: ENM-2 and VAR-3 need multi-pattern exclusion
# (handled inline since they check 2 exclude patterns)

# Tier A special: PAT-1 needs both pattern + context on same line
# (opt.value() only flagged when line also contains "optional"/"opt")

# Tier A special: PAT-2 needs "nullopt" not-in-line check

# Tier B: Match + context window check.
RULES_CONTEXT: list[Rule] = [
    Rule("PAT-11", RE_PAT11_QREGEX,
         "QRegularExpression constructed inside loop \u2014 compile once before loop",
         context_before=5, context_pattern=RE_LOOP_CONSTRUCT,
         context_match_required=True),
    Rule("PAT-15", RE_PAT15_NOEXCEPT,
         "noexcept on function with Q_ASSERT \u2014 incompatible; noexcept terminates on throw",
         context_after=15, context_pattern=RE_QASSERT,
         context_match_required=True),
    Rule("ERR-2", RE_ERR2_FROMJSON,
         "QJsonDocument::fromJson() not validated \u2014 check isNull()/isObject()",
         context_after=5, context_pattern=RE_ERR2_VALID,
         context_match_required=False),
    Rule("ERR-3", RE_ERR3_READALL,
         "QNetworkReply data read without prior error check",
         context_before=3, context_pattern=RE_ERR3_ERRCHECK,
         context_match_required=False),
]

# Tier C: Match + file-level flag guard.
RULES_FLAG: list[Rule] = [
    Rule("ERR-5", RE_ERR5_REQ,
         "QNetworkRequest without setTransferTimeout \u2014 may hang indefinitely",
         requires_no_flag="has_transfer_timeout"),
    Rule("ERR-7", RE_ERR7_XML,
         "QXmlStreamWriter without hasError() \u2014 write errors undetected",
         requires_no_flag="has_haserror"),
    Rule("ERR-9", RE_ERR9_NAM,
         "QNetworkAccessManager without sslErrors handling",
         requires_no_flag="has_sslerrors"),
    Rule("LCY-6", RE_LCY6_QDELETEALL,
         "qDeleteAll \u2014 verify grandchildren are also cleaned (non-recursive)",
         requires_flag="has_destructor"),
]

# Framework-only rules: only active when --framework flag is passed.
# These enforce Qt module/library conventions (include style, qdoc,
# internal shims) that don't apply to application code.
RULES_FRAMEWORK: list[Rule] = [
    Rule("INC-6", RE_INC6_QGLOBAL,
         "Do not include qglobal.h \u2014 use fine-grained headers instead"),
    Rule("INC-1", RE_INC1_BARE_QT,
         "Qt header included without module prefix \u2014 use <QtModule/qheader.h>",
         header_only=True),
    Rule("CND-2", RE_CND2_HASINC,
         "__has_include() for non-Qt header \u2014 prefer __cpp_lib_* feature macros"),
    Rule("VAL-6", RE_VAL6_METATYPE,
         "Q_DECLARE_METATYPE \u2014 automatic since Qt 6, remove"),
    Rule("PAT-6", RE_PAT6_MAKEUNIQUE,
         "std::make_unique<T[]> \u2014 consider q20::make_unique_for_overwrite (avoids zeroing)"),
]


# ---------------------------------------------------------------------------
# Scope-aware context window builder
# ---------------------------------------------------------------------------

def _scope_truncated_window(
    code_lines: list[str],
    anchor: int,
    before: int,
    after: int,
) -> str:
    """Build a context window that stops at function-scope boundaries.

    Scans backward/forward from *anchor* up to *before*/*after* lines,
    but truncates at the first column-0 closing brace (``}`` at position 0),
    which in standard Qt/C++ style marks a function boundary.
    """
    num_lines = len(code_lines)
    parts: list[str] = []

    # Backward scan: walk from anchor-1 downward, stop at scope boundary
    if before:
        backward: list[str] = []
        start = max(anchor - before, 0)
        for j in range(anchor - 1, start - 1, -1):
            if RE_SCOPE_BOUNDARY.match(code_lines[j]):
                break
            backward.append(code_lines[j])
        backward.reverse()
        if backward:
            parts.append("\n".join(backward))

    # Forward scan: walk from anchor+1 upward, stop at scope boundary
    if after:
        forward: list[str] = []
        end = min(anchor + 1 + after, num_lines)
        for j in range(anchor + 1, end):
            if RE_SCOPE_BOUNDARY.match(code_lines[j]):
                break
            forward.append(code_lines[j])
        if forward:
            parts.append("\n".join(forward))

    return "\n".join(parts)


# ---------------------------------------------------------------------------
# Per-file scanner
# ---------------------------------------------------------------------------

def scan_file(filepath: str, framework: bool = False,
              text: str | None = None) -> list[Finding]:
    """Scan a single file and return all findings. `text` replaces the
    file's content on disk, as when the end of a diff range differs from
    the working tree."""
    findings: list[Finding] = []
    path = Path(filepath)

    try:
        if text is None:
            text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return findings
    lines = text.splitlines()

    ext = path.suffix.lstrip(".")
    is_header = ext in ("h", "hpp")
    num_lines = len(lines)

    def emit(line: int, rule: str, msg: str) -> None:
        findings.append(Finding(filepath, line, rule, msg))

    # --- File-level pre-scans (O(1) per file) ---
    full_text = "\n".join(lines)

    # Strip single-line comments so pre-scan flags don't match
    # keywords inside comments (e.g. "// missing deleteLater()").
    # Note: this also strips // inside string literals, which is
    # imperfect but acceptable — the affected keywords (hasError,
    # sslErrors, deleteLater, etc.) don't appear in strings.
    code_lines = [re.sub(r'//.*$', '', ln) for ln in lines]
    code_text = "\n".join(code_lines)

    file_flags: dict[str, bool] = {
        "has_haserror":          "hasError" in code_text,
        "has_sslerrors":         "sslErrors" in code_text,
        "has_transfer_timeout":  bool(re.search(
            r'(setTransferTimeout|setTimeout|transferTimeout)', code_text)),
        "has_deletelater":       "deleteLater" in code_text,
        "has_destructor":        bool(RE_DESTRUCTOR.search(code_text)),
        "is_header":             is_header,
    }

    # Model signal balance (for post-scan MDL-1/MDL-6)
    has_rolenames = bool(RE_ROLE_NAMES.search(code_text))
    has_case_role = bool(RE_CASE_ROLE.search(code_text))
    has_default_case = bool(RE_DEFAULT_CASE.search(code_text))
    has_structural_mut = bool(RE_STRUCTURAL_MUT.search(code_text))
    has_begin_insert = bool(RE_BEGIN_INSERT.search(code_text))
    has_end_insert = bool(RE_END_INSERT.search(code_text))
    has_begin_remove = bool(RE_BEGIN_REMOVE.search(code_text))
    has_end_remove = bool(RE_END_REMOVE.search(code_text))
    has_begin_move = bool(RE_BEGIN_MOVE.search(code_text))
    has_end_move = bool(RE_END_MOVE.search(code_text))
    has_begin_reset = bool(RE_BEGIN_RESET.search(code_text))
    has_end_reset = bool(RE_END_RESET.search(code_text))

    # Containers with size caps (for procedural LCY-5)
    capped_containers: set[str] = set()
    for match in re.finditer(RE_TRIM_CALL, code_text):
        capped_containers.add(match.group(1))
    for match in re.finditer(RE_SIZE_GUARD, code_text):
        capped_containers.add(match.group(1))

    # State tracking for post-scan and procedural rules
    last_qt_include_line = 0
    first_std_include_line = 0
    layout_changed_line = 0

    # Pre-compute active rule list (avoid rebuilding per line)
    active_simple = RULES_SIMPLE + RULES_FRAMEWORK if framework else RULES_SIMPLE

    # --- Line-by-line scan ---
    for i, line in enumerate(lines):
        lineno = i + 1

        if RE_COMMENT_LINE.match(line):
            continue

        # --- Tier A: simple rules (+ framework rules if enabled) ---
        for rule in active_simple:
            if rule.header_only and not is_header:
                continue
            if not rule.pattern.search(line):
                continue
            if rule.exclude and rule.exclude.search(line):
                continue
            emit(lineno, rule.id, rule.message)

        # --- Tier A special: multi-exclude rules ---

        # ENM-2: unscoped enum without class or explicit type
        if (RE_ENM2_UNSCOPED.search(line)
                and not RE_ENM2_CLASS.search(line)
                and not RE_ENM2_TYPED.search(line)):
            emit(lineno, "ENM-2",
              "Unscoped enum without explicit underlying type \u2014 add type to prevent BiC")

        # VAR-3: direct brace init (needs 2 excludes + keyword check)
        if (RE_VAR3_DIRECT_INIT.search(line)
                and not RE_VAR3_COPY_INIT.search(line)
                and not RE_VAR3_KEYWORDS.search(line)):
            emit(lineno, "VAR-3",
              "Direct brace initialization \u2014 prefer copy-init (var = {...}) for safety")

        # PAT-1: std::optional::value() — only when line has optional context
        if RE_PAT1_OPT_VALUE.search(line) and RE_PAT1_OPT_CTX.search(line):
            emit(lineno, "PAT-1",
              "std::optional::value() \u2014 use *opt or opt->foo (value() throws on empty)")

        # PAT-2: std::optional default-constructed without nullopt
        if RE_PAT2_OPT_DEFAULT.search(line) and "nullopt" not in line:
            emit(lineno, "PAT-2",
              "std::optional default-constructed \u2014 use std::nullopt explicitly (GCC warning bug)")

        # LCY-3: Q_ASSERT with side-effectful expression
        if RE_LCY3_ASSERT_SIDE.search(line) and RE_LCY3_EFFECTS.search(line):
            emit(lineno, "LCY-3",
              "Q_ASSERT wraps side-effectful call \u2014 compiled out in release")

        # ERR-1: QFile::open with its result discarded
        if (RE_ERR1_OPEN.search(line)
                and RE_ERR1_IODEV.search(line)
                and any(line[:m.start()].count("(") == line[:m.start()].count(")")
                        for m in RE_ERR1_DISCARDED.finditer(line))):
            emit(lineno, "ERR-1",
              "QFile::open() return not checked \u2014 silent failure if file cannot open")

        # --- Tier B: context-aware rules ---
        for rule in RULES_CONTEXT:
            if not rule.pattern.search(line):
                continue
            if rule.exclude and rule.exclude.search(line):
                continue
            # Build context window (use comment-stripped lines)
            if rule.scope_aware:
                ctx = _scope_truncated_window(
                    code_lines, i, rule.context_before, rule.context_after)
            else:
                ctx_parts = []
                if rule.context_before:
                    start = max(i - rule.context_before, 0)
                    ctx_parts.append("\n".join(code_lines[start:i]))
                if rule.context_after:
                    end = min(i + 1 + rule.context_after, num_lines)
                    ctx_parts.append("\n".join(code_lines[i + 1:end]))
                ctx = "\n".join(ctx_parts)
            has_ctx = bool(rule.context_pattern.search(ctx)) if rule.context_pattern else True
            if has_ctx == rule.context_match_required:
                emit(lineno, rule.id, rule.message)

        # --- Tier C: file-flag-gated rules ---
        for rule in RULES_FLAG:
            if rule.requires_flag and not file_flags.get(rule.requires_flag):
                continue
            if rule.requires_no_flag and file_flags.get(rule.requires_no_flag):
                continue
            if not rule.pattern.search(line):
                continue
            if rule.exclude and rule.exclude.search(line):
                continue
            emit(lineno, rule.id, rule.message)

        # --- Tier D: Procedural rules (cannot be table-driven) ---

        # INC-3: dynamic regex from capture group, cross-file search
        # (framework only — qNN headers are a Qt module convention)
        m = RE_INC3_QNN.search(line) if framework else None
        if m:
            std_name = m.group(2)
            if re.search(rf'^\s*#\s*include\s+<{re.escape(std_name)}>', full_text, re.M):
                emit(lineno, "INC-3",
                  f"Both q{m.group(1)}{std_name} and <{std_name}> included \u2014 remove one")

        # ERR-6: count placeholders vs .arg() calls
        # Use max placeholder index (e.g. %2 → need 2 args) vs .arg() count
        if RE_ERR6_MULTI_PH.search(line) and RE_ERR6_ARG.search(line):
            max_ph = max(int(p.lstrip("%")) for p in RE_ERR6_PH.findall(line))
            args = len(RE_ERR6_ARG.findall(line))
            if max_ph > args:
                emit(lineno, "ERR-6",
                  f"QString::arg() has %{max_ph} but only {args} .arg() calls")

        # LCY-4: Q_ASSERT(var) as sole null guard — extract var, check dereference
        m = RE_LCY4_ASSERT_PTR.search(line)
        if m:
            varname = m.group(1)
            after = "\n".join(lines[i + 1:min(i + 6, num_lines)])
            if f"{varname}->" in after:
                if not re.search(
                    rf'if\s*\(\s*!?{re.escape(varname)}|'
                    rf'{re.escape(varname)}\s*[!=]=',
                    after
                ):
                    emit(lineno, "LCY-4",
                      f"Q_ASSERT({varname}) is sole null guard \u2014 crashes in release")

        # LCY-5: unbounded container growth — extract name, check capped set
        container = None
        m = RE_LCY5_APPEND.search(line)
        if m:
            container = m.group(1)
        else:
            m2 = RE_LCY5_SHIFT.search(line)
            if m2:
                container = f"m_{m2.group(1)}"
        if container and container not in capped_containers:
            emit(lineno, "LCY-5",
              f"{container} grows without size cap \u2014 unbounded memory growth")

        # LCY-1: reply read without deleteLater — 2 branches
        if RE_ERR3_READALL.search(line):
            if not file_flags["has_deletelater"]:
                emit(lineno, "LCY-1",
                  "QNetworkReply read without deleteLater() \u2014 reply leaked")
            else:
                window = "\n".join(lines[max(i - 10, 0):min(i + 11, num_lines)])
                if "deleteLater" not in window:
                    emit(lineno, "LCY-1",
                      "QNetworkReply read without deleteLater() in this handler")

        # --- State tracking for post-scan rules ---
        if RE_QT_INCLUDE.search(line):
            last_qt_include_line = lineno
        if RE_STD_INCLUDE.search(line) and first_std_include_line == 0:
            first_std_include_line = lineno
        if RE_LAYOUT_CHANGED.search(line):
            layout_changed_line = lineno

    # --- Post-scan file-level checks (Tier D) ---

    # INC-2: std header before Qt header
    if (first_std_include_line > 0
            and last_qt_include_line > 0
            and first_std_include_line < last_qt_include_line):
        emit(first_std_include_line, "INC-2",
          "C++ standard header before Qt header \u2014 reorder by descending specificity")

    # MDL-1: layoutChanged for structural mutations without begin/end
    if layout_changed_line and has_structural_mut:
        if not (has_begin_insert or has_begin_remove or has_begin_move):
            emit(layout_changed_line, "MDL-1",
              "layoutChanged for structural changes \u2014 use beginInsertRows/beginRemoveRows")

    # MDL-6: unbalanced begin/end pairs
    for begin, end, name in [
        (has_begin_insert, has_end_insert, "InsertRows"),
        (has_begin_remove, has_end_remove, "RemoveRows"),
        (has_begin_move,   has_end_move,   "MoveRows"),
        (has_begin_reset,  has_end_reset,  "ResetModel"),
    ]:
        if begin and not end:
            emit(1, "MDL-6", f"begin{name} without matching end{name}")
        if not begin and end:
            emit(1, "MDL-6", f"end{name} without matching begin{name}")

    # MDL-7: roleNames + data() with default: swallowing roles
    if has_rolenames and has_case_role and has_default_case:
        for j, ln in enumerate(lines):
            if RE_DEFAULT_CASE.search(ln):
                emit(j + 1, "MDL-7",
                  "data() switch has default: \u2014 may hide unhandled roles; list all cases")
                break

    return findings


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

CPP_SUFFIXES = (".cpp", ".cc", ".cxx", ".h", ".hh", ".hpp", ".hxx")
RE_HUNK = re.compile(r"^@@ -\S+ \+(\d+)(?:,(\d+))? @@")
RE_INDEX = re.compile(r"^index [0-9a-f]+\.\.([0-9a-f]+)")


def git(*args: str) -> str:
    return subprocess.run(["git", *args], capture_output=True, text=True,
                          check=True).stdout


def get_changed_lines(diff_args: list[str]
                      ) -> tuple[str, dict[str, set[int]], dict[str, str]]:
    """Return the repository root and, per changed C++ file (relative to
    the root), the line numbers added or modified by `git diff <diff_args>`
    and the blob of the file at the end of the range. Files with deletions
    only map to an empty set; a pure rename has no blob."""
    root = git("rev-parse", "--show-toplevel").strip()
    diff = git("-C", root, "-c", "core.quotePath=false", "diff", "-U0",
               "--full-index", "--no-color", "--no-ext-diff",
               "--src-prefix=a/", "--dst-prefix=b/", *diff_args)
    changed: dict[str, set[int]] = {}
    blobs: dict[str, str] = {}
    blob: str | None = None
    current: set[int] | None = None
    for line in diff.splitlines():
        if line.startswith("diff --git "):
            blob = None
            current = None
        elif current is None and RE_INDEX.match(line):
            blob = RE_INDEX.match(line).group(1)
        elif line.startswith("+++ "):
            path = line[4:].rstrip("\t")
            current = None
            if path.startswith("b/") and path.endswith(CPP_SUFFIXES):
                current = changed.setdefault(path[2:], set())
                if blob:
                    blobs[path[2:]] = blob
        elif current is not None and line.startswith("@@"):
            match = RE_HUNK.match(line)
            if match:
                start = int(match.group(1))
                count = int(match.group(2)) if match.group(2) is not None else 1
                current.update(range(start, start + count))
    return root, changed, blobs


def read_range_end_texts(root: str, blobs: dict[str, str]) -> dict[str, str]:
    """Return, per file whose working tree content differs from its blob
    at the end of the diff range, the blob's text. A range ending at the
    working tree gives the working tree's own hashes, so nothing differs."""
    rels = [rel for rel in sorted(blobs) if os.path.isfile(os.path.join(root, rel))]
    if not rels:
        return {}
    # hash-object applies the same clean filters as git diff; without -w
    # it writes nothing
    hashes = git("-C", root, "hash-object", "--", *rels).split()
    texts: dict[str, str] = {}
    for rel, disk in zip(rels, hashes):
        if disk != blobs[rel]:
            data = subprocess.run(["git", "-C", root, "cat-file", "blob", blobs[rel]],
                                  capture_output=True, check=True).stdout
            texts[rel] = data.decode("utf-8", errors="replace")
    return texts


def map_diags_to_range_end(diags: list[qt_analysers.Diag],
                           end_texts: dict[str, str]
                           ) -> tuple[list[qt_analysers.Diag], dict[str, set[int]]]:
    """The analysers compiled the working tree; move their diagnostics on
    the files in `end_texts` to the line numbers at the end of the diff
    range, dropping those on lines edited since. Returns the diagnostics
    and, per such file, the range-end lines that the working tree still
    has, the only ones the analysers saw."""
    # working tree line -> range-end line, per file
    to_end: dict[str, dict[int, int]] = {}
    for filepath, text in end_texts.items():
        try:
            disk = Path(filepath).read_text(encoding="utf-8", errors="replace")
        except OSError:
            disk = ""
        to_end[filepath] = {}
        for tag, i1, i2, j1, _ in difflib.SequenceMatcher(
                None, text.splitlines(), disk.splitlines(),
                autojunk=False).get_opcodes():
            if tag == "equal":
                to_end[filepath].update((j1 + k + 1, i1 + k + 1)
                                        for k in range(i2 - i1))
    kept = [d._replace(line=to_end[d.file][d.line]) if d.file in to_end else d
            for d in diags
            if d.file not in to_end or d.line in to_end[d.file]]
    return kept, {f: set(m.values()) for f, m in to_end.items()}


def main() -> int:
    if len(sys.argv) < 2:
        print("Usage: qt_review_lint.py [--framework] [--summary] <file> [file ...]",
              file=sys.stderr)
        print("       qt_review_lint.py --files-from=- < list.txt",
              file=sys.stderr)
        print("       qt_review_lint.py [--framework] [--summary] --diff=<git diff args>",
              file=sys.stderr)
        print("       analysers: [--analyse] [--clang-tidy[=<path>]] [--clazy[=<path>]] "
              "[--build-dir=<dir>] [--clang-tidy-config=<file>] "
              "[--analyser-timeout=<s>]", file=sys.stderr)
        return 2

    framework = False
    summary = False
    diff_args: list[str] | None = None
    analysers: dict[str, str] = {}
    build_dir: str | None = None
    tidy_config: str | None = None
    analyser_timeout = qt_analysers.DEFAULT_TIMEOUT
    files: list[str] = []
    for arg in sys.argv[1:]:
        if arg == "--framework":
            framework = True
        elif arg == "--summary":
            summary = True
        elif arg == "--analyse":
            analysers.setdefault("clang-tidy", "")
            analysers.setdefault("clazy", "")
        elif arg == "--clang-tidy" or arg.startswith("--clang-tidy="):
            analysers["clang-tidy"] = arg[len("--clang-tidy="):]
        elif arg == "--clazy" or arg.startswith("--clazy="):
            analysers["clazy"] = arg[len("--clazy="):]
        elif arg.startswith("--build-dir="):
            build_dir = arg[len("--build-dir="):]
        elif arg.startswith("--clang-tidy-config="):
            tidy_config = arg[len("--clang-tidy-config="):]
        elif arg.startswith("--analyser-timeout="):
            try:
                analyser_timeout = int(arg[len("--analyser-timeout="):])
            except ValueError:
                print(f"Error: bad {arg}", file=sys.stderr)
                return 2
        elif arg.startswith("--diff="):
            diff_args = shlex.split(arg[len("--diff="):])
        elif arg == "--files-from=-":
            files.extend(line.strip() for line in sys.stdin if line.strip())
        else:
            files.append(arg)

    root: str | None = None
    changed: dict[str, set[int]] = {}
    # Per file whose working tree differs from the end of the diff range:
    # its text there, and the range-end lines the working tree still has
    end_texts: dict[str, str] = {}
    seen_lines: dict[str, set[int]] = {}
    drift_status: list[str] = []
    if diff_args is not None:
        if files:
            print("Error: --diff takes no file arguments", file=sys.stderr)
            return 2
        try:
            root, changed, blobs = get_changed_lines(diff_args)
            end_texts = {os.path.join(root, rel): text for rel, text
                         in read_range_end_texts(root, blobs).items()}
        except (OSError, subprocess.CalledProcessError) as e:
            detail = getattr(e, "stderr", None) or str(e)
            print(f"Error: git diff failed: {detail.strip()}", file=sys.stderr)
            return 2
        files = [os.path.join(root, rel) for rel in sorted(changed)
                 if os.path.isfile(os.path.join(root, rel))]
        if not files:
            print(f"No changed C++ files in git diff {' '.join(diff_args)}")
            return 0
    elif not files:
        print("Error: no input files specified", file=sys.stderr)
        return 2

    if end_texts:
        names = ", ".join(sorted(os.path.relpath(f, root) for f in end_texts))
        drift_status.append("diff: line numbers refer to the end of the range; "
                            f"working tree differs: {names}")

    all_findings: list[Finding] = []
    for filepath in files:
        all_findings.extend(scan_file(filepath, framework=framework,
                                      text=end_texts.get(filepath)))

    analyser_status: list[str] = []
    if analysers:
        bases = [os.getcwd()] if root is None else [os.getcwd(), root]
        diags, analyser_status, covered = qt_analysers.run_analysers(
            analysers, files, build_dir, bases, framework, tidy_config,
            analyser_timeout)
        if end_texts:
            kept, seen_lines = map_diags_to_range_end(diags, end_texts)
            if len(kept) < len(diags):
                drift_status.append(f"analysers: {len(diags) - len(kept)} diagnostic(s) "
                                    "dropped on lines edited after the end of the range")
            diags = kept
        # Trust the tools over the linter rules they supersede, on the
        # files they analysed: a silent tool is an answer too. On a file
        # edited since the end of the range, only on lines the tools saw.
        superseded = qt_analysers.select_superseded_rules(covered, tidy_config is not None)
        if superseded:
            all_findings = [f for f in all_findings
                            if f.rule not in superseded
                            or f.file not in covered[superseded[f.rule]]
                            or (f.file in seen_lines and f.line not in seen_lines[f.file])]
            by_tool = {tool: ", ".join(sorted(r for r, t in superseded.items() if t == tool))
                       for tool in sorted(set(superseded.values()))}
            analyser_status.append("analysers: superseded on analysed files: " + ", ".join(
                f"{tool} ({rules})" for tool, rules in by_tool.items()))
        all_findings.extend(Finding(*d) for d in diags)
    if not summary:
        for line in drift_status + analyser_status:
            print(line, file=sys.stderr)

    if root is not None:
        all_findings = [f for f in all_findings
                        if f.line in changed.get(os.path.relpath(f.file, root), ())]

    # Sort by file, then line
    all_findings.sort(key=lambda f: (f.file, f.line))

    if summary:
        if root is None:
            dirs = [os.path.dirname(os.path.abspath(f)) for f in files]
            root = os.path.commonpath(dirs)
        print(f"Paths relative to {root}/")
        if diff_args is not None:
            total = sum(len(lines) for lines in changed.values())
            print(f"Diff `git diff {' '.join(diff_args)}`: {len(changed)} C++ file(s), "
                  f"{total} added or modified line(s)")
            print("  " + "  ".join(f"{rel} +{len(lines)}"
                                   for rel, lines in sorted(changed.items())))
        for line in drift_status + analyser_status:
            print(line)
        print_summary(all_findings, root)
    else:
        for finding in all_findings:
            print(finding)

    return 1 if all_findings else 0


def print_summary(findings: list[Finding], root: str) -> None:
    """Print findings grouped by (rule, message), locations per file,
    with paths relative to root.

    Example:
        LCY-2 QObject created with new but no parent (3)
          main.cpp:12,40  widget.cpp:88
    """
    groups: dict[tuple[str, str], dict[str, list[int]]] = {}
    for f in findings:
        path = os.path.relpath(os.path.abspath(f.file), root)
        groups.setdefault((f.rule, f.message), {}).setdefault(path, []).append(f.line)
    print(f"{len(findings)} finding(s), {len(groups)} distinct rule/message pair(s)")
    for (rule, message), by_file in sorted(groups.items()):
        count = sum(len(v) for v in by_file.values())
        print(f"{rule} {message} ({count})")
        locs = [f"{path}:{','.join(str(n) for n in sorted(lines))}"
                for path, lines in sorted(by_file.items())]
        print("  " + "  ".join(locs))


if __name__ == "__main__":
    sys.exit(main())
