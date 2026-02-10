#!/bin/bash
# Validate zsh configuration for common issues

set -e

echo "🔍 Validating zsh configuration..."

ZSH_CONFIG_DIR="$HOME/.config/dotfiles/zsh"
ERRORS=0

# Check for alias/function name conflicts
echo "  Checking for alias/function name conflicts..."

ALIASES_FILE="$ZSH_CONFIG_DIR/aliases.zsh"
FUNCTIONS_FILE="$ZSH_CONFIG_DIR/functions.zsh"

if [[ -f "$ALIASES_FILE" ]] && [[ -f "$FUNCTIONS_FILE" ]]; then
    # Extract alias names
    ALIAS_NAMES=$(grep -E '^alias [a-zA-Z0-9_-]+=' "$ALIASES_FILE" 2>/dev/null | sed 's/alias //' | cut -d'=' -f1 | sort)

    # Extract function names
    FUNCTION_NAMES=$(grep -E '^[a-zA-Z0-9_-]+\(\)' "$FUNCTIONS_FILE" 2>/dev/null | sed 's/()//' | sort)

    # Find conflicts
    CONFLICTS=$(comm -12 <(echo "$ALIAS_NAMES") <(echo "$FUNCTION_NAMES"))

    if [[ -n "$CONFLICTS" ]]; then
        echo "  ❌ Found alias/function name conflicts:"
        echo "$CONFLICTS" | while read -r name; do
            echo "    - $name (defined as both alias and function)"
        done
        ERRORS=$((ERRORS + 1))
    else
        echo "  ✅ No alias/function conflicts found"
    fi
else
    echo "  ⚠️  Config files not found, skipping conflict check"
fi

# Test zsh syntax
echo "  Testing zsh syntax..."

for config_file in "$ZSH_CONFIG_DIR"/*.zsh; do
    if [[ -f "$config_file" ]]; then
        filename=$(basename "$config_file")
        if zsh -n "$config_file" 2>/dev/null; then
            echo "  ✅ $filename: valid syntax"
        else
            echo "  ❌ $filename: syntax errors detected"
            zsh -n "$config_file" 2>&1 | sed 's/^/    /'
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

# Check for common mistakes
echo "  Checking for common configuration mistakes..."

# Check for $1, $2 in aliases (should be in functions)
PARAM_ALIASES=$(grep -n '\$[0-9]' "$ALIASES_FILE" 2>/dev/null || true)
if [[ -n "$PARAM_ALIASES" ]]; then
    echo "  ⚠️  Found parameter references in aliases (should be functions):"
    echo "$PARAM_ALIASES" | sed 's/^/    /'
    echo "    💡 Aliases can't use parameters. Use functions instead."
fi

if [[ $ERRORS -eq 0 ]]; then
    echo "✅ Zsh configuration is valid"
    exit 0
else
    echo "❌ Found $ERRORS error(s) in zsh configuration"
    exit 1
fi
