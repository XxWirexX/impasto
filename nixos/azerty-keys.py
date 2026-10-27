#!/usr/bin/env python3
"""nixos: put the AZERTY shortcuts into the profiles and settings in $HOME.

The shell's profiles carry their own shortcuts, and these win over
keybinds.lua. The repository's profiles are fixed already; the copies in
~/.local/share/impasto/profiles and the active settings in
~/.local/state/quickshell/settings.json are not, so this rewrites them:

  - workspaces: SUPER + 1..0 -> the physical keys of that row (code:10..19),
    since AZERTY only types the digits with SHIFT
  - emoji: SUPER + period -> SUPER + semicolon, the same key without SHIFT

Run it again after rebinding one of those from the shell, then restart the
shell (SUPER + CTRL + R).
"""

import glob
import json
import os
import re

HOME = os.path.expanduser("~")
DATA = os.environ.get("XDG_DATA_HOME") or os.path.join(HOME, ".local/share")
STATE = os.environ.get("XDG_STATE_HOME") or os.path.join(HOME, ".local/state")

WORKSPACE = re.compile(r'("Workspaces · (?:Go to|Move the window to) workspace \d+":\s*)"SUPER \+ (SHIFT \+ )?(\d)"')
EMOJI = re.compile(r'("Shell · Pick an emoji":\s*)"SUPER \+ period"')


def fix(text):
    text, workspaces = WORKSPACE.subn(
        lambda m: f'{m.group(1)}"SUPER + {m.group(2) or ""}code:{9 + (int(m.group(3)) or 10)}"', text)
    text, emoji = EMOJI.subn(lambda m: f'{m.group(1)}"SUPER + semicolon"', text)
    return text, workspaces + emoji


def main():
    files = sorted(glob.glob(os.path.join(DATA, "impasto/profiles/*.json")))
    files.append(os.path.join(STATE, "quickshell/settings.json"))
    for path in files:
        if not os.path.isfile(path):
            continue
        with open(path, encoding="utf-8") as source:
            text = source.read()
        fixed, count = fix(text)
        if count:
            json.loads(fixed)  # never write a broken file
            with open(path, "w", encoding="utf-8") as target:
                target.write(fixed)
        print(f"{count:3d} shortcut(s)  {path}")
    print("Now restart the shell: SUPER + CTRL + R")


if __name__ == "__main__":
    main()
