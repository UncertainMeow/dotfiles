#!/usr/bin/env zsh

# Environment Variables and XDG Configuration

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# User documents directory (for coding projects)
export XDG_DOCUMENTS_DIR="$HOME/Documents"

# PATH Management
# Add user binaries directory first (highest priority)
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# Language-specific binary directories
[[ -d "$HOME/.local/share/cargo/bin" ]] && export PATH="$HOME/.local/share/cargo/bin:$PATH"  # Rust
[[ -d "$HOME/.local/share/go/bin" ]] && export PATH="$HOME/.local/share/go/bin:$PATH"      # Go
[[ -d "$HOME/.local/share/npm/bin" ]] && export PATH="$HOME/.local/share/npm/bin:$PATH"    # Node.js

# Application Configuration
export EDITOR="nvim"
export VISUAL="$EDITOR"
export PAGER="less"
export BROWSER="firefox"

# XDG-compliant application configurations
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export HISTFILE="$XDG_STATE_HOME/zsh/history"

# Language-specific XDG compliance
export CARGO_HOME="$XDG_DATA_HOME/cargo"           # Rust
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"         # Rust
export GOPATH="$XDG_DATA_HOME/go"                  # Go
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"  # Node.js
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"             # Node.js
export PYTHON_EGG_CACHE="$XDG_CACHE_HOME/python-eggs"     # Python
export PYLINTHOME="$XDG_CACHE_HOME/pylint"                # Python

# Docker XDG compliance
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"

# AWS CLI XDG compliance
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME/aws/credentials"

# Kubectl XDG compliance
export KUBECONFIG="$XDG_CONFIG_HOME/kube/config"

# GPG XDG compliance (if using modern GPG)
export GNUPGHOME="$XDG_DATA_HOME/gnupg"

# Development Environment
export DEVELOPMENT_DIR="$XDG_DOCUMENTS_DIR/coding-projects"

# Locale settings
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Security: don't log certain commands to history
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help:history:clear"

# Make applications respect XDG directories
# Create necessary directories
mkdir -p "$XDG_STATE_HOME/less" \
         "$XDG_STATE_HOME/zsh" \
         "$XDG_CACHE_HOME/zsh" \
         "$XDG_CONFIG_HOME/npm" \
         "$XDG_CONFIG_HOME/docker" \
         "$XDG_CONFIG_HOME/aws" \
         "$XDG_CONFIG_HOME/kube" \
         "$XDG_DATA_HOME/cargo" \
         "$XDG_DATA_HOME/rustup" \
         "$XDG_DATA_HOME/go" \
         "$XDG_DATA_HOME/gnupg" \
         "$DEVELOPMENT_DIR" 2>/dev/null

# Set appropriate permissions for security-sensitive directories
[[ -d "$XDG_DATA_HOME/gnupg" ]] && chmod 700 "$XDG_DATA_HOME/gnupg"
[[ -d "$XDG_CONFIG_HOME/aws" ]] && chmod 700 "$XDG_CONFIG_HOME/aws"

# =============================================================================
# EXTERNAL TOOL INTEGRATIONS
# =============================================================================

# =============================================================================
# SECURITY-SENSITIVE DIRECTORIES
# =============================================================================
# Set XDG defaults if not already defined
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_CONFIG_HOME:=$HOME/.config}"

# Lock down permissions
[[ -d "$XDG_DATA_HOME/gnupg" ]]  && chmod 700 "$XDG_DATA_HOME/gnupg"
[[ -d "$XDG_CONFIG_HOME/aws" ]]  && chmod 700 "$XDG_CONFIG_HOME/aws"

# =============================================================================
# COMPLETIONS
# =============================================================================
# make sure compdef exists before plugins or tools rely on it
autoload -U compinit
compinit

# =============================================================================
# PATH SETUP (Homebrew on Apple Silicon vs Intel)
# =============================================================================
if [[ -x /opt/homebrew/bin/brew ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
elif [[ -x /usr/local/bin/brew ]]; then
  export PATH="/usr/local/bin:$PATH"
fi

# =============================================================================
# ZOXIDE (smart cd with builtin fallback + debug)
# =============================================================================
# initialize zoxide
eval "$(zoxide init zsh)"

# hybrid cd: try builtin first for real dirs, else try zoxide, else fallback
cd() {
  if [[ $# -eq 0 ]]; then
    echo "[cd] No args → builtin cd ~"
    builtin cd
    return
  fi

  # direct cases: real dir, previous dir (-), directory stack refs (+1, -2)
  if [[ -d "$1" ]] || [[ "$1" == "-" ]] || [[ "$1" =~ ^[-+][0-9]*$ ]]; then
    echo "[cd] Direct match → builtin cd $*"
    builtin cd "$@"
    return
  fi

  # try zoxide fuzzy jump
  if typeset -f __zoxide_z >/dev/null 2>&1; then
    if __zoxide_z "$@" 2>/dev/null; then
      echo "[cd] zoxide matched → $*"
      return
    else
      echo "[cd] zoxide had no match for: $*"
    fi
  else
    echo "[cd] zoxide not initialized, falling back"
  fi

  # last resort: regular cd (will error if truly not a dir)
  echo "[cd] Fallback → builtin cd $*"
  builtin cd "$@"
}

# =============================================================================
# DIRENV (per-project environments)
# =============================================================================
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# =============================================================================
# TERMINAL COMPATIBILITY
# =============================================================================

# Ensure TERM is set properly for SSH connections
# Some remote servers expect standard terminal types
if [[ -z "$TERM" ]] || [[ "$TERM" == "ghostty" ]]; then
  export TERM="xterm-256color"
fi
=======
