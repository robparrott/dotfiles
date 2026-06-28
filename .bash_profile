
# Source global definitions
[ -f /etc/bashrc ]      && . /etc/bashrc
[ -f /etc/bash.bashrc ] && . /etc/bash.bashrc
[ -f "$HOME/.bashrc" ]  && . "$HOME/.bashrc"

# =============================================================================
# PATH
# =============================================================================

# Homebrew (Apple Silicon)
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv bash)"
# Homebrew (Intel)
[ -d /usr/local/Cellar ] && PATH="/usr/local/bin:$PATH"

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
# SHELL OPTIONS
# =============================================================================

shopt -s checkwinsize cdable_vars cmdhist histappend extglob

export HISTCONTROL=ignoreboth
export HISTIGNORE="&:bg:fg:ll:h"

# =============================================================================
# PROMPT
# =============================================================================

PS1='\u@\h:\w\$ '

# =============================================================================
# ALIASES
# =============================================================================

alias dotfiles="ls -ldF .[a-zA-Z0-9]*"
alias j="jobs -l"
alias k9="kill -9"
alias ll="ls -lah"

# Color ls on Linux
if [ "$(uname)" = "Linux" ]; then
    alias ls='ls --color=auto'
fi

# =============================================================================
# STARSHIP PROMPT
# =============================================================================

if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi

# =============================================================================
# TMUX: auto-attach on SSH login
# =============================================================================

if [ -n "$SSH_CONNECTION" ] && [ -z "$TMUX" ] && [ "$TERM" != "screen" ]; then
    if command -v tmux &>/dev/null; then
        tmux attach-session -t main 2>/dev/null || tmux new-session -s main
    fi
fi
