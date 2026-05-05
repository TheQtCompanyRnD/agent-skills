# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

"""Generate one MkDocs page per SKILL.md.

Walks ``skills/<name>/SKILL.md``, strips the YAML frontmatter, rewrites
relative file links (e.g. ``references/foo.md``) to absolute GitHub URLs
so they resolve on the rendered site without copying the references
folders, and emits ``skills/<name>.md`` virtually via mkdocs-gen-files.

Also emits ``skills/index.md`` — a generated overview table — from the
same SKILL.md frontmatter, so the skills list never drifts out of sync
with the actual skills present in the repo.

The repo's SKILL.md files are the single source of truth — the docs
site stays in sync automatically and nothing is duplicated under docs/.
"""

from __future__ import annotations

import re
from pathlib import Path

import mkdocs_gen_files
import yaml

SKILLS_ROOT = Path("skills")
GITHUB_BLOB = "https://github.com/TheQtCompanyRnD/agent-skills/blob/dev"

FRONTMATTER_RE = re.compile(r"\A---\n(.*?)\n---\n+", re.DOTALL)
RELATIVE_LINK_RE = re.compile(
    r"\[([^\]]+)\]\((?!https?://|#|/)([^)]+)\)"
)


def rewrite_relative_links(body: str, skill_name: str) -> str:
    def repl(match: re.Match[str]) -> str:
        text, target = match.group(1), match.group(2)
        return f"[{text}]({GITHUB_BLOB}/skills/{skill_name}/{target})"

    return RELATIVE_LINK_RE.sub(repl, body)


def render_page(skill_name: str, frontmatter: dict, body: str) -> str:
    description = (frontmatter.get("description") or "").strip()
    description = " ".join(description.split())  # collapse whitespace

    source_link = f"{GITHUB_BLOB}/skills/{skill_name}/SKILL.md"

    metadata_rows = []
    for key in ("compatibility", "argument-hint", "license"):
        value = frontmatter.get(key)
        if value:
            value = " ".join(str(value).split())
            metadata_rows.append(f"| **{key}** | {value} |")
    meta = frontmatter.get("metadata") or {}
    for key in ("category", "qt-version", "version"):
        value = meta.get(key)
        if value:
            metadata_rows.append(f"| **{key}** | {value} |")

    metadata_block = ""
    if metadata_rows:
        metadata_block = (
            "| | |\n|---|---|\n" + "\n".join(metadata_rows) + "\n\n"
        )

    return (
        f"# {skill_name}\n\n"
        f"!!! abstract \"When to use\"\n    {description}\n\n"
        f"**Source:** [`skills/{skill_name}/SKILL.md`]({source_link})\n\n"
        f"{metadata_block}"
        f"---\n\n"
        f"{body}"
    )


def render_index(entries: list[tuple[str, str]]) -> str:
    rows = "\n".join(
        f"| [{name}]({name}.md) | {summary} |" for name, summary in entries
    )
    return (
        "# Skills\n\n"
        "Each skill lives under `skills/<name>/SKILL.md` in the repo. "
        "Click through for details and triggering rules.\n\n"
        "| Skill | Purpose |\n"
        "|---|---|\n"
        f"{rows}\n"
    )


index_entries: list[tuple[str, str]] = []

for skill_dir in sorted(SKILLS_ROOT.iterdir()):
    if not skill_dir.is_dir():
        continue
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.exists():
        continue

    raw = skill_md.read_text(encoding="utf-8")
    fm_match = FRONTMATTER_RE.match(raw)
    if not fm_match:
        continue

    frontmatter = yaml.safe_load(fm_match.group(1)) or {}
    body = raw[fm_match.end():]
    skill_name = skill_dir.name

    body = rewrite_relative_links(body, skill_name)
    page = render_page(skill_name, frontmatter, body)

    out_path = f"skills/{skill_name}.md"
    with mkdocs_gen_files.open(out_path, "w") as fh:
        fh.write(page)
    mkdocs_gen_files.set_edit_path(out_path, f"skills/{skill_name}/SKILL.md")

    summary = " ".join((frontmatter.get("description") or "").split())
    # First sentence only, for a concise table cell.
    summary = re.split(r"(?<=[.!?])\s", summary, maxsplit=1)[0]
    index_entries.append((skill_name, summary))


with mkdocs_gen_files.open("skills/index.md", "w") as fh:
    fh.write(render_index(index_entries))
