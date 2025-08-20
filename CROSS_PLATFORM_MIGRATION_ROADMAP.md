# Cross-Platform Dotfiles Migration Roadmap

**TACTICAL IMPLEMENTATION GUIDE FOR CLAUDE CODE**

This document provides paint-by-numbers instructions to migrate the current macOS-only dotfiles to a cross-platform setup supporting macOS, Debian, Arch, and CachyOS.

## Current State Analysis

### Repository Structure (as of commit 51f803d)
```
dotfiles/
├── .tmux.conf                    # ✅ Universal - works on all platforms
├── .zshrc                        # ⚠️ Needs OS conditionals for PATH/aliases  
├── .zprofile                     # ⚠️ Needs OS conditionals for PATH
├── .tmux-cheatsheet.txt          # ✅ Universal
├── ghostty_config                # ❌ macOS only - need Linux alternatives
├── ssh_config                    # ✅ Mostly universal
├── install.sh                    # ⚠️ Needs OS detection & package management
├── README.md                     # ⚠️ Needs OS compatibility notes
└── scripts/                      # (empty after debug script removal)
```

### Key Issues to Solve
1. **Package managers**: `brew` (macOS) vs `apt` (Debian) vs `pacman` (Arch/CachyOS)
2. **PATH differences**: `/opt/homebrew/bin` vs `/usr/local/bin`
3. **Terminal emulators**: Ghostty (macOS) vs Alacritty/Kitty (Linux)
4. **Clipboard tools**: `pbcopy` (macOS) vs `xclip` (Linux)
5. **Shell integration features**: Different capabilities per OS

## Phase 1: Add OS Detection to install.sh

### TASK 1.1: Add OS Detection Functions

**File:** `install.sh`
**Action:** Add these functions at the top (after the shebang and initial comments):

```bash
# OS Detection and Package Management
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        DISTRO="macos"
        PACKAGE_MANAGER="brew"
    elif [[ -f "/etc/debian_version" ]]; then
        OS="linux"
        DISTRO="debian"
        PACKAGE_MANAGER="apt"
    elif [[ -f "/etc/arch-release" ]]; then
        OS="linux"
        DISTRO="arch"
        PACKAGE_MANAGER="pacman"
    elif command -v pacman >/dev/null 2>&1; then
        # CachyOS and other Arch derivatives
        OS="linux"
        DISTRO="cachy"
        PACKAGE_MANAGER="pacman"
    else
        OS="linux"
        DISTRO="unknown"
        PACKAGE_MANAGER="unknown"
    fi
    
    echo "🔍 Detected OS: $OS ($DISTRO)"
}

install_dependencies() {
    echo "📦 Installing system dependencies..."
    
    case $PACKAGE_MANAGER in
        "brew")
            # macOS dependencies
            command -v tmux >/dev/null || brew install tmux
            command -v git >/dev/null || brew install git
            ;;
        "apt")
            # Debian dependencies
            sudo apt update
            sudo apt install -y tmux git curl zsh
            ;;
        "pacman")
            # Arch/CachyOS dependencies
            sudo pacman -S --needed tmux git curl zsh
            ;;
        *)
            echo "⚠️ Unknown package manager. Please install tmux, git, curl, zsh manually."
            ;;
    esac
}
```

**Action:** Replace the current OS check section with:

```bash
# Detect OS and set up package management
detect_os
install_dependencies

# Warn about optimization for macOS but continue for other systems
if [[ "$OS" != "macos" ]]; then
    echo "⚠️ This configuration was originally optimized for macOS"
    echo "🐧 Running on $DISTRO - some features may need adjustment"
    read -p "Continue? (Y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        exit 1
    fi
fi
```

### TASK 1.2: Make File Operations OS-Aware

**File:** `install.sh`
**Action:** Replace the current "Copy configuration files" section:

