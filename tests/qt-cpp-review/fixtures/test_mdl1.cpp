// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
// Test file for MDL-1: layoutChanged for structural mutations
// Must be separate file -- conflicting file-level checks in
// main test file suppress this rule.

void removeCategory() {
    emit layoutAboutToBeChanged();
    categoryItem->children.removeOne(item);
    delete item;
    emit layoutChanged();
}
