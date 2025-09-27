# Lars' Dotfiles

My personal dotfiles for macOS, managed with GNU Stow.

## Installation

1. Install Homebrew (if not already installed):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Clone this repository:
```bash
git clone https://github.com/lars-tice/dotfiles.git ~/dotfiles
```

3. Run the installation script:
```bash
cd ~/dotfiles
./install.sh
```

## What's Included

### Configurations
- **zsh**: Shell configuration with aliases and environment variables
- **git**: Git configuration with delta for better diffs
- **nvim**: Neovim configuration with LazyVim, Tokyo Night theme, and Telescope integrations
- **ghostty**: Ghostty terminal configuration with transparency and Tokyo Night theme
- **aerospace**: AeroSpace tiling window manager configuration
- **starship**: Cross-shell prompt with Git integration and Tokyo Night theme
- **tmux**: Terminal multiplexer with custom keybindings and Tokyo Night theme

### Command Line Tools
- **bat**: Better `cat` with syntax highlighting
- **eza**: Modern `ls` replacement with icons
- **atuin**: Shell history database with search
- **zoxide**: Smarter `cd` that learns your habits
- **git-delta**: Better git diffs with syntax highlighting
- **uv**: Fast Python package manager by Astral
- **glow**: Beautiful markdown reader for terminal

## Manual Stowing

To stow individual configurations:

```bash
cd ~/dotfiles
stow zsh
stow git
stow nvim
stow ghostty
stow aerospace
stow starship
stow tmux
```

To unstow (remove symlinks):
```bash
stow -D zsh
```

## Dependencies

The install script will install these via Homebrew:

### Core Tools
- git
- gh (GitHub CLI)
- neovim
- stow

### Development Tools
- ripgrep
- fd
- fzf
- lazygit
- git-delta
- uv
- glow

### Shell Enhancements
- starship
- bat
- tmux
- atuin
- eza
- zoxide

### GUI Applications
- ghostty
- aerospace

### Fonts
- JetBrains Mono Nerd Font