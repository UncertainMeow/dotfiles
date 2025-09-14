#!/usr/bin/env zsh

# Arch Linux specific configuration
# Works on Arch, Manjaro, EndeavourOS, etc.

# Detect if we're on an Arch derivative
if [[ -f /etc/arch-release ]] || command -v pacman &> /dev/null; then
    export ARCH_BASED=true
else
    return 0  # Not Arch-based, skip this config
fi

# Package management aliases (pacman + AUR)
alias pkg-update='sudo pacman -Syu'
alias pkg-install='sudo pacman -S'
alias pkg-remove='sudo pacman -Rs'
alias pkg-search='pacman -Ss'
alias pkg-info='pacman -Si'
alias pkg-clean='sudo pacman -Sc'
alias pkg-list='pacman -Q'

# AUR helpers (detect which is available)
if command -v yay &> /dev/null; then
    alias aur-install='yay -S'
    alias aur-search='yay -Ss'
    alias aur-update='yay -Syu'
elif command -v paru &> /dev/null; then
    alias aur-install='paru -S'
    alias aur-search='paru -Ss'  
    alias aur-update='paru -Syu'
fi

# Arch-specific aliases
alias mirrors='sudo reflector --verbose --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist'
alias paclog='tail -f /var/log/pacman.log'
alias pacdiff='sudo pacdiff'

# System maintenance
alias cleanup='sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null || echo "No orphaned packages"'
alias sysinfo='inxi -Fxz'

# Development tools (Arch has great dev packages)
alias dev-install='sudo pacman -S base-devel git vim tmux zsh docker nodejs npm python python-pip'

# Arch-specific environment variables
export EDITOR=vim
export PAGER=less

# Arch Linux banner (optional - comment out if too much)
if [[ -t 0 && $- == *i* ]]; then
    echo "🏛️  Arch Linux detected - I use Arch BTW"
fi