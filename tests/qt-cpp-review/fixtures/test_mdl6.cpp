// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
// Test file for MDL-6: unbalanced begin/end insert rows
// Separate file due to file-level check conflicts.

void addBroken() {
    beginInsertRows(QModelIndex(), 0, 0);
    m_items.append(newItem);
    // missing end-of-insert call
}
