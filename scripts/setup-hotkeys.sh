#!/bin/bash
# Automatic Hotkey Setup - Detects and configures available automation tools
# Supports: Keyboard Maestro, Alfred, Hammerspoon

set -e

echo "🎹 Hotkey Setup for Environment Launcher"
echo ""

# Detect available tools
HAS_KM=false
HAS_ALFRED=false
HAS_HAMMERSPOON=false

# Check Keyboard Maestro
if [[ -d "/Applications/Keyboard Maestro.app" ]]; then
    HAS_KM=true
    echo "✅ Keyboard Maestro detected"
fi

# Check Alfred
if [[ -d "/Applications/Alfred 5.app" ]] || [[ -d "/Applications/Alfred 4.app" ]]; then
    HAS_ALFRED=true
    echo "✅ Alfred detected"
fi

# Check Hammerspoon
if [[ -d "/Applications/Hammerspoon.app" ]]; then
    HAS_HAMMERSPOON=true
    echo "✅ Hammerspoon detected"
fi

echo ""

# If none detected, offer installation
if ! $HAS_KM && ! $HAS_ALFRED && ! $HAS_HAMMERSPOON; then
    echo "⚠️  No automation tools detected"
    echo ""
    echo "Available options:"
    echo "  1. Install Hammerspoon (free, open source)"
    echo "  2. I'll install Keyboard Maestro/Alfred manually"
    echo ""
    read -p "Choose option (1-2): " choice

    if [[ "$choice" == "1" ]]; then
        if command -v brew >/dev/null 2>&1; then
            echo "📦 Installing Hammerspoon..."
            brew install --cask hammerspoon
            HAS_HAMMERSPOON=true
        else
            echo "❌ Homebrew not found. Please install from: https://brew.sh"
            exit 1
        fi
    else
        echo ""
        echo "Manual installation options:"
        echo "  Keyboard Maestro: https://www.keyboardmaestro.com"
        echo "  Alfred: https://www.alfredapp.com"
        echo "  Hammerspoon: https://www.hammerspoon.org"
        echo ""
        echo "Run this script again after installation."
        exit 0
    fi
fi

echo ""
echo "🔧 Which tool would you like to configure?"
echo ""

OPTIONS=()
[[ $HAS_KM == true ]] && OPTIONS+=("Keyboard Maestro (recommended)")
[[ $HAS_ALFRED == true ]] && OPTIONS+=("Alfred PowerPack")
[[ $HAS_HAMMERSPOON == true ]] && OPTIONS+=("Hammerspoon")

