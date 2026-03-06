#!/bin/bash
# Dotfiles installer - modular terminal configuration

echo "🚀 Installing modern dotfiles..."

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  Warning: This setup is optimized for macOS"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Backup existing files
echo "📦 Backing up existing configurations..."
mkdir -p ~/.local/state/dotfiles-backups/$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=~/.local/state/dotfiles-backups/$(date +%Y%m%d_%H%M%S)

cp ~/.tmux.conf "$BACKUP_DIR/" 2>/dev/null && echo "  ✓ Backed up ~/.tmux.conf" || echo "  - No existing ~/.tmux.conf"
cp ~/.zshrc "$BACKUP_DIR/" 2>/dev/null && echo "  ✓ Backed up ~/.zshrc" || echo "  - No existing ~/.zshrc"
cp ~/.zprofile "$BACKUP_DIR/" 2>/dev/null && echo "  ✓ Backed up ~/.zprofile" || echo "  - No existing ~/.zprofile"
cp ~/.ssh/config "$BACKUP_DIR/" 2>/dev/null && echo "  ✓ Backed up ~/.ssh/config" || echo "  - No existing ~/.ssh/config"
cp ~/.config/ghostty/config "$BACKUP_DIR/" 2>/dev/null && echo "  ✓ Backed up ghostty config" || echo "  - No existing ghostty config"
cp ~/.gitconfig "$BACKUP_DIR/" 2>/dev/null && echo "  ✓ Backed up ~/.gitconfig" || echo "  - No existing ~/.gitconfig"
cp ~/.config/bat/config "$BACKUP_DIR/bat-config" 2>/dev/null && echo "  ✓ Backed up bat config" || echo "  - No existing bat config"
cp ~/.config/lazygit/config.yml "$BACKUP_DIR/lazygit-config.yml" 2>/dev/null && echo "  ✓ Backed up lazygit config" || echo "  - No existing lazygit config"
cp ~/.tmux-cheatsheet.txt "$BACKUP_DIR/" 2>/dev/null || true

# Create required directories (XDG compliant)
echo "📁 Creating required directories..."
mkdir -p ~/.config/ghostty
mkdir -p ~/.config/alacritty/themes
mkdir -p ~/.config/bat
mkdir -p ~/.config/lazygit
mkdir -p ~/.config/tmux/plugins
mkdir -p ~/.config/git
mkdir -p ~/.config/p10k
mkdir -p ~/.local/state/terraform
mkdir -p ~/.ssh

# Install tmux plugin manager (TPM) if not present
# XDG: tmux 3.1+ reads from ~/.config/tmux/ automatically
if [ ! -d ~/.config/tmux/plugins/tpm ]; then
    echo "🔌 Installing tmux plugin manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
    echo "  ✓ TPM installed"
else
    echo "  ✓ TPM already installed"
fi

# Copy configuration files (XDG compliant - nothing loose in $HOME except .zshrc/.zprofile)
echo "⚙️  Installing configuration files..."
cp .tmux.conf ~/.config/tmux/tmux.conf && echo "  ✓ tmux configuration → ~/.config/tmux/"
cp .zshrc ~ && echo "  ✓ zsh configuration"

# Copy modular config directory
if [[ -d config ]]; then
    mkdir -p ~/.config/dotfiles
    cp -r config ~/.config/dotfiles/ && echo "  ✓ modular zsh configurations"
else
    echo "  ⚠️  config directory not found"
fi

# Copy optional files if they exist
[[ -f .zprofile ]] && cp .zprofile ~ && echo "  ✓ zsh profile"
[[ -f .tmux-cheatsheet.txt ]] && cp .tmux-cheatsheet.txt ~/.config/tmux/cheatsheet.txt && echo "  ✓ tmux cheatsheet → ~/.config/tmux/"
[[ -f ssh_config ]] && cp ssh_config ~/.ssh/config && echo "  ✓ SSH configuration"
[[ -f ghostty_config ]] && cp ghostty_config ~/.config/ghostty/config && echo "  ✓ Ghostty terminal configuration"
[[ -f alacritty_config.toml ]] && cp alacritty_config.toml ~/.config/alacritty/alacritty.toml && echo "  ✓ Alacritty terminal configuration"
[[ -f alacritty_theme_catppuccin-mocha.toml ]] && cp alacritty_theme_catppuccin-mocha.toml ~/.config/alacritty/themes/catppuccin-mocha.toml && echo "  ✓ Alacritty Catppuccin theme"

# Application configs (theming) — all go under ~/.config/
[[ -f .gitconfig ]] && cp .gitconfig ~/.config/git/config && echo "  ✓ Git configuration → ~/.config/git/"
[[ -f config/bat/config ]] && cp config/bat/config ~/.config/bat/config && echo "  ✓ bat configuration (Catppuccin theme)"
[[ -f config/lazygit/config.yml ]] && cp config/lazygit/config.yml ~/.config/lazygit/config.yml && echo "  ✓ lazygit configuration (Catppuccin theme)"

# Clean up old non-XDG locations if they exist
if [[ -f ~/.tmux.conf ]]; then
    echo "  🧹 Removing old ~/.tmux.conf (now in ~/.config/tmux/)"
    rm -f ~/.tmux.conf
