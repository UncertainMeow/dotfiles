#!/bin/bash
# Sync live configuration changes back to the dotfiles repo
# Use this to update the repo with changes you've made to your live config

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory (the dotfiles repo)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}🔄 Syncing Live Config to Repo${NC}"
echo "Repo directory: $REPO_DIR"
echo

# Check if we're in a git repo
if ! git -C "$REPO_DIR" rev-parse --git-dir >/dev/null 2>&1; then
    echo -e "${RED}❌ Not in a git repository!${NC}"
    echo "Please run this script from within the dotfiles repo."
    exit 1
fi

# Function to sync a file
sync_file() {
    local source="$1"
    local dest="$2"
    local description="$3"

    if [[ -f "$source" ]]; then
        if [[ -f "$dest" ]]; then
            # Check if files are different
            if ! diff -q "$source" "$dest" >/dev/null 2>&1; then
                cp "$source" "$dest"
                echo -e "  ${GREEN}✓${NC} Updated: $description"
                return 0
            else
                echo -e "  ${BLUE}-${NC} No changes: $description"
                return 1
            fi
        else
            cp "$source" "$dest"
            echo -e "  ${GREEN}+${NC} Added: $description"
            return 0
        fi
    else
        echo -e "  ${YELLOW}?${NC} Not found: $description (source: $source)"
        return 1
    fi
}

# Function to sync a directory
sync_directory() {
    local source="$1"
    local dest="$2"
    local description="$3"

    if [[ -d "$source" ]]; then
        if [[ -d "$dest" ]]; then
            # Use rsync to sync directory contents
            if command -v rsync >/dev/null 2>&1; then
                if rsync -a --delete --dry-run "$source/" "$dest/" | grep -q "^>"; then
                    rsync -a --delete "$source/" "$dest/"
                    echo -e "  ${GREEN}✓${NC} Synced directory: $description"
                    return 0
                else
                    echo -e "  ${BLUE}-${NC} No changes in directory: $description"
                    return 1
                fi
            else
                # Fallback to cp
                cp -r "$source/" "$dest/"
                echo -e "  ${GREEN}✓${NC} Copied directory: $description"
                return 0
            fi
        else
            mkdir -p "$(dirname "$dest")"
            cp -r "$source" "$dest"
            echo -e "  ${GREEN}+${NC} Added directory: $description"
            return 0
        fi
    else
        echo -e "  ${YELLOW}?${NC} Directory not found: $description (source: $source)"
        return 1
    fi
}

# Track if any files were changed
CHANGES_MADE=0

echo "📁 Syncing configuration files..."

# Sync main config files
if sync_file "$HOME/.zshrc" "$REPO_DIR/.zshrc" "Main zsh configuration"; then
    ((CHANGES_MADE++))
fi

if sync_file "$HOME/.tmux.conf" "$REPO_DIR/.tmux.conf" "tmux configuration"; then
    ((CHANGES_MADE++))
fi

if sync_file "$HOME/.zprofile" "$REPO_DIR/.zprofile" "zsh profile"; then
    ((CHANGES_MADE++))
fi

# Sync terminal configs
if sync_file "$HOME/.config/ghostty/config" "$REPO_DIR/ghostty_config" "Ghostty configuration"; then
    ((CHANGES_MADE++))
fi

if sync_file "$HOME/.config/alacritty/alacritty.toml" "$REPO_DIR/alacritty_config.toml" "Alacritty configuration"; then
    ((CHANGES_MADE++))
fi

if sync_file "$HOME/.config/alacritty/themes/catppuccin-mocha.toml" "$REPO_DIR/alacritty_theme_catppuccin-mocha.toml" "Alacritty theme"; then
    ((CHANGES_MADE++))
fi

echo
echo "📂 Syncing modular configurations..."

# Sync the modular config directory
if sync_directory "$HOME/dotfiles-config/zsh" "$REPO_DIR/config/zsh" "Modular zsh configs"; then
    ((CHANGES_MADE++))
fi

# Handle any local customizations with warning
if [[ -f "$HOME/.zshrc.local" ]]; then
    echo
    echo -e "${YELLOW}⚠️  Local customizations found:${NC}"
    echo "  $HOME/.zshrc.local exists but won't be synced to repo"
    echo "  (This is intentional - local files should stay local)"
fi

echo
echo "🔍 Checking for git changes..."

# Change to repo directory for git operations
cd "$REPO_DIR"

# Check git status
if git status --porcelain | grep -q .; then
    echo -e "${BLUE}📋 Git Status:${NC}"
    git status --short | sed 's/^/  /'
    echo

    # Show what changed
    echo -e "${BLUE}📝 Changes made:${NC}"
    git diff --name-only | while read -r file; do
        echo -e "  ${GREEN}•${NC} Modified: $file"
    done

    git ls-files --others --exclude-standard | while read -r file; do
        echo -e "  ${GREEN}•${NC} Added: $file"
    done

    echo
    echo -e "${BLUE}💡 Next steps:${NC}"
    echo "  1. Review changes: git diff"
    echo "  2. Add files: git add ."
    echo "  3. Commit: git commit -m \"sync: Update configs from live system\""
    echo "  4. Push: git push"
    echo
    echo "Or run the commit automatically:"
    read -p "Commit and push changes now? (y/N): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo
        echo -e "${BLUE}📦 Committing changes...${NC}"

        git add .
        git commit -m "sync: Update configs from live system

Synced live configuration changes back to repo.

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

        echo -e "${BLUE}🚀 Pushing to remote...${NC}"
        git push

        echo -e "${GREEN}✅ Sync complete!${NC}"
    else
        echo "Changes staged but not committed."
    fi

elif [[ $CHANGES_MADE -gt 0 ]]; then
    echo -e "${BLUE}ℹ️  Files were copied but no git changes detected${NC}"
    echo "This usually means the repo was already up to date."
else
    echo -e "${GREEN}✅ All configurations are already in sync!${NC}"
fi

echo
echo -e "${BLUE}💡 Pro tip:${NC} Run this script periodically to keep your repo updated"
echo "   with any tweaks you make to your live configuration."