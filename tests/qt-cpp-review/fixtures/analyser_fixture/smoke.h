// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#pragma once

#include <QObject>
#include <QString>

class Smoke : public QObject
{
    Q_OBJECT

public:
    explicit Smoke(QObject *parent = nullptr);

    void wireUp(Smoke *other);
    bool save();

Q_SIGNALS:
    void changed(const QString &what);

private Q_SLOTS:
    void onChanged(const QString &what);
};
