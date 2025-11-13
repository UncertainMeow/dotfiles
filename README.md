# Modern Dotfiles for Infrastructure & Development

A practical, modular terminal configuration optimized for homelab management and development work. No buzzwords, just tools that work.

## Quick Start

### Personal Computer
```bash
git clone https://github.com/UncertainMeow/dotfiles.git
cd dotfiles
./install.sh
```

### Work Computer (No Hammerspoon)
```bash
git clone https://github.com/UncertainMeow/dotfiles.git
cd dotfiles
./install-work.sh  # Work-safe mode, no special permissions required
```

The installer backs up your existing configs and sets everything up. Compatible with macOS, Arch Linux, NixOS, and Bazzite.

**See [WORK-COMPUTER-SECURITY.md](WORK-COMPUTER-SECURITY.md) for security best practices.**

## What You Get

### Terminal Emulator Support
- **Ghostty** - Primary terminal with optimized SSH compatibility
- **Alacritty** - High-performance backup terminal
- **Consistent theming** - Catppuccin Mocha across both terminals

### Shell Environment
- **zsh with zinit** - Modern shell with intelligent plugin management
- **tmux integration** - Session persistence with server-friendly keybindings
- **Modern tool replacements** - eza, fzf, vivid, powerlevel10k

### Development Environment Launcher
Hit **⌘+Shift+D** for instant access to:
- 🐍 Python containers
- 🟢 Node.js environments
- 🦀 Rust development
- 🧪 Clean testing environments
- 🖥️ Virtual machines (UTM)
- 🧹 System management

## Architecture

This setup uses a **modular copy-based approach** (no symlinks). Configuration is split into logical modules that load in sequence:

```
~/.zshrc                    # Main config - loads everything else
~/dotfiles-config/zsh/      # Modular configurations:
├── environment.zsh         #   PATH, exports, tool integrations
├── aliases.zsh             #   Command shortcuts
├── functions.zsh           #   Custom shell functions
├── history.zsh             #   History behavior
├── completion.zsh          #   Tab completion settings
└── os/macos.zsh           #   OS-specific optimizations
```

**Key design principles:**
- **Stable**: Live config won't break when experimenting with the repo
- **Modular**: Each file handles one concern
- **Ordered**: Components load in dependency order
- **Safe**: Installer always backs up existing configs

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed implementation guide.

## SSH & Remote Work Optimizations

- **Terminal compatibility** - Automatic TERM variable handling for problematic SSH servers
- **tmux persistence** - Sessions survive disconnections with proper naming
- **Infrastructure aliases** - Common server management shortcuts
- **Cross-platform** - Same config works on local macOS and remote Linux servers

## Environment Launcher Setup

The hotkey system requires these dependencies:

```bash
brew install fzf docker yq
```

Add to your `~/.hammerspoon/init.lua`:

```lua
-- Environment Launcher hotkey (⌘+Shift+D)
dofile(os.getenv("HOME") .. "/dotfiles/environment-launcher/hammerspoon-setup.lua")
```

## Customization

### Quick Changes
Edit configs directly in `~/dotfiles-config/zsh/` - changes apply to new terminals immediately.

### Permanent Changes
1. Edit files in the repo
2. Run `./install.sh` to deploy (backs up current config first)

### Local-Only Customizations
Create `~/.zshrc.local` for machine-specific settings that won't be tracked in git.

### Adding New Modules
Create new `.zsh` files in `config/zsh/` and add source lines to the main `.zshrc`.

## Included Tools & Functions

**Cheat Sheets & Discovery:**
- `funcs` - List all custom functions (with search!)
- `funcs <keyword>` - Search functions
- `alias-help` - Complete aliases cheat sheet
- `alias-search <keyword>` - Search aliases

**Shell Functions:**
- `mkcd <dir>` - Create and enter directory
- `up [n]` - Navigate up n directories
- `extract <file>` - Universal archive extractor
- `zoxpath <query>` or `zp <query>` - Get zoxide path without changing directory (copies to clipboard!)
- Git shortcuts and file operations

**Scripts Library Integration:**
- `scripts` - List all your scripts in `~/scripts`
- `scripts <name>` - Run a specific script
- `run-script` - Interactive fzf menu for scripts
- `edit-script <name>` - Edit or create a script

**Modern Replacements:**
- `eza` instead of `ls` (icons, git integration)
- `fzf` for fuzzy finding (Ctrl-R history search)
- `vivid` for modern LS_COLORS
- `zoxide` for smart directory jumping

## File Structure

```
dotfiles/
├── install.sh                      # Main installer
├── .zshrc                          # Shell configuration entry point
├── .tmux.conf                      # Terminal multiplexer config
├── ghostty_config                  # Primary terminal settings
├── alacritty_config.toml           # Backup terminal settings
├── alacritty_theme_catppuccin-mocha.toml # Terminal theme
├── config/zsh/                     # Modular shell configurations
│   ├── environment.zsh             # PATH and exports
│   ├── aliases.zsh                 # Command shortcuts
│   ├── functions.zsh               # Useful shell functions
│   ├── history.zsh                 # History configuration
│   ├── completion.zsh              # Tab completion
│   └── os/                         # OS-specific configs
└── environment-launcher/           # Development environment hotkeys
```

## Troubleshooting

**Changes not applying?** Open a new terminal - configs only load on shell startup.

**Broke something?** Restore from `~/dotfiles_backup/TIMESTAMP/` or reinstall.

**SSH issues?** The setup includes automatic TERM fixes for compatibility with remote servers.

**Ghostty theme errors?** Run `./scripts/validate-ghostty-themes.sh` to check and auto-fix theme issues.

**Zsh parse errors?** Run `./scripts/validate-zsh-config.sh` to check for common configuration problems.

## Maintenance Scripts

The `scripts/` directory includes helpful validation tools:

- `validate-ghostty-themes.sh` - Checks if Ghostty themes exist and downloads missing ones
- `validate-zsh-config.sh` - Detects alias/function conflicts and syntax errors
- `backup-config.sh` - Manual backup of live configurations
- `restore-config.sh` - Restore from backups
- `sync-configs.sh` - Sync live changes back to repo

---

Built for practical daily use in homelab and development environments.

*Full disclosure: About 90% of this was architected by Claude Code because I was tired of my terminal breaking every time I touched a config file. Turns out AI is pretty good at making things that actually work. Who knew?* 🤖

Contributions welcome - but honestly, it's probably easier to just ask Claude to add whatever you need.