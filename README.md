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

- **zsh**: Shell configuration with aliases and environment variables
- **git**: Git configuration and aliases
- **nvim**: Neovim configuration with LazyVim
- **ghostty**: Ghostty terminal configuration
- **aerospace**: AeroSpace tiling window manager configuration
- **starship**: Cross-shell prompt with Git integration and customization

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
```

To unstow (remove symlinks):
```bash
stow -D zsh
```

## Dependencies

The install script will install these via Homebrew:
- git
- gh (GitHub CLI)
- neovim
- stow
- ripgrep
- fd
- fzf
- lazygit
- starship
- ghostty
- aerospace
- JetBrains Mono Nerd Font