#!/bin/bash
# Fix Keyboard Maestro - Clean setup

echo "🔧 Keyboard Maestro Cleanup Script"
echo ""
echo "This will:"
echo "  1. Close Keyboard Maestro"
echo "  2. Import a clean, working macro"
echo "  3. Reopen Keyboard Maestro"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Step 1: Closing Keyboard Maestro..."
osascript -e 'quit app "Keyboard Maestro"' 2>/dev/null || true
osascript -e 'quit app "Keyboard Maestro Engine"' 2>/dev/null || true
sleep 1

echo "Step 2: Opening macro file for import..."
open ~/dotfiles/environment-launcher/DevLauncher-Simple.kmmacros

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Keyboard Maestro should now open"
echo ""
echo "IMPORTANT: In Keyboard Maestro:"
echo ""
echo "1. It should ask to import - Click 'Import'"
echo "2. Delete your old broken macros:"
echo "   - Click 'Dev Environment Launcher' → Delete"
echo "   - Click 'Docker Cleanup' → Delete"
echo "   (Delete any duplicates)"
echo ""
echo "3. Your NEW macro 'Dev Launcher' should work:"
echo "   - Select it in the list"
echo "   - Click 'Try' button at bottom"
echo "   - Terminal should open with menu"
echo ""
echo "4. Test the hotkey: Press ⌘⇧D"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
