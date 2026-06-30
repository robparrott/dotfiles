#!/usr/bin/env bash
set -uo pipefail

# =============================================================================
# packages.sh — Install common packages across macOS and Linux
#
# Usage:
#   ./packages.sh [--cli|--desktop|--all] [--dry-run]
#
#   --cli       CLI tools only (safe for headless/servers)
#   --desktop   GUI apps and fonts only
#   --all       Everything (default when run interactively)
#   --dry-run   Print what would be installed without installing
# =============================================================================

DRY_RUN=false
MODE=""

for arg in "${@:-}"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --cli)     MODE=cli ;;
        --desktop) MODE=desktop ;;
        --all)     MODE=all ;;
    esac
done

info()    { echo "[packages] $*"; }
success() { echo "[packages] ✓ $*"; }
warning() { echo "[packages] ! $*"; }
error()   { echo "[packages] ✗ $*" >&2; }
skip()    { echo "[packages] - (dry-run) would install: $*"; }

ask() {
    local prompt="$1" default="${2:-y}" yn input=/dev/tty
    ( : </dev/tty ) 2>/dev/null || input=/dev/stdin
    if [[ "$default" == "y" ]]; then
        read -r -p "[packages] $prompt [Y/n] " yn <"$input"
        [[ "${yn:-y}" =~ ^[Yy]$ ]]
    else
        read -r -p "[packages] $prompt [y/N] " yn <"$input"
        [[ "${yn:-n}" =~ ^[Yy]$ ]]
    fi
}

ask_mode() {
    echo ""
    echo "[packages] What would you like to install?"
    echo "  1) CLI only    — terminal tools, suitable for headless servers"
    echo "  2) Desktop only — GUI apps and fonts"
    echo "  3) All          — CLI + desktop"
    echo ""
    local choice
    local input=/dev/tty; ( : </dev/tty ) 2>/dev/null || input=/dev/stdin
    read -r -p "[packages] Choice [1/2/3] (default: 3): " choice <"$input"
    case "${choice:-3}" in
        1) MODE=cli ;;
        2) MODE=desktop ;;
        *) MODE=all ;;
    esac
    info "Installing: $MODE"
    echo ""
}

FAILED=()

# ── macOS / Homebrew ──────────────────────────────────────────────────────────

BREW_CLI=(
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

    # Media
    ffmpeg

    # AI / local models
    ollama
)

BREW_DESKTOP=(
    # Fonts (needed for tmux-powerline glyphs)
    font-jetbrains-mono-nerd-font

    # Productivity & utilities
    1password
    1password-cli
    google-drive
    iterm2
    zed
    zoom

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

brew_install() {
    local pkg="$1" cask="${2:-}"
    if $DRY_RUN; then
        skip "$pkg${cask:+ (cask)}"
    elif [[ -n "$cask" ]] && brew list --cask "$pkg" &>/dev/null; then
        info "$pkg already installed"
    elif [[ -z "$cask" ]] && brew list --formula "$pkg" &>/dev/null; then
        info "$pkg already installed"
    else
        info "Installing $pkg..."
        if brew install ${cask:+--cask} "$pkg"; then
            success "$pkg"
        else
            error "$pkg failed — continuing"
            FAILED+=("$pkg")
        fi
    fi
}

install_brew_packages() {
    if ! command -v brew &>/dev/null; then
        if $DRY_RUN; then skip "Homebrew (not installed)"; return; fi
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv bash)" 2>/dev/null || \
        eval "$(/usr/local/bin/brew shellenv bash)"    2>/dev/null || true
    fi

    $DRY_RUN || brew update -q

    if [[ "$MODE" == "cli" || "$MODE" == "all" ]]; then
        info "Installing CLI formulae..."
        for pkg in "${BREW_CLI[@]}"; do brew_install "$pkg"; done
    fi

    if [[ "$MODE" == "desktop" || "$MODE" == "all" ]]; then
        info "Installing desktop casks..."
        for pkg in "${BREW_DESKTOP[@]}"; do brew_install "$pkg" cask; done
    fi
}

# ── Linux / apt (Debian, Ubuntu) ──────────────────────────────────────────────

APT_CLI=(
    tmux
    ripgrep
    curl
    wget
    git
    emacs
    python3
    python3-pip
    ca-certificates
    openssl
)

APT_DESKTOP=(
    # Add Linux desktop packages here as needed
)

install_apt_packages() {
    if ! command -v apt-get &>/dev/null; then warning "apt-get not found, skipping"; return; fi

    $DRY_RUN || sudo apt-get update -q

    local pkgs=()
    [[ "$MODE" == "cli"     || "$MODE" == "all" ]] && pkgs+=("${APT_CLI[@]}")
    [[ "$MODE" == "desktop" || "$MODE" == "all" ]] && [[ ${#APT_DESKTOP[@]} -gt 0 ]] && pkgs+=("${APT_DESKTOP[@]}")

    for pkg in "${pkgs[@]}"; do
        if $DRY_RUN; then
            skip "$pkg"
        elif dpkg -s "$pkg" &>/dev/null 2>&1; then
            info "$pkg already installed"
        else
            info "Installing $pkg..."
            if sudo apt-get install -y "$pkg"; then success "$pkg"
            else error "$pkg failed — continuing"; FAILED+=("$pkg"); fi
        fi
    done
}

# ── Linux / dnf (Fedora, RHEL) ───────────────────────────────────────────────

DNF_CLI=(
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

DNF_DESKTOP=(
    # Add Linux desktop packages here as needed
)

install_dnf_packages() {
    if ! command -v dnf &>/dev/null; then warning "dnf not found, skipping"; return; fi

    local pkgs=()
    [[ "$MODE" == "cli"     || "$MODE" == "all" ]] && pkgs+=("${DNF_CLI[@]}")
    [[ "$MODE" == "desktop" || "$MODE" == "all" ]] && [[ ${#DNF_DESKTOP[@]} -gt 0 ]] && pkgs+=("${DNF_DESKTOP[@]}")

    for pkg in "${pkgs[@]}"; do
        if $DRY_RUN; then
            skip "$pkg"
        elif rpm -q "$pkg" &>/dev/null 2>&1; then
            info "$pkg already installed"
        else
            info "Installing $pkg..."
            if sudo dnf install -y "$pkg"; then success "$pkg"
            else error "$pkg failed — continuing"; FAILED+=("$pkg"); fi
        fi
    done
}

# ── Mode selection ────────────────────────────────────────────────────────────

[[ -z "$MODE" ]] && ask_mode

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

if [[ ${#FAILED[@]} -gt 0 ]]; then
    error "The following packages failed to install:"
    for pkg in "${FAILED[@]}"; do error "  - $pkg"; done
    exit 1
fi

success "All done."
