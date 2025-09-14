#!/usr/bin/env zsh

# NixOS specific configuration
# The functional package manager OS

# Detect if we're on NixOS
if [[ -f /etc/nixos/configuration.nix ]] || command -v nixos-rebuild &> /dev/null; then
    export NIXOS=true
else
    return 0  # Not NixOS, skip this config
fi

# NixOS package management (different philosophy!)
alias nix-search='nix-env -qa | grep'
alias nix-install='nix-env -iA'
alias nix-remove='nix-env -e'
alias nix-list='nix-env -q'
alias nix-update='nix-channel --update && nix-env -u'

# System management (the NixOS way)
alias nixos-rebuild='sudo nixos-rebuild switch'
alias nixos-test='sudo nixos-rebuild test'
alias nixos-upgrade='sudo nixos-rebuild switch --upgrade'
alias nixos-rollback='sudo nixos-rebuild switch --rollback'
alias nixos-generations='sudo nix-env --list-generations --profile /nix/var/nix/profiles/system'

# Configuration management
alias nixos-config='sudo vim /etc/nixos/configuration.nix'
alias nixos-hardware='sudo vim /etc/nixos/hardware-configuration.nix'

# Nix store management
alias nix-collect-garbage='nix-collect-garbage -d'
alias nix-store-verify='nix-store --verify --check-contents'
alias nix-store-optimize='nix-store --optimise'

# Development environments (nix-shell magic!)
alias dev-python='nix-shell -p python3 python3Packages.pip'
alias dev-node='nix-shell -p nodejs npm'
alias dev-rust='nix-shell -p rustc cargo'
alias dev-go='nix-shell -p go'
alias dev-haskell='nix-shell -p ghc cabal-install'

# Temporary package installation (the Nix way)
alias try='nix-shell -p'  # Example: try firefox (runs without installing)

# Home Manager integration (if available)
if command -v home-manager &> /dev/null; then
    alias hm-switch='home-manager switch'
    alias hm-config='vim ~/.config/nixpkgs/home.nix'
fi

# Flakes support (modern Nix)
if command -v nix flake &> /dev/null 2>&1; then
    alias flake-update='nix flake update'
    alias flake-show='nix flake show'
fi

# NixOS specific environment
export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH

# Helpful functions
nixos-search() {
    # Search NixOS packages online
    local query="$1"
    echo "Searching for: $query"
    echo "Visit: https://search.nixos.org/packages?query=$query"
}

nixos-option() {
    # Look up NixOS options
    local option="$1"
    nixos-option $option 2>/dev/null || echo "Option not found: $option"
}

# NixOS banner
if [[ -t 0 && $- == *i* ]]; then
    echo "❄️  NixOS detected - Functional package management active"
    echo "   Try: 'try firefox' to run packages without installing"
fi