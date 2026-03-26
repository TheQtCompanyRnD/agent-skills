---
name: msvc
description: Discover MSVC installations, activate a Visual Studio developer environment, and persist it for the session. Use when user wants to set up MSVC/Visual Studio build tools, or says things like "MSVC2022 64-bit", "set up VS", "use Visual Studio compiler".
aliases:
  - vcvars
  - find-msvc
user_invocable: true
---

# MSVC Environment Activator

You are activating a Visual Studio / MSVC developer environment on Windows.

## Arguments

The user may invoke this skill with optional arguments:

- No args: discover all installations and present a menu
- Version shorthand: e.g., "2022", "2019", "2017" — filters to that VS version
- Architecture shorthand: e.g., "64-bit", "32-bit", "x64", "x86", "arm64"
- Combined: e.g., "2022 64-bit", "MSVC2019 32-bit"
- "status" or "info": show currently active MSVC env if any
- "clear" or "deactivate": remove the active MSVC env

User args: `{{ args }}`

## Step 1: Platform Check and Temp Directory

Verify we're on Windows and resolve the temp directory in a single Bash call:
```bash
uname -s && cygpath -u "$TEMP"
```
If `uname` output does not contain "MINGW", "MSYS", or "CYGWIN", tell the user this skill only works on Windows and stop.

Save the second line of output as `TMPDIR` — use this resolved path for ALL temp file operations in later steps (both Write tool and Bash commands). This avoids path mismatches between tools.

## Step 2: Handle "status" / "clear" Commands

If the user asked for **status/info**:
- Check if `.msvc_env.sh` exists in the project root
- If yes, read it and report which VS version/arch is active (look for the comment header)
- If no, report no MSVC environment is active
- Stop here.

If the user asked for **clear/deactivate**:
- Delete `.msvc_env.sh` from the project root if it exists
- Confirm deactivation
- Stop here.

## Step 3: Discover Installations

Scan for vcvars bat files and check for an existing `.msvc_env.sh` in a single Bash call:

```bash
echo "=== EXISTING ENV ===" && head -4 .msvc_env.sh 2>/dev/null || echo "(none)" && echo "=== INSTALLATIONS ===" && for dir in "/c/Program Files/Microsoft Visual Studio/"*/*"/VC/Auxiliary/Build" "/c/Program Files (x86)/Microsoft Visual Studio/"*/*"/VC/Auxiliary/Build"; do if [ -d "$dir" ]; then echo "--- $dir ---"; ls "$dir"/vcvars*.bat 2>/dev/null; fi; done
```

This searches:
- `C:\Program Files\Microsoft Visual Studio\{year}\{edition}\VC\Auxiliary\Build\`
- `C:\Program Files (x86)\Microsoft Visual Studio\{year}\{edition}\VC\Auxiliary\Build\`

Where `{year}` is 2017, 2019, 2022, 2025 (and any other year directories found) and `{edition}` is Professional, Enterprise, Community, BuildTools, Preview.

## Step 4: Parse & Select

From the discovered installations, build a list of available configurations. Each vcvars bat file maps to a specific configuration:

| Bat file | Host arch | Target arch | Description |
|----------|-----------|-------------|-------------|
| `vcvars32.bat` | x86 | x86 | 32-bit native tools, 32-bit output |
| `vcvars64.bat` | x64 | x64 | 64-bit native tools, 64-bit output |
| `vcvarsx86_amd64.bat` | x86 | x64 | 32-bit cross tools, 64-bit output |
| `vcvarsamd64_x86.bat` | x64 | x86 | 64-bit cross tools, 32-bit output |
| `vcvarsamd64_arm64.bat` | x64 | ARM64 | Cross-compile for ARM64 |
| `vcvarsall.bat` | (varies) | (varies) | Umbrella script (used internally) |

**If the user provided arguments**, try to match:
- Version number (2017/2019/2022/2025) filters the VS year
- "64-bit" or "x64" → prefer `vcvars64.bat` (native x64→x64)
- "32-bit" or "x86" → this is ambiguous! It could mean:
  - `vcvars32.bat` (x86 tools producing x86 output)
  - `vcvarsamd64_x86.bat` (x64 tools cross-compiling to x86 output)
  - Ask the user which they want. Frame it as: "Do you want native 32-bit tools (`vcvars32`) or 64-bit host cross-compiling to 32-bit (`vcvarsamd64_x86`)? The cross-compile option is usually faster on modern machines."
- "arm64" → `vcvarsamd64_arm64.bat`

**If no arguments or multiple installations found**, present a numbered menu like:
```
Found MSVC installations:

  VS 2022 Professional (C:\Program Files\Microsoft Visual Studio\2022\Professional)
    1) x64 native (vcvars64) — 64-bit tools → 64-bit output
    2) x86 native (vcvars32) — 32-bit tools → 32-bit output
    3) x64 → x86 cross (vcvarsamd64_x86) — 64-bit tools → 32-bit output
    4) x86 → x64 cross (vcvarsx86_amd64) — 32-bit tools → 64-bit output

  VS 2019 Professional (C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional)
    5) x64 native (vcvars64) — ...
    ...

