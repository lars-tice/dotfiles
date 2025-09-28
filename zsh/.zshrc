# Local configuration (not tracked in git)
# You can store local environment variables in ~/.zshrc.local
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Git configuration
export GIT_EDITOR="vim"

# Homebrew path (for Apple Silicon Macs)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Neovim alias
alias vim="nvim"
alias vi="nvim"

# FZF integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Starship prompt
eval "$(starship init zsh)"

# Tmux aliases
alias ta='tmux attach -t'
alias ts='tmux new-session -s'
alias tl='tmux list-sessions'
alias tk='tmux kill-session -t'

# Better defaults with bat
alias cat='bat'
alias less='bat'
export BAT_THEME="TwoDark"  # Nice theme that works well with Tokyo Night

# Atuin for better shell history
eval "$(atuin init zsh)"
# Useful atuin aliases
alias h='atuin search'         # Quick history search
alias hs='atuin stats'          # Command usage stats
alias hlist='atuin history list --limit 50'  # Show recent commands

# Better ls with eza
alias ls='eza --icons'
alias lsa='eza -lsa --icons'     # Detailed list with hidden files
alias lt='eza --tree --icons'   # Tree view
alias ld='eza -D --icons'       # List only directories

# Zoxide for smarter directory navigation
# Note: eval "$(zoxide init zsh)" has issues in some environments
# Using direct implementation instead
unalias z 2>/dev/null || true
unalias zi 2>/dev/null || true

z() {
    if [ $# -eq 0 ]; then
        cd ~
    elif [ "$1" = "-" ]; then
        cd -
    elif [ -d "$1" ]; then
        cd "$1"
    else
        local result
        result="$(zoxide query -- "$@")" && cd "$result"
    fi
}
zi() {
    result="$(zoxide query -i -- "$@")" && cd "$result"
}

# Auto-start tmux when opening terminal
if command -v tmux &> /dev/null && [ -z "$TMUX" ] && [ -z "$VSCODE_INJECTION" ] && [[ $- == *i* ]]; then
    # Attach to existing session named 'main' or create it
    exec tmux new-session -A -s main
fi
