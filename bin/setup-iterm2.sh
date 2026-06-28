#!/usr/bin/env bash
# Configure iTerm2 via a Dynamic Profile — picked up live, no restart needed.
# Sets a Nerd Font so tmux-powerline glyphs render correctly.

FONT="${1:-JetBrainsMonoNerdFontMono-Regular}"
FONT_SIZE="${2:-13}"
PROFILE_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
PROFILE_FILE="$PROFILE_DIR/dotfiles.json"

if [[ "$(uname)" != "Darwin" ]]; then
    echo "[iterm2] Not macOS, skipping"
    exit 0
fi

if ! pgrep -q iTerm2 && [[ ! -d "/Applications/iTerm.app" ]]; then
    echo "[iterm2] iTerm2 not installed, skipping"
    exit 0
fi

mkdir -p "$PROFILE_DIR"

cat > "$PROFILE_FILE" <<EOF
{
  "Profiles": [
    {
      "Name": "dotfiles",
      "Guid": "dotfiles-dynamic-profile",
      "Dynamic Profile Parent Name": "Default",
      "Normal Font": "$FONT $FONT_SIZE",
      "Use Non-ASCII Font": false,
      "Use Bold Font": true,
      "Use Italic Font": true
    }
  ]
}
EOF

echo "[iterm2] ✓ Dynamic profile written to $PROFILE_FILE"
echo "[iterm2]   Font: $FONT $FONT_SIZE"

# Set as the default profile by writing the GUID to iTerm2 preferences
defaults write com.googlecode.iterm2 "Default Bookmark Guid" "dotfiles-dynamic-profile"
echo "[iterm2] ✓ Set as default profile (new windows will use it)"
echo "[iterm2]   To apply to existing windows: Profiles > dotfiles > Set as Default"
