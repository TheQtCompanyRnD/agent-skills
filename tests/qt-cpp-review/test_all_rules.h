// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
// Test file for qt_review_lint.py — header-specific rules
// This file should trigger header-only rules (INC-1) plus
// rules that apply to both headers and source files.
#pragma once

// INC-6: Don't include qglobal.h
#include <qglobal.h>

// INC-1: Bare Qt header without module prefix (header only)
#include <qstring.h>

// INC-3: Both qNN and standard header included
#include "q20algorithm"
#include <algorithm>

// DEP-1: QScopedPointer
#include <QScopedPointer>
QScopedPointer<int> scopedPtr;

// DEP-5: QPair
QPair<int, int> pairVal;

// PAT-9: QList<QString> instead of QStringList
QList<QString> stringList;

// ENM-2: Unscoped enum without underlying type
enum NoteRoles {
    TitleRole,
    ContentRole
};

// TMO-1: Integer timeout parameter
void setTimeout(int timeout);
void setAutoSaveInterval(int interval);

// API-5: get-prefix on getter
QString getNoteTitle() const;
QVariantMap getNoteStatistics();

// PRP / VAR-3: Direct brace initialization
// (VAR-3 triggers on non-keyword direct init)
// int count{0};  — would trigger but tricky in header context

// DEP-9: QAtomic
QAtomicInt atomicCounter;

// DEP-13: QChar as object type
QChar separator = u'/';

// VAL-6: Q_DECLARE_METATYPE
Q_DECLARE_METATYPE(NoteRoles)
