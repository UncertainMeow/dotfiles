# Dotfiles

Modern terminal configuration for homelab infrastructure management and development work.

## What's Included

### **Terminal Configuration**
- **tmux** - Session management with persistent naming and Catppuccin theme
- **zsh** - Modern shell with plugin management and intelligent completions
- **Modular config** - Organized by function (aliases, functions, environment, etc.)

### **Development Tools**
- **Environment Launcher** - Hammerspoon hotkey (⌘+Shift+D) for instant dev containers/VMs
- **Cross-platform support** - macOS, Arch, NixOS, Bazzite-specific optimizations
- **Modern replacements** - eza instead of ls, better defaults

### **Key Features**
- **Modular design** - Easy to customize and maintain
- **Safety first** - Interactive mode for destructive commands
- **Infrastructure focus** - Optimized for server management workflows
- **Plugin management** - Automatic zinit setup and plugin loading

## Quick Install

```bash
git clone https://github.com/UncertainMeow/dotfiles.git
cd dotfiles
./install.sh
```

## Environment Launcher

Hit **⌘+Shift+D** to get instant access to:
- 🐍 Python development containers
- 🟢 Node.js environments 
- 🦀 Rust development setup
- 🧪 Clean testing environments
- 🖥️ Virtual machines (UTM integration)
- 🧹 System management tools

### Setup Environment Launcher
1. Install dependencies: `brew install fzf docker yq`
2. Make sure Docker Desktop is running
3. Add to your `~/.hammerspoon/init.lua`:

```lua
-- Environment Launcher hotkey (⌘+Shift+D)
dofile(os.getenv("HOME") .. "/dotfiles/environment-launcher/hammerspoon-setup.lua")
```

## Configuration Structure

```
dotfiles/
├── .tmux.conf              # tmux configuration
├── .zshrc                  # Main zsh config (loads modules)
├── install.sh              # Installation script
├── config/
│   └── zsh/
│       ├── aliases.zsh     # Command aliases
│       ├── functions.zsh   # Useful shell functions
│       ├── environment.zsh # PATH and environment variables
│       ├── history.zsh     # History configuration
│       ├── completion.zsh  # Completion settings
│       └── os/             # OS-specific configurations
└── environment-launcher/   # Development environment hotkey system
```

## Customization

### Adding Personal Aliases
Edit `config/zsh/aliases.zsh` or create `~/.zshrc.local` for local-only customizations.

### OS-Specific Configuration
The system automatically loads the appropriate config from `config/zsh/os/` based on your operating system.

### Environment Variables
Add your PATH modifications and exports to `config/zsh/environment.zsh`.

## Useful Functions

- `mkcd <dir>` - Create directory and cd into it
- `up [n]` - Go up n directories (default: 1)
- Various git shortcuts and file operations

## Modern Tool Integration

- **eza** - Modern ls replacement with icons and git integration
- **fzf** - Fuzzy finding for command history and files
- **vivid** - Modern LS_COLORS with Catppuccin theme
- **powerlevel10k** - Fast, customizable prompt

---

No buzzwords, just practical terminal configuration that works.