fi
if [[ -f ~/.tmux-cheatsheet.txt ]]; then
    echo "  🧹 Removing old ~/.tmux-cheatsheet.txt (now in ~/.config/tmux/)"
    rm -f ~/.tmux-cheatsheet.txt
fi
if [[ -f ~/.gitconfig ]] && [[ -f ~/.config/git/config ]]; then
    echo "  🧹 Removing old ~/.gitconfig (now in ~/.config/git/)"
    rm -f ~/.gitconfig
fi

# Validate and fix Ghostty themes if needed
if [[ -f scripts/validate-ghostty-themes.sh ]]; then
    echo "🔍 Validating Ghostty themes..."
    if bash scripts/validate-ghostty-themes.sh; then
        echo "  ✓ Ghostty themes validated"
    else
        echo "  ⚠️  Ghostty theme validation failed (non-fatal)"
    fi
fi

# Validate zsh configuration
if [[ -f scripts/validate-zsh-config.sh ]]; then
    echo "🔍 Validating zsh configuration..."
    if bash scripts/validate-zsh-config.sh; then
        echo "  ✓ Zsh configuration validated"
    else
        echo "  ⚠️  Zsh configuration validation failed (non-fatal)"
    fi
fi

# Set proper permissions
chmod 644 ~/.ssh/config
chmod 644 ~/.config/ghostty/config 2>/dev/null || true
chmod 644 ~/.config/alacritty/alacritty.toml 2>/dev/null || true
chmod 644 ~/.config/alacritty/themes/catppuccin-mocha.toml 2>/dev/null || true
chmod 644 ~/.config/tmux/tmux.conf 2>/dev/null || true
chmod 644 ~/.config/tmux/cheatsheet.txt 2>/dev/null || true
chmod 644 ~/.config/git/config 2>/dev/null || true
chmod 644 ~/.zshrc
chmod 644 ~/.zprofile

# Optional: Environment Launcher setup
echo ""
echo "🚀 Setting up Environment Launcher..."
if command -v brew >/dev/null 2>&1; then
    # Install Hammerspoon if not present
    if ! command -v hammerspoon >/dev/null 2>&1 && ! [[ -d "/Applications/Hammerspoon.app" ]]; then
        echo "  📦 Installing Hammerspoon..."
        brew install hammerspoon --quiet
    fi

    # Install dependencies
    deps_needed=()
    command -v fzf >/dev/null 2>&1 || deps_needed+=(fzf)
    command -v yq >/dev/null 2>&1 || deps_needed+=(yq)

    if [[ ${#deps_needed[@]} -gt 0 ]]; then
        echo "  📦 Installing environment launcher dependencies: ${deps_needed[*]}"
        brew install "${deps_needed[@]}" --quiet
    fi

    # Set up Hammerspoon config if it doesn't exist
    if [[ ! -f "$HOME/.hammerspoon/init.lua" ]]; then
        echo "  ⚙️ Configuring Hammerspoon hotkeys..."
        mkdir -p "$HOME/.hammerspoon"
        [[ -f "environment-launcher/hammerspoon-setup.lua" ]] && \
            cp environment-launcher/hammerspoon-setup.lua "$HOME/.hammerspoon/init.lua"
    fi

    # Set up environment launcher config
    if [[ -d "environment-launcher" ]]; then
        echo "  ⚙️ Setting up environment launcher..."
        mkdir -p "$HOME/.config/dev-environments"
        [[ -f "environment-launcher/containers.yaml" ]] && \
            cp environment-launcher/containers.yaml "$HOME/.config/dev-environments/" 2>/dev/null || true

        # Ensure dev-launcher is in place and executable
        [[ -f "environment-launcher/dev-launcher" ]] && \
            cp environment-launcher/dev-launcher "$HOME/.local/bin/" && \
            chmod +x "$HOME/.local/bin/dev-launcher"
    fi

    echo "  ✓ Environment launcher configured"
    echo "  💡 Use ⌘+Shift+D after starting Docker Desktop"
else
    echo "  ⚠️ Homebrew not found - skipping environment launcher setup"
fi

echo ""
echo "🎉 Dotfiles installed successfully!"
echo ""
echo "📋 Next steps:"
echo "  1. Start a new terminal session"
echo "  2. Launch tmux and run 'Ctrl-a + I' to install tmux plugins"
echo "  3. Use 'Ctrl-a + C' for the tmux cheatsheet"
echo "  4. Start Docker Desktop and try ⌘+Shift+D for environment launcher"
echo ""
echo "💡 Key features:"
echo "  • Catppuccin Mocha theme everywhere (Ghostty, Alacritty, tmux, bat, fzf, lazygit, delta)"
echo "  • tmux with homelab-optimized keybindings"
echo "  • SSH config for infrastructure work"
echo "  • Ghostty & Alacritty terminal configurations"
echo "  • git-delta for beautiful diffs (side-by-side, syntax highlighted)"
echo "  • Environment launcher with ⌘+Shift+D hotkey"
echo "  • Session persistence and restoration"
echo "  • deploy-dots <user@host> to push portable config to servers"
