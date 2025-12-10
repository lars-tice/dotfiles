# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ============================================================================
# Editor Configuration
# ============================================================================
export VISUAL=nvim
export EDITOR="$VISUAL"

# Enable vi mode for the command line
set -o vi

# ============================================================================
# History Configuration
# ============================================================================
# Don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# History length
HISTSIZE=1000
HISTFILESIZE=2000

# ============================================================================
# Shell Options
# ============================================================================
# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories
#shopt -s globstar

# ============================================================================
# XDG Base Directory Specification
# ============================================================================
export XDG_CONFIG_HOME="$HOME/.config"

# ============================================================================
# Local Binaries PATH
# ============================================================================
# Add ~/.local/bin to PATH for user-installed tools (nvim, zoxide, starship, etc.)
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# ============================================================================
# Prompt Configuration
# ============================================================================
# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying the chroot you work in
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# ============================================================================
# Color Support & Basic Aliases
# ============================================================================
# Enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Standard ls aliases (will be overridden by eza if available)
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alert alias for long running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# ============================================================================
# Programmable Completion
# ============================================================================
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# ============================================================================
# nvm (Node Version Manager)
# ============================================================================
export NVM_DIR="$HOME/.config/nvm"
export NVM_DIR="$HOME/.config/nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ============================================================================
# Rust/Cargo Environment
# ============================================================================
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# ============================================================================
# Starship Prompt
# ============================================================================
eval "$(starship init bash)"

# ============================================================================
# FZF Integration
# ============================================================================
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# ============================================================================
# Atuin Shell History
# ============================================================================
# Load atuin environment
[ -f "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"

# Load bash-preexec for atuin
[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh

# Initialize atuin
eval "$(atuin init bash)"

# Atuin aliases
alias h='atuin search'
alias hs='atuin stats'
alias hlist='atuin history list --limit 50'

# ============================================================================
# bat (Better cat)
# ============================================================================
# Ubuntu/Debian use 'batcat' due to naming conflict
if command -v batcat &>/dev/null; then
    alias cat='batcat'
    alias less='batcat'
elif command -v bat &>/dev/null; then
    alias cat='bat'
    alias less='bat'
fi
export BAT_THEME="tokyonight_night"

# ============================================================================
# eza (Better ls)
# ============================================================================
alias ls='eza --icons'
alias lsa='eza -la --icons'
alias lt='eza --tree --icons'
alias ld='eza -1D --icons'

# ============================================================================
# zoxide (Smarter cd)
# ============================================================================
eval "$(zoxide init bash)"

# ============================================================================
# User Aliases
# ============================================================================
# Load custom aliases if they exist
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# ============================================================================
# Machine-Specific Configuration
# ============================================================================
# Source machine-specific config (secrets, local paths, etc.)
# This file should NOT be committed to git
if [ -f ~/.bashrc.local ]; then
    . ~/.bashrc.local
fi
