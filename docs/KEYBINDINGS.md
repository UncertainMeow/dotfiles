# Keybindings Guide

## Smart Tab Completion 🎯

**The Problem:** When you see grey autocomplete text (from history), you instinctively press Tab, but it shows a dropdown instead of accepting the suggestion.

**The Solution:** Tab now intelligently accepts grey suggestions!

### How It Works

```bash
# Scenario 1: Grey suggestion visible
$ cd network-services-st[grey: ack]
# Press Tab → Accepts the grey text
$ cd network-services-stack

# Scenario 2: No suggestion visible
$ cd netw[no grey text]
# Press Tab → Shows completion dropdown as normal
```

### Key Behaviors

| Key | With Grey Suggestion | Without Suggestion |
|-----|---------------------|-------------------|
| **Tab** | ✅ Accepts suggestion | Shows completion menu |
| **Ctrl+Space** | Shows completion menu | Shows completion menu |
| **Right Arrow** | Accepts suggestion | Moves cursor right |
| **Ctrl+F** | Accepts one word | Accepts one word |

### Additional Keybindings

#### Navigation
- `Ctrl+A` - Beginning of line
- `Ctrl+E` - End of line
- `Alt+Left` - Previous word
- `Alt+Right` - Next word

#### Editing
- `Ctrl+U` - Clear entire line
- `Ctrl+K` - Kill to end of line
- `Ctrl+W` - Delete word backwards

#### History
- `Up/Down arrows` - Search history based on current input
- `Ctrl+R` - FZF fuzzy history search

### Tips

**Accept partial suggestions:**
```bash
$ cd network-services-stack/ansible/playbooks
          ^^^^^^^^^^^^^^^ Press Ctrl+F to accept one word at a time
```

**Force completion menu:**
If you want completions even when there's a grey suggestion, use `Ctrl+Space` instead of Tab.

**Why This Is Better:**
- More intuitive - Tab does what you expect
- Faster workflow - fewer keystrokes
- Muscle memory from other apps works!

### Customization

Edit `~/dotfiles-config/zsh/keybindings.zsh` to customize:

```zsh
# Change Tab key behavior
bindkey '^I' _smart_tab_complete    # Current: Smart Tab

# Use different key for smart completion
bindkey '^N' _smart_tab_complete    # Ctrl+N for smart complete
bindkey '^I' expand-or-complete     # Tab for normal complete
```

### Troubleshooting

**Tab not working as expected?**
1. Reload: `source ~/.zshrc`
2. Check autosuggestions is installed: `zinit list | grep autosuggestions`
3. Verify keybindings loaded: `bindkey | grep _smart_tab`

**Want old behavior back?**
Comment out in `.zshrc`:
```zsh
# [[ -f "$ZSH_CONFIG_DIR/keybindings.zsh" ]] && source "$ZSH_CONFIG_DIR/keybindings.zsh"
```

---

**Quick Test:**
```bash
# Type a command you've used before
$ cd netw
# You should see grey completion
# Press Tab - it should accept it!
```

Enjoy your newfound Tab efficiency! 🚀
