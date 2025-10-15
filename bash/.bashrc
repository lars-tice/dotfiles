# Starship prompt
eval "$(starship init bash)"

# FZF integration
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Atuin for better shell history
eval "$(atuin init bash)"
# Useful atuin aliases
alias h='atuin search'
alias hs='atuin stats'
alias hlist='atuin history list --limit 50'

# Better defaults with bat
alias cat='bat'
alias less='bat'
export BAT_THEME="TwoDark"

# Better ls with eza
alias ls='eza --icons'
alias lsa='eza -lsa --icons'
alias lt='eza --tree --icons'
alias ld='eza -1D --icons'

# Zoxide for smarter directory navigation
eval "$(zoxide init bash)"
