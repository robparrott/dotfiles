#!/usr/bin/env bash
# Output all tmux sessions for status-left with powerline wedge separators.
# Active session: colour31 (steel blue). Inactive: colour24 (dark blue).

ACTIVE=$(tmux display-message -p '#S')
BAR_BG="colour235"
ACTIVE_BG="colour31"
INACTIVE_BG="colour24"
FG="colour255"
WEDGE=""

prev_bg=""
output=""

while IFS= read -r session; do
    if [[ "$session" == "$ACTIVE" ]]; then
        bg="$ACTIVE_BG"
    else
        bg="$INACTIVE_BG"
    fi

    if [[ -z "$prev_bg" ]]; then
        output+="#[fg=${FG},bg=${bg},bold] ${session} "
    else
        output+="#[fg=${prev_bg},bg=${bg},nobold]${WEDGE}#[fg=${FG},bg=${bg},bold] ${session} "
    fi
    prev_bg="$bg"
done < <(tmux list-sessions -F '#S' 2>/dev/null)

# Final wedge into bar background
output+="#[fg=${prev_bg},bg=${BAR_BG},nobold]${WEDGE}"

printf '%s' "$output"
