#!/usr/bin/env zsh
# =============================================================================
# PORTABLE DOTFILES - Minimal Remote Setup
# =============================================================================
# Ultra-lightweight config for SSH sessions
# Zero dependencies - works on any Linux server

# XDG Base Directory (if not set)
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# Essential environment
export EDITOR="${EDITOR:-vim}"
export VISUAL="$EDITOR"
export PAGER="less"

# History configuration
HISTFILE="${XDG_DATA_HOME}/zsh/history"
HISTSIZE=10000
SAVEHIST=$HISTSIZE
mkdir -p "$(dirname "$HISTFILE")"

# Shell options (fast, no plugins needed)
setopt auto_cd              # Type directory name to cd
setopt extended_glob        # Enhanced pattern matching
setopt no_beep              # No annoying beeps
setopt auto_pushd           # Make cd push old directory to stack
setopt pushd_ignore_dups    # Don't push dupes
setopt hist_ignore_space    # Ignore commands starting with space
setopt hist_ignore_all_dups # Remove older dups
setopt share_history        # Share history between sessions
setopt inc_append_history   # Add commands immediately

# PATH additions (if they exist)
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# Load portable configs
DOTFILES_DIR="${HOME}/.dotfiles"
[[ -f "$DOTFILES_DIR/config/portable/aliases.zsh" ]] && source "$DOTFILES_DIR/config/portable/aliases.zsh"
[[ -f "$DOTFILES_DIR/config/portable/functions.zsh" ]] && source "$DOTFILES_DIR/config/portable/functions.zsh"

# Minimal prompt (fast, no dependencies)
# Shows: user@host:~/path$
autoload -U colors && colors
PROMPT='%F{cyan}%n@%m%f:%F{blue}%~%f$ '

# Git prompt (if in git repo)
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' %F{yellow}[%b]%f'
precmd() { vcs_info }
setopt prompt_subst
PROMPT='%F{cyan}%n@%m%f:%F{blue}%~%f${vcs_info_msg_0_}$ '

# Basic completion (no plugins needed)
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Completion options
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

echo "📦 Portable dotfiles loaded - use 'dotpull' to update"
