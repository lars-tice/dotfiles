# macOS-specific environment variables and settings

# Homebrew environment
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# macOS clipboard integration now handled by terminal OSC 52 escape sequences

# macOS specific paths
export PATH="/usr/local/sbin:$PATH"
. "$HOME/.cargo/env"
