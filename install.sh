#!/bin/bash
# Dotfiles installer

echo "Installing dotfiles..."

# Backup existing files
mkdir -p ~/dotfiles_backup
cp ~/.zshrc ~/dotfiles_backup/ 2>/dev/null || true
cp ~/.zprofile ~/dotfiles_backup/ 2>/dev/null || true
cp ~/.tmux.conf ~/dotfiles_backup/ 2>/dev/null || true
cp ~/.ssh/config ~/dotfiles_backup/ 2>/dev/null || true

# Create required directories
mkdir -p ~/.config/ghostty
mkdir -p ~/.ssh

# Copy configuration files
cp .zshrc ~/
cp .zprofile ~/
cp .tmux.conf ~/
cp ssh_config ~/.ssh/config
cp ghostty_config ~/.config/ghostty/config 2>/dev/null || true

# Set proper permissions
chmod 644 ~/.ssh/config
chmod 644 ~/.config/ghostty/config 2>/dev/null || true

echo "Dotfiles installed! Start a new terminal session."
