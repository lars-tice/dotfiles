#!/bin/bash

# Dotfiles installation script

set -e  # Exit on error

echo "🚀 Starting dotfiles installation..."

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "📦 Installing dependencies via Homebrew..."

# Core tools
brew install git gh neovim stow

# Security tools
brew install gnupg git-crypt

# Development tools
brew install ripgrep fd fzf lazygit git-delta uv glow

# Shell enhancements
brew install starship bat tmux atuin eza zoxide

# Terminal and window manager
brew install --cask ghostty
brew install --cask nikitabobko/tap/aerospace

# Fonts
brew install --cask font-jetbrains-mono-nerd-font

# Install fzf shell integration
$(brew --prefix)/opt/fzf/install --all --no-bash --no-fish --no-update-rc

echo "🔗 Stowing dotfiles..."

# Remove existing files if they exist (backup first)
for config in .zshrc .gitconfig .fzf.zsh; do
    if [ -f ~/$config ] && [ ! -L ~/$config ]; then
        echo "Backing up existing $config to $config.backup"
        mv ~/$config ~/$config.backup
    fi
done

# Stow configurations
stow zsh
stow git
stow nvim
stow ghostty
stow aerospace
stow starship
stow tmux
stow karabiner

echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "1. Restart your terminal"
echo "2. Open Neovim (nvim) to install plugins"
echo "3. Configure Git with your user info:"
echo "   git config --global user.name 'Your Name'"
echo "   git config --global user.email 'your.email@example.com'"