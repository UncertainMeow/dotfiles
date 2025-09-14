#!/usr/bin/env zsh

# Bazzite OS specific configuration  
# Gaming-focused Fedora Atomic desktop (Steam Deck-like experience)

# Detect if we're on Bazzite (check for atomic + gaming indicators)
if [[ -f /usr/lib/os-release ]] && grep -q "bazzite" /usr/lib/os-release 2>/dev/null; then
    export BAZZITE=true
elif [[ -f /etc/os-release ]] && grep -q -i "bazzite" /etc/os-release 2>/dev/null; then
    export BAZZITE=true  
elif command -v rpm-ostree &> /dev/null && command -v steam &> /dev/null; then
    # Likely an atomic desktop with gaming focus
    export BAZZITE_LIKE=true
else
    return 0  # Not Bazzite, skip this config
fi

# Atomic system management (rpm-ostree)
alias system-update='rpm-ostree upgrade && systemctl reboot'
alias system-rollback='rpm-ostree rollback && systemctl reboot'  
alias system-status='rpm-ostree status'
alias system-packages='rpm-ostree db list'

# Layered package management (sparingly used on atomic)
alias layer-install='rpm-ostree install'
alias layer-remove='rpm-ostree uninstall'

# Flatpak management (primary app installation method)
alias flat-install='flatpak install'
alias flat-remove='flatpak uninstall'
alias flat-update='flatpak update'
alias flat-search='flatpak search'
alias flat-list='flatpak list'
alias flat-run='flatpak run'

# Gaming-specific aliases
alias steam-native='steam-native'  # Native Steam (not Flatpak)
alias steam-flatpak='flatpak run com.valvesoftware.Steam'
alias lutris='flatpak run net.lutris.Lutris'
alias heroic='flatpak run com.heroicgameslauncher.hgl'  
alias bottles='flatpak run com.usebottles.bottles'

# GPU and performance
alias gpu-info='glxinfo | grep "OpenGL renderer"'
alias performance='gamemode'  # GameMode for better gaming performance
alias nvidia-info='nvidia-smi'  # If NVIDIA GPU present

# Development tools (prefer Flatpaks/toolboxes on atomic systems)
alias code='flatpak run com.visualstudio.code'
alias discord='flatpak run com.discordapp.Discord'
alias obs='flatpak run com.obsproject.Studio'

# Toolbox/container development (atomic systems approach)
alias create-dev='toolbox create dev'
alias enter-dev='toolbox enter dev'
alias list-toolboxes='toolbox list'

# Distrobox support (if available - better than toolbox for some uses)
if command -v distrobox &> /dev/null; then
    alias create-ubuntu='distrobox create --name ubuntu --image ubuntu:latest'
    alias create-arch='distrobox create --name arch --image archlinux:latest'  
    alias enter-ubuntu='distrobox enter ubuntu'
    alias enter-arch='distrobox enter arch'
fi

# System information  
alias system-info='rpm-ostree status && flatpak list --app'
alias gaming-info='steam --version && lutris --version 2>/dev/null || echo "Lutris not installed"'

# Bazzite-specific optimizations
export GAMEMODE=1  # Enable GameMode by default for compatible apps
export DXVK_HUD=1  # Enable DXVK overlay for Vulkan games (if desired)

# Gaming performance tweaks
setup_gaming_environment() {
    # CPU governor for performance
    echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null || true
    
    # Disable swap for gaming (if enough RAM)
    local ram_gb=$(free -g | awk '/^Mem:/{print $2}')
    if [[ $ram_gb -gt 16 ]]; then
        sudo swapoff -a 2>/dev/null || true
    fi
}

# Development in containers (atomic system best practice)
dev_environment() {
    local env_name=$1
    case $env_name in
        "web")
            toolbox create web-dev
            toolbox run --container web-dev bash -c "dnf install -y nodejs npm python3 git vim"
            ;;
        "python")
            toolbox create python-dev  
            toolbox run --container python-dev bash -c "dnf install -y python3 python3-pip git vim"
            ;;
        *)
            echo "Usage: dev_environment [web|python]"
            echo "Available environments: $(toolbox list)"
            ;;
    esac
}

# Bazzite welcome message
if [[ -t 0 && $- == *i* ]]; then
    echo "🎮 Bazzite detected - Gaming-optimized atomic desktop"
    echo "   Use 'flat-*' commands for apps, 'toolbox' for development"
    echo "   Gaming ready: Steam, Lutris, GameMode available"
fi

# Auto-setup gaming performance on login (optional - comment out if not desired)  
# setup_gaming_environment