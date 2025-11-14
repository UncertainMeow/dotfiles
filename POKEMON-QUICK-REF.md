# ⚡ Pokemon Theme Quick Reference

Your dotfiles just got 10x more fun with Pokemon-themed provisioning tools!

## 📦 Portable Dotfiles - "dotlets"

**Problem:** SSH into a server, type `ll`, cry because it doesn't work.

**Solution:** Use **dotlets** to bootstrap your dotfiles!

### Installation (One-Time Setup)

Add `dotlets` to your PATH:

```bash
# Copy to your local bin
cp ~/dotfiles/scripts/dotlets ~/.local/bin/

# Or add alias to your .zshrc
alias dotlets='~/dotfiles/scripts/dotlets'
```

### Usage

```bash
# Bootstrap current machine
dotlets

# Bootstrap remote machine
dotlets user@server

# That's it! Now 'll' works everywhere!
```

**What it does:**
- Curls and runs `bootstrap-portable.sh`
- Installs minimal zsh config
- All your aliases (ll, gs, gst, etc.)
- All your functions (mkcd, extract, etc.)
- Updates with `dotpull` command

## ⚡ Tailscale Pokemon Provisioners

### 🔴 Pokeball - Local Capture

"I'm gonna catch this server!"

```bash
cd ~/dotfiles/scripts/tailscale
./pokeball.sh jeremy
```

**Alias version:**
```bash
./mines-now.sh jeremy  # Same thing, more attitude
```

### ⚫ Master Ball - Remote Capture

"Never fails!" - Capture remote servers via SSH:

```bash
./master-ball.sh user@192.168.1.100 jeremy
```

### ⚡ Choose-You - VM Generator

"I choose you!" - Create cloud-init configs:

```bash
./choose-you.sh
# Follow prompts, generates cloud-init YAML
```

### ⚡ Go-Dockahu - Docker Generator

"Go Pikachu!" - Create docker-compose with Tailscale:

```bash
./go-dockahu.sh
# Follow prompts, generates docker-compose.yaml
```

## Quick Aliases to Add

Add these to your `~/.zshrc` or `~/dotfiles-config/zsh/aliases.zsh`:

```bash
# Portable dotfiles
alias dotlets='~/dotfiles/scripts/dotlets'

# Tailscale Pokemon
alias pokeball='~/dotfiles/scripts/tailscale/pokeball.sh'
alias masterball='~/dotfiles/scripts/tailscale/master-ball.sh'
alias chooseyou='~/dotfiles/scripts/tailscale/choose-you.sh'
alias godockahu='~/dotfiles/scripts/tailscale/go-dockahu.sh'
alias minesnow='~/dotfiles/scripts/tailscale/mines-now.sh'

# Quick captures
alias catch='pokeball'
alias remote-catch='masterball'
```

## Common Workflows

### New Server (Physical/VM)
```bash
# 1. Bootstrap dotfiles
dotlets user@server

# 2. Capture with Pokeball
ssh user@server
pokeball my-server
```

### Remote Server (No Initial Access)
```bash
# One command - does it all
masterball user@server my-server
```

### New Proxmox VM
```bash
# 1. Generate cloud-init
chooseyou
# Follow prompts

# 2. Upload to Proxmox
scp cloud-init-*.yaml proxmox:/var/lib/vz/snippets/

# 3. VM auto-provisions on boot!
```

### Dockerized Service
```bash
# 1. Generate compose file
godockahu
# Follow prompts

# 2. Deploy
echo 'TAILSCALE_AUTHKEY=tskey-xxx' > .env
docker-compose -f docker-compose-*.yaml up -d

# 3. Access via Tailscale
curl http://my-service
```

## The Full Pokemon Evolution

```
Level 1: dotlets
  └─> Portable dotfiles everywhere

Level 2: pokeball
  └─> Capture local servers

Level 3: masterball
  └─> Capture remote servers

Level 4: chooseyou
  └─> Auto-provision VMs

Level 5: godockahu
  └─> Containerize everything

Level 6: ???
  └─> Full infrastructure as code!
```

## Tips & Tricks

### 1. Set TAILSCALE_AUTHKEY Once

```bash
# In your ~/.zshrc.local or .env
export TAILSCALE_AUTHKEY="tskey-auth-xxxxxxxxxxxxx"

# Now all Pokemon commands work without --authkey
```

### 2. Quick Remote Bootstrap & Capture

```bash
# Bootstrap + capture in one go
masterball user@server my-server
# It will prompt for dotfiles if needed
```

### 3. Template Your Cloud-Init

```bash
# Generate once, reuse many times
chooseyou  # Creates template

# Edit for each VM
cp cloud-init-template.yaml cloud-init-web-01.yaml
cp cloud-init-template.yaml cloud-init-web-02.yaml
# Edit hostnames, deploy!
```

### 4. Docker Compose Stack

```bash
# Generate multiple services
godockahu  # web
godockahu  # db
godockahu  # cache

# Deploy as stack
docker stack deploy -c docker-compose-web.yaml app
```

## Cheat Sheet

| Want to... | Use... | Command |
|-----------|--------|---------|
| Fix `ll` on remote server | dotlets | `dotlets user@server` |
| Capture current server | pokeball | `./pokeball.sh jeremy` |
| Capture remote server | master-ball | `./master-ball.sh user@host jeremy` |
| Create auto-provisioning VM | choose-you | `./choose-you.sh` |
| Dockerize with Tailscale | go-dockahu | `./go-dockahu.sh` |

---

**"Gotta provision 'em all!"** ⚡

See full docs: [scripts/tailscale/README.md](scripts/tailscale/README.md)
