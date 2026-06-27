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
error()   { echo "[dotfiles] ✗ $*" >&2; }

# Ask a yes/no question; return 0 for yes, 1 for no
ask() {
    local prompt="$1"
    local default="${2:-y}"   # y or n
    local yn
    if [[ "$default" == "y" ]]; then
        read -r -p "[dotfiles] $prompt [Y/n] " yn
        [[ "${yn:-y}" =~ ^[Yy]$ ]]
    else
        read -r -p "[dotfiles] $prompt [y/N] " yn
        [[ "${yn:-n}" =~ ^[Yy]$ ]]
    fi
}

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
    success "Linked $dst"
}

# ── 1. Ensure git is available ────────────────────────────────────────────────

if ! command -v git &>/dev/null; then
    error "git is required but not installed. Install git and re-run."
    exit 1
fi

# ── 2. Ensure Homebrew is available (macOS) ───────────────────────────────────

install_homebrew() {
    if command -v brew &>/dev/null; then
        return 0
    fi

    if [[ "$(uname)" != "Darwin" ]]; then
        return 0
    fi

    warning "Homebrew is not installed."
    if ask "Install Homebrew now?"; then
        info "Installing Homebrew..."
        if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            # Add brew to PATH for the rest of this script
            eval "$(/opt/homebrew/bin/brew shellenv bash)" 2>/dev/null || \
            eval "$(/usr/local/bin/brew shellenv bash)"    2>/dev/null || true
            success "Homebrew installed"
        else
            error "Homebrew installation failed. Continuing without it."
        fi
    else
        info "Skipping Homebrew installation."
    fi
}

# ── 3. Clone or update the repo ──────────────────────────────────────────────

clone_or_update() {
    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        info "Updating existing dotfiles repo at $DOTFILES_DIR"
        if ! git -C "$DOTFILES_DIR" pull --ff-only; then
            error "git pull failed — repo may have local changes. Continuing with current state."
        fi
    else
        info "Cloning dotfiles to $DOTFILES_DIR"
        if ! git clone "$REPO" "$DOTFILES_DIR"; then
            error "Failed to clone $REPO"
            exit 1
        fi
    fi
}

# ── 4. Symlink dotfiles into $HOME ────────────────────────────────────────────

link_dotfiles() {
    info "Symlinking dotfiles into $HOME..."
    for f in "${DOTFILES[@]}"; do
        local src="$DOTFILES_DIR/$f"
        local dst="$HOME/$f"
        if [[ -e "$src" ]]; then
            backup_and_link "$src" "$dst"
        else
            warning "Skipping $f (not in repo)"
        fi
    done
}

# ── 5. Platform-specific setup ────────────────────────────────────────────────

platform_setup() {
    if [[ "$(uname)" == "Darwin" ]]; then
        info "macOS detected"
        # 1Password SSH agent
        if ! grep -q "1password" "$HOME/.ssh/config" 2>/dev/null; then
            mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
            info "Adding 1Password SSH agent to ~/.ssh/config"
            cat >> "$HOME/.ssh/config" <<'EOF'

# 1Password SSH agent
Host *
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
EOF
            chmod 600 "$HOME/.ssh/config"
            success "Updated ~/.ssh/config"
        fi
    elif [[ "$(uname)" == "Linux" ]]; then
        info "Linux detected"
    fi
}

# ── 6. Optionally install packages ────────────────────────────────────────────

maybe_install_packages() {
    local packages_script="$DOTFILES_DIR/packages.sh"

    if [[ ! -x "$packages_script" ]]; then
        warning "packages.sh not found or not executable, skipping"
        return
    fi

    echo ""
    if ask "Install packages via packages.sh?"; then
        info "Running packages.sh..."
        if ! bash "$packages_script"; then
            error "packages.sh encountered errors. Some packages may not have installed."
        else
            success "Package installation complete"
        fi
    else
        info "Skipping package installation. You can run it later:"
        info "  bash ~/.dotfiles/packages.sh"
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────

echo ""
echo "  dotfiles installer"
echo "  repo: $REPO"
echo "  destination: $DOTFILES_DIR"
echo ""

install_homebrew
clone_or_update
link_dotfiles
platform_setup
maybe_install_packages

echo ""
success "All done! Open a new shell or run:"
info "  source ~/.zshrc      # zsh"
info "  source ~/.bash_profile  # bash"
echo ""
