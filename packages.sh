#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# packages.sh — Install common packages across macOS and Linux
#
# Usage:
#   ./packages.sh           # install everything for this platform
#   ./packages.sh --dry-run # show what would be installed
# =============================================================================

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

info()    { echo "[packages] $*"; }
success() { echo "[packages] ✓ $*"; }
warning() { echo "[packages] ! $*"; }
skip()    { echo "[packages] - (dry-run) would install: $*"; }

# ── macOS / Homebrew ──────────────────────────────────────────────────────────

BREW_FORMULAE=(
    # Shell & terminal
    tmux
    starship
    ripgrep
    gh
    whois
    gettext

    # Editors
    emacs

    # Languages & runtimes
    python@3.14

    # Security & networking
    ca-certificates
    openssl@3
    tailscale

    # Media (remove if not needed)
    ffmpeg

    # AI / local models
    ollama
)

BREW_CASKS=(
    # Fonts (needed for tmux-powerline glyphs)
    font-jetbrains-mono-nerd-font

    # Productivity & utilities
    1password
    1password-cli
    google-drive
    iterm2
    zed

    # Browsers
    google-chrome

    # AI tools
    claude
    claude-code
    chatgpt
    lm-studio

    # Containers
    docker-desktop
)

install_brew_packages() {
    # Ensure Homebrew is installed
    if ! command -v brew &>/dev/null; then
        if $DRY_RUN; then
            skip "Homebrew (not installed)"
            return
        fi
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv bash)" 2>/dev/null || \
        eval "$(/usr/local/bin/brew shellenv bash)"    2>/dev/null || true
    fi

    info "Updating Homebrew..."
    $DRY_RUN || brew update -q

    info "Installing formulae..."
    for pkg in "${BREW_FORMULAE[@]}"; do
        if $DRY_RUN; then
            skip "$pkg"
        elif brew list --formula "$pkg" &>/dev/null; then
            info "$pkg already installed"
        else
            info "Installing $pkg..."
            brew install "$pkg" && success "$pkg"
        fi
    done

    info "Installing casks..."
    for cask in "${BREW_CASKS[@]}"; do
        if $DRY_RUN; then
            skip "$cask (cask)"
        elif brew list --cask "$cask" &>/dev/null; then
            info "$cask already installed"
        else
            info "Installing $cask..."
            brew install --cask "$cask" && success "$cask"
        fi
    done
}

# ── Linux / apt (Debian, Ubuntu) ──────────────────────────────────────────────

APT_PACKAGES=(
    # Shell & terminal
    tmux
    ripgrep
    curl
    wget
    git

    # Security & networking
    ca-certificates
    openssl

    # Editors
    emacs

    # Languages
    python3
    python3-pip
)

install_apt_packages() {
    if ! command -v apt-get &>/dev/null; then
        warning "apt-get not found, skipping"
        return
    fi

    info "Updating apt..."
    $DRY_RUN || sudo apt-get update -q

    for pkg in "${APT_PACKAGES[@]}"; do
        if $DRY_RUN; then
            skip "$pkg"
        elif dpkg -s "$pkg" &>/dev/null 2>&1; then
            info "$pkg already installed"
        else
            info "Installing $pkg..."
            sudo apt-get install -y "$pkg" && success "$pkg"
        fi
    done
}

# ── Linux / dnf (Fedora, RHEL) ───────────────────────────────────────────────

DNF_PACKAGES=(
    tmux
    ripgrep
    curl
    wget
    git
    ca-certificates
    openssl
    emacs
    python3
    python3-pip
)

install_dnf_packages() {
    if ! command -v dnf &>/dev/null; then
        warning "dnf not found, skipping"
        return
    fi

    for pkg in "${DNF_PACKAGES[@]}"; do
        if $DRY_RUN; then
            skip "$pkg"
        elif rpm -q "$pkg" &>/dev/null 2>&1; then
            info "$pkg already installed"
        else
            info "Installing $pkg..."
            sudo dnf install -y "$pkg" && success "$pkg"
        fi
    done
}

# ── Dispatch ──────────────────────────────────────────────────────────────────

case "$(uname)" in
    Darwin)
        info "macOS detected — using Homebrew"
        install_brew_packages
        ;;
    Linux)
        info "Linux detected"
        if command -v apt-get &>/dev/null; then
            info "Using apt"
            install_apt_packages
        elif command -v dnf &>/dev/null; then
            info "Using dnf"
            install_dnf_packages
        else
            warning "No supported package manager found (apt, dnf). Add your distro above."
            exit 1
        fi
        ;;
    *)
        warning "Unsupported platform: $(uname)"
        exit 1
        ;;
esac

success "All done."
