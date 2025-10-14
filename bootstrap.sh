#!/bin/bash
# bootstrap.sh - Idempotent bootstrap script for dotfiles
# Installs uv, uses it to install Ansible, then runs the playbook
#
# Usage:
#   ./bootstrap.sh                    # Normal mode (adopts existing configs)
#   ./bootstrap.sh --extra-vars "force_config=true"  # Force mode (prioritizes dotfiles)

set -e  # Exit on error

echo "🚀 Starting dotfiles bootstrap..."

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

# Install uv (idempotent check)
if ! command -v uv &> /dev/null; then
    echo "📦 Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
    echo "✓ uv installed"
else
    echo "✓ uv already installed ($(uv --version))"
fi

# Ensure uv is in PATH for this session
export PATH="$HOME/.local/bin:$PATH"

# Install Ansible via uv (idempotent check)
if ! uv tool list 2>/dev/null | grep -q ansible-core; then
    echo "📦 Installing Ansible via uv..."
    uv tool install ansible-core
    echo "✓ Ansible installed via uv"
else
    echo "✓ Ansible already installed via uv ($(ansible --version | head -n1))"
fi

# Install Ansible collections
echo "📦 Installing Ansible collections..."
ansible-galaxy collection install -r "$(dirname "$0")/requirements.yml"

# Run playbook
echo "▶️  Running Ansible playbook..."
ansible-playbook "$(dirname "$0")/playbook.yml" \
    --extra-vars "platform=$PLATFORM" \
    "$@"

echo ""
echo "✅ Bootstrap complete!"
echo ""
echo "📖 Next steps:"
echo "1. Restart your terminal or run: source ~/.zshrc (macOS) or source ~/.bashrc (Linux)"
if [ "$PLATFORM" = "linux" ]; then
    echo "2. Test Ghostty terminal: Press Ctrl+Alt+T"
    echo "3. Test GNOME launcher: Press Super, type 'term' or 'terminal'"
fi
echo "$([ "$PLATFORM" = "linux" ] && echo "4" || echo "2"). Open tmux and test clipboard integration"
echo "$([ "$PLATFORM" = "linux" ] && echo "5" || echo "3"). Open Neovim (nvim) to install plugins"
