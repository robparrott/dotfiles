#!/usr/bin/env bash
# Powerline session list: wedge printed AFTER each segment (fg=segment_bg, bg=next_bg).
# Active: yellow (colour220) / black. Inactive: dark blue (colour24) / white.

ACTIVE=$(tmux display-message -p '#S')
BAR_BG="colour235"
ACTIVE_BG="colour220"
ACTIVE_FG="colour232"
INACTIVE_BG="colour24"
INACTIVE_FG="colour255"

sessions=()
while IFS= read -r s; do sessions+=("$s"); done < <(tmux list-sessions -F '#S' 2>/dev/null)

output=""
for i in "${!sessions[@]}"; do
    session="${sessions[$i]}"
    if [[ "$session" == "$ACTIVE" ]]; then bg="$ACTIVE_BG"; fg="$ACTIVE_FG"
    else bg="$INACTIVE_BG"; fg="$INACTIVE_FG"; fi
    next="${sessions[$(( i+1 ))]}"; 
    if [[ -n "$next" ]]; then
        [[ "$next" == "$ACTIVE" ]] && next_bg="$ACTIVE_BG" || next_bg="$INACTIVE_BG"
    else
        # Use active window bg if first window is active, else inactive bg
        first_active=$(tmux list-windows -F "#{window_index} #{window_active}" | awk "\$1==1{print \$2}")
        [[ "$first_active" == "1" ]] && next_bg="colour31" || next_bg="colour24"
    fi
    output+="#[fg=${fg},bg=${bg},bold] ${session} #[fg=${bg},bg=${next_bg},nobold]"
done

printf '%s' "$output"
