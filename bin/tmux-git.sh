#!/usr/bin/env bash
# Show git branch and dirty status for the current pane's directory.
# Called by tmux status-right via #(~/.dotfiles/bin/tmux-git.sh #{pane_current_path})

dir="${1:-$PWD}"
cd "$dir" 2>/dev/null || exit 0

branch=$(git symbolic-ref --short HEAD 2>/dev/null) || exit 0

dirty=""
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    dirty="*"
fi

echo " ${branch}${dirty}"
