#!/bin/bash
# Validate and fix Ghostty theme configuration

set -e

GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
GHOSTTY_THEMES_DIR="$HOME/.config/ghostty/themes"

echo "🔍 Validating Ghostty theme configuration..."

# Check if config file exists
if [[ ! -f "$GHOSTTY_CONFIG" ]]; then
    echo "❌ Ghostty config file not found at: $GHOSTTY_CONFIG"
    exit 1
fi

# Extract theme name from config
THEME_NAME=$(grep '^theme = ' "$GHOSTTY_CONFIG" | sed 's/theme = //' | tr -d '"' | xargs)

if [[ -z "$THEME_NAME" ]]; then
    echo "✅ No theme specified in config (using default colors)"
    exit 0
fi

echo "  Found theme: $THEME_NAME"

# Check if themes directory exists
if [[ ! -d "$GHOSTTY_THEMES_DIR" ]]; then
    echo "  📁 Creating themes directory..."
    mkdir -p "$GHOSTTY_THEMES_DIR"
fi

# Check if theme file exists
THEME_FILE="$GHOSTTY_THEMES_DIR/$THEME_NAME"

if [[ ! -f "$THEME_FILE" ]]; then
    echo "  ⚠️  Theme file not found: $THEME_FILE"

    # Try to download catppuccin themes
    if [[ "$THEME_NAME" == catppuccin-* ]]; then
        echo "  📥 Downloading Catppuccin theme..."
        THEME_URL="https://raw.githubusercontent.com/catppuccin/ghostty/main/themes/${THEME_NAME}.conf"

        if curl -fsSL "$THEME_URL" -o "$THEME_FILE" 2>/dev/null; then
            echo "  ✅ Downloaded theme successfully"
        else
            echo "  ❌ Failed to download theme from: $THEME_URL"
            echo "  💡 Available themes at: https://github.com/catppuccin/ghostty/tree/main/themes"
            exit 1
        fi
    else
        echo "  ❌ Unknown theme: $THEME_NAME"
        echo "  💡 You need to manually install this theme or comment out the theme line in config"
        exit 1
    fi
else
    echo "  ✅ Theme file exists: $THEME_FILE"
fi

echo "✅ Ghostty theme configuration is valid"
