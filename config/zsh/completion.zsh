# ZSH Completion Configuration
# Configured for XDG Base Directory Specification compliance

# Set completion dump file location (XDG compliant)
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

# Create completion cache directory if it doesn't exist  
[[ ! -d "$XDG_CACHE_HOME/zsh" ]] && mkdir -p "$XDG_CACHE_HOME/zsh"

# Load and initialize completion system
autoload -Uz compinit
compinit -d "$ZSH_COMPDUMP"

# Completion options
setopt ALWAYS_TO_END        # Move cursor to end of word when completing
setopt AUTO_MENU            # Show menu after pressing tab twice
setopt AUTO_LIST            # Automatically list choices on ambiguous completion
setopt AUTO_PARAM_SLASH     # Add trailing slash when completing directories
setopt COMPLETE_IN_WORD     # Allow completion in middle of word
setopt FLOW_CONTROL         # Disable start/stop characters in shell editor
unsetopt MENU_COMPLETE      # Don't autoselect first completion entry

# Completion matching
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Completion menu
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' special-dirs true

# Completion colors (use LS_COLORS if available)
if [[ "$OSTYPE" == darwin* ]]; then
    # macOS
    export CLICOLOR=1
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
else
    # Linux and others
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi

# Process completion
zstyle ':completion:*:processes' command 'ps -u $USER -o pid,user,comm -w -w'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

# Directory completion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*' squeeze-slashes true

# Cache completion for better performance
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/completion-cache"