Enter a number to activate:
```

## Step 5: Capture Environment

Once a vcvars bat is selected, capture the environment diff and generate `.msvc_env.sh`.

Use the `TMPDIR` resolved in Step 1 for ALL temp file paths — in EVERY tool call in this step. Do NOT use `/tmp/` anywhere; always substitute the resolved `TMPDIR`. This is critical because the Write tool and Bash may resolve `/tmp/` to different physical directories on Windows.

**Step 5a:** Capture before/after environments in a single Bash call. Replace `<TMPDIR>` with the bash-style path from Step 1 (e.g. `/c/Users/.../AppData/Local/Temp`), and `<VCVARS_BAT_PATH>` with the Windows-style path:

```bash
powershell.exe -NoProfile -Command "cmd /c 'set'" 2>&1 | sort > <TMPDIR>/msvc_env_before.txt && powershell.exe -NoProfile -Command "cmd /c '\"<VCVARS_BAT_PATH>\" >nul 2>&1 && set'" 2>&1 | sort > <TMPDIR>/msvc_env_after.txt && echo "Captured before/after environments"
```

**Step 5b:** Use the Write tool to create the Python diff script at `<TMPDIR>/gen_msvc_env.py` (use the **Windows-style** path for the Write tool, e.g. `C:/Users/.../AppData/Local/Temp/gen_msvc_env.py`). This handles diffing the environments, converting Windows PATH to bash format, and extracting only the new PATH entries.

```python
import sys, os
from datetime import datetime

BACKSLASH = chr(92)  # avoid literal backslash — gets mangled by Write tool

def parse_env(path):
    env = {}
    with open(path, encoding='utf-8', errors='replace') as f:
        for line in f:
            line = line.rstrip(chr(10)).rstrip(chr(13))
            if '=' in line:
                k, v = line.split('=', 1)
                env[k] = v
    return env

def win_to_bash_path(p):
    entries = p.split(';')
    bash_entries = []
    for e in entries:
        e = e.replace(BACKSLASH, '/')
        if len(e) >= 2 and e[1] == ':':
            e = '/' + e[0].lower() + e[2:]
        bash_entries.append(e)
    return ':'.join(bash_entries)

before = parse_env(sys.argv[1])
after = parse_env(sys.argv[2])
output_path = sys.argv[3]
label = sys.argv[4]
vcvars_path = sys.argv[5] if len(sys.argv) > 5 else "unknown"

lines = [
    '#!/bin/bash',
    f'# MSVC Environment: {label}',
    f'# Generated: {datetime.now().astimezone().isoformat()}',
    f'# Source: {vcvars_path}',
    '',
]

for k in sorted(after.keys()):
    if k not in before or before[k] != after[k]:
        v = after[k]
        if k == 'PATH':
            old_path = before.get('PATH', '')
            marker = old_path[:100]
            idx = v.find(marker)
            if idx > 0:
                new_prefix = v[:idx].rstrip(';')
                suffix_start = idx + len(old_path)
                new_suffix = v[suffix_start:].lstrip(';') if suffix_start < len(v) else ''
                prefix_bash = win_to_bash_path(new_prefix)
                if new_suffix:
                    suffix_bash = win_to_bash_path(new_suffix)
                    lines.append(f"export PATH='{prefix_bash}':\"$PATH\":'{suffix_bash}'")
                else:
                    lines.append(f"export PATH='{prefix_bash}':\"$PATH\"")
            else:
                v_bash = win_to_bash_path(v)
                lines.append(f"export PATH='{v_bash}'")
        else:
            v_escaped = v.replace("'", "'" + BACKSLASH + "''")
            lines.append(f"export {k}='{v_escaped}'")

with open(output_path, 'w', newline=chr(10)) as f:
    f.write(chr(10).join(lines) + chr(10))

print(f"OK: wrote {len(lines)} lines to {output_path}")
```

**Step 5c:** Run the script and clean up in a single Bash call (use the **bash-style** `TMPDIR` path here):

```bash
python <TMPDIR>/gen_msvc_env.py <TMPDIR>/msvc_env_before.txt <TMPDIR>/msvc_env_after.txt .msvc_env.sh "VS <YEAR> <EDITION> - <VCVARS_NAME> (<DESCRIPTION>)" "<VCVARS_BAT_PATH>" && rm -f <TMPDIR>/gen_msvc_env.py <TMPDIR>/msvc_env_before.txt <TMPDIR>/msvc_env_after.txt
```

## Step 6: Verify

After generating `.msvc_env.sh`, verify it works:

```bash
source .msvc_env.sh && cl 2>&1 | head -3
```

This should show the MSVC compiler version banner. Report the result to the user.

## Step 7: Gitignore

If `.gitignore` exists, check whether it already contains `.msvc_env.sh`. If not, append it:
```bash
grep -qxF '.msvc_env.sh' .gitignore 2>/dev/null || echo '.msvc_env.sh' >> .gitignore
```
If `.gitignore` does not exist, ask the user whether they'd like one created.

## Step 8: Confirm

Tell the user:
- Which VS version and architecture was activated
- That `.msvc_env.sh` was written to the project root
- That subsequent build commands (cmake, cl, nmake, ninja, msbuild, link) will automatically use this environment
- Whether `.msvc_env.sh` was added to `.gitignore` (or that it was already there)
- They can run `/msvc status` to check, `/msvc clear` to deactivate, or `/msvc <other args>` to switch

## Notes

- If `.msvc_env.sh` already exists when activating, warn the user it will be overwritten and which env was previously active.
- The `vcvarsall.bat` entry should generally not be shown in the menu — it's the umbrella script. The specific vcvars scripts are more explicit.
- Always use Windows-style paths (backslashes) when invoking bat files via cmd.exe/powershell, but Unix-style paths in the generated bash env script where appropriate.
