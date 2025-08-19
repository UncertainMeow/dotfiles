# Homelab Dotfiles

🏠 Production-ready terminal configuration for homelab infrastructure management and development work.

## What's Included

### Core Configuration
- **Tmux configuration** with Catppuccin theme and homelab-optimized keybindings
- **SSH configuration** for secure homelab host management  
- **Ghostty terminal** configuration with optimized settings
- **Tmux cheatsheet** for quick reference

### Key Features
- **Session persistence** - automatic save/restore of tmux sessions
- **Vim-style navigation** - consistent keybindings across all tools
- **Quick access shortcuts** - prefix-based commands for common tasks
- **Plugin management** - automatic TPM installation and plugin support
- **Infrastructure focus** - optimized for server management workflows

## Quick Installation

```bash
git clone https://github.com/UncertainMeow/dotfiles.git
cd dotfiles
./install.sh
```

The install script will:
- Back up your existing configurations with timestamps
- Install tmux plugin manager (TPM) automatically
- Set up all configuration files with proper permissions
- Provide clear next steps for completing the setup

## Manual Installation

If you prefer to install manually:

```bash
# Create directories
mkdir -p ~/.config/ghostty ~/.ssh ~/.tmux/plugins

# Install TPM (tmux plugin manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Copy configurations
cp .tmux.conf ~/ 
cp .tmux-cheatsheet.txt ~/
cp ssh_config ~/.ssh/config
cp ghostty_config ~/.config/ghostty/config

# Set permissions
chmod 644 ~/.ssh/config ~/.tmux.conf
```

## Post-Installation Setup

1. **Start tmux**: `tmux`
2. **Install plugins**: Press `Ctrl-a + I` to install tmux plugins
3. **View cheatsheet**: Press `Ctrl-a + C` for quick reference
4. **Test SSH config**: Verify your homelab hosts are accessible

## Key Bindings

All tmux commands use the **Ctrl-a** prefix:

### Essential Shortcuts
- `Ctrl-a + c` - New window in current directory
- `Ctrl-a + C` - Show cheatsheet popup
- `Ctrl-a + s` - Save session  
- `Ctrl-a + d` - Detach session safely

### Navigation  
- `Ctrl-a + h/j/k/l` - Navigate panes (vim-style)
- `Ctrl-a + H/J/K/L` - Resize panes
- `Ctrl-a + |` - Split horizontally
- `Ctrl-a + -` - Split vertically

### Session Management
- `Ctrl-a + S` - New session
- `Ctrl-a + K` - Kill session  
- Outside tmux: `tmux a` to reattach

## Configuration Files

| File | Purpose | Location |
|------|---------|----------|
| `.tmux.conf` | Tmux configuration with plugins | `~/` |
| `.tmux-cheatsheet.txt` | Quick reference guide | `~/` |
| `ssh_config` | SSH client configuration | `~/.ssh/config` |
| `ghostty_config` | Terminal emulator settings | `~/.config/ghostty/config` |

## Compatibility

- **Primary**: macOS (tested and optimized)
- **Secondary**: Linux (should work with minimal adjustments)
- **Requirements**: Git, tmux, modern terminal emulator

## Troubleshooting

**Tmux plugins not working?**
- Run `Ctrl-a + I` to install plugins
- Check `~/.tmux/plugins/tpm` exists

**SSH connections failing?**  
- Verify SSH config syntax: `ssh -F ~/.ssh/config -T <hostname>`
- Check host key fingerprints match your homelab

**Permission issues?**
- SSH config: `chmod 644 ~/.ssh/config`
- Tmux config: `chmod 644 ~/.tmux.conf`
