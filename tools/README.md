<!--
Copyright (C) 2026 The Qt Company Ltd.
SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
-->

# tools/

Repository management tooling for **maintainers** of the Qt Development
Skills plugin.

**Nothing in this directory is part of the distributed skill set.** These
files are not skills, they are not loaded by any agent, and they are not
consumed by anyone using the plugin. If you installed this plugin to *use*
the skills, you can ignore this directory entirely — it exists only to help
the people who publish the repository.

## Contents

| File | Purpose |
|------|---------|
| `bump-version.py` | Bump the plugin version across the three metadata files on a fresh branch off `origin/dev`, and optionally push it to Gerrit for review. |

## bump-version.py

Requires Python 3.8+ and `git` on `PATH`. Run it from anywhere in a checkout —
it locates the repository root relative to its own location.

```bash
# Bump to 1.7.0 on a fresh branch off origin/dev and push for review:
python tools/bump-version.py 1.7.0 --reason "Release of the qt-foo skill." --push

# Bump without pushing — the commit stays local for inspection first:
python tools/bump-version.py 1.7.0 --reason "Release of the qt-foo skill."
```

`--reason` is required: every bump carries a stated rationale, which becomes
the commit body. The script always fetches `origin/dev` and does the bump on a
throwaway `bump-version-<version>` branch cut from it, then pushes to
`refs/for/dev` — the bump lands on the trunk every release is cut from.

The script keeps every `version` field in `.claude-plugin/marketplace.json`,
`.claude-plugin/plugin.json`, and `gemini-extension.json` in lockstep. It
rewrites *any* semver-valued `version` field to the target, so a copy that has
drifted out of sync is brought back into line rather than skipped.

Release ordering: the version-bump change should land **after** the change
that adds the new content (skill, MCP server, etc.) is merged, so the release
surface and the released artifacts agree.

### Cutting a maintained release branch

Most releases are just a version bump on `dev` (bumped here) plus a tag. A
long-lived `release/<version>` branch — one you maintain independently, with
its own cherry-picks — is only worth cutting for a major version. When you do,
branch off `dev` at the point the bump commit has landed, so the release line
starts from a known-released state:

```bash
git fetch origin dev
git branch release/2.0.0 <sha-of-merged-bump-commit>
git push origin release/2.0.0
```

This is a deliberate, infrequent act, so it stays a documented manual step
rather than a flag on the bump script.
