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

# Set proper permissions
chmod 644 ~/.ssh/config
chmod 644 ~/.config/ghostty/config 2>/dev/null || true
chmod 644 ~/.config/alacritty/alacritty.toml 2>/dev/null || true
chmod 644 ~/.config/alacritty/themes/catppuccin-mocha.toml 2>/dev/null || true
chmod 644 ~/.tmux.conf
chmod 644 ~/.zshrc
chmod 644 ~/.zprofile
chmod 644 ~/.tmux-cheatsheet.txt

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
echo "  • tmux with homelab-optimized keybindings"
echo "  • SSH config for infrastructure work"
echo "  • Ghostty & Alacritty terminal configurations"
echo "  • Environment launcher with ⌘+Shift+D hotkey"
echo "  • Session persistence and restoration"
echo "  • Catppuccin Mocha theme for both terminals"
