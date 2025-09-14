#!/usr/bin/env zsh

# macOS Container/VM Support
# For running macOS in containers (macOS on macOS) or VMs

# Detect if we're running macOS in a container or VM environment
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Check if we're in a container environment
    if [[ -f /.dockerenv ]] || [[ -n "$container" ]]; then
        export MACOS_CONTAINER=true
    # Check if we're in a VM (common VM indicators)
    elif system_profiler SPHardwareDataType | grep -q "Virtual\|VMware\|Parallels\|VirtualBox"; then
        export MACOS_VM=true
    else
        # Regular macOS, load standard macOS config
        [[ -f "$HOME/.config/zsh/os/macos.zsh" ]] && source "$HOME/.config/zsh/os/macos.zsh"
        return 0
    fi
else
    return 0  # Not macOS, skip
fi

echo "🍎 macOS Container/VM Environment Detected"

# Container/VM optimized aliases
alias ls='ls -G'  # Force color output (might be disabled in containers)
alias ll='ls -la'
alias la='ls -A'

# Package management - lightweight options for containers
if command -v brew &> /dev/null; then
    # Homebrew available - use minimal installs
    alias pkg-install='brew install'
    alias pkg-search='brew search'  
    alias pkg-info='brew info'
    alias pkg-minimal='brew install curl git vim tmux zsh'
else
    # No Homebrew - provide installation guidance
    alias install-brew='echo "Install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""'
fi

# Clipboard integration (if available in container)
if command -v pbcopy &> /dev/null && command -v pbpaste &> /dev/null; then
    alias copy='pbcopy'
    alias paste='pbpaste'
else
    # Fallback for containers without full macOS clipboard
    alias copy='tee /tmp/clipboard'
    alias paste='cat /tmp/clipboard 2>/dev/null || echo "No clipboard content"'
fi

# Container-specific optimizations
if [[ "$MACOS_CONTAINER" == "true" ]]; then
    echo "   Running in container - optimized for minimal footprint"
    
    # Disable spotlight indexing (not useful in containers)
    alias disable-spotlight='sudo mdutil -a -i off 2>/dev/null || true'
    
    # Container-friendly defaults
    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_NO_INSTALL_CLEANUP=1
    
    # Minimal PS1 for containers
    export PS1='📦 %n@container:%~ %# '
    
elif [[ "$MACOS_VM" == "true" ]]; then
    echo "   Running in VM - optimized for virtualization"
    
    # VM-specific optimizations
    alias vm-tools-status='echo "VM Tools status varies by hypervisor (VMware/Parallels/VirtualBox)"'
    
    # Detect VM type
    vm_type=$(system_profiler SPHardwareDataType | grep -i "virtual\|vmware\|parallels" | head -1)
    if [[ -n "$vm_type" ]]; then
        echo "   VM Type: $vm_type"
    fi
fi

# Development environment optimizations for containers/VMs
setup_macos_container_dev() {
    echo "Setting up minimal macOS development environment..."
    
    # Essential development tools
    local essential_tools=(
        "git"
        "vim" 
        "tmux"
        "curl"
        "wget"
    )
    
    # Install only if missing
    for tool in "${essential_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            if command -v brew &> /dev/null; then
                brew install "$tool"
            else
                echo "⚠️  $tool not found and Homebrew not available"
            fi
        fi
    done
}

# Container networking helpers
if [[ "$MACOS_CONTAINER" == "true" ]]; then
    # Container might have limited networking
    alias network-test='ping -c 3 8.8.8.8'
    alias dns-test='nslookup google.com'
    
    # Check if we can reach host system
    alias host-check='ping -c 1 host.docker.internal 2>/dev/null || ping -c 1 192.168.65.254 2>/dev/null || echo "Cannot reach host system"'
fi

# Performance optimizations for VMs
if [[ "$MACOS_VM" == "true" ]]; then
    # Reduce visual effects for better VM performance
    alias performance-mode='defaults write com.apple.dock expose-animation-duration -float 0.1; killall Dock'
    alias restore-animations='defaults delete com.apple.dock expose-animation-duration; killall Dock'
fi

# Xcode Command Line Tools check (essential for development)
check_xcode_tools() {
    if ! xcode-select -p &> /dev/null; then
        echo "⚠️  Xcode Command Line Tools not installed"
        echo "Install with: xcode-select --install"
        return 1
    else
        echo "✅ Xcode Command Line Tools installed"
        return 0
    fi
}

# Auto-setup function
macos_container_setup() {
    echo "🔧 Configuring macOS container/VM environment..."
    
    check_xcode_tools
    setup_macos_container_dev
    
    if [[ "$MACOS_CONTAINER" == "true" ]]; then
        disable-spotlight
    elif [[ "$MACOS_VM" == "true" ]]; then
        echo "💡 Tip: Run 'performance-mode' to optimize for VM environment"
    fi
    
    echo "✅ macOS container/VM setup complete"
}

# Useful functions for container development
docker_macos_tips() {
    cat << 'EOF'
🐳 macOS in Docker Tips:
- Use Docker Desktop for Mac for best compatibility
- Mount volumes for persistence: -v ~/code:/workspace
- Forward ports: -p 8080:8080 for web development
- Use host networking if needed: --network host
- Access host: host.docker.internal from container

Example: docker run -it -v ~/code:/workspace macos-container
EOF
}

# Show environment info
echo "Environment: $(uname -a)"
if [[ "$MACOS_CONTAINER" == "true" ]]; then
    echo "💡 Run 'macos_container_setup' for development environment"
    echo "💡 Run 'docker_macos_tips' for Docker-specific guidance"
fi