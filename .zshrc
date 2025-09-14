# =============================================================================
# HOMELAB DOTFILES - Modular Terminal Setup
# =============================================================================

# Instant prompt for Powerlevel10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =============================================================================
# MODULAR CONFIG LOADING
# =============================================================================

# Get the directory where config modules are located
# Check if we're in the dotfiles repo or if configs are in ~/dotfiles-config
if [[ -d "${${(%):-%x}:A:h}/config/zsh" ]]; then
    ZSH_CONFIG_DIR="${${(%):-%x}:A:h}/config/zsh"
elif [[ -d "$HOME/dotfiles-config/zsh" ]]; then
    ZSH_CONFIG_DIR="$HOME/dotfiles-config/zsh"
else
    ZSH_CONFIG_DIR=""
fi

# Load modular configurations
if [[ -d "$ZSH_CONFIG_DIR" ]]; then
  # Core configuration modules
  [[ -f "$ZSH_CONFIG_DIR/environment.zsh" ]] && source "$ZSH_CONFIG_DIR/environment.zsh"
  [[ -f "$ZSH_CONFIG_DIR/history.zsh" ]] && source "$ZSH_CONFIG_DIR/history.zsh"
  [[ -f "$ZSH_CONFIG_DIR/completion.zsh" ]] && source "$ZSH_CONFIG_DIR/completion.zsh"
  [[ -f "$ZSH_CONFIG_DIR/aliases.zsh" ]] && source "$ZSH_CONFIG_DIR/aliases.zsh"
  [[ -f "$ZSH_CONFIG_DIR/functions.zsh" ]] && source "$ZSH_CONFIG_DIR/functions.zsh"
  
  # OS-specific configurations
  case "$(uname -s)" in
    Darwin*)
      [[ -f "$ZSH_CONFIG_DIR/os/macos.zsh" ]] && source "$ZSH_CONFIG_DIR/os/macos.zsh"
      ;;
    Linux*)
      # Detect specific Linux distributions
      if [[ -f /etc/arch-release ]]; then
        [[ -f "$ZSH_CONFIG_DIR/os/arch.zsh" ]] && source "$ZSH_CONFIG_DIR/os/arch.zsh"
      elif [[ -f /etc/fedora-release ]] && grep -q "Bazzite" /etc/os-release 2>/dev/null; then
        [[ -f "$ZSH_CONFIG_DIR/os/bazzite.zsh" ]] && source "$ZSH_CONFIG_DIR/os/bazzite.zsh"
      elif [[ -f /etc/NIXOS ]]; then
        [[ -f "$ZSH_CONFIG_DIR/os/nixos.zsh" ]] && source "$ZSH_CONFIG_DIR/os/nixos.zsh"
      fi
      ;;
  esac
fi

# =============================================================================
# SHELL OPTIONS & BEHAVIOR (from your working config)
# =============================================================================
setopt auto_cd extended_glob no_beep correct_all interactive_comments
setopt auto_pushd pushd_ignore_dups pushd_minus

# =============================================================================
# ZINIT PLUGIN MANAGER (from your working config)
# =============================================================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# =============================================================================
# ZINIT PLUGINS (from your working config)
# =============================================================================

# Load powerlevel10k theme
zinit ice depth"1"
zinit load romkatv/powerlevel10k

# Essential plugins for infrastructure work
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions

# Additional useful plugins
zinit light Aloxaf/fzf-tab
zinit light hlissner/zsh-autopair

# Load completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# =============================================================================
# COLORS & VISUAL (from your working config)  
# =============================================================================
if command -v vivid >/dev/null 2>&1; then
  export LS_COLORS="$(vivid generate catppuccin-mocha)"
elif command -v gdircolors >/dev/null 2>&1; then
  eval "$(gdircolors -b 2>/dev/null || true)"
fi

# =============================================================================
# FINAL CONFIGURATIONS
# =============================================================================

# Load prompt configuration if it exists
[[ -f "$ZSH_CONFIG_DIR/prompt.zsh" ]] && source "$ZSH_CONFIG_DIR/prompt.zsh"

# Load any local customizations (not tracked in git)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh