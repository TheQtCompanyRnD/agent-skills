# find-msvc

A Claude Code skill that discovers MSVC / Visual Studio installations on Windows, activates a developer environment, and persists it so that build commands (cmake, cl, ninja, etc.) Just Work across tool invocations.

## Installation

Copy `msvc.md` into your project's `.claude/skills/` directory:

```
.claude/skills/msvc.md
```

Then add the following to your project's `CLAUDE.md` so the environment is sourced automatically before build commands:

```markdown
## MSVC Environment Integration

When `.msvc_env.sh` exists in the project root, **always source it before running build-related commands**:

    source .msvc_env.sh && cmake ...

This applies to: cmake, cl, nmake, msbuild, link, ninja, lib, rc, dumpbin, ml, ml64, and any other MSVC toolchain command.

If `.msvc_env.sh` does not exist, do not attempt to source it — suggest running `/msvc` first.
```

Add `.msvc_env.sh` to your `.gitignore` — it's machine-specific.

## Usage

| Command | Description |
|---------|-------------|
| `/msvc` | Discover all installations, present a menu |
| `/msvc 2022 64-bit` | Activate VS 2022, native x64 |
| `/msvc 2019 32-bit` | Activate VS 2019 (will ask about native vs cross-compile) |
| `/msvc status` | Show currently active environment |
| `/msvc clear` | Deactivate the MSVC environment |

Aliases: `/vcvars`, `/find-msvc`

## Requirements

- Windows (Git Bash / MSYS2 / Cygwin)
- Python 3 on PATH
- At least one Visual Studio or Build Tools installation

## How It Works

1. Scans standard VS install locations for `vcvars*.bat` files
2. Runs the selected vcvars bat via PowerShell, capturing the environment before and after
3. Diffs the environments and writes the new/changed variables to `.msvc_env.sh`
4. PATH entries are converted to bash format and prepended (not replaced)
5. Subsequent build commands source this file per CLAUDE.md instructions
