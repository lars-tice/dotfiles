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

# Auto-start tmux when opening terminal
if command -v tmux &> /dev/null && [ -z "$TMUX" ] && [ -z "$VSCODE_INJECTION" ] && [[ $- == *i* ]]; then
    # Attach to existing session named 'main' or create it
    exec tmux new-session -A -s main
fi