```bash
# Copy configuration files based on OS
echo "⚙️ Installing configuration files..."
cp .tmux.conf ~ && echo "  ✅ tmux configuration"
cp .zshrc ~ && echo "  ✅ zsh configuration (with OS detection)"
cp .zprofile ~ && echo "  ✅ zsh profile (with OS-specific PATH)"
cp .tmux-cheatsheet.txt ~ && echo "  ✅ tmux cheatsheet"
cp ssh_config ~/.ssh/config && echo "  ✅ SSH configuration"

# Terminal emulator config (OS-specific)
if [[ "$OS" == "macos" ]]; then
    cp ghostty_config ~/.config/ghostty/config && echo "  ✅ Ghostty terminal configuration"
else
    echo "  ⏭️ Skipping Ghostty (macOS only) - consider Alacritty or Kitty for Linux"
fi
```

### TASK 1.3: Update Installation Message

**File:** `install.sh`
**Action:** Replace the final success message:

```bash
echo ""
echo "🎉 Dotfiles installed successfully on $DISTRO!"
echo ""
echo "📋 Next steps:"
if [[ "$OS" == "macos" ]]; then
    echo "  1. Start a new terminal session"
    echo "  2. Launch tmux and run 'Ctrl-a + I' to install tmux plugins"
    echo "  3. Use 'Ctrl-a + C' for the tmux cheatsheet"
    echo "  4. Restart Ghostty to apply terminal configuration"
else
    echo "  1. Start a new terminal session (or run 'exec zsh')"
    echo "  2. Launch tmux and run 'Ctrl-a + I' to install tmux plugins"
    echo "  3. Use 'Ctrl-a + C' for the tmux cheatsheet"
    echo "  4. Consider installing Alacritty or Kitty terminal emulator"
    echo "  5. Install clipboard manager: 'sudo $PACKAGE_MANAGER install xclip' (Linux)"
fi
```

## Phase 2: Move OS-Specific Configs to Subdirectories

### TASK 2.1: Create Directory Structure

**Commands to run:**
```bash
mkdir -p configs/macos
mkdir -p configs/linux
mkdir -p configs/shared
mkdir -p configs/debian
mkdir -p configs/arch
```

### TASK 2.2: Move and Create OS-Specific Files

**Actions:**
1. **Move Ghostty config:** `mv ghostty_config configs/macos/`
2. **Create Alacritty config for Linux:**

**File:** `configs/linux/alacritty.yml`
**Content:**
```yaml
# Alacritty Configuration for Linux Homelab Work
# Based on Ghostty config optimized for server monitoring

window:
  padding:
    x: 10
    y: 10
  decorations: full

font:
  normal:
    family: "JetBrains Mono Nerd Font"
    style: Medium
  size: 13.0

# Catppuccin Mocha theme
colors:
  primary:
    background: "#1e1e2e"
    foreground: "#cdd6f4"
  cursor:
    text: "#1e1e2e"
    cursor: "#f5e0dc"
  normal:
    black: "#45475a"
    red: "#f38ba8"
    green: "#a6e3a1"
    yellow: "#f9e2af"
    blue: "#89b4fa"
    magenta: "#f5c2e7"
    cyan: "#94e2d5"
    white: "#bac2de"
  bright:
    black: "#585b70"
    red: "#f38ba8"
    green: "#a6e3a1"
    yellow: "#f9e2af"
    blue: "#89b4fa"
    magenta: "#f5c2e7"
    cyan: "#94e2d5"
    white: "#a6adc8"

cursor:
  style:
    shape: Block
    blinking: Never

selection:
  save_to_clipboard: true

shell:
  program: /usr/bin/zsh
  args:
    - --login
```

**File:** `configs/linux/kitty.conf` (alternative)
**Content:**
```conf
# Kitty Configuration for Linux Homelab Work

# Font configuration
font_family JetBrains Mono Nerd Font Medium
font_size 13.0

# Theme - Catppuccin Mocha
include ~/.config/kitty/themes/Catppuccin-Mocha.conf

# Window settings
window_padding_width 10
remember_window_size yes
initial_window_width 1200
initial_window_height 800

# Cursor
cursor_shape block
cursor_blink_interval 0

# Performance
repaint_delay 10
input_delay 3
sync_to_monitor yes

# Shell integration
shell_integration enabled
allow_remote_control yes

# Clipboard
copy_on_select clipboard

# Bell
enable_audio_bell no
```

### TASK 2.3: Create Package-Manager-Specific Install Scripts

