#!/bin/bash
# Migrate dotfiles to XDG-compliant locations
# This cleans up the home directory by moving folders to proper XDG locations

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧹 XDG Migration Script${NC}"
echo "This will reorganize your dotfiles to follow XDG Base Directory spec"
echo

# Define old and new locations
OLD_CONFIG="$HOME/dotfiles-config"
NEW_CONFIG="$HOME/.config/dotfiles"

OLD_BACKUP="$HOME/dotfiles_backup"
NEW_BACKUP="$HOME/.local/state/dotfiles-backups"

# Safety check: Create a pre-migration backup
SAFETY_BACKUP="$HOME/.dotfiles-pre-xdg-migration-$(date +%Y%m%d_%H%M%S)"
echo -e "${YELLOW}⚠️  Creating safety backup first...${NC}"
mkdir -p "$SAFETY_BACKUP"

if [[ -d "$OLD_CONFIG" ]]; then
    cp -r "$OLD_CONFIG" "$SAFETY_BACKUP/"
    echo -e "  ${GREEN}✓${NC} Backed up dotfiles-config"
fi

if [[ -d "$OLD_BACKUP" ]]; then
    cp -r "$OLD_BACKUP" "$SAFETY_BACKUP/"
    echo -e "  ${GREEN}✓${NC} Backed up dotfiles_backup"
fi

echo -e "${GREEN}✓${NC} Safety backup created at: $SAFETY_BACKUP"
echo

# Show what will happen
echo -e "${BLUE}📋 Migration Plan:${NC}"
echo -e "  ${YELLOW}→${NC} $OLD_CONFIG"
echo -e "  ${GREEN}→${NC} $NEW_CONFIG"
echo
echo -e "  ${YELLOW}→${NC} $OLD_BACKUP"
echo -e "  ${GREEN}→${NC} $NEW_BACKUP"
echo

read -p "Proceed with migration? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Migration cancelled."
    exit 0
fi

echo
echo -e "${BLUE}🚀 Starting migration...${NC}"

# Migrate dotfiles-config
if [[ -d "$OLD_CONFIG" ]]; then
    if [[ -d "$NEW_CONFIG" ]]; then
        echo -e "${YELLOW}⚠️  $NEW_CONFIG already exists!${NC}"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$NEW_CONFIG"
        else
            echo "Skipping dotfiles-config migration"
            OLD_CONFIG=""  # Skip deletion later
        fi
    fi

    if [[ -n "$OLD_CONFIG" ]]; then
        mkdir -p "$(dirname "$NEW_CONFIG")"
        mv "$OLD_CONFIG" "$NEW_CONFIG"
        echo -e "  ${GREEN}✓${NC} Moved dotfiles-config → .config/dotfiles"
    fi
else
    echo -e "  ${YELLOW}-${NC} No dotfiles-config to migrate"
fi

# Migrate dotfiles_backup
if [[ -d "$OLD_BACKUP" ]]; then
    if [[ -d "$NEW_BACKUP" ]]; then
        echo -e "${YELLOW}⚠️  $NEW_BACKUP already exists!${NC}"
        read -p "Merge backups? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Move all backup folders into the new location
            for backup_dir in "$OLD_BACKUP"/*; do
                if [[ -d "$backup_dir" ]]; then
                    mv "$backup_dir" "$NEW_BACKUP/"
                fi
            done
            rmdir "$OLD_BACKUP" 2>/dev/null || rm -rf "$OLD_BACKUP"
            echo -e "  ${GREEN}✓${NC} Merged backups into .local/state/dotfiles-backups"
        else
            echo "Skipping backup migration"
        fi
    else
        mkdir -p "$(dirname "$NEW_BACKUP")"
        mv "$OLD_BACKUP" "$NEW_BACKUP"
        echo -e "  ${GREEN}✓${NC} Moved dotfiles_backup → .local/state/dotfiles-backups"
    fi
else
    echo -e "  ${YELLOW}-${NC} No dotfiles_backup to migrate"
fi

echo
echo -e "${GREEN}🎉 Migration complete!${NC}"
echo
echo -e "${BLUE}📍 New locations:${NC}"
echo -e "  Config:  ${GREEN}~/.config/dotfiles${NC}"
echo -e "  Backups: ${GREEN}~/.local/state/dotfiles-backups${NC}"
echo
echo -e "${YELLOW}⚠️  Important:${NC} Your shell needs to reload the new configuration"
echo -e "  Either: ${BLUE}source ~/.zshrc${NC}"
echo -e "  Or:     ${BLUE}exec zsh${NC} (start fresh shell)"
echo
echo -e "${BLUE}💾 Safety backup location:${NC} $SAFETY_BACKUP"
echo "   You can delete this after confirming everything works."
echo
echo -e "${BLUE}🔄 Next:${NC} Your dotfiles scripts have been updated to use new paths."
