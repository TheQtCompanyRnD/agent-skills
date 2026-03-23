---
name: qt-widgets
description: >-
  Guides Qt Widgets development patterns — QWidget subclassing,
  layout management, model/view architecture, QSS styling, .ui
  file usage, and widget lifecycle. Use when writing or reviewing
  Qt Widgets C++ code, working with .ui files, or building
  desktop UIs with QWidget.
license: BSD-3-Clause
compatibility: >-
  Designed for Claude Code, GitHub Copilot, and similar agents.
disable-model-invocation: false
metadata:
  author: qt-ai-skills
  version: "0.1"
  qt-version: "6.x"
  category: conceptual
---

# Qt Widgets

TODO: This skill is a placeholder. Content to be developed.

## Intended Scope

Widget-specific development patterns:

- **QWidget subclassing** — proper constructor chains,
  `setupUi()`, widget lifecycle, parent-child ownership
- **Layout management** — QVBoxLayout, QHBoxLayout,
  QGridLayout, QFormLayout, size policies, stretch factors,
  spacer items
- **Model/View** — QAbstractItemModel, QStandardItemModel,
  QSortFilterProxyModel, custom delegates, QTableView,
  QTreeView, QListView
- **.ui files** — Qt Designer integration, `uic` generated
  code, promoting widgets, custom widget plugins
- **QSS styling** — stylesheet syntax, selector specificity,
  pseudo-states, sub-controls, stylesheet vs palette
- **Signals and slots** — widget-specific signal patterns,
  auto-connection via `on_<object>_<signal>`, lambda
  connections
- **Dialogs** — QDialog patterns, QMessageBox, QFileDialog,
  modal vs modeless, exec vs open
- **Main window** — QMainWindow, dockable widgets, toolbars,
  status bar, central widget patterns
- **Custom painting** — QPainter, paintEvent, double
  buffering, high-DPI rendering
- **Event handling** — event filters, key/mouse events,
  drag and drop, focus management
