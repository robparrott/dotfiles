# =============================================================================
# HOMEBREW
# =============================================================================

for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x "$_brew" ]] && eval "$($_brew shellenv zsh)" && break
done
unset _brew

# =============================================================================
# PATH
# =============================================================================

# Homebrew takes precedence, then local bin
PATH="$HOME/bin:$PATH"
export PATH

# =============================================================================
# EDITOR
# =============================================================================

if   command -v emacs &>/dev/null; then EDITOR=emacs
elif command -v vim   &>/dev/null; then EDITOR=vim
else                                    EDITOR=vi
fi
export EDITOR

# =============================================================================
# ALIASES
# =============================================================================

alias dotfiles="ls -ldF .[a-zA-Z0-9]*"
alias j="jobs -l"
alias k9="kill -9"
alias ll="ls -lah"
alias ls="ls -G"

# =============================================================================
# TMUX: auto-attach on SSH login
# =============================================================================

if [[ -n "$SSH_CONNECTION" ]] && [[ -z "$TMUX" ]]; then
    if command -v tmux &>/dev/null; then
        tmux attach-session -t main 2>/dev/null || tmux new-session -s main
    fi
fi