**File:** `configs/debian/packages.txt`
**Content:**
```
tmux
git
curl
zsh
alacritty
xclip
fzf
ripgrep
bat
exa
```

**File:** `configs/arch/packages.txt`
**Content:**
```
tmux
git
curl
zsh
alacritty
xclip
fzf
ripgrep
bat
exa
```

**File:** `configs/macos/packages.txt`
**Content:**
```
tmux
git
curl
fzf
ripgrep
bat
exa
```

## Phase 3: Add Conditionals to Shared Configs

### TASK 3.1: Update .zshrc with OS Conditionals

**File:** `.zshrc`
**Action:** Replace the PATH section (around line 4-8):

**Before:**
```bash
# Enhanced PATH with Homebrew
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
```

**After:**
```bash
# OS-specific PATH configuration
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - Homebrew paths
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    export PATH="/usr/local/bin:$PATH"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux - Standard paths
    export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
    
    # Add user local bin if it exists
    [[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
    
    # Add cargo/rust if installed
    [[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH"
fi
```

### TASK 3.2: Add OS-Specific Aliases

**File:** `.zshrc`
**Action:** Add after the existing alias section (around line 80):

```bash
# =============================================================================
# OS-SPECIFIC ALIASES & FUNCTIONS
# =============================================================================

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS specific aliases
    alias copy='pbcopy'
    alias paste='pbpaste'
    alias ls='ls -G'  # colorized ls
    alias finder='open -a Finder'
    
    # macOS specific functions
    function flushdns() { sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder; }
    
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux specific aliases
    alias copy='xclip -selection clipboard'
    alias paste='xclip -selection clipboard -o'
    alias ls='ls --color=auto'
    alias ll='ls -alF --color=auto'
    alias la='ls -A --color=auto'
    alias l='ls -CF --color=auto'
    
    # Package manager shortcuts
    if command -v apt >/dev/null 2>&1; then
        alias update='sudo apt update && sudo apt upgrade'
        alias search='apt search'
        alias install='sudo apt install'
    elif command -v pacman >/dev/null 2>&1; then
        alias update='sudo pacman -Syu'
        alias search='pacman -Ss'
        alias install='sudo pacman -S'
        
        # CachyOS/AUR helpers
        if command -v yay >/dev/null 2>&1; then
            alias aur-update='yay -Syu'
            alias aur-search='yay -Ss'
            alias aur-install='yay -S'
        fi
    fi
    
    # Linux specific functions
    function ports() { netstat -tuln; }
    function processes() { ps aux | grep -v grep | grep -i "$1"; }
fi

# Universal clipboard function that works everywhere
function clip() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        pbcopy
    elif command -v xclip >/dev/null 2>&1; then
        xclip -selection clipboard
    else
        echo "No clipboard tool available"
        return 1
    fi
}
```

### TASK 3.3: Update .zprofile with OS Detection

**File:** `.zprofile`
**Action:** Replace the PATH section:

**Before:**
```bash
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin"
```

**After:**
```bash
# OS-specific PATH setup (loaded before .zshrc)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS PATH
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux PATH
    export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
    
    # Add common Linux directories if they exist
    [[ -d "/snap/bin" ]] && export PATH="/snap/bin:$PATH"
    [[ -d "/usr/games" ]] && export PATH="/usr/games:$PATH"
fi
```

## Phase 4: Update Install Script for New Structure

### TASK 4.1: Modify install.sh for New Directory Structure

**File:** `install.sh`
**Action:** Replace the file copying section with:

