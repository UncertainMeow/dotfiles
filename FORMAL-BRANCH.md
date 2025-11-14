# Creating the Formal Branch

The Pokemon theme is amazing for fun, but you also want a "formal" version for professional contexts.

## The Formal Version Exists!

Commit `3e5d35e` contains the **complete formal version** with all the engineering excellence, BEFORE Pokemon naming was applied:

- ✅ Portable dotfiles system (`bootstrap-portable.sh`)
- ✅ Tailscale auto-provisioner (`provision.sh`)
- ✅ Cloud-init templates
- ✅ Docker compose examples
- ✅ Full documentation
- ✅ All the innovation and technique

## Create Formal Branch

When you want the formal version:

```bash
cd ~/dotfiles

# Create formal branch from pre-Pokemon commit
git branch formal 3e5d35e

# Switch to it
git checkout formal

# Push to remotes (optional)
git push origin formal
git push gitlab formal
```

## File Differences: Pokemon vs Formal

### Pokemon Branch (main)
```
scripts/tailscale/
├── pokeball.sh          # Was: provision.sh
├── mines-now.sh         # Symlink to pokeball
├── master-ball.sh       # Remote provisioning
├── choose-you.sh        # Cloud-init generator
└── go-dockahu.sh        # Docker compose generator
```

### Formal Branch (formal)
```
scripts/tailscale/
├── provision.sh         # Main provisioner
├── README.md            # Professional docs
├── cloud-init-example.yaml
└── docker-compose-example.yaml
```

## Which Branch to Use?

**Pokemon (main):**
- Homelab projects
- Personal servers
- Learning environments
- Showing friends
- When you want to have fun!

**Formal (formal branch):**
- Work projects
- Professional documentation
- Enterprise environments
- Demos to colleagues
- Serious business

## Both Are Fully Functional!

The Pokemon version is **identical** in functionality - just more fun names:
- `pokeball.sh` = `provision.sh`
- `master-ball.sh` = Enhanced remote wrapper (NEW!)
- `choose-you.sh` = Interactive cloud-init generator (NEW!)
- `go-dockahu.sh` = Interactive docker-compose generator (NEW!)

## Pro Tip: Use Both!

```bash
# For homelab (Pokemon!)
git checkout main
./scripts/tailscale/pokeball.sh my-server

# For work (Formal)
git checkout formal
./scripts/tailscale/provision.sh my-server
```

---

**Current Status:**
- ✅ Pokemon version: Fully documented, pushed to GitHub & GitLab
- ⏳ Formal branch: Ready to create from commit `3e5d35e`

Create it when you need it with: `git branch formal 3e5d35e`
