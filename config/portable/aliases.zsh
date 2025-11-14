#!/usr/bin/env zsh
# Portable Dotfiles - Essential Aliases Only
# Minimal set for SSH sessions on remote servers

# === Safety First ===
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# === Directory Navigation (Muscle Memory!) ===
alias ls='ls --color=auto 2>/dev/null || ls -G'
alias ll='ls -lAh'
alias la='ls -A'
alias l='ls -CF'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# === Git Essentials ===
alias g='git'
alias gs='git status'
alias gst='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate'

# === System Info (Quick Checks) ===
alias df='df -h'
alias du='du -h'
alias free='free -h 2>/dev/null || vm_stat'
alias ports='netstat -tulanp 2>/dev/null || lsof -i'

# === Quick Edits ===
alias v='${EDITOR:-vim}'
alias vi='${EDITOR:-vim}'

# === Networking ===
alias myip='curl -s ifconfig.me'
alias ping='ping -c 5'

# === Dotfiles Management ===
alias dotpull='cd ~/.dotfiles && git pull && source ~/.zshrc && cd -'
alias dotstatus='cd ~/.dotfiles && git status && cd -'

# === Quick System ===
alias h='history'
alias j='jobs'
alias c='clear'
alias reload='exec ${SHELL} -l'
