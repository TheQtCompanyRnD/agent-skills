---
name: check-screenshot
description: Use when user says "check latest screenshot", "check screenshot", or wants to view their most recent screenshot
user_invocable: true
---

# Check Latest Screenshot

View the most recent screenshot(s) from the user's Screenshots folder.

## Arguments

The user may invoke this skill with optional arguments:

- No args: show the single most recent screenshot
- A single integer N (e.g., `/check-screenshot 3`): show the N most recent screenshots

User args: `{{ args }}`

## Step 1: Locate Screenshots Folder

The screenshots folder path should be defined in the user's CLAUDE.md (global or project) via a "Check latest screenshot" shortcut. Look for it there.

Common locations:
- Windows: `C:/Users/<username>/Pictures/Screenshots` or a OneDrive-synced variant
- macOS: `~/Desktop` (default) or `~/Screenshots`
- Linux: `~/Pictures/Screenshots`

If no shortcut is defined and the folder can't be found, ask the user where their screenshots are saved.

## Step 2: Get Latest Screenshot(s)

Determine how many screenshots to show:
- If args is empty or not a number: N = 1
- If args is a number: N = that number

```bash
ls -1rt "<SCREENSHOTS_FOLDER>" | tail -n<N>
```

## Step 3: View and Describe

For each screenshot filename returned:
1. Read the image file using the Read tool with the full path
2. Describe what you see
3. Ask if the user needs help with anything related to it