```bash
# Copy configuration files based on OS and new structure
echo "⚙️ Installing configuration files..."

# Universal configs
cp .tmux.conf ~ && echo "  ✅ tmux configuration"
cp .zshrc ~ && echo "  ✅ zsh configuration (with OS conditionals)"
cp .zprofile ~ && echo "  ✅ zsh profile (with OS-specific PATH)"
cp .tmux-cheatsheet.txt ~ && echo "  ✅ tmux cheatsheet"
cp ssh_config ~/.ssh/config && echo "  ✅ SSH configuration"

# OS-specific terminal emulator configs
case $OS in
    "macos")
        if [[ -f "configs/macos/ghostty_config" ]]; then
            cp configs/macos/ghostty_config ~/.config/ghostty/config && echo "  ✅ Ghostty terminal configuration"
        fi
        ;;
    "linux")
        echo "  🐧 Linux terminal options:"
        if command -v alacritty >/dev/null 2>&1; then
            mkdir -p ~/.config/alacritty
            cp configs/linux/alacritty.yml ~/.config/alacritty/ && echo "    ✅ Alacritty configuration"
        else
            echo "    ⏭️ Alacritty not installed - config available in configs/linux/"
        fi
        
        if command -v kitty >/dev/null 2>&1; then
            mkdir -p ~/.config/kitty
            cp configs/linux/kitty.conf ~/.config/kitty/ && echo "    ✅ Kitty configuration"
        else
            echo "    ⏭️ Kitty not installed - config available in configs/linux/"
        fi
        ;;
esac

# Install OS-specific packages if requested
echo ""
read -p "📦 Install recommended packages for $DISTRO? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [[ -f "configs/$DISTRO/packages.txt" ]]; then
        echo "📦 Installing packages from configs/$DISTRO/packages.txt..."
        case $PACKAGE_MANAGER in
            "brew")
                while read -r package; do
                    [[ -n "$package" && ! "$package" =~ ^#.* ]] && brew install "$package"
                done < "configs/$DISTRO/packages.txt"
                ;;
            "apt")
                packages=$(grep -v '^#' "configs/$DISTRO/packages.txt" | tr '\n' ' ')
                sudo apt install -y $packages
                ;;
            "pacman")
                packages=$(grep -v '^#' "configs/$DISTRO/packages.txt" | tr '\n' ' ')
                sudo pacman -S --needed $packages
                ;;
        esac
    fi
fi
```

### TASK 4.2: Update README.md

**File:** `README.md`
**Action:** Replace the "Compatibility" section:

**Before:**
```markdown
## Compatibility

- **Primary**: macOS (tested and optimized)
- **Secondary**: Linux (should work with minimal adjustments)
- **Requirements**: Git, tmux, modern terminal emulator
```

**After:**
```markdown
## Compatibility

- **macOS**: Fully supported with Ghostty terminal emulator
- **Debian/Ubuntu**: Supported with Alacritty or Kitty terminal emulator  
- **Arch Linux/CachyOS**: Supported with Alacritty or Kitty terminal emulator
- **Other Linux**: Should work with minor adjustments

### Requirements by OS
- **All**: Git, tmux, zsh
- **macOS**: Homebrew, Ghostty (recommended)
- **Linux**: Package manager (apt/pacman), Alacritty or Kitty, xclip

### Tested Configurations
- macOS Ventura+ with Homebrew and Ghostty
- Debian 11+ with apt and Alacritty
- Arch Linux with pacman and Kitty
- CachyOS with yay and Alacritty
```

## Testing Checklist

After completing migration, test on each OS:

### macOS Testing
- [ ] `./install.sh` completes without errors
- [ ] Ghostty config applied correctly
- [ ] tmux window naming persists
- [ ] Shell completions work (no compdef errors)
- [ ] Homebrew paths in PATH
- [ ] `copy` alias uses pbcopy

### Debian Testing  
- [ ] `./install.sh` detects Debian correctly
- [ ] Alacritty config copied if Alacritty installed
- [ ] Linux-specific aliases work (`ls --color`, `copy` with xclip)
- [ ] Package installation works with apt
- [ ] tmux plugins install correctly

### Arch/CachyOS Testing
- [ ] `./install.sh` detects Arch correctly  
- [ ] Terminal emulator configs available
- [ ] Package installation works with pacman
- [ ] AUR helper aliases work if yay installed
- [ ] All universal configs (tmux, ssh) work

## Final Notes for Next Claude Instance

1. **Test each phase separately** - don't do all phases at once
2. **Backup current configs** before starting migration  
3. **Use git branches** for testing if preferred
4. **Check PATH variables** carefully - they're critical for functionality
5. **Terminal emulator configs** may need fine-tuning per user preference
6. **Package lists** in configs/*/packages.txt can be customized per user needs

The current repo state is a solid foundation - this migration preserves all working functionality while adding cross-platform support.