# Work Computer Setup Summary

## TL;DR

**Hammerspoon is a security risk for work computers.** Use the work-safe installer instead:

```bash
cd ~/dotfiles
./install-work.sh
```

Same functionality, just type `dev` instead of pressing ⌘+Shift+D.

---

## What You Asked About

### Hammerspoon Analysis

**What it does:**
- Listens for keyboard shortcuts system-wide
- Launches scripts when hotkeys are pressed
- Shows notifications

**What permissions it needs:**
- **Accessibility access** (can monitor ALL keyboard input and screen content)
- Can execute shell commands
- Runs continuously in background

**Security concerns:**
- Could log keystrokes (including passwords)
- Could capture sensitive data from screen
- If dotfiles repo is compromised, attacker gets this access
- Many companies prohibit automation tools with these permissions

**My honest assessment:** Hammerspoon is overkill for launching a shell script, and the Accessibility permissions are a legitimate security concern on a work computer.

### Parallels vs Hammerspoon

**They're not comparable.** They solve different problems:

| | Hammerspoon | Parallels |
|---|-------------|-----------|
| **What it does** | Hotkey automation | Virtual machine hypervisor |
| **Your use case** | Press ⌘+Shift+D to open menu | Run Windows for Excel |
| **Resource cost** | ~50MB RAM | 4-8GB RAM per VM |
| **Isolation level** | None (runs as you) | High (separate OS) |
| **Can replace each other?** | No | No |

