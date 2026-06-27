#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/robparrott/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

# Files to symlink into $HOME
DOTFILES=(
    .bash_profile
    .bashrc
    .emacs
    .emacs.d
    .gitignore
    .screenrc
    .tmux
    .tmux.conf
    .zprofile
    .zshrc
)

info()    { echo "[dotfiles] $*"; }
success() { echo "[dotfiles] ✓ $*"; }
warning() { echo "[dotfiles] ! $*"; }

backup_and_link() {
    local src="$1"
    local dst="$2"

    # Already the correct symlink — nothing to do
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
        return
    fi

    # Back up existing file/dir
    if [[ -e "$dst" || -L "$dst" ]]; then
        local backup="${dst}.bak.$(date +%Y%m%d%H%M%S)"
        warning "Backing up existing $dst -> $backup"
        mv "$dst" "$backup"
    fi

    ln -s "$src" "$dst"
    success "Linked $dst -> $src"
}

# ── 1. Clone or update the repo ──────────────────────────────────────────────

if [[ -d "$DOTFILES_DIR/.git" ]]; then
    info "Updating existing dotfiles repo at $DOTFILES_DIR"
    git -C "$DOTFILES_DIR" pull --ff-only
else
    info "Cloning dotfiles to $DOTFILES_DIR"
    git clone "$REPO" "$DOTFILES_DIR"
fi

# ── 2. Symlink dotfiles into $HOME ────────────────────────────────────────────

info "Symlinking dotfiles..."
for f in "${DOTFILES[@]}"; do
    src="$DOTFILES_DIR/$f"
    dst="$HOME/$f"
    if [[ -e "$src" ]]; then
        backup_and_link "$src" "$dst"
    else
        warning "Skipping $f (not found in repo)"
    fi
done

# ── 3. Platform-specific setup ────────────────────────────────────────────────

if [[ "$(uname)" == "Darwin" ]]; then
    info "macOS detected"
    # Ensure 1Password SSH agent socket is configured
    if [[ ! -f "$HOME/.ssh/config" ]] || ! grep -q "1password" "$HOME/.ssh/config" 2>/dev/null; then
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        info "Adding 1Password SSH agent to ~/.ssh/config"
        cat >> "$HOME/.ssh/config" <<'EOF'

# 1Password SSH agent
Host *
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
EOF
        chmod 600 "$HOME/.ssh/config"
    fi
elif [[ "$(uname)" == "Linux" ]]; then
    info "Linux detected"
fi

success "Done. Open a new shell or run: source ~/.zshrc  (or ~/.bash_profile)"
