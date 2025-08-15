# Homebrew shellenv (Apple Silicon vs Intel)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Ensure unique PATH entries
typeset -gU PATH FPATH

# 1Password CLI integration (if installed)
if command -v op >/dev/null 2>&1; then
  eval "$(op completion zsh)"; compdef _op op
fi
