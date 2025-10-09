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
echo "📦 Installing core tools..."
for pkg in git gh neovim stow; do
    if ! brew list | grep -q "^$pkg$"; then
        brew install "$pkg"
    else
        echo "✓ $pkg already installed"
    fi
done

# Security tools
echo "📦 Installing security tools..."
for pkg in gnupg git-crypt; do
    if ! brew list | grep -q "^$pkg$"; then
        brew install "$pkg"
    else
        echo "✓ $pkg already installed"
    fi
done

# Development tools
echo "📦 Installing development tools..."
for pkg in ripgrep fd fzf lazygit git-delta uv glow; do
    if ! brew list | grep -q "^$pkg$"; then
        brew install "$pkg"
    else
        echo "✓ $pkg already installed"
    fi
done

# Shell enhancements
echo "📦 Installing shell enhancements..."
for pkg in starship bat tmux atuin eza zoxide; do
    if ! brew list | grep -q "^$pkg$"; then
        brew install "$pkg"
    else
        echo "✓ $pkg already installed"
    fi
done

# Terminal and window manager
echo "📦 Installing terminal and window manager..."
for cask in ghostty nikitabobko/tap/aerospace; do
    if ! brew list --cask | grep -q "$(basename $cask)$"; then
        brew install --cask "$cask"
    else
        echo "✓ $(basename $cask) already installed"
    fi
done

# Fonts
echo "📦 Installing fonts..."
if ! brew list --cask | grep -q "^font-jetbrains-mono-nerd-font$"; then
    brew install --cask font-jetbrains-mono-nerd-font
else
    echo "✓ font-jetbrains-mono-nerd-font already installed"
fi

# Install fzf shell integration
$(brew --prefix)/opt/fzf/install --all --no-bash --no-fish --no-update-rc

echo "🔗 Stowing dotfiles..."

# Helper function to safely stow packages
safe_stow() {
    local package="$1"
    if [ -d "$package" ]; then
        if stow -n "$package" 2>/dev/null; then
            stow "$package"
            echo "✓ Stowed $package"
        else
            echo "⚠️  Conflicts detected for $package, attempting to resolve..."
            stow --adopt "$package" 2>/dev/null || true
            stow "$package"
            echo "✓ Stowed $package (with conflict resolution)"
        fi
    else
        echo "⚠️  Directory $package not found, skipping"
    fi
}

# Remove existing files if they exist (backup first)
for config in .zshrc .gitconfig .fzf.zsh; do
    if [ -f ~/$config ] && [ ! -L ~/$config ]; then
        echo "Backing up existing $config to $config.backup"
        mv ~/$config ~/$config.backup
    fi
done

# Stow configurations
safe_stow zsh
safe_stow git
safe_stow nvim
safe_stow ghostty
safe_stow aerospace
safe_stow starship
safe_stow tmux
safe_stow karabiner

echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "1. Restart your terminal"
echo "2. Open Neovim (nvim) to install plugins"
echo "3. Configure Git with your user info:"
echo "   git config --global user.name 'Your Name'"
echo "   git config --global user.email 'your.email@example.com'"