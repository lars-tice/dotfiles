#!/bin/bash

# Cross-platform dotfiles installation script
# 
# Usage:
#   ./install-cross-platform.sh                    # Normal mode (adopts existing configs)
#   FORCE_CONFIG=true ./install-cross-platform.sh  # Force mode (prioritizes dotfiles)

set -e  # Exit on error

echo "🚀 Starting cross-platform dotfiles installation..."

# Check for force configuration mode
if [ "$FORCE_CONFIG" = "true" ]; then
    echo "⚡ Force configuration mode enabled - dotfiles will override existing configs"
fi

# Detect platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
    echo "🍎 Detected macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
    echo "🐧 Detected Linux"
else
    echo "❌ Unsupported platform: $OSTYPE"
    exit 1
fi

# Platform-specific package installation
if [ "$PLATFORM" = "macos" ]; then
    echo "📦 Installing dependencies via Homebrew..."
    
    # Install Homebrew if not present
    if ! command -v brew &> /dev/null; then
        echo "📦 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
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

elif [ "$PLATFORM" = "linux" ]; then
    echo "📦 Installing dependencies via apt..."
    
    # Update package list
    sudo apt update
    
    # Core tools
    echo "📦 Installing core tools..."
    for pkg in git stow neovim; do
        if ! dpkg -l | grep -q "^ii  $pkg "; then
            sudo apt install -y "$pkg"
        else
            echo "✓ $pkg already installed"
        fi
    done
    
    # Clipboard integration
    echo "📦 Installing clipboard integration..."
    if ! dpkg -l | grep -q "^ii  xclip "; then
        sudo apt install -y xclip
    else
        echo "✓ xclip already installed"
    fi
    
    # Development tools (install what's available)
    echo "📦 Installing development tools..."
    for pkg in ripgrep fd-find fzf bat tmux curl wget; do
        if ! dpkg -l | grep -q "^ii  $pkg "; then
            sudo apt install -y "$pkg"
        else
            echo "✓ $pkg already installed"
        fi
    done
    
    # Install Ghostty terminal emulator
    echo "📦 Installing Ghostty terminal emulator..."
    if ! command -v ghostty &> /dev/null; then
        if [ ! -f "ghostty_1.1.3-0.ppa2_amd64_24.04.deb" ]; then
            wget https://github.com/mkasberg/ghostty-ubuntu/releases/download/1.1.3-0-ppa2/ghostty_1.1.3-0.ppa2_amd64_24.04.deb
        fi
        sudo dpkg -i ghostty_1.1.3-0.ppa2_amd64_24.04.deb || sudo apt-get install -f
    else
        echo "✓ Ghostty already installed"
    fi
    
    # Set Ghostty as default terminal
    echo "🖥️ Setting Ghostty as default terminal..."
    if ! update-alternatives --query x-terminal-emulator | grep -q "/usr/bin/ghostty"; then
        sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/ghostty 50
    else
        echo "✓ Ghostty already in alternatives"
    fi
    
    if [ "$(readlink /etc/alternatives/x-terminal-emulator)" != "/usr/bin/ghostty" ]; then
        sudo update-alternatives --set x-terminal-emulator /usr/bin/ghostty
    else
        echo "✓ Ghostty already set as default terminal"
    fi
    
    # Set Ghostty as GNOME default terminal (overrides Ctrl+Alt+T)
    gsettings set org.gnome.desktop.default-applications.terminal exec 'ghostty'
    
    # Install keyd for keyboard remapping
    echo "⌨️ Installing keyd keyboard remapping daemon..."
    if ! dpkg -l | grep -q "^ii  keyd "; then
        echo "📦 Installing keyd via package manager..."
        # Try native package first (Ubuntu 25.04+, Debian 13+)
        if ! sudo apt install -y keyd 2>/dev/null; then
            # Fall back to PPA for older Ubuntu versions
            echo "📦 Adding keyd PPA for older Ubuntu versions..."
            sudo add-apt-repository -y ppa:keyd-team/ppa
            sudo apt update
            sudo apt install -y keyd
        fi
        echo "✓ keyd installed via package manager"
    else
        echo "✓ keyd already installed"
    fi
    
    # Service should be automatically enabled by package installation
    if ! systemctl is-active keyd &> /dev/null; then
        sudo systemctl start keyd
        echo "✓ keyd service started"
    else
        echo "✓ keyd service already running"
    fi
    
    # Install JetBrains Mono Nerd Font
    echo "🔤 Installing JetBrains Mono Nerd Font..."
    FONT_DIR="$HOME/.local/share/fonts"
    FONT_NAME="JetBrainsMono"
    if [ ! -f "$FONT_DIR/${FONT_NAME}NerdFontMono-Regular.ttf" ]; then
        mkdir -p "$FONT_DIR"
        FONT_VERSION="3.3.0"
        wget -O "/tmp/${FONT_NAME}.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v${FONT_VERSION}/${FONT_NAME}.zip"
        unzip -o "/tmp/${FONT_NAME}.zip" -d "/tmp/${FONT_NAME}/" *.ttf
        cp /tmp/${FONT_NAME}/*.ttf "$FONT_DIR/"
        fc-cache -fv
        echo "✓ JetBrains Mono Nerd Font installed"
        rm -rf "/tmp/${FONT_NAME}.zip" "/tmp/${FONT_NAME}/"
    else
        echo "✓ JetBrains Mono Nerd Font already installed"
    fi
    
    # Install Starship
    echo "🚀 Installing Starship..."
    if ! command -v starship &> /dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
        echo "✓ Starship installed"
    else
        echo "✓ Starship already installed"
    fi

    # Install Git Credential Manager
    echo "🔐 Installing Git Credential Manager..."
    if ! command -v git-credential-manager &> /dev/null; then
        GCM_VERSION="2.6.0"
        GCM_DEB="gcm-linux_amd64.${GCM_VERSION}.deb"
        if [ ! -f "/tmp/${GCM_DEB}" ]; then
            wget -O "/tmp/${GCM_DEB}" "https://github.com/git-ecosystem/git-credential-manager/releases/download/v${GCM_VERSION}/${GCM_DEB}"
        fi
        sudo dpkg -i "/tmp/${GCM_DEB}" || sudo apt-get install -f -y
        rm -f "/tmp/${GCM_DEB}"
        echo "✓ Git Credential Manager installed"
    else
        echo "✓ Git Credential Manager already installed"
    fi

    # Install other tools manually if not in apt
    echo "ℹ️  Some tools may need manual installation on Linux:"
    echo "   - gh (GitHub CLI): https://cli.github.com/manual/installation"
    echo "   - eza: https://github.com/eza-community/eza/blob/main/INSTALL.md"
fi

echo "🔗 Stowing dotfiles..."

# Helper function to get config path for a package
get_config_path() {
    local package="$1"
    case "$package" in
        nvim) echo "$HOME/.config/nvim" ;;
        starship) echo "$HOME/.config/starship.toml" ;;
        ghostty) echo "$HOME/.config/ghostty" ;;
        tmux) echo "$HOME/.tmux.conf" ;;
        zsh) echo "$HOME/.zshrc" ;;
        git) echo "$HOME/.gitconfig" ;;
        keyd) echo "" ;;  # Handled specially, no standard path
        @macos) echo "$HOME/.config" ;;  # Multiple paths, handle specially
        aerospace) echo "$HOME/.config/aerospace" ;;
        karabiner) echo "$HOME/.config/karabiner" ;;
        *) echo "" ;;  # Unknown package
    esac
}

# Helper function to safely stow packages
safe_stow() {
    local package="$1"
    if [ -d "$package" ]; then
        # Special handling for system-level configs that can't be stowed
        if [ "$package" = "keyd" ]; then
            if [ -f "keyd/.config/keyd/default.conf" ]; then
                # Check if config needs updating
                if [ "$FORCE_CONFIG" = "true" ] || ! sudo cmp -s "keyd/.config/keyd/default.conf" "/etc/keyd/default.conf" 2>/dev/null; then
                    sudo mkdir -p /etc/keyd
                    sudo cp "keyd/.config/keyd/default.conf" "/etc/keyd/default.conf"
                    sudo systemctl restart keyd
                    echo "✓ keyd configuration updated and service restarted"
                else
                    echo "✓ keyd configuration already up to date"
                fi
            else
                echo "⚠️  keyd config file not found in dotfiles"
            fi
            return
        fi
        
        # Handle force configuration mode for regular packages
        if [ "$FORCE_CONFIG" = "true" ]; then
            local config_path
            config_path=$(get_config_path "$package")
            
            if [ -n "$config_path" ] && [ -e "$config_path" ] && [ ! -L "$config_path" ]; then
                local backup_path="${config_path}.backup.$(date +%Y%m%d_%H%M%S)"
                mv "$config_path" "$backup_path"
                echo "📋 Backed up existing $package config to $(basename "$backup_path")"
            fi
            
            # Special handling for git package conflicts
            if [ "$package" = "git" ]; then
                # Handle .config/git/ignore conflict specifically
                if [ -f "$HOME/.config/git/ignore" ] && [ ! -L "$HOME/.config/git/ignore" ]; then
                    local backup_path="$HOME/.config/git/ignore.backup.$(date +%Y%m%d_%H%M%S)"
                    mv "$HOME/.config/git/ignore" "$backup_path"
                    echo "📋 Backed up git ignore file to $(basename "$backup_path")"
                fi
            fi
        fi
        
        # Attempt to stow
        if stow -n "$package" 2>/dev/null; then
            stow "$package"
            echo "✓ Stowed $package"
        else
            if [ "$FORCE_CONFIG" = "true" ]; then
                # In force mode, try to stow anyway after backup
                stow "$package" 2>/dev/null || {
                    echo "⚠️  Force stow failed for $package, may need manual intervention"
                    return 1
                }
                echo "✓ Force stowed $package"
            else
                # Normal mode: adopt existing configs
                echo "⚠️  Conflicts detected for $package, attempting to resolve..."
                stow --adopt "$package" 2>/dev/null || true
                stow "$package"
                echo "✓ Stowed $package (with conflict resolution)"
            fi
        fi
    else
        echo "⚠️  Directory $package not found, skipping"
    fi
}

# Backup existing files if they exist
for config in .zshrc .gitconfig .fzf.zsh .profile; do
    if [ -f ~/$config ] && [ ! -L ~/$config ]; then
        echo "📋 Backing up existing $config to $config.backup"
        mv ~/$config ~/$config.backup
    fi
done

# Stow cross-platform configurations
echo "🔧 Stowing cross-platform configs..."
safe_stow zsh
safe_stow git
safe_stow nvim
safe_stow starship
safe_stow tmux
safe_stow ghostty

# Platform-specific additional stowing
if [ "$PLATFORM" = "macos" ]; then
    safe_stow @macos
    safe_stow aerospace
    safe_stow karabiner
elif [ "$PLATFORM" = "linux" ]; then
    # Stow Linux-specific configurations
    safe_stow keyd
    
    # Create custom Ghostty desktop file with search keywords
    echo "🔍 Setting up Ghostty launcher keywords..."
    mkdir -p ~/.local/share/applications/
    cat > ~/.local/share/applications/com.mitchellh.ghostty.desktop << 'EOF'
[Desktop Entry]
Name=Ghostty
Type=Application
Comment=Fast, feature-rich, cross-platform terminal emulator
Exec=/usr/bin/ghostty
Icon=com.mitchellh.ghostty
Categories=System;TerminalEmulator;
Keywords=terminal;tty;pty;term;console;shell;ghostty;
StartupNotify=true
StartupWMClass=com.mitchellh.ghostty
Terminal=false
Actions=new-window;
X-GNOME-UsesNotifications=true
X-TerminalArgExec=-e
X-TerminalArgTitle=--title=
X-TerminalArgAppId=--class=
X-TerminalArgDir=--working-directory=
X-TerminalArgHold=--wait-after-command

[Desktop Action new-window]
Name=New Window
Exec=/usr/bin/ghostty
EOF
    update-desktop-database ~/.local/share/applications/ 2>/dev/null || true
    
fi

echo "✅ Installation complete!"
echo ""

# Show force mode summary if used
if [ "$FORCE_CONFIG" = "true" ]; then
    echo "⚡ Force configuration mode was used:"
    echo "   - Existing configs were backed up with timestamps"
    echo "   - Dotfiles configurations now take precedence"
    echo "   - Check .backup.* files if you need to restore anything"
    echo ""
fi

echo "📖 Usage modes:"
echo "   Normal:  ./install-cross-platform.sh                    (adopts existing configs)"
echo "   Force:   FORCE_CONFIG=true ./install-cross-platform.sh  (prioritizes dotfiles)"
echo ""
echo "Next steps:"
echo "1. Restart your terminal or run: source ~/.zshrc"
if [ "$PLATFORM" = "linux" ]; then
    echo "2. Test Ghostty terminal: Press Ctrl+Alt+T (should open Ghostty)"
    echo "3. Test GNOME launcher: Press Super, type 'term' or 'terminal'"
    echo "4. Open tmux and test clipboard integration"
    echo "5. Open Neovim (nvim) to install plugins"
    echo "6. Consider manually installing additional tools mentioned above"
else
    echo "2. Open tmux and test clipboard integration"
    echo "3. Open Neovim (nvim) to install plugins"
fi
echo ""
echo "🔍 To test tmux clipboard:"
echo "   1. Start tmux: tmux"
echo "   2. Enter copy mode: Ctrl+Space ["
echo "   3. Select text and copy: v (select) then y (copy)"
echo "   4. Test paste outside tmux"
if [ "$PLATFORM" = "linux" ]; then
    echo ""
    echo "🖥️ Ghostty features:"
    echo "   - Press Ctrl+Plus/Minus to adjust font size"
    echo "   - Tmux starts automatically when opening Ghostty"
    echo "   - Search 'term', 'terminal', 'console' in GNOME launcher"
fi