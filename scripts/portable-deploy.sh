#!/usr/bin/env bash
set -euo pipefail

# Portable dotfiles deployment for SSH sessions
# Usage: ./portable-deploy.sh [remote-host]

REMOTE_HOST="${1:-}"
SCRIPT_DIR="$(dirname "$0")"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

if [[ -z "$REMOTE_HOST" ]]; then
    echo "Usage: $0 <remote-host>"
    echo "Example: $0 user@server.example.com"
    exit 1
fi

echo "🚀 Deploying portable dotfiles to $REMOTE_HOST"

# Create minimal portable package
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "📦 Creating portable package..."

# Copy essential configs
cp "$DOTFILES_DIR/.tmux.conf" "$TEMP_DIR/"
cp "$DOTFILES_DIR/config/zsh/aliases.zsh" "$TEMP_DIR/"
cp "$DOTFILES_DIR/config/zsh/functions.zsh" "$TEMP_DIR/"

# Create minimal zshrc for remote
cat > "$TEMP_DIR/.zshrc" << 'EOF'
# Portable dotfiles - minimal remote setup

# Load aliases and functions if available
[[ -f ~/.aliases.zsh ]] && source ~/.aliases.zsh
[[ -f ~/.functions.zsh ]] && source ~/.functions.zsh

# Basic shell options
setopt auto_cd extended_glob no_beep
setopt auto_pushd pushd_ignore_dups

# Enhanced history
HISTSIZE=10000
SAVEHIST=$HISTSIZE
setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups

# Basic prompt if no fancy stuff available
if ! command -v starship >/dev/null 2>&1; then
    PS1='%F{cyan}%n@%m%f:%F{blue}%~%f$ '
fi

echo "🚀 Portable dotfiles loaded"
EOF

# Create simple installer for remote
cat > "$TEMP_DIR/install-portable.sh" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "📝 Installing portable dotfiles..."

# Backup existing configs
[[ -f ~/.zshrc ]] && cp ~/.zshrc ~/.zshrc.backup.$(date +%s)
[[ -f ~/.tmux.conf ]] && cp ~/.tmux.conf ~/.tmux.conf.backup.$(date +%s)

# Install configs
cp .zshrc ~/.zshrc
cp .tmux.conf ~/.tmux.conf
cp aliases.zsh ~/.aliases.zsh
cp functions.zsh ~/.functions.zsh

echo "✅ Portable dotfiles installed!"
echo "💡 Run 'exec zsh' to reload your shell"
EOF

chmod +x "$TEMP_DIR/install-portable.sh"

echo "📤 Copying to remote host..."

# Copy portable package to remote
scp -r "$TEMP_DIR"/* "$REMOTE_HOST:~/"

echo "🔧 Installing on remote host..."

# Run installer on remote
ssh "$REMOTE_HOST" 'bash ~/install-portable.sh && rm ~/install-portable.sh'

echo "✅ Portable dotfiles deployed successfully!"
echo "💡 SSH in and run 'exec zsh' to activate"