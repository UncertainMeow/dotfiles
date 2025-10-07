# Installation Comparison: Regular vs Work-Safe

## Quick Decision Guide

**Personal computer at home?** → Use `./install.sh`

**Work computer with sensitive data?** → Use `./install-work.sh`

---

## Feature Comparison

| Feature | install.sh | install-work.sh |
|---------|-----------|----------------|
| **Terminal configs** | ✅ Yes | ✅ Yes |
| **Shell aliases/functions** | ✅ Yes | ✅ Yes |
| **Container launcher** | ✅ Yes | ✅ Yes |
| **Parallels integration** | ✅ Yes | ✅ Yes |
| **tmux configuration** | ✅ Yes | ✅ Yes |
| **Modern tools (fzf, eza)** | ✅ Yes | ✅ Yes |
| **Hotkeys (⌘+Shift+D)** | ✅ Yes | ❌ No |
| **Hammerspoon** | ✅ Installed | ❌ Not installed |
| **Accessibility permissions** | ⚠️ Required | ✅ Not required |
| **Launch dev menu** | Press ⌘+Shift+D | Type `dev` |
| **Security audit needed** | Maybe | No |

---

## Permissions Comparison

### Regular Install (install.sh)

**Requires:**
- Accessibility permissions for Hammerspoon
- Can monitor keyboard input system-wide
- Can capture screen content
- Can execute shell commands

**Security team concerns:**
- Could log keystrokes (including passwords)
- Could capture sensitive on-screen data
- Automation tool monitoring all input
- Third-party Lua scripts with high privileges

### Work-Safe Install (install-work.sh)

**Requires:**
- No special permissions beyond normal shell access
- Only what terminal apps normally need

**Security team concerns:**
- None (standard development tools)

---

## What You Lose in Work-Safe Mode

**The ONLY difference:** No system-wide hotkeys

| Action | Regular Install | Work-Safe Install |
|--------|----------------|------------------|
| Open dev menu | Press ⌘+Shift+D | Type `dev` |
| Clean Docker | Press ⌘+Shift+C | Type `dev-clean` |

**That's it.** Everything else is identical.

---

## What You Keep in Work-Safe Mode

- ✅ All shell functions (mkcd, extract, backup, etc.)
- ✅ All aliases (ll, gs, d, k, etc.)
- ✅ Container launcher with interactive menu
- ✅ Parallels VM integration
- ✅ Modern tools (fzf, eza, zoxide)
- ✅ Catppuccin theme
- ✅ tmux configuration
- ✅ SSH integration
- ✅ Git enhancements

---

## Installation Commands

### Personal Computer

```bash
git clone https://github.com/UncertainMeow/dotfiles.git
cd dotfiles
./install.sh
```

### Work Computer

```bash
git clone https://github.com/UncertainMeow/dotfiles.git
cd dotfiles
./install-work.sh
```

Both create timestamped backups of existing configs.

---

## Usage After Installation

### Regular Install

```bash
# Press hotkeys
⌘+Shift+D          # Open dev environment menu
⌘+Shift+C          # Docker cleanup

# Or use commands
dev                 # Open menu
dev-clean           # Docker cleanup
```

### Work-Safe Install

```bash
# Use commands (no hotkeys)
dev                 # Open dev environment menu
dev-clean           # Docker cleanup

# Everything else identical
mkcd test           # Make and cd to directory
extract file.tar.gz # Extract archives
pvm                 # List Parallels VMs
```

---

## When to Use Which

### Use Regular Install (install.sh) If:

- Personal computer
- Home lab / learning environment
- No sensitive work data
- Company allows automation tools
- You want hotkey convenience

### Use Work-Safe Install (install-work.sh) If:

- Work computer
- Sensitive data present
- Company has security policies
- IT hasn't approved Hammerspoon
- Don't want to request special permissions
- Security team would audit automation tools

---

## Can I Switch Between Them?

Yes! Both installers back up existing configs.

**From regular to work-safe:**
```bash
cd ~/dotfiles
./install-work.sh  # Replaces configs, removes Hammerspoon
```

**From work-safe to regular:**
```bash
cd ~/dotfiles
./install.sh  # Adds Hammerspoon and hotkeys
```

---

## Branch Strategy

**You don't need separate branches.**

Both installers work from the same repository:
- Hammerspoon config exists in repo
- `install.sh` installs it
- `install-work.sh` skips it

Keep one `main` branch, use appropriate installer per machine.

---

## Summary

**Regular install:** Full-featured, requires Accessibility permissions

**Work-safe install:** Same features, no special permissions, type commands instead of hotkeys

**Recommendation for work computer:** Use work-safe install unless IT explicitly approves Hammerspoon.
