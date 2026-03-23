#!/bin/sh
# Install Qt AI Skills for OpenAI Codex CLI
# Generates an AGENTS.md file from all skills and places it at the target location.
#
# Usage:
#   sh tooling/codex/install.sh              # Install to ~/.codex/AGENTS.md (global)
#   sh tooling/codex/install.sh /path/to/repo # Install to <repo>/AGENTS.md (project)

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"

TARGET_DIR="${1:-$HOME/.codex}"
if [ "$TARGET_DIR" = "$HOME/.codex" ]; then
    TARGET_FILE="$TARGET_DIR/AGENTS.md"
    echo "Installing globally to $TARGET_FILE"
else
    TARGET_FILE="$TARGET_DIR/AGENTS.md"
    echo "Installing to project: $TARGET_FILE"
fi

if [ ! -d "$SKILLS_SRC" ]; then
    echo "Error: skills/ directory not found at $SKILLS_SRC"
    exit 1
fi

mkdir -p "$TARGET_DIR"

# Build AGENTS.md by concatenating skill bodies (strip YAML frontmatter)
{
    echo "# Qt AI Skills"
    echo ""
    echo "Auto-generated from qtaiskills repo. Do not edit directly."
    echo "Source: $REPO_ROOT"
    echo ""

    for skill_dir in "$SKILLS_SRC"/*/; do
        skill_file="$skill_dir/SKILL.md"
        if [ ! -f "$skill_file" ]; then
            continue
        fi

        skill_name="$(basename "$skill_dir")"

        # Strip YAML frontmatter (everything between first --- and second ---)
        # then append the markdown body
        awk '
            BEGIN { in_frontmatter=0; past_frontmatter=0 }
            /^---$/ {
                if (!past_frontmatter) {
                    in_frontmatter = !in_frontmatter
                    if (!in_frontmatter) past_frontmatter = 1
                    next
                }
            }
            past_frontmatter { print }
        ' "$skill_file"

        echo ""
        echo "---"
        echo ""
    done
} > "$TARGET_FILE"

skill_count=$(find "$SKILLS_SRC" -maxdepth 2 -name "SKILL.md" | wc -l)
echo "Done. $skill_count skills written to $TARGET_FILE"
echo ""
echo "Note: Codex AGENTS.md has a 32KB default limit."
echo "If truncated, increase project_doc_max_bytes in ~/.codex/config.toml"
