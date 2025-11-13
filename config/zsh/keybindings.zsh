#!/usr/bin/env zsh

# Custom Keybindings and Smart Tab Completion

# =============================================================================
# SMART TAB COMPLETION WITH AUTOSUGGESTIONS
# =============================================================================
#
# Behavior:
# - If grey autosuggestion is visible: Tab accepts it
# - If no suggestion: Tab shows completion menu
# - Ctrl+Space: Force completion menu even with suggestions
#
# This makes Tab work intuitively with zsh-autosuggestions!

# Track if we just accepted a suggestion (for double-tap behavior)
typeset -g _TAB_JUST_ACCEPTED=0

# Custom Tab completion widget
_smart_tab_complete() {
    # Check if there's an autosuggestion visible
    # $POSTDISPLAY contains the grey suggestion text
    if [[ -n "$POSTDISPLAY" ]]; then
        # There's a suggestion - accept it
        zle autosuggest-accept
        _TAB_JUST_ACCEPTED=1

        # Optional: If you want double-tap to show menu, uncomment below
        # This would require pressing Tab again immediately to show completions
        # For now, keeping it simple - Tab accepts, that's it
    else
        # No suggestion visible - do normal tab completion
        _TAB_JUST_ACCEPTED=0
        zle expand-or-complete
    fi
}

# Register the custom widget
zle -N _smart_tab_complete

# Bind Tab to our smart completion
bindkey '^I' _smart_tab_complete

# Alternative keybinding: Ctrl+Space forces completion menu
# (useful if you want completions even when suggestion is visible)
bindkey '^ ' expand-or-complete

# =============================================================================
# PARTIAL WORD ACCEPTANCE (Optional - using Ctrl+Right or Ctrl+F)
# =============================================================================
#
# Accept one word at a time from the suggestion
# Default: Ctrl+F or Ctrl+Right Arrow

# This is already provided by zsh-autosuggestions by default
# Keeping these for reference:
# bindkey '^F' forward-word                    # Ctrl+F accepts one word
# bindkey '^[[1;5C' forward-word               # Ctrl+Right Arrow

# =============================================================================
# OTHER USEFUL KEYBINDINGS
# =============================================================================

# Ctrl+U: Clear line (standard behavior, ensuring it's set)
bindkey '^U' kill-whole-line

# Ctrl+K: Kill to end of line
bindkey '^K' kill-line

# Ctrl+A: Beginning of line
bindkey '^A' beginning-of-line

# Ctrl+E: End of line
bindkey '^E' end-of-line

# Ctrl+W: Delete word backwards
bindkey '^W' backward-kill-word

# Alt+Left/Right: Move by words (macOS Terminal)
bindkey '^[[1;3D' backward-word              # Alt+Left
bindkey '^[[1;3C' forward-word               # Alt+Right

# =============================================================================
# HISTORY SEARCH KEYBINDINGS
# =============================================================================

# Up/Down arrows: Search history based on what's typed
bindkey '^[[A' history-beginning-search-backward    # Up arrow
bindkey '^[[B' history-beginning-search-forward     # Down arrow

# Ctrl+R: FZF history search (if fzf is available)
if command -v fzf >/dev/null 2>&1; then
    # This is usually set up by fzf installation
    # Just ensuring it's bound
    bindkey '^R' fzf-history-widget 2>/dev/null || bindkey '^R' history-incremental-search-backward
fi

# =============================================================================
# CONFIGURATION NOTES
# =============================================================================
#
# If Tab behavior doesn't work as expected:
# 1. Make sure zsh-autosuggestions is loaded BEFORE this file
# 2. Check your .zshrc loads modules in correct order
# 3. Try: source ~/.zshrc to reload
#
# To customize:
# - Change '^I' binding to use a different key
# - Modify _smart_tab_complete function logic
# - Add more custom keybindings below
#
# To disable smart Tab (revert to default):
# - Comment out: bindkey '^I' _smart_tab_complete
# - Uncomment: bindkey '^I' expand-or-complete
