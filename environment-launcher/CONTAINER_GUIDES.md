# 🚀 Environment Launcher Container Guides

*Idiot-proof instructions for each container environment*

## 🎯 Learning & Exploration

### ❄️ NixOS Learning Environment
**Goal:** Learn Nix package management and NixOS concepts

**First Steps:**
```bash
# Check what's available
nix --version
nix-env --version

# Search for packages
nix search nixpkgs firefox
nix search nixpkgs python

# Install a package temporarily
nix-shell -p firefox python3

# Learn Nix language basics
nix repl
```

**What to Learn:**
- Package management with `nix-env`
- Temporary environments with `nix-shell`
- Writing simple Nix expressions
- Understanding derivations and the Nix store

**Resources:**
- https://nixos.org/learn.html
- https://nix.dev/tutorials/

---

### 🏛️ Omakub (37signals Opinionated Arch)
**Goal:** Experience Arch Linux and 37signals' development philosophy

**First Steps:**
```bash
# Update package database
pacman -Syu

# Install common tools
pacman -S vim git curl wget htop

# Explore the AUR (Arch User Repository)
pacman -S yay
yay -S visual-studio-code-bin
```

**What to Learn:**
- Arch package management with `pacman`
- AUR (Arch User Repository) usage
- Rolling release model
- Minimal system philosophy

---

### 🎮 Bazzite Gaming Environment
**Goal:** Explore Fedora-based gaming setup

**First Steps:**
```bash
# Update system
dnf update

# Install gaming tools
dnf install steam lutris

# Check system info
neofetch
```

## 🏠 Homelab & Infrastructure

### ☸️ K3s Kubernetes Lab
**Goal:** Learn Kubernetes on a lightweight distribution

**First Steps:**
```bash
# Check if K3s is running
kubectl get nodes

# Create your first pod
kubectl run test-pod --image=nginx
kubectl get pods

# Expose the pod as a service
kubectl expose pod test-pod --port=80 --type=NodePort
kubectl get services

# Clean up
kubectl delete pod test-pod
kubectl delete service test-pod
```

**Learning Path:**
1. Understand pods, services, deployments
2. Learn kubectl commands
3. Explore namespaces
4. Try persistent volumes

---

### 🐋 Docker Swarm Manager
**Goal:** Learn Docker orchestration

**First Steps:**
```bash
# Initialize swarm
docker swarm init

# Create a simple service
docker service create --name web --publish 8080:80 nginx
docker service ls

# Scale the service
docker service scale web=3
docker service ps web

# Clean up
docker service rm web
```

**What to Learn:**
- Service management
- Scaling applications
- Load balancing
- Rolling updates

---

### 🗄️ MicroCeph Storage Lab
**Goal:** Understand distributed storage

**First Steps:**
```bash
# Install MicroCeph via snap
snap install microceph

# Initialize cluster (single node for learning)
microceph cluster bootstrap

# Check cluster status
microceph status

# Create a storage pool
microceph disk add /dev/loop0 --wipe
```

**Learning Goals:**
- Understand Ceph concepts (OSDs, MONs, etc.)
- Learn about distributed storage
- Explore object storage vs block storage

## 🛠️ Practical Learning

### 🏠 Homelab Toolkit
**Goal:** Manage infrastructure with common tools

**Pre-installed Tools:**
- `ansible` - Configuration management
- `htop` - Process monitoring
- `ncdu` - Disk usage analyzer
- `tree` - Directory structure viewer
- `jq` - JSON processor
- `yq` - YAML processor

**First Steps:**
```bash
# Check your SSH connectivity
ssh-keygen -t ed25519 -f ~/.ssh/test_key
ssh-copy-id -i ~/.ssh/test_key user@your-server

# Create a simple Ansible inventory
cat > inventory.yml << 'EOF'
all:
  hosts:
    local:
      ansible_host: localhost
      ansible_connection: local
EOF

# Run a simple Ansible command
ansible all -i inventory.yml -m ping

# Monitor processes
htop

# Analyze disk usage
ncdu /workspace
```

---

### 🌐 Network Analysis Lab
**Goal:** Troubleshoot network issues

**Available Tools:**
- `nmap` - Network scanning
- `tcpdump` - Packet capture
- `dig` - DNS lookup
- `curl` - HTTP client
- `netstat` - Network connections
- `ss` - Socket statistics

**Common Tasks:**
```bash
# Scan your local network
nmap -sn 192.168.1.0/24

# Check DNS resolution
dig google.com
nslookup cloudflare.com

# Test HTTP connectivity
curl -I https://github.com

# Monitor network traffic
tcpdump -i eth0

# Check open ports
ss -tulnp
netstat -tulnp
```

---

### 📊 Monitoring & Observability
**Goal:** Learn monitoring with Grafana

**First Steps:**
```bash
# Grafana should auto-start
# Access at http://localhost:3000
# Login: admin/admin

# Check Grafana process
ps aux | grep grafana

# View logs
tail -f /var/log/grafana/grafana.log
```

**Learning Path:**
1. Explore default dashboards
2. Create custom dashboards
3. Set up data sources
4. Configure alerts

## 💡 Quick Reference

### Universal Commands (work in most containers)
```bash
# Check what's installed
which docker kubectl ansible python3 node

# See running processes
ps aux

# Check disk space
df -h

# Monitor resources
top
htop

# Network info
ip addr show
ip route show

# Exit container
exit
# or Ctrl+D
```

### Getting Help
```bash
# Most tools have help
command --help
man command

# Package managers
pacman -S package    # Arch
dnf install package  # Fedora
apt install package  # Ubuntu/Debian
```

### File Locations
- `/workspace` - Your mounted project directory
- `/home/` - User home directories
- `/etc/` - System configuration files
- `/var/log/` - Log files

---

*Remember: These are disposable containers! Experiment freely - if you break something, just exit and start fresh.*