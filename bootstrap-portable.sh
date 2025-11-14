#!/usr/bin/env bash
# =============================================================================
# PORTABLE DOTFILES BOOTSTRAP
# =============================================================================
# One-liner install for remote servers
# Usage: curl -fsSL https://raw.githubusercontent.com/UncertainMeow/dotfiles/main/bootstrap-portable.sh | bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        📦 Portable Dotfiles Bootstrap                  ║${NC}"
echo -e "${BLUE}║        Minimal config for remote servers               ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Detect OS
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
    elif command -v lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
        OS_VERSION=$(lsb_release -sr)
    else
        OS=$(uname -s | tr '[:upper:]' '[:lower:]')
        OS_VERSION="unknown"
    fi

    echo -e "${GREEN}✓${NC} Detected OS: $OS $OS_VERSION"
}

# Check for git
check_git() {
    if ! command -v git >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠${NC}  Git not found - attempting to install..."

        case "$OS" in
            ubuntu|debian)
                sudo apt-get update && sudo apt-get install -y git
                ;;
            centos|rhel|fedora)
                sudo yum install -y git || sudo dnf install -y git
                ;;
            arch)
                sudo pacman -Sy --noconfirm git
                ;;
            *)
                echo -e "${RED}✗${NC} Cannot auto-install git on $OS"
                echo -e "${YELLOW}💡${NC} Please install git manually and re-run"
                exit 1
                ;;
        esac
    fi

    echo -e "${GREEN}✓${NC} Git is available"
}

# Install dotfiles
install_dotfiles() {
    DOTFILES_DIR="$HOME/.dotfiles"

    # Backup existing dotfiles
    if [[ -f "$HOME/.zshrc" ]]; then
        echo -e "${YELLOW}⚠${NC}  Backing up existing .zshrc"
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%s)"
    fi

    # Clone or update repository
    if [[ -d "$DOTFILES_DIR" ]]; then
        echo -e "${BLUE}ℹ${NC}  Dotfiles already exist - updating..."
        cd "$DOTFILES_DIR"
        git pull
    else
        echo -e "${BLUE}ℹ${NC}  Cloning portable dotfiles..."
        git clone https://github.com/UncertainMeow/dotfiles.git "$DOTFILES_DIR"
    fi

    echo -e "${GREEN}✓${NC} Dotfiles downloaded"
}

# Install portable configs
install_configs() {
    echo -e "${BLUE}ℹ${NC}  Installing portable configuration..."

    # Create necessary directories
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.local/share/zsh"

    # Link portable zshrc
    ln -sf "$HOME/.dotfiles/config/portable/zshrc" "$HOME/.zshrc"

    echo -e "${GREEN}✓${NC} Configuration installed"
}

# Check for zsh
check_zsh() {
    if ! command -v zsh >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠${NC}  Zsh not found"
        echo -e "${YELLOW}💡${NC} Portable dotfiles work with bash too, but zsh is recommended"
        echo ""
        echo -e "  To install zsh:"
        echo -e "    ${BLUE}Ubuntu/Debian:${NC} sudo apt-get install zsh"
        echo -e "    ${BLUE}CentOS/RHEL:${NC}   sudo yum install zsh"
        echo -e "    ${BLUE}Arch:${NC}          sudo pacman -S zsh"
        echo ""
        return 1
    fi

    echo -e "${GREEN}✓${NC} Zsh is available"
    return 0
}

# Change default shell
change_shell() {
    if check_zsh; then
        if [[ "$SHELL" != *"zsh"* ]]; then
            echo -e "${BLUE}ℹ${NC}  Current shell: $SHELL"
            echo -e "${YELLOW}💡${NC} To make zsh your default shell, run:"
            echo -e "    ${BLUE}chsh -s \$(which zsh)${NC}"
            echo ""
        fi
    fi
}

# Main installation
main() {
    detect_os
    check_git
    install_dotfiles
    install_configs
    change_shell

    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                  ✅ Installation Complete!              ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}🚀 Next steps:${NC}"
    echo -e "  ${GREEN}1.${NC} Start zsh:      ${BLUE}exec zsh${NC}"
    echo -e "  ${GREEN}2.${NC} Test it:        ${BLUE}ll${NC}  (should work now!)"
    echo -e "  ${GREEN}3.${NC} Update anytime: ${BLUE}dotpull${NC}"
    echo ""
    echo -e "${YELLOW}💡 Tip:${NC} All your muscle-memory aliases (ll, gs, gst, etc.) are ready!"
    echo ""
}

# Run installation
main