**However**, you can use Parallels for isolated dev environments (it's already approved):

```bash
# These functions are now in your dotfiles
pvm-start "Ubuntu Dev"    # Start Linux VM
work-windows              # Launch Windows VM
pvm-ssh "Ubuntu Dev"      # SSH into VM
```

See `config/zsh/parallels-integration.zsh` for full Parallels CLI integration.

---

## What I Created for You

### 1. Work-Safe Installer: `install-work.sh`

**What's different from regular install:**
- ❌ No Hammerspoon installation
- ❌ No Accessibility permissions required
- ✅ All terminal configs, aliases, functions included
- ✅ Container/VM launcher included
- ✅ Creates `~/.zshrc.local` for work-specific settings

**Usage:**
```bash
cd ~/dotfiles
./install-work.sh
source ~/.zshrc

# Now you can:
dev              # Opens environment launcher menu
dev-clean        # Clean up Docker containers
```

### 2. Security Guide: `WORK-COMPUTER-SECURITY.md`

Comprehensive guide covering:
- What data could leak (shell history, git config, env vars)
- Container security best practices
- Files that should never be committed
- Audit checklist for work computers
- What to ask your IT/security team
- Red flags to watch for

**Key recommendations:**
- Use `~/.zshrc.local` for work-specific settings (not tracked in git)
- Prefix sensitive commands with space (won't save to history)
- Don't mount work directories into containers
- Set up separate git config for work directories

### 3. Parallels Integration: `config/zsh/parallels-integration.zsh`

Since Parallels is already approved, you can use it for isolation:

**Available commands:**
```bash
# VM Management
pvm                          # List all VMs
pvm-start "VM Name"          # Start a VM
pvm-stop "VM Name"           # Stop a VM
pvm-console "VM Name"        # Open VM console
pvm-ssh "VM Name"            # SSH into VM
pvm-exec "VM Name" <cmd>     # Run command in VM

# Snapshots
pvm-snapshot "VM Name"       # Create snapshot
pvm-snapshots "VM Name"      # List snapshots

# Work shortcuts (customize these)
work-windows                 # Launch Windows VM
work-ubuntu                  # Launch Ubuntu Dev VM

# Interactive selector (requires fzf)
pvm-select                   # Pick VM from menu
```

**Advantages over Docker containers:**
- Stronger isolation (separate kernel)
- Already approved by your company
- Can snapshot entire system state
- Better for Windows/GUI applications

### 4. Updated README

Now includes work-safe installation instructions at the top.

---

## Branch Strategy: My Recommendation

**Option A: No branching needed** (simplest)

Keep one branch (`main`), use different installers:
- Personal machine: `./install.sh`
- Work machine: `./install-work.sh`

**Pros:**
- Single codebase to maintain
- Changes automatically shared
- Clear which installer to use

**Cons:**
- Hammerspoon config still in repo (just not installed on work machine)

**Option B: Work-specific .zshrc.local** (what install-work.sh does)

All work-specific settings go in `~/.zshrc.local`:
```bash
# This file is NOT tracked in git
export WORK_MODE=true
export WORK_EMAIL="you@company.com"

# Work-specific aliases
alias work-vpn='...'
alias work-jump='ssh jumpbox.internal'
```

**Option C: Separate branch**

```bash
# Only if you want to customize dotfiles significantly for work
git checkout -b work
# Remove Hammerspoon files entirely
rm -rf environment-launcher/hammerspoon-setup.lua
git commit -m "Remove Hammerspoon for work branch"
```

**My recommendation:** Option A + Option B. Use `install-work.sh` and put machine-specific settings in `~/.zshrc.local`.

---

## Security Checklist for Your Work Laptop

### Before Using Dotfiles

- [ ] Run `install-work.sh` (not regular `install.sh`)
- [ ] Review `WORK-COMPUTER-SECURITY.md`
- [ ] Create `.zshrc.local` for work-specific settings
- [ ] Check if Docker Desktop is approved
- [ ] Verify terminal emulators are allowed

### Ongoing Practices

- [ ] Never commit credentials to dotfiles repo
- [ ] Don't mount sensitive work directories into containers
- [ ] Prefix sensitive commands with space (not saved to history)
- [ ] Review shell history monthly for leaked secrets
- [ ] Use separate git config for work repos

### What to Ask IT

1. "Is Docker Desktop approved for local development?"
2. "Are Ghostty/Alacritty approved terminal emulators?"
3. "Do we have policies about running local containers?"
4. "Should I use 1Password SSH agent or another solution?"

---

## Parallels + Dotfiles: Best of Both Worlds

Since you have Parallels (approved) and these dotfiles (work-safe):

**For isolation:**
- Use Parallels VMs for work projects
- VMs have stronger isolation than containers
- Can snapshot before experiments
- IT already trusts Parallels

**For convenience:**
- Use dotfiles shell aliases/functions
- `pvm-ssh "Ubuntu Dev"` - quick access
- `work-windows` - launch Windows immediately
- `pvm-snapshot "Ubuntu Dev"` - save state before changes

**Example workflow:**
```bash
# Morning: Start work VM
work-ubuntu

# Do work in isolated VM...

# Snapshot before experiment
pvm-snapshot "Ubuntu Dev" "before-k8s-upgrade"

# Try something risky...
# If it breaks, restore from snapshot

# Evening: Stop VM
pvm-stop "Ubuntu Dev"
```

---

## Other Security Considerations

### Shell History Exposure

Your `~/.zsh_history` might contain:
- Accidentally pasted passwords
- Internal hostnames/IPs
- Proprietary commands

**Mitigation (already in install-work.sh):**
```bash
# Commands starting with space aren't saved
setopt HIST_IGNORE_SPACE

# Example: note the leading space
 ssh admin@10.internal.company.com -p 2222
```

### Git Configuration Leaks

**Problem:** Commits show work email, internal repo URLs

**Solution:**
```bash
# Use different git config for work directories
git config --global includeIf.gitdir:~/work/.path ~/work/.gitconfig

# In ~/work/.gitconfig
[user]
    email = you@workdomain.com
```

### Container Risks

**Don't:**
- Mount sensitive directories: `docker run -v ~/work:/work`
- Run with `--privileged` flag
- Use untrusted container images

**Do:**
- Set `DOCKER_CONTENT_TRUST=1` (require signed images)
- Mount read-only: `docker run -v ~/data:/data:ro`
- Review container definitions before running

---

## Summary: What You Should Do

### Immediate (Right Now)

1. **Run work-safe installer:**
   ```bash
   cd ~/dotfiles
   ./install-work.sh
   ```

2. **Test it works:**
   ```bash
   source ~/.zshrc
   dev  # Should open environment menu
   ```

3. **Check permissions:**
   - System Settings → Privacy & Security → Accessibility
   - Hammerspoon should NOT be listed

### This Week

1. **Create work-specific config:**
   ```bash
   vim ~/.zshrc.local
   # Add work-specific aliases, env vars
   ```

2. **Review security guide:**
   ```bash
   cat ~/dotfiles/WORK-COMPUTER-SECURITY.md
   ```

3. **Check with IT:**
   - Is Docker Desktop approved?
   - Any restrictions on containers?

### Ongoing

- Keep work secrets in `.zshrc.local` (not in git)
- Use Parallels for isolated work projects
- Prefix sensitive commands with space
- Don't commit internal details to dotfiles

---

## Final Thoughts

**Hammerspoon:** Convenient but security risk. Not worth it on work computer.

**Parallels:** You already have it, it's approved, use it for isolation.

**These dotfiles:** Work-safe mode gives you all the productivity benefits without security concerns.

**The container/VM features are fine** - it's just the Hammerspoon hotkey system that's problematic.

**Bottom line:** Use `install-work.sh`, type `dev` instead of pressing a hotkey, and leverage your existing Parallels setup for VMs.
