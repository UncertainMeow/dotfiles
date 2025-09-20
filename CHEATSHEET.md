# Quick Reference Cheat Sheet

*Because nobody remembers all their aliases and keybindings* 📝

## Essential Commands

### Navigation
- `mkcd <dir>` - Create directory and cd into it (because who has time for two commands?)
- `up [n]` - Go up n directories (default: 1)
- `z <fuzzy-name>` - Smart cd with zoxide (learns your habits)

### Git Shortcuts
*Check `config/zsh/aliases.zsh` for the full list - there are probably more than you think*

### tmux Essentials
- `Ctrl-a` - Prefix key (because Ctrl-b is for peasants)
- `Ctrl-a + c` - New window
- `Ctrl-a + |` - Split vertically
- `Ctrl-a + -` - Split horizontally
- `Ctrl-a + C` - Show tmux cheatsheet

### Modern Tool Replacements
- `ll` - Better `ls` with eza (has icons and git status)
- `la` - List all files including hidden
- `tree` - Directory tree view
- `Ctrl-r` - Fuzzy history search with fzf

## Terminal Switching

### Ghostty (Primary)
- Should just work™ with the catppuccin theme
- SSH compatibility built-in
- If it breaks, try Alacritty

### Alacritty (Backup)
- Launch with: `alacritty`
- Same config, same theme, less fancy features
- More stable if Ghostty acts up

## Troubleshooting

### "Something broke"
1. Try a new terminal window first
2. Check `~/dotfiles_backup/TIMESTAMP/` for your old configs
3. Nuclear option: `cd dotfiles && ./install.sh`

### "My aliases disappeared"
- Check if you're in the right shell: `echo $SHELL`
- Source manually: `source ~/.zshrc`
- Check if modules loaded: `ls ~/dotfiles-config/zsh/`

### "SSH is weird"
The setup auto-fixes TERM variables, but if you're still having issues:
```bash
export TERM=xterm-256color
```

## Configuration Locations

*After install, your actual config files live here:*

```
~/.zshrc                    # Main entry point
~/dotfiles-config/zsh/      # The modular configs
~/.config/ghostty/config    # Ghostty settings
~/.config/alacritty/        # Alacritty settings
```

## Environment Launcher (⌘+Shift+D)

Hit the hotkey and type:
- `python` - Python dev container
- `node` - Node.js environment
- `rust` - Rust development
- `clean` - Fresh testing environment

*Pro tip: If you break something in a container, just nuke it and spawn a new one*

---

*This cheat sheet exists because even the person who "built" this forgets half the features. Thanks Claude!* 🤖