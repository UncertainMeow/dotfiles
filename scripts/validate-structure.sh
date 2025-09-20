#!/bin/bash
# Validate dotfiles structure and configuration integrity

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

error() {
    echo -e "${RED}❌ ERROR: $1${NC}" >&2
    ((ERRORS++))
}

warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}" >&2
    ((WARNINGS++))
}

info() {
    echo -e "${BLUE}ℹ️  INFO: $1${NC}"
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

echo -e "${BLUE}🔍 Validating dotfiles structure...${NC}"
echo

# Check for required files
required_files=(
    ".zshrc"
    "install.sh"
    "README.md"
    "config/zsh/environment.zsh"
    "config/zsh/aliases.zsh"
    "config/zsh/functions.zsh"
    "config/zsh/history.zsh"
    "config/zsh/completion.zsh"
)

echo "📁 Checking required files..."
for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        success "Found: $file"
    else
        error "Missing required file: $file"
    fi
done
echo

# Check install.sh is executable
echo "🔧 Checking script permissions..."
if [[ -f "install.sh" ]]; then
    if [[ -x "install.sh" ]]; then
        success "install.sh is executable"
    else
        error "install.sh is not executable (run: chmod +x install.sh)"
    fi
fi

# Check for backup scripts
if [[ -f "scripts/backup-config.sh" ]]; then
    if [[ -x "scripts/backup-config.sh" ]]; then
        success "backup-config.sh is executable"
    else
        warning "backup-config.sh is not executable"
    fi
fi

if [[ -f "scripts/restore-config.sh" ]]; then
    if [[ -x "scripts/restore-config.sh" ]]; then
        success "restore-config.sh is executable"
    else
        warning "restore-config.sh is not executable"
    fi
fi
echo

# Validate zsh module loading in .zshrc
echo "🐚 Checking zsh configuration..."
if [[ -f ".zshrc" ]]; then
    # Check if .zshrc sources the modular configs
    if grep -q "ZSH_CONFIG_DIR" ".zshrc"; then
        success ".zshrc includes modular config loading"
    else
        error ".zshrc missing modular config loading logic"
    fi

    # Check for key modules being sourced
    modules=("environment.zsh" "aliases.zsh" "functions.zsh" "history.zsh" "completion.zsh")
    for module in "${modules[@]}"; do
        if grep -q "$module" ".zshrc"; then
            success ".zshrc sources $module"
        else
            warning ".zshrc doesn't explicitly source $module"
        fi
    done
fi
echo

# Check terminal configurations
echo "🖥️  Checking terminal configurations..."

# Ghostty
if [[ -f "ghostty_config" ]]; then
    success "Found ghostty_config"

    # Check for SSH compatibility
    if grep -q "term = xterm-256color" "ghostty_config"; then
        success "Ghostty has SSH terminal compatibility"
    else
        warning "Ghostty missing SSH terminal compatibility (add: term = xterm-256color)"
    fi

    # Check for theme
    if grep -q "theme = " "ghostty_config"; then
        success "Ghostty has theme configured"
    else
        warning "Ghostty missing theme configuration"
    fi
else
    warning "Missing ghostty_config"
fi

# Alacritty
if [[ -f "alacritty_config.toml" ]]; then
    success "Found alacritty_config.toml"

    # Check TOML syntax
    if command -v toml-sort >/dev/null 2>&1; then
        if toml-sort --check "alacritty_config.toml" >/dev/null 2>&1; then
            success "Alacritty config has valid TOML syntax"
        else
            error "Alacritty config has invalid TOML syntax"
        fi
    fi
else
    warning "Missing alacritty_config.toml"
fi
echo

# Check environment-launcher if present
echo "🚀 Checking environment launcher..."
if [[ -d "environment-launcher" ]]; then
    success "Found environment-launcher directory"

    if [[ -f "environment-launcher/dev-launcher" ]]; then
        if [[ -x "environment-launcher/dev-launcher" ]]; then
            success "dev-launcher is executable"
        else
            warning "dev-launcher is not executable"
        fi
    else
        warning "Missing dev-launcher script"
    fi

    if [[ -f "environment-launcher/containers.yaml" ]]; then
        success "Found containers.yaml"
    else
        warning "Missing containers.yaml"
    fi
else
    info "Environment launcher not present (optional)"
fi
echo

# Check for common issues
echo "🔍 Checking for common issues..."

# Check for hardcoded paths
if grep -r -l "/Users/[^/]*/\|/home/[^/]*/" config/ 2>/dev/null; then
    warning "Found potential hardcoded home paths in config files"
fi

# Check for backup directory references
if grep -r -l "dotfiles_backup" . --exclude-dir=.git 2>/dev/null | grep -v scripts/ | grep -v README.md | grep -v ARCHITECTURE.md; then
    info "Found backup directory references (this is usually fine)"
fi

# Summary
echo
echo -e "${BLUE}📊 Validation Summary${NC}"
echo "===================="

if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}🎉 All checks passed! Configuration looks good.${NC}"
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "${YELLOW}⚠️  $WARNINGS warnings found, but no errors.${NC}"
    echo "Configuration should work, but consider addressing warnings."
    exit 0
else
    echo -e "${RED}❌ $ERRORS errors and $WARNINGS warnings found.${NC}"
    echo "Please fix errors before committing."
    exit 1
fi