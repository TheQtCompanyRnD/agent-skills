#!/bin/sh
# Install Qt AI Skills as Cursor rules (.mdc files)
# Converts each SKILL.md into a .mdc rule file in .cursor/rules/
#
# Usage:
#   sh tooling/cursor/install.sh /path/to/project
#
# Global Cursor rules cannot be installed via filesystem (stored in SQLite).
# This script installs project-level rules only.

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"

if [ -z "${1:-}" ]; then
    echo "Usage: bash tooling/cursor/install.sh /path/to/project"
    echo ""
    echo "Installs Qt AI Skills as .mdc rule files in <project>/.cursor/rules/"
    exit 1
fi

TARGET_DIR="$1/.cursor/rules"

if [ ! -d "$SKILLS_SRC" ]; then
    echo "Error: skills/ directory not found at $SKILLS_SRC"
    exit 1
fi

mkdir -p "$TARGET_DIR"

installed=0

for skill_dir in "$SKILLS_SRC"/*/; do
    skill_file="$skill_dir/SKILL.md"
    if [ ! -f "$skill_file" ]; then
        continue
    fi

    skill_name="$(basename "$skill_dir")"

    # Extract description from YAML frontmatter
    description=$(awk '
        BEGIN { in_fm=0 }
        /^---$/ { in_fm = !in_fm; next }
        in_fm && /^description:/ {
            sub(/^description:[[:space:]]*/, "")
            # Remove surrounding quotes if present
            gsub(/^["'\''"]|["'\''"]$/, "")
            print
            exit
        }
    ' "$skill_file")

    # Extract body (strip YAML frontmatter)
    body=$(awk '
        BEGIN { in_frontmatter=0; past_frontmatter=0 }
        /^---$/ {
            if (!past_frontmatter) {
                in_frontmatter = !in_frontmatter
                if (!in_frontmatter) past_frontmatter = 1
                next
            }
        }
        past_frontmatter { print }
    ' "$skill_file")

    # Write .mdc file
    target_file="$TARGET_DIR/$skill_name.mdc"
    {
        echo "---"
        echo "description: \"$description\""
        echo "alwaysApply: false"
        echo "---"
        echo ""
        echo "$body"
    } > "$target_file"

    echo "  add: $skill_name.mdc"
    installed=$((installed + 1))
done

echo ""
echo "Done. $installed rules written to $TARGET_DIR"
echo "Rules are type 'Agent-Requested' — Cursor will include them when relevant."
