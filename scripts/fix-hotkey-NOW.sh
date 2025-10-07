#!/bin/bash
# FIX THE DAMN HOTKEY

set -e

echo "🔥 FIXING HOTKEY - FOR REAL THIS TIME"
echo ""

# Check Accessibility permissions
echo "Checking Keyboard Maestro permissions..."
ACCESSIBILITY_CHECK=$(sqlite3 "/Library/Application Support/com.apple.TCC/TCC.db" "SELECT service FROM access WHERE client='com.stairways.keyboardmaestro.engine' AND service='kTCCServiceAccessibility';" 2>/dev/null || echo "")

if [[ -z "$ACCESSIBILITY_CHECK" ]]; then
    echo "❌ Keyboard Maestro does NOT have Accessibility permissions"
    echo ""
    echo "FIX THIS NOW:"
    echo "1. Open System Settings"
    echo "2. Privacy & Security → Accessibility"
    echo "3. Make sure 'Keyboard Maestro Engine' is CHECKED"
    echo ""
    read -p "Press Enter after you've enabled it..."
fi

# Restart Keyboard Maestro Engine
echo "Restarting Keyboard Maestro Engine..."
killall "Keyboard Maestro Engine" 2>/dev/null || true
sleep 2
open -a "Keyboard Maestro Engine"
sleep 2

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TEST THESE HOTKEYS (one will work):"
echo ""
echo "1. Press ⌘⇧D"
echo "2. Press ⌃⌥F (Control+Option+F)"
echo ""
echo "If NEITHER works, I'm giving you a backup:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Add shell alias as backup
if ! grep -q "alias dev=" ~/.zshrc 2>/dev/null; then
    echo "Adding 'dev' command to your shell..."
    echo "" >> ~/.zshrc
    echo "# Dev environment launcher" >> ~/.zshrc
    echo "alias dev='~/.local/bin/dev-launcher'" >> ~/.zshrc
    echo "✅ Added 'dev' command"
    echo ""
    echo "BACKUP OPTION: Just type 'dev' in terminal"
    echo "(Open new terminal or run: source ~/.zshrc)"
fi

echo ""
echo "Which method do you want to try?"
echo "  1. Fix Keyboard Maestro (keep trying)"
echo "  2. Use Alfred instead (you have it installed)"
echo "  3. Use Hammerspoon (simple, works)"
echo "  4. Just use 'dev' command (no hotkey)"
echo ""
read -p "Choice (1-4): " choice

case "$choice" in
    2)
        echo ""
        echo "ALFRED SETUP:"
        echo "1. Open Alfred Preferences"
        echo "2. Workflows → + → Import Workflow"
        echo "3. Select: ~/dotfiles/environment-launcher/alfred-dev-launcher.alfredworkflow"
        echo "4. Test: Type 'dev' in Alfred"
        ;;
    3)
        echo ""
        echo "Installing Hammerspoon..."
        brew install --cask hammerspoon 2>/dev/null || echo "Hammerspoon already installed"
        mkdir -p ~/.hammerspoon
        cat > ~/.hammerspoon/init.lua << 'EOF'
-- Dev Launcher Hotkey
hs.hotkey.bind({"cmd", "shift"}, "d", function()
    hs.osascript.applescript([[
        tell application "Terminal"
            activate
            do script "~/.local/bin/dev-launcher"
        end tell
    ]])
end)

hs.notify.new({title="Hammerspoon", informativeText="Dev launcher ready: ⌘⇧D"}):send()
EOF
        open -a Hammerspoon
        echo "✅ Hammerspoon configured"
        echo "Grant Accessibility permissions when prompted"
        echo "Then press ⌘⇧D"
        ;;
    4)
        source ~/.zshrc 2>/dev/null || true
        echo ""
        echo "✅ Just type 'dev' in any terminal"
        echo ""
        exec $SHELL
        ;;
    *)
        echo ""
        echo "Open Keyboard Maestro and make sure:"
        echo "1. The macro is ENABLED (checkbox)"
        echo "2. The macro group is ENABLED"
        echo "3. Try the test hotkey: ⌃⌥F"
        ;;
esac
