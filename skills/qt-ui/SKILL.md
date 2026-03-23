---
name: qt-ui
description: >-
  Guides cross-cutting Qt UI design principles — layout strategy,
  accessibility, theming, responsive design, and platform
  conventions. Applies to both QML and Widgets UIs. Use when
  designing user interfaces, choosing layout approaches, or
  ensuring accessibility and platform consistency.
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

# Qt UI

TODO: This skill is a placeholder. Content to be developed.

## Intended Scope

Cross-cutting UI design principles for Qt applications:

- **Layout strategy** — choosing between anchors, positioners,
  and layout managers; responsive patterns for different screen
  sizes and orientations
- **Anchors vs Layouts** — when to use each, never mix them on
  the same item (QML), layout nesting best practices (Widgets)
- **Accessibility** — keyboard navigation, focus chains, screen
  reader support, Accessible attached properties, QAccessible
- **Theming and styling** — Qt Quick styles, palette usage,
  QSS vs palette in Widgets, dark/light mode support
- **Platform conventions** — native look-and-feel, platform
  menu placement, dialog patterns, HIG adherence
- **Responsive design** — adapting to screen density, DPI
  awareness, scalable assets, Screen attached object
- **Animation and transitions** — meaningful motion, performance
  considerations, Behavior vs Transition
- **Internationalisation** — `qsTr()` / `tr()`, right-to-left
  layout support, LayoutMirroring, plural forms
- **Icon and asset management** — Qt Resource system, icon
  themes, scalable graphics (SVG), image providers
