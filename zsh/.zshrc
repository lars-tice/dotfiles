# GitHub Personal Access Token
# Store your token in ~/.zshrc.local (not tracked in git)
# export GITHUB_TOKEN="your_token_here"
# export GH_TOKEN="your_token_here"
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Git configuration
export GIT_EDITOR="vim"

# Homebrew path (for Apple Silicon Macs)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Neovim alias
alias vim="nvim"
alias vi="nvim"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
