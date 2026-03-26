# check-screenshot

A Claude Code skill that views the most recent screenshot(s) from your system's Screenshots folder and describes what's in them.

## Installation

Copy `check-screenshot.md` into your project's `.claude/skills/` directory:

```
.claude/skills/check-screenshot.md
```

For automatic screenshot folder detection, add a shortcut to your global `~/.claude/CLAUDE.md`:

```markdown
## Shortcuts

- "Check latest screenshot" means: run `ls -1rt "<YOUR_SCREENSHOTS_FOLDER>" | tail -n1` to get the filename, then view that image
```

Replace `<YOUR_SCREENSHOTS_FOLDER>` with the actual path (e.g., `C:/Users/you/Pictures/Screenshots`).

## Usage

| Command | Description |
|---------|-------------|
| `/check-screenshot` | View the most recent screenshot |
| `/check-screenshot 3` | View the 3 most recent screenshots |

## How It Works

1. Lists the screenshots folder sorted by modification time
2. Reads the image file(s) using Claude's multimodal capabilities
3. Describes what's shown and offers to help with anything related
