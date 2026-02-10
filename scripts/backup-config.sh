#!/bin/bash
# Manual backup script for dotfiles configuration
# Use this before experimenting with configs

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BACKUP_BASE_DIR="$HOME/.local/state/dotfiles-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_BASE_DIR/manual_$TIMESTAMP"

echo -e "${BLUE}🔄 Manual Dotfiles Backup${NC}"
echo "Creating backup at: $BACKUP_DIR"
echo

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Files to backup
declare -a FILES=(
    "$HOME/.zshrc"
    "$HOME/.zprofile"
    "$HOME/.tmux.conf"
    "$HOME/.config/ghostty/config"
    "$HOME/.config/alacritty/alacritty.toml"
    "$HOME/.config/alacritty/themes/catppuccin-mocha.toml"
    "$HOME/.zshrc.local"
)

# Directories to backup
declare -a DIRS=(
    "$HOME/.config/dotfiles"
    "$HOME/.config/ghostty/themes"
)

# Function to backup a file
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local relative_path="${file#$HOME/}"
        local backup_file_dir="$BACKUP_DIR/$(dirname "$relative_path")"
        mkdir -p "$backup_file_dir"
        cp "$file" "$backup_file_dir/"
        echo -e "  ${GREEN}✓${NC} Backed up: $relative_path"
    else
        echo -e "  ${YELLOW}-${NC} Not found: ${file#$HOME/}"
    fi
}

# Function to backup a directory
backup_dir() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        local relative_path="${dir#$HOME/}"
        local backup_dir_parent="$BACKUP_DIR/$(dirname "$relative_path")"
        mkdir -p "$backup_dir_parent"
        cp -r "$dir" "$backup_dir_parent/"
        echo -e "  ${GREEN}✓${NC} Backed up directory: $relative_path"
    else
        echo -e "  ${YELLOW}-${NC} Directory not found: ${dir#$HOME/}"
    fi
}

echo "📁 Backing up configuration files..."
for file in "${FILES[@]}"; do
    backup_file "$file"
done

echo
echo "📂 Backing up configuration directories..."
for dir in "${DIRS[@]}"; do
    backup_dir "$dir"
done

# Create a manifest of what was backed up
echo
echo "📋 Creating backup manifest..."
cat > "$BACKUP_DIR/MANIFEST.txt" << EOF
Dotfiles Manual Backup
Created: $(date)
Backup Directory: $BACKUP_DIR

Files backed up:
$(find "$BACKUP_DIR" -type f | sort | sed "s|$BACKUP_DIR/||" | grep -v MANIFEST.txt)

Original locations:
$(for file in "${FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo "  ${file#$HOME/} -> $(basename "$file")"
    fi
done)

Directories backed up:
$(for dir in "${DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        echo "  ${dir#$HOME/} -> $(basename "$dir")"
    fi
done)

To restore this backup:
  cd dotfiles && ./scripts/restore-config.sh "$BACKUP_DIR"

EOF

echo -e "  ${GREEN}✓${NC} Created manifest: MANIFEST.txt"

# Show backup summary
echo
echo -e "${GREEN}🎉 Backup completed successfully!${NC}"
echo
echo "📍 Backup location: $BACKUP_DIR"
echo "📄 View manifest: cat \"$BACKUP_DIR/MANIFEST.txt\""
echo "🔄 To restore: cd dotfiles && ./scripts/restore-config.sh \"$BACKUP_DIR\""
echo

# Clean up old backups (keep last 10)
echo "🧹 Cleaning up old backups (keeping 10 most recent)..."
if [[ -d "$BACKUP_BASE_DIR" ]]; then
    # Remove old backups, keeping only the 10 most recent
    ls -1t "$BACKUP_BASE_DIR" | tail -n +11 | while read -r old_backup; do
        if [[ -d "$BACKUP_BASE_DIR/$old_backup" ]]; then
            rm -rf "$BACKUP_BASE_DIR/$old_backup"
            echo -e "  ${YELLOW}🗑️${NC} Removed old backup: $old_backup"
        fi
    done
fi

echo
echo -e "${BLUE}💡 Pro tip:${NC} Run this script before experimenting with configs!"
echo "   Then you can easily restore if something breaks."