#!/bin/bash
# Restore script for dotfiles configuration backups
# Usage: ./restore-config.sh [backup_directory]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BACKUP_BASE_DIR="$HOME/.local/state/dotfiles-backups"

# Function to show usage
show_usage() {
    echo -e "${BLUE}🔄 Dotfiles Restore Script${NC}"
    echo
    echo "Usage: $0 [backup_directory]"
    echo
    echo "Examples:"
    echo "  $0                                    # Interactive selection from available backups"
    echo "  $0 ~/.local/state/dotfiles-backups/manual_20240101_120000  # Restore specific backup"
    echo
    echo "Available backups:"
    if [[ -d "$BACKUP_BASE_DIR" ]]; then
        ls -1t "$BACKUP_BASE_DIR" | head -10 | while read -r backup; do
            echo "  $BACKUP_BASE_DIR/$backup"
        done
    else
        echo "  No backups found in $BACKUP_BASE_DIR"
    fi
}

# Function to select backup interactively
select_backup() {
    echo -e "${BLUE}📂 Available Backups${NC}"
    echo

    if [[ ! -d "$BACKUP_BASE_DIR" ]]; then
        echo -e "${RED}❌ No backup directory found at: $BACKUP_BASE_DIR${NC}"
        exit 1
    fi

    local backups=($(ls -1t "$BACKUP_BASE_DIR" 2>/dev/null || true))

    if [[ ${#backups[@]} -eq 0 ]]; then
        echo -e "${RED}❌ No backups found in: $BACKUP_BASE_DIR${NC}"
        exit 1
    fi

    echo "Select a backup to restore:"
    echo

    for i in "${!backups[@]}"; do
        local backup="${backups[$i]}"
        local backup_path="$BACKUP_BASE_DIR/$backup"

        # Extract date from backup name if possible
        local display_name="$backup"
        if [[ "$backup" =~ ([0-9]{8}_[0-9]{6}) ]]; then
            local timestamp="${BASH_REMATCH[1]}"
            local formatted_date=$(date -j -f "%Y%m%d_%H%M%S" "$timestamp" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "$timestamp")
            display_name="$backup ($formatted_date)"
        fi

        echo "  $((i+1)). $display_name"

        # Show manifest preview if available
        if [[ -f "$backup_path/MANIFEST.txt" ]]; then
            echo "     $(head -3 "$backup_path/MANIFEST.txt" | tail -1)"
        fi
    done

    echo
    read -p "Enter selection (1-${#backups[@]}) or 'q' to quit: " selection

    if [[ "$selection" == "q" ]] || [[ "$selection" == "Q" ]]; then
        echo "Cancelled."
        exit 0
    fi

    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [[ "$selection" -lt 1 ]] || [[ "$selection" -gt "${#backups[@]}" ]]; then
        echo -e "${RED}❌ Invalid selection${NC}"
        exit 1
    fi

    local selected_backup="${backups[$((selection-1))]}"
    echo "$BACKUP_BASE_DIR/$selected_backup"
}

# Function to restore files
restore_files() {
    local backup_dir="$1"

    echo -e "${BLUE}🔄 Restoring configuration from:${NC}"
    echo "  $backup_dir"
    echo

    # Verify backup directory exists
    if [[ ! -d "$backup_dir" ]]; then
        echo -e "${RED}❌ Backup directory not found: $backup_dir${NC}"
        exit 1
    fi

    # Show manifest if available
    if [[ -f "$backup_dir/MANIFEST.txt" ]]; then
        echo -e "${BLUE}📋 Backup Information:${NC}"
        head -10 "$backup_dir/MANIFEST.txt" | sed 's/^/  /'
        echo
    fi

    # Confirm before proceeding
    echo -e "${YELLOW}⚠️  This will overwrite your current configuration!${NC}"
    read -p "Continue? (y/N): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi

    echo
    echo -e "${BLUE}📦 Creating safety backup of current config...${NC}"

    # Create a safety backup before restoring
    SAFETY_BACKUP_DIR="$BACKUP_BASE_DIR/pre_restore_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$SAFETY_BACKUP_DIR"

    # Quick backup of current files
    declare -a current_files=(
        "$HOME/.zshrc"
        "$HOME/.zprofile"
        "$HOME/.tmux.conf"
        "$HOME/.zshrc.local"
    )

    for file in "${current_files[@]}"; do
        if [[ -f "$file" ]]; then
            cp "$file" "$SAFETY_BACKUP_DIR/" 2>/dev/null || true
        fi
    done

    if [[ -d "$HOME/.config/dotfiles" ]]; then
        cp -r "$HOME/.config/dotfiles" "$SAFETY_BACKUP_DIR/" 2>/dev/null || true
    fi

    if [[ -d "$HOME/.config/ghostty" ]]; then
        mkdir -p "$SAFETY_BACKUP_DIR/.config"
        cp -r "$HOME/.config/ghostty" "$SAFETY_BACKUP_DIR/.config/" 2>/dev/null || true
    fi

    if [[ -d "$HOME/.config/alacritty" ]]; then
        mkdir -p "$SAFETY_BACKUP_DIR/.config"
        cp -r "$HOME/.config/alacritty" "$SAFETY_BACKUP_DIR/.config/" 2>/dev/null || true
    fi

    echo -e "  ${GREEN}✓${NC} Safety backup created: $SAFETY_BACKUP_DIR"
    echo

    # Restore files
    echo -e "${BLUE}🔄 Restoring files...${NC}"

    # Restore each file/directory found in backup
    find "$backup_dir" -type f -not -name "MANIFEST.txt" | while read -r backup_file; do
        # Calculate relative path from backup dir
        local rel_path="${backup_file#$backup_dir/}"
        local target_file="$HOME/$rel_path"
        local target_dir="$(dirname "$target_file")"

        # Create target directory if needed
        mkdir -p "$target_dir"

        # Restore file
        cp "$backup_file" "$target_file"
        echo -e "  ${GREEN}✓${NC} Restored: $rel_path"
    done

    echo
    echo -e "${GREEN}🎉 Restore completed successfully!${NC}"
    echo
    echo -e "${BLUE}📍 Next steps:${NC}"
    echo "  1. Open a new terminal to test the restored configuration"
    echo "  2. If something's wrong, restore from safety backup:"
    echo "     $0 \"$SAFETY_BACKUP_DIR\""
    echo
    echo -e "${BLUE}💡 Pro tip:${NC} The restored config might need a terminal restart to take effect."
}

# Main script logic
main() {
    local backup_dir=""

    # Handle command line arguments
    if [[ $# -eq 0 ]]; then
        backup_dir=$(select_backup)
    elif [[ $# -eq 1 ]]; then
        if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
            show_usage
            exit 0
        fi
        backup_dir="$1"
    else
        echo -e "${RED}❌ Too many arguments${NC}"
        show_usage
        exit 1
    fi

    restore_files "$backup_dir"
}

# Run main function with all arguments
main "$@"