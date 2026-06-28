#!/usr/bin/env python3
"""
Convert starship prompt ANSI output to tmux status-bar format strings.
Usage: starship-tmux.py <path>
"""
import subprocess, sys, re, os

path = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("PWD", os.path.expanduser("~"))
config = os.path.expanduser("~/.config/starship-tmux.toml")

env = os.environ.copy()
env["STARSHIP_CONFIG"] = config

result = subprocess.run(
    ["starship", "prompt", "--path", path],
    capture_output=True, text=True, env=env
)
raw = result.stdout.rstrip("\n")

# Parse ANSI SGR sequences and convert to tmux #[...] format strings
# Handles: reset (0), bold (1), fg RGB (38;2;r;g;b), bg RGB (48;2;r;g;b)
output = []
i = 0
while i < len(raw):
    if raw[i] == '\x1b' and i + 1 < len(raw) and raw[i+1] == '[':
        # Find end of escape sequence
        j = i + 2
        while j < len(raw) and raw[j] not in 'mM':
            j += 1
        codes = raw[i+2:j].split(';')
        tmux_attrs = []
        k = 0
        while k < len(codes):
            c = codes[k]
            if c == '0' or c == '':
                tmux_attrs.append('default')
            elif c == '1':
                tmux_attrs.append('bold')
            elif c == '38' and k+1 < len(codes) and codes[k+1] == '2':
                r, g, b = codes[k+2], codes[k+3], codes[k+4]
                tmux_attrs.append(f'fg=#{int(r):02x}{int(g):02x}{int(b):02x}')
                k += 4
            elif c == '48' and k+1 < len(codes) and codes[k+1] == '2':
                r, g, b = codes[k+2], codes[k+3], codes[k+4]
                tmux_attrs.append(f'bg=#{int(r):02x}{int(g):02x}{int(b):02x}')
                k += 4
            k += 1
        if tmux_attrs:
            output.append('#[' + ','.join(tmux_attrs) + ']')
        i = j + 1
    else:
        output.append(raw[i])
        i += 1

print(''.join(output), end='')
