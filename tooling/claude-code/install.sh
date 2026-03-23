#!/bin/sh
# Install Qt AI Skills for Claude Code
# Skills are symlinked into ~/.claude/skills/ for automatic discovery.

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"
SKILLS_DST="$HOME/.claude/skills"

if [ ! -d "$SKILLS_SRC" ]; then
    echo "Error: skills/ directory not found at $SKILLS_SRC"
    exit 1
fi

mkdir -p "$SKILLS_DST"

installed=0
skipped=0

for skill_dir in "$SKILLS_SRC"/*/; do
    skill_name="$(basename "$skill_dir")"

    # Verify it has a SKILL.md
    if [ ! -f "$skill_dir/SKILL.md" ]; then
        echo "  skip: $skill_name (no SKILL.md)"
        skipped=$((skipped + 1))
        continue
    fi

    target="$SKILLS_DST/$skill_name"

    if [ -L "$target" ]; then
        # Already symlinked — update if pointing somewhere else
        existing="$(readlink "$target")"
        if [ "$existing" = "$skill_dir" ] || [ "$existing" = "${skill_dir%/}" ]; then
            echo "  ok:   $skill_name (already linked)"
            skipped=$((skipped + 1))
            continue
        else
            rm "$target"
        fi
    elif [ -d "$target" ]; then
        echo "  skip: $skill_name (directory exists, not a symlink — remove manually to replace)"
        skipped=$((skipped + 1))
        continue
    fi

    ln -s "${skill_dir%/}" "$target"
    echo "  add:  $skill_name -> $target"
    installed=$((installed + 1))
done

echo ""
echo "Done. $installed installed, $skipped skipped."
echo "Skills are loaded automatically — no restart needed."
