#!/usr/bin/env bash
# Output all tmux sessions for status-left with powerline wedge separators.
# Active session: yellow bg, black text. Inactive: dark blue bg, white text.

ACTIVE=$(tmux display-message -p '#S')
BAR_BG="colour235"
ACTIVE_BG="colour220"
ACTIVE_FG="colour232"
INACTIVE_BG="colour24"
INACTIVE_FG="colour255"
WEDGE=""

prev_bg=""
output=""

while IFS= read -r session; do
    if [[ "$session" == "$ACTIVE" ]]; then
        bg="$ACTIVE_BG"
        fg="$ACTIVE_FG"
    else
        bg="$INACTIVE_BG"
        fg="$INACTIVE_FG"
    fi

    if [[ -z "$prev_bg" ]]; then
        output+="#[fg=${fg},bg=${bg},bold] ${session} "
    else
        output+="#[fg=${prev_bg},bg=${bg},nobold]${WEDGE}#[fg=${fg},bg=${bg},bold] ${session} "
    fi
    prev_bg="$bg"
done < <(tmux list-sessions -F '#S' 2>/dev/null)

output+="#[fg=${prev_bg},bg=${BAR_BG},nobold]"

printf '%s' "$output"
