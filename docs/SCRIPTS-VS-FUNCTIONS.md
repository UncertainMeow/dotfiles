# Scripts vs Functions - Integration Guide

## Quick Answer

**Functions** = Loaded into your shell, instant execution
**Scripts** = Standalone files, slight overhead but more portable

## When to Use Each

### Use Shell Functions When:
- ✅ You need instant execution (no disk read)
- ✅ You need access to shell variables and environment
- ✅ It's a quick, frequently-used operation
- ✅ It's specific to your interactive shell workflow

**Examples:**
```bash
mkcd() { mkdir -p "$1" && cd "$1"; }
up() { cd $(printf '../%.0s' $(seq 1 ${1:-1})); }
```

### Use Scripts When:
- ✅ Complex logic that would clutter your shell
- ✅ Needs to run from cron, other shells, or scripts
- ✅ Should be version-controlled separately
- ✅ Might be shared with others
- ✅ Requires specific permissions or setup

**Examples:**
```bash
#!/bin/bash
# backup-system.sh - Can be run independently
```

## How They're Now Integrated

### Your Dotfiles Functions (~/dotfiles-config/zsh/functions.zsh)
Quick operations loaded into every shell:
```bash
funcs              # List all functions
funcs git          # Search for git-related functions
alias-help       # Show all aliases
zoxpath dotfiles   # Get path to dotfiles (zoxide)
zp network         # Short form of zoxpath
```

### Your Scripts Library (~/scripts/)
Standalone tools accessible via functions:
```bash
scripts            # List all scripts
scripts backup     # Run backup script
run-script         # Interactive fzf menu
edit-script backup # Edit a script
```

## Integration Features

### 1. Functions Wrap Scripts
```bash
# In your shell, type:
scripts backup-system

# This runs: ~/scripts/backup-system.sh
# Functions provide the interface, scripts do the work
```

### 2. Automatic Discovery
Your scripts are automatically discovered if they:
- Live in `$SCRIPTS_DIR` (default: `~/scripts`)
- Are executable (`chmod +x script.sh`)
- Have a shebang (`#!/bin/bash`)

### 3. Self-Documenting
Add comments to your scripts:
```bash
#!/bin/bash
# Backup system configuration and important files

# This line will appear in `scripts` listing!
```

## Best Practices

### Organization
```
~/scripts/
├── backup-system.sh        # System-wide backups
├── deploy-service.sh       # Deployment automation
├── health-check.sh         # Infrastructure monitoring
└── utils/
    ├── git-helpers.sh      # Git utilities
    └── docker-cleanup.sh   # Docker maintenance
```

### Naming Conventions
- **Functions**: Short, memorable names (`mkcd`, `zp`, `glog`)
- **Scripts**: Descriptive, hyphenated names (`backup-system.sh`, `deploy-homelab.sh`)

### Documentation
```bash
# In functions.zsh
# Documented by the funcs() help system

# In scripts
#!/bin/bash
# Brief description here
#
# Usage: script-name [options]
# Options:
#   -h  Show help
#   -v  Verbose mode
```

## Migration Strategy

### Moving Function → Script
When a function gets too complex:

1. **Extract to script:**
```bash
# Create script
edit-script my-complex-task

# Add your logic
#!/bin/bash
# Description: Complex task automation
[... your code ...]
```

2. **Keep function as wrapper (optional):**
```bash
# In functions.zsh
my-complex-task() {
    ~/scripts/my-complex-task.sh "$@"
}
```

### Moving Script → Function
When a script is simple enough:

1. **Copy logic to functions.zsh**
2. **Remove script or keep for backwards compatibility**
3. **Update documentation**

## Real Examples from Your Setup

### Functions (Fast, Frequent)
```bash
# Directory jumping
mkcd project-name          # Make and enter directory
up 3                       # Go up 3 directories
zoxpath dotfiles           # Get dotfiles path

# Quick info
funcs docker               # Find docker functions
alias-help | grep git    # Search git aliases
```

### Scripts (Complex, Portable)
```bash
# From your dotfiles repo
./scripts/backup-config.sh    # Backup configurations
./scripts/sync-configs.sh     # Sync to repo
./scripts/validate-structure.sh  # Validate setup

# Your personal scripts
scripts deploy-homelab        # Deploy infrastructure
scripts health-check          # Monitor services
run-script                    # Interactive menu
```

## Advanced Integration

### Environment Variables
```bash
# In .zshrc.local
export SCRIPTS_DIR="$HOME/my-custom-scripts"
export DOTFILES_DIR="$HOME/dotfiles"
```

### Aliases for Common Scripts
```bash
# In aliases.zsh
alias backup='scripts backup-system'
alias deploy='scripts deploy-homelab'
alias healthcheck='scripts health-check'
```

### Functions That Call Scripts
```bash
# In functions.zsh
homelab() {
    case "$1" in
        deploy)   scripts deploy-homelab "${@:2}" ;;
        backup)   scripts backup-homelab "${@:2}" ;;
        status)   scripts homelab-status "${@:2}" ;;
        *)        echo "Usage: homelab {deploy|backup|status}" ;;
    esac
}
```

## Troubleshooting

### Script Not Found
```bash
# Check location
echo $SCRIPTS_DIR

# List scripts
ls -la ~/scripts/

# Make executable
chmod +x ~/scripts/my-script.sh
```

### Function Not Available
```bash
# Reload shell config
source ~/.zshrc

# Check if function exists
type function_name

# List all functions
print -l ${(ok)functions}
```

## Summary

| Aspect | Functions | Scripts |
|--------|-----------|---------|
| **Speed** | Instant | ~ms overhead |
| **Access** | Shell environment | Isolated |
| **Portability** | Shell-specific | Universal |
| **Complexity** | Simple | Any complexity |
| **Best For** | Interactive workflow | Automation & sharing |

**Your Setup:** Functions provide the interactive shell experience, scripts handle complex automation. They work together seamlessly!

---

**Quick Commands to Remember:**
- `funcs` - List functions
- `alias-help` - List aliases
- `scripts` - List scripts
- `run-script` - Interactive script menu
- `zoxpath <query>` - Get zoxide path
