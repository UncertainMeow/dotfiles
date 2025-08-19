# =============================================================================
# HOMELAB TERMINAL SETUP - Infrastructure Focus
# =============================================================================

# Instant prompt for Powerlevel10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =============================================================================
# SHELL OPTIONS & BEHAVIOR
# =============================================================================
setopt auto_cd extended_glob no_beep correct_all interactive_comments
setopt auto_pushd pushd_ignore_dups pushd_minus

# Enhanced history for infrastructure work
HISTSIZE=100000
SAVEHIST=$HISTSIZE
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
mkdir -p "${HISTFILE:h}"
setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups \
       hist_save_no_dups hist_ignore_dups hist_find_no_dups hist_verify

# =============================================================================
# COLORS & VISUAL
# =============================================================================
if command -v vivid >/dev/null 2>&1; then
  export LS_COLORS="$(vivid generate catppuccin-mocha)"
elif command -v gdircolors >/dev/null 2>&1; then
  eval "$(gdircolors -b 2>/dev/null || true)"
fi

# =============================================================================
# ZINIT PLUGIN MANAGER
# =============================================================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# =============================================================================
# PLUGINS
# =============================================================================
# Prompt
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Essential ZSH enhancements
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab

# =============================================================================
# COMPLETIONS
# =============================================================================
autoload -Uz compinit
ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compdump"
mkdir -p "${ZSH_COMPDUMP:h}"
compinit -C -d "$ZSH_COMPDUMP"
zinit cdreplay -q

# 1Password CLI completion (moved from .zprofile)
if command -v op >/dev/null 2>&1; then
  eval "$(op completion zsh)"
  if type compdef >/dev/null 2>&1; then
    compdef _op op
  fi
fi

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'

# FZF-tab previews
if command -v eza >/dev/null 2>&1; then
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color=always --icons --group-directories-first $realpath'
  zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color=always --icons --group-directories-first $realpath'
else
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -G $realpath'
fi

# =============================================================================
# KEY BINDINGS
# =============================================================================
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^R' fzf-history-widget

# =============================================================================
# HOMELAB-SPECIFIC ALIASES
# =============================================================================

# Package management
alias upgrade='brew update && brew upgrade && brew cleanup'
alias search='brew search'
alias install='brew install'
alias remove='brew uninstall'
alias cleanup='brew cleanup -s && rm -rf "$(brew --cache)"'
alias services='brew services'

# File operations with eza
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -lah --icons --group-directories-first --git'
  alias tree='eza --tree --icons --group-directories-first'
  alias lt='eza --tree --level=2 --icons'
else
  alias ll='ls -lahG'
fi

# Infrastructure tools
alias tf='terraform'
alias tfa='terraform apply'
alias tfp='terraform plan'
alias tfi='terraform init'
alias tfv='terraform validate'
alias tff='terraform fmt'

alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kdel='kubectl delete'
alias klog='kubectl logs'

# Git workflow (preparing for GitLab)
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gs='git status'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gm='git merge'
alias lg='lazygit'

# SSH shortcuts (update IPs as needed)
alias socrates='ssh root@10.203.3.42'  # AI workload server
alias stuffs='ssh admin@10.203.3.99'   # UGREEN NAS

# Homelab utilities
alias tailup='tailscale up --ssh'
alias taildown='tailscale down'
alias tailstat='tailscale status'
alias tailnode='tailscale up --ssh --exit-node='
alias tailexit='tailscale up --ssh --exit-node-allow-lan-access'
alias ports='netstat -tulanp'
alias myip='curl -s ifconfig.me'
alias localip='ipconfig getifaddr en0'

# Quick navigation
alias h='cd ~'
alias lab='cd ~/homelab'
alias repos='cd ~/repos'
alias ref='cd ~/reference'
alias dots='cd ~/.dotfiles'

# Tmux management
alias tmux-clean="rm -rf ~/.local/share/tmux/resurrect/* && echo 'Tmux restore data cleared'"

# Better defaults
alias grep='grep --color=auto'
alias cat='bat --paging=never'
alias df='df -h'
alias ps='ps aux'

# Vim learning helpers (keep these!)
alias vim='echo "Learning vim? Try: vimtutor" && nano'
alias nvim='echo "Ready for nvim? Remove this alias first!" && nano'

# =============================================================================
# SHELL INTEGRATIONS
# =============================================================================

# FZF with custom options for infrastructure work
if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --margin=1 --padding=1'
  
  # Source FZF files if they exist (skip installation to avoid console output)
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
  
  # Fallback to brew-installed fzf shell integrations
  for f in "$(brew --prefix 2>/dev/null)/opt/fzf/shell"/{completion,key-bindings}.zsh; do
    [ -f "$f" ] && source "$f"
  done
fi

# Zoxide (smart cd)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi

# Direnv (project environments)
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# Terraform completion (use compdef for zsh)
if command -v terraform >/dev/null 2>&1; then
  if type compdef >/dev/null 2>&1; then
    compdef _terraform terraform
  fi
fi

# =============================================================================
# 1PASSWORD INTEGRATION
# =============================================================================
# SSH agent through 1Password (replaces traditional ssh-agent)
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# Quick 1Password lookups
alias opl='op item list'
alias opg='op item get'

# =============================================================================
# ENVIRONMENT VARIABLES
# =============================================================================
export EDITOR="nano"  # Simple and reliable
export VISUAL="$EDITOR"
export PAGER="less -R"
export LESS='-R --use-color -Dd+g -Du+b'
export CLICOLOR=1

# Infrastructure-specific
export ANSIBLE_HOST_KEY_CHECKING=False
export TERRAFORM_LOG_PATH="$HOME/.terraform.log"
export KUBECONFIG="$HOME/.kube/config"

# XDG compliance
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# =============================================================================
# PROMPT CONFIGURATION
# =============================================================================
[[ -f "${HOME}/.p10k.zsh" ]] && source "${HOME}/.p10k.zsh"

# =============================================================================
# PERFORMANCE OPTIMIZATION
# =============================================================================
# Compile zsh files for faster loading
{
  for f in ~/.zshrc ~/.p10k.zsh; do
    [ -f "$f" ] && zcompile -R -- "$f" "${f}.zwc" 2>/dev/null || true
  done
} &!

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