if [[ ${#OPTIONS[@]} -eq 1 ]]; then
    echo "Only ${OPTIONS[0]} is available."
    CHOICE="${OPTIONS[0]}"
else
    echo "Available tools:"
    for i in "${!OPTIONS[@]}"; do
        echo "  $((i+1)). ${OPTIONS[$i]}"
    done
    echo ""
    read -p "Choose (1-${#OPTIONS[@]}): " choice_num

    if [[ "$choice_num" =~ ^[0-9]+$ ]] && [[ "$choice_num" -ge 1 ]] && [[ "$choice_num" -le ${#OPTIONS[@]} ]]; then
        CHOICE="${OPTIONS[$((choice_num-1))]}"
    else
        echo "❌ Invalid choice"
        exit 1
    fi
fi

echo ""
echo "Setting up: $CHOICE"
echo ""

# Setup based on choice
if [[ "$CHOICE" == *"Keyboard Maestro"* ]]; then
    echo "📋 Keyboard Maestro Setup Instructions:"
    echo ""
    echo "1. Open Keyboard Maestro Editor"
    echo "2. Choose one of these options:"
    echo ""
    echo "   OPTION A: Import pre-built macros (if available)"
    if [[ -f "environment-launcher/keyboard-maestro-macros.kmmacros" ]]; then
        echo "      Double-click: environment-launcher/keyboard-maestro-macros.kmmacros"
    else
        echo "      (No exported macros found)"
    fi
    echo ""
    echo "   OPTION B: Create manually (5 minutes)"
    echo "      See detailed guide: environment-launcher/keyboard-maestro-setup.md"
    echo ""
    echo "Quick setup:"
    echo "  - Create macro 'Dev Launcher'"
    echo "  - Trigger: Hotkey ⌘⇧D"
    echo "  - Action: Execute Shell Script in Terminal"
    echo "    Script: ~/.local/bin/dev-launcher"
    echo ""

    if command -v open >/dev/null 2>&1; then
        read -p "Open setup guide now? (y/N) " open_guide
        if [[ "$open_guide" =~ ^[Yy]$ ]]; then
            open "environment-launcher/keyboard-maestro-setup.md"
        fi
    fi

elif [[ "$CHOICE" == *"Alfred"* ]]; then
    echo "🎩 Alfred Setup Instructions:"
    echo ""
    echo "1. Open Alfred Preferences → Workflows"
    echo "2. Choose one of these options:"
    echo ""
    echo "   OPTION A: Import workflow (if available)"
    if [[ -f "environment-launcher/alfred-workflows/dev-launcher.alfredworkflow" ]]; then
        echo "      Double-click: environment-launcher/alfred-workflows/dev-launcher.alfredworkflow"
    else
        echo "      (No exported workflows found)"
    fi
    echo ""
    echo "   OPTION B: Create manually (5 minutes)"
    echo "      See detailed guide: environment-launcher/alfred-setup.md"
    echo ""
    echo "Quick setup:"
    echo "  - Create workflow 'Dev Launcher'"
    echo "  - Add Hotkey Input: ⌘⇧D"
    echo "  - Add Run Script action:"
    echo "    osascript -e 'tell application \"Terminal\""
    echo "      do script \"~/.local/bin/dev-launcher\""
    echo "    end tell'"
    echo ""

    if command -v open >/dev/null 2>&1; then
        read -p "Open setup guide now? (y/N) " open_guide
        if [[ "$open_guide" =~ ^[Yy]$ ]]; then
            open "environment-launcher/alfred-setup.md"
        fi
    fi

elif [[ "$CHOICE" == *"Hammerspoon"* ]]; then
    echo "🔨 Setting up Hammerspoon..."
    echo ""

    mkdir -p ~/.hammerspoon

    # Detect which config to use
    CONFIG_FILE="environment-launcher/hammerspoon-work-safe.lua"
    if [[ ! -f "$CONFIG_FILE" ]]; then
        CONFIG_FILE="environment-launcher/hammerspoon-setup.lua"
    fi

    if [[ -f "$CONFIG_FILE" ]]; then
        if [[ -f ~/.hammerspoon/init.lua ]]; then
            echo "⚠️  Existing Hammerspoon config detected"
            echo ""
            read -p "Backup and replace with dev launcher config? (y/N) " replace

            if [[ "$replace" =~ ^[Yy]$ ]]; then
                backup_file=~/.hammerspoon/init.lua.backup.$(date +%Y%m%d_%H%M%S)
                cp ~/.hammerspoon/init.lua "$backup_file"
                echo "  ✓ Backed up to: $backup_file"

                cp "$CONFIG_FILE" ~/.hammerspoon/init.lua
                echo "  ✓ Installed dev launcher config"
            else
                echo ""
                echo "Manual setup:"
                echo "  Add this to your ~/.hammerspoon/init.lua:"
                echo ""
                echo "  dofile(os.getenv(\"HOME\") .. \"/$CONFIG_FILE\")"
                echo ""
            fi
        else
            cp "$CONFIG_FILE" ~/.hammerspoon/init.lua
            echo "  ✓ Installed Hammerspoon config"
        fi

        echo ""
        echo "✅ Hammerspoon configured"
        echo ""
        echo "Next steps:"
        echo "  1. Grant Accessibility permissions: System Settings → Privacy & Security → Accessibility"
        echo "  2. Open Hammerspoon.app (or reload config if already open)"
        echo "  3. Test with ⌘+Shift+D"
        echo ""

        # Offer to open Hammerspoon
        read -p "Open Hammerspoon now? (y/N) " open_app
        if [[ "$open_app" =~ ^[Yy]$ ]]; then
            open -a Hammerspoon
            echo ""
            echo "Don't forget to enable accessibility permissions!"
        fi
    else
        echo "❌ Config file not found: $CONFIG_FILE"
        exit 1
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Setup complete!"
echo ""
echo "Hotkey bindings:"
echo "  ⌘+Shift+D  → Open dev environment menu"
echo "  ⌘+Shift+C  → Docker cleanup (if configured)"
echo ""
echo "Test it out by pressing ⌘+Shift+D"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
