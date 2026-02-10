# The Idiot's Guide to Your Own Dotfiles

*Written by someone who definitely needed an idiot's guide to his own setup*

## Overview: How This All Works

Your dotfiles follow a **modular approach** where configuration is split into logical pieces that get loaded together. Think of it like building blocks - each piece has a specific job, and they all combine to create your complete shell environment.

## The Key Files and What They Do

### 1. `.zshrc` - The Orchestra Conductor
**Location:** `~/.zshrc` (copied from the repo)
**Job:** This is the "main" file that loads everything else

```bash
# This is the key part - it finds and loads all the modules
if [[ -d "$ZSH_CONFIG_DIR" ]]; then
  # Core configuration modules
  [[ -f "$ZSH_CONFIG_DIR/environment.zsh" ]] && source "$ZSH_CONFIG_DIR/environment.zsh"
  [[ -f "$ZSH_CONFIG_DIR/history.zsh" ]] && source "$ZSH_CONFIG_DIR/history.zsh"
  # ... and so on
fi
```

**How it works:** When you open a new terminal, zsh runs this file first. It determines where your config modules are located (`~/.config/dotfiles/zsh/` or in the repo), then systematically loads each module.

### 2. Config Modules - The Individual Musicians
**Location:** `~/.config/dotfiles/zsh/` (copied from `config/zsh/` in the repo)

Each module handles one aspect of your shell:

- **`environment.zsh`** - Sets PATH, exports variables, tool integrations
- **`aliases.zsh`** - Command shortcuts (`ll`, `la`, etc.)
- **`functions.zsh`** - Custom shell functions (`mkcd`, `up`, etc.)
- **`history.zsh`** - How command history behaves
- **`completion.zsh`** - Tab completion settings
- **`os/macos.zsh`** - macOS-specific tweaks

### 3. Terminal Configurations - The Stage
**Ghostty:** `~/.config/ghostty/config` + `~/.config/ghostty/themes/catppuccin-mocha`
**Alacritty:** `~/.config/alacritty/alacritty.toml` + `~/.config/alacritty/themes/catppuccin-mocha.toml`

These configure how your terminal looks and behaves (colors, fonts, padding, etc.)

## How The Magic Happens: No Symlinks!

**Important:** This setup **COPIES** files, it doesn't symlink them. Here's why:

```bash
# install.sh does this:
cp .zshrc ~ && echo "✓ zsh configuration"
cp -r config ~/dotfiles-config && echo "✓ modular zsh configurations"
```

**What this means:**
- Files are **copied** from the repo to your home directory
- Changes to the repo don't automatically affect your live config
- You have a stable, working setup that won't break if you experiment with the repo

## The Loading Chain: Step by Step

When you open a terminal, here's what happens:

1. **zsh starts** → reads `~/.zshrc`
2. **`.zshrc` looks for modules** → finds `~/.config/dotfiles/zsh/`
3. **Loads core modules in order:**
   - `environment.zsh` → Sets up PATH, variables, tool integrations
   - `history.zsh` → Configures command history
   - `completion.zsh` → Sets up tab completion
   - `aliases.zsh` → Creates command shortcuts
   - `functions.zsh` → Loads custom functions
4. **Loads OS-specific config** → `os/macos.zsh` (on macOS)
5. **Loads plugins** → zinit installs/loads zsh plugins
6. **Final customizations** → `~/.zshrc.local` if it exists

## Directory Structure Breakdown

```
Your actual file locations after install:

HOME/
├── .zshrc                           # Main config (from repo)
├── .tmux.conf                       # tmux config (from repo)
├── .config/
│   ├── ghostty/
│   │   ├── config                   # Ghostty settings (from repo)
│   │   └── themes/catppuccin-mocha  # Theme file (downloaded)
│   └── alacritty/
│       ├── alacritty.toml           # Alacritty settings (from repo)
│       └── themes/catppuccin-mocha.toml # Theme file (from repo)
└── .config/dotfiles/                 # Modular configs (from repo)
    └── zsh/
        ├── environment.zsh          # PATH, exports, tool setup
        ├── aliases.zsh              # Command shortcuts
        ├── functions.zsh            # Custom functions
        ├── history.zsh              # History settings
        ├── completion.zsh           # Tab completion
        └── os/macos.zsh            # macOS-specific settings

Repo structure (for reference):
dotfiles/
├── .zshrc                          # Gets copied to ~/
├── .tmux.conf                      # Gets copied to ~/
├── ghostty_config                  # Gets copied to ~/.config/ghostty/config
├── alacritty_config.toml           # Gets copied to ~/.config/alacritty/alacritty.toml
├── alacritty_theme_catppuccin-mocha.toml # Gets copied to ~/.config/alacritty/themes/
├── install.sh                      # The installer script
└── config/zsh/                     # Gets copied to ~/.config/dotfiles/zsh/
    ├── environment.zsh
    ├── aliases.zsh
    └── ...
```

## How to Make Changes

### Option 1: Edit Live Config (Quick Changes)
```bash
# Edit the actual config that's being used
nano ~/.config/dotfiles/zsh/aliases.zsh
# Changes take effect in new terminals immediately
```

### Option 2: Edit Repo and Reinstall (Permanent Changes)
```bash
cd ~/path/to/dotfiles/repo
nano config/zsh/aliases.zsh
./install.sh  # This will backup your current config and install the new one
```

### Option 3: Local-Only Customizations
```bash
# Create this file for changes you don't want in the repo
nano ~/.zshrc.local
# This gets loaded last and overrides everything else
```

## The SSH/Terminal Compatibility Fix

**The Problem:** Some SSH servers expect TERM to be set to standard values like "xterm-256color", but terminal emulators sometimes set custom values.

**The Solution:**
- Ghostty config: `term = xterm-256color`
- Environment config: Fallback check that sets TERM if it's missing or non-standard
- Both terminals now work with SSH out of the box

## Plugin Management with Zinit

**Where:** Handled in the main `.zshrc` file
**What it does:** Automatically installs and loads zsh plugins like:
- `zsh-autosuggestions` - Shows command suggestions as you type
- `zsh-syntax-highlighting` - Colors commands as you type them
- `powerlevel10k` - The fancy prompt theme

**How it works:** Zinit auto-installs on first run and keeps plugins updated.

## Troubleshooting

### "My changes aren't showing up"
- Did you open a new terminal? Changes only apply to new sessions
- Are you editing the right file? Check `~/.config/dotfiles/zsh/` not the repo

### "I broke something"
- Restore from backup: `~/.local/state/dotfiles-backups/YYYYMMDD_HHMMSS/`
- Or reinstall: `cd dotfiles && ./install.sh`

### "I want to reset everything"
```bash
cd dotfiles
./install.sh  # This backs up your current config and reinstalls fresh
```

## Key Concepts to Remember

1. **No symlinks** - Files are copied, not linked
2. **Modular** - Each file has one job
3. **Ordered loading** - Environment → History → Completion → Aliases → Functions → OS-specific
4. **Stable** - Your live config won't break if you experiment with the repo
5. **Backups** - `install.sh` always backs up your existing config first

This setup gives you a professional, maintainable shell environment that's easy to understand and modify.