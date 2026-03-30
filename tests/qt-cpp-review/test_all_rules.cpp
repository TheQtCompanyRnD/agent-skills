// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
// Test file for qt_review_lint.py -- source file rules
// Each section is labeled with the rule it should trigger.
// This file deliberately omits certain cleanup/guard calls
// to trigger file-level pre-scan rules.

#include <vector>
#include <QtCore/QObject>

// ===== DEP rules =====

// DEP-2: QSharedPointer (not QSharedDataPointer)
QSharedPointer<MyClass> sharedObj;

// DEP-3: QWeakPointer
QWeakPointer<MyClass> weakObj;

// DEP-4: Q_FOREACH
void iterateOld(QList<int> items) {
    Q_FOREACH(int item, items) {
        process(item);
    }
}

// DEP-6: QSharedDataPointer (not QExplicitlySharedDataPointer)
QSharedDataPointer<MyData> dataPtr;

// DEP-7: qMin/qMax/qBound
int clamped = qMin(a, qMax(b, c));

// DEP-8: qsnprintf
char buf[64];
qsnprintf(buf, sizeof(buf), "%d", value);

// DEP-10: .count()/.length() on non-excluded types
int n = items.count();
int len = notes.length();

// DEP-11: QDateTime::currentDateTime()
QDateTime now = QDateTime::currentDateTime();

// DEP-12: Java-style iterator
QListIterator<int> it(list);
QHashMutableIterator<QString, int> mit(hash);

// ===== PAT / HDR / CND rules =====

// HDR-3: Unprotected std::min/max
int lo = std::min(a, b);
int hi = std::max(a, b);

// HDR-3: Unprotected numeric_limits
int maxInt = std::numeric_limits<int>::max();

// PAT-1: std::optional::value()
void useOptional(std::optional<int> opt) {
    int v = opt.value();
}

// PAT-2: std::optional default-constructed without nullopt
std::optional<QString> maybeStr;

// PAT-3: std::holds_alternative
if (std::holds_alternative<int>(myVariant)) {}

// TRN-3: Ternary to invert bool
bool flipped = condition ? true : false;

// PAT-5: Q_UNLIKELY before qWarning
if (Q_UNLIKELY(ptr == nullptr)) qWarning("null");

// CND-2: __has_include for non-Qt header
#if __has_include(<format>)
#include <format>
#endif

// PAT-6: make_unique for array
auto arr = std::make_unique<int[]>(100);

// PAT-7: QMap usage
QMap<QString, int> mapping;

// PAT-8: QMap with pointer key
QMap<QObject*, int> ptrMap;

// VAL-5: qSwap
qSwap(a, b);

// VAR-3: Direct brace initialization
int count{42};

// PAT-10: return std::move()
QVariantMap getStats() {
    QVariantMap stats;
    stats["count"] = 10;
    return std::move(stats);
}

// PAT-11: QRegularExpression in loop
void searchLoop(const QList<NoteItem*>& notes, const QString& query) {
    for (const auto* note : notes) {
        QRegularExpression regex(query);
        auto match = regex.match(note->title);
    }
}

// PAT-12: Non-const range-for reference (COW detach)
void processNotes(QList<NoteItem*> notes) {
    for (auto *&note : notes) {
        doSomething(note);
    }
}

// PAT-14: std::sort on QStrings (case-sensitive)
void sortNames(QStringList& names) {
    std::sort(names.begin(), names.end()); // QString default
}

// PAT-15: noexcept on function containing Q_ASSERT
bool validateItem(const NoteItem& item) noexcept {
    Q_ASSERT(!item.title.isEmpty());
    return item.content.size() < 50000;
}

// ===== MDL rules =====

// MDL-2: dataChanged with empty roles
void notifyChange(const QModelIndex& idx) {
    emit dataChanged(idx, idx, {});
}

// MDL-4: beginRemoveRows with 0..count-1
void clearAll(const QModelIndex& parent, int count) {
    beginRemoveRows(parent, 0, count - 1);
}

// MDL-5: ItemIsEditable without conditional
Qt::ItemFlags flags(const QModelIndex& index) const {
    return Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemIsEditable;
}

// MDL-1: Tested in test_mdl1.cpp (conflicts with MDL-4 in same file)

// MDL-7: data() with default: and roleNames()
QHash<int, QByteArray> roleNames() const {
    QHash<int, QByteArray> roles;
    roles[TitleRole] = "title";
    return roles;
}

QVariant data(const QModelIndex& index, int role) const {
    switch (role) {
    case TitleRole:
        return item->title;
    default:
        return QVariant();
    }
}

// MDL-6: Tested in test_mdl6.cpp (conflicts with MDL-1 in same file)

// ===== ERR rules =====

// ERR-1: QFile::open() not checked
void saveFile(const QString& path) {
    QFile file(path);
    file.open(QIODevice::WriteOnly);
    file.write(data);
}

// ERR-2: QJsonDocument::fromJson without validation
void parseJson(const QByteArray& data) {
    QJsonDocument doc = QJsonDocument::fromJson(data);
    QJsonObject obj = doc.object();
}

// ERR-3: reply->readAll without prior error check
void onReplyFinished(QNetworkReply* reply) {
    QByteArray data = reply->readAll();
    processData(data);
}

// ERR-4: Hardcoded http:// URL
QString serverUrl = "http://api.example.com/v1";

// ERR-5: QNetworkRequest without timeout guard (file-level)
void startRequest() {
    QNetworkRequest request(QUrl(m_url));
    m_nam->get(request);
}

// ERR-6: QString::arg() placeholder mismatch
QString snippet = QString("%1 (%2)").arg(category);

// ERR-7: QXmlStreamWriter without error check (file-level)
void writeXml(QFile& file) {
    QXmlStreamWriter xml(&file);
    xml.writeStartDocument();
    xml.writeEndDocument();
}

// ERR-9: QNetworkAccessManager without SSL guard (file-level)
QNetworkAccessManager* m_nam = new QNetworkAccessManager(this);

// ===== LCY rules =====

// LCY-2: QObject created with new but no parent
void setup() {
    QTimer* timer = new QTimer();
    timer->start(1000);
}

// LCY-3: Q_ASSERT with side-effectful expression
void removeFromList(QList<NoteItem*>& list, NoteItem* note) {
    Q_ASSERT(list.removeOne(note));
}

// LCY-4: Q_ASSERT as sole null guard
void processCategory(NoteItem* categoryItem) {
    Q_ASSERT(categoryItem);
    int count = categoryItem->children.size();
    for (auto* child : categoryItem->children) {
        process(child);
    }
}

// LCY-5: Unbounded container growth (no cap)
void logOperation(const QString& op) {
    m_operationLog.append(op);
}
void trackSearch(const QString& query) {
    m_searchHistory << query;
}

// LCY-6: qDeleteAll in file with destructor
TestModel::~TestModel() {
    qDeleteAll(m_rootItem->children);
    delete m_rootItem;
}

// LCY-1: reply->readAll without cleanup in handler
// (triggered via ERR-3 readAll above -- LCY-1 fires
// because no reply cleanup call anywhere in file)

// ===== INC-2 file-level: std header before Qt header =====
// (the #include <vector> at top is before #include <QtCore/QObject>)
