#!/bin/bash
# Work-safe dotfiles installer - no Hammerspoon, no special permissions required

echo "🏢 Installing work-safe dotfiles (no Hammerspoon)..."

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
mkdir -p ~/dotfiles_backup/$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=~/dotfiles_backup/$(date +%Y%m%d_%H%M%S)

cp ~/.tmux.conf "$BACKUP_DIR/" 2>/dev/null && echo "  ✓ Backed up ~/.tmux.conf" || echo "  - No existing ~/.tmux.conf"
cp ~/.zshrc "$BACKUP_DIR/" 2>/dev/null && echo "  ✓ Backed up ~/.zshrc" || echo "  - No existing ~/.zshrc"
cp ~/.zprofile "$BACKUP_DIR/" 2>/dev/null && echo "  ✓ Backed up ~/.zprofile" || echo "  - No existing ~/.zprofile"
cp ~/.ssh/config "$BACKUP_DIR/" 2>/dev/null && echo "  ✓ Backed up ~/.ssh/config" || echo "  - No existing ~/.ssh/config"
cp ~/.config/ghostty/config "$BACKUP_DIR/" 2>/dev/null && echo "  ✓ Backed up ghostty config" || echo "  - No existing ghostty config"
cp ~/.tmux-cheatsheet.txt "$BACKUP_DIR/" 2>/dev/null || true

# Create required directories
echo "📁 Creating required directories..."
mkdir -p ~/.config/ghostty
mkdir -p ~/.config/alacritty/themes
mkdir -p ~/.ssh
mkdir -p ~/.tmux/plugins
mkdir -p ~/.local/bin

# Install tmux plugin manager (TPM) if not present
if [ ! -d ~/.tmux/plugins/tpm ]; then
    echo "🔌 Installing tmux plugin manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "  ✓ TPM installed"
else
    echo "  ✓ TPM already installed"
fi

# Copy configuration files
echo "⚙️  Installing configuration files..."
cp .tmux.conf ~ && echo "  ✓ tmux configuration"
cp .zshrc ~ && echo "  ✓ zsh configuration (modular setup)"

# Copy modular config directory
if [[ -d config ]]; then
    cp -r config ~/dotfiles-config && echo "  ✓ modular zsh configurations"
else
    echo "  ⚠️  config directory not found"
fi

# Copy optional files if they exist
[[ -f .zprofile ]] && cp .zprofile ~ && echo "  ✓ zsh profile"
[[ -f .tmux-cheatsheet.txt ]] && cp .tmux-cheatsheet.txt ~ && echo "  ✓ tmux cheatsheet"
[[ -f ssh_config ]] && cp ssh_config ~/.ssh/config && echo "  ✓ SSH configuration"
[[ -f ghostty_config ]] && cp ghostty_config ~/.config/ghostty/config && echo "  ✓ Ghostty terminal configuration"
[[ -f alacritty_config.toml ]] && cp alacritty_config.toml ~/.config/alacritty/alacritty.toml && echo "  ✓ Alacritty terminal configuration"
[[ -f alacritty_theme_catppuccin-mocha.toml ]] && cp alacritty_theme_catppuccin-mocha.toml ~/.config/alacritty/themes/catppuccin-mocha.toml && echo "  ✓ Alacritty Catppuccin theme"

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
chmod 644 ~/.ssh/config 2>/dev/null || true
chmod 644 ~/.config/ghostty/config 2>/dev/null || true
chmod 644 ~/.config/alacritty/alacritty.toml 2>/dev/null || true
chmod 644 ~/.config/alacritty/themes/catppuccin-mocha.toml 2>/dev/null || true
chmod 644 ~/.tmux.conf 2>/dev/null || true
chmod 644 ~/.zshrc 2>/dev/null || true
chmod 644 ~/.zprofile 2>/dev/null || true
chmod 644 ~/.tmux-cheatsheet.txt 2>/dev/null || true

# Environment Launcher setup (NO HAMMERSPOON)
echo ""
echo "🚀 Setting up Environment Launcher (work-safe mode)..."
if command -v brew >/dev/null 2>&1; then
    # Install only the essential dependencies (NO Hammerspoon)
    deps_needed=()
    command -v fzf >/dev/null 2>&1 || deps_needed+=(fzf)
    command -v yq >/dev/null 2>&1 || deps_needed+=(yq)

    if [[ ${#deps_needed[@]} -gt 0 ]]; then
        echo "  📦 Installing environment launcher dependencies: ${deps_needed[*]}"
        brew install "${deps_needed[@]}" --quiet
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
else
    echo "  ⚠️  Homebrew not found, skipping optional dependencies"
fi

# Add work-safe aliases for dev launcher
echo ""
echo "✅ Adding work-safe shell aliases..."
cat >> ~/.zshrc.local << 'EOF'
# Work-safe development environment aliases (no Hammerspoon required)
alias dev='~/.local/bin/dev-launcher'
alias dev-menu='~/.local/bin/dev-launcher'
alias dev-clean='docker system prune -f && echo "Docker cleanup complete"'
EOF
chmod 644 ~/.zshrc.local

echo ""
echo "✅ Work-safe installation complete!"
echo ""
echo "🎯 What's different from full install:"
echo "  - No Hammerspoon (no Accessibility permissions required)"
echo "  - Use 'dev' or 'dev-menu' command instead of ⌘+Shift+D hotkey"
echo "  - All container/VM functionality intact"
echo ""
echo "📖 Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Type 'dev' to launch the environment menu"
echo "  3. Check ~/.zshrc.local for additional work-specific customizations"
echo ""
echo "🔒 Security:"
echo "  - No special macOS permissions required"
echo "  - All containers run isolated"
echo "  - Edit ~/.zshrc.local for machine-specific settings (not tracked in git)"
echo ""
