// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#include "smoke.h"

#include <QFile>

Smoke::Smoke(QObject *parent)
    : QObject(parent)
{
}

void Smoke::wireUp(Smoke *other)
{
    connect(other, SIGNAL(changed(QString)), this, SLOT(onChanged(QString)));
}

bool Smoke::save()
{
    QFile file(QStringLiteral("smoke.txt"));
    file.open(QIODevice::WriteOnly);
    return file.isOpen();
}

void Smoke::onChanged(const QString &what)
{
    Q_UNUSED(what);
}
