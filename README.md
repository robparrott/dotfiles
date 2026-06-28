# dotfiles

Personal shell and terminal configuration for macOS (and Linux).

## What's included

| File / Dir | Purpose |
|---|---|
| `.zshrc` / `.zprofile` | Zsh shell config |
| `.bash_profile` / `.bashrc` | Bash shell config |
| `.tmux.conf` | tmux config with powerline status bar |
| `.emacs` / `.emacs.d/` | Emacs config and modes |
| `.screenrc` | GNU Screen config |
| `.ssh/config` | SSH client config (1Password agent) |
| `.config/starship/` | [Starship](https://starship.rs) prompt config |
| `bin/` | Helper scripts (tmux powerline segments, iTerm2 setup) |

## tmux status bar

The status bar uses [Nerd Font](https://www.nerdfonts.com) powerline glyphs:

- **Left**: one segment per tmux session — active session in yellow, inactive in dark blue
- **Center**: window tabs with wedge separators — active window in bright blue, inactive in dark blue
- **Right**: Starship prompt segments (host, IP, time)

Requires a Nerd Font installed and configured in your terminal (iTerm2 setup is automated via `bin/setup-iterm2.sh`).

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/robparrott/dotfiles/master/install.sh | bash
```

Or clone manually:

```bash
git clone https://github.com/robparrott/dotfiles.git ~/.dotfiles
bash ~/.dotfiles/install.sh
```

The installer will:
1. Clone the repo to `~/.dotfiles`
2. Symlink dotfiles into `$HOME`
3. Install TPM and tmux plugins
4. Optionally run `packages.sh` to install Homebrew formulae and casks

## Packages

`packages.sh` installs common tools via Homebrew (macOS) or apt (Linux):

```bash
bash ~/.dotfiles/packages.sh          # install
bash ~/.dotfiles/packages.sh --dry-run  # preview
```

## Requirements

- macOS or Linux
- `git`
- [Homebrew](https://brew.sh) (macOS, auto-installed if missing)
- A [Nerd Font](https://www.nerdfonts.com) for powerline glyphs in tmux
