# Hotkey Tools Comparison: Keyboard Maestro vs Alfred vs Hammerspoon

Since you already have **Keyboard Maestro** and **Alfred PowerPack** approved and running on your work computer, you have three excellent options for hotkey functionality.

## Executive Summary

| Tool | Setup Time | Power | UI Quality | Work-Safe | Recommendation |
|------|-----------|-------|-----------|-----------|----------------|
| **Keyboard Maestro** | 5 min | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ Already approved | **BEST CHOICE** |
| **Alfred PowerPack** | 5 min | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ Already approved | **SECOND BEST** |
| **Hammerspoon** | 2 min | ⭐⭐⭐⭐ | ⭐⭐⭐ | ✅ No worse than KM/Alfred | Still valid |

**Bottom line:** Use **Keyboard Maestro**. It's the most powerful, you already have it, and it's clearly work-approved.

---

## Detailed Comparison

### 1. Keyboard Maestro (Recommended)

**What it is:** Professional macOS automation tool with visual editor

**Pros:**
- ✅ Already installed and licensed on work computer
- ✅ Most powerful of the three options
- ✅ Visual macro editor (easy to audit)
- ✅ Can show native macOS menus (no terminal needed)
- ✅ Professional tool, clearly work-approved
- ✅ Best error handling and safety features
- ✅ Can export macros for backup/sharing
- ✅ Conditional logic, variables, integrations
- ✅ Can run scripts in background with notifications
- ✅ Active development and support

**Cons:**
- ⚠️ Requires license ($36, but you already have it)
- ⚠️ Slight learning curve (but worth it)

**Best for:**
- Professional work environments
- Complex automation workflows
- When you want native UI instead of terminal
- Long-term maintainability

**Setup complexity:** ⭐⭐ (5 minutes, visual interface)

---

### 2. Alfred PowerPack

**What it is:** Productivity app with workflow capabilities

**Pros:**
- ✅ Already installed on work computer
- ✅ Beautiful, polished UI
- ✅ Keyword triggers (`dev` in Alfred bar)
- ✅ Hotkey triggers (⌘+Shift+D)
- ✅ Great for quick actions
- ✅ Workflow sharing community
- ✅ Can export workflows for backup
- ✅ Integrates with clipboard, snippets, file search
- ✅ More "natural" than terminal commands

**Cons:**
- ⚠️ Less powerful than Keyboard Maestro for complex automation
- ⚠️ Workflows are less visual than KM macros
- ⚠️ Limited conditional logic compared to KM

**Best for:**
- Quick access to commands
- When you want keyword triggers (type `dev`)
- Integration with other Alfred features
- Simpler workflows

**Setup complexity:** ⭐⭐ (5 minutes, workflow editor)

---

### 3. Hammerspoon

**What it is:** Open-source macOS automation using Lua scripts

**Pros:**
- ✅ Free and open source
- ✅ Lightweight (minimal memory usage)
- ✅ Highly scriptable (Lua)
- ✅ Large community and documentation
- ✅ Already in your dotfiles
- ✅ Good for version control (text files)
- ✅ No worse security-wise than KM/Alfred

**Cons:**
- ⚠️ Text-based config (less visual)
- ⚠️ Requires learning Lua (but our scripts are simple)
- ⚠️ Less polished UI than Alfred/KM
- ⚠️ May be less familiar to IT compared to commercial tools

**Best for:**
- When you want everything in version control
- Lightweight automation
- Personal computers or when KM/Alfred aren't available
- Developers who like code-based configuration

**Setup complexity:** ⭐ (2 minutes, copy config file)

---

## Feature Matrix

| Feature | Keyboard Maestro | Alfred PowerPack | Hammerspoon |
|---------|-----------------|------------------|-------------|
| **Hotkey triggers** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Keyword triggers** | ⚠️ Via Text Expansion | ✅ Yes (best) | ❌ No |
| **Visual editor** | ✅ Yes (best) | ✅ Yes | ❌ Code only |
| **Native menus** | ✅ Yes (best) | ⚠️ Limited | ❌ No |
| **Shell script execution** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Conditional logic** | ✅ Yes (extensive) | ⚠️ Limited | ✅ Yes (code) |
| **Error handling** | ✅ Yes (best) | ⚠️ Basic | ⚠️ Manual |
| **Notifications** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Background execution** | ✅ Yes | ⚠️ Limited | ✅ Yes |
| **Export/sharing** | ✅ .kmmacros files | ✅ .alfredworkflow | ✅ .lua files |
| **Version control** | ⚠️ XML (works) | ⚠️ Binary (harder) | ✅ Plain text |
| **Work approval status** | ✅ Already approved | ✅ Already approved | ⚠️ Not prohibited |
| **Cost** | $36 (you have it) | £34 (you have it) | Free |

---

## Security Comparison

**All three require the same Accessibility permissions.**

Since you already have Keyboard Maestro and Alfred approved with these permissions, Hammerspoon is no additional security risk.

| Permission | KM | Alfred | Hammerspoon |
|------------|----|----|------------|
| Accessibility | ✅ Required | ✅ Required | ✅ Required |
| Automation | ✅ Required | ✅ Required | ✅ Required |

**Our use case (launching terminal scripts):**
- ✅ No keylogging in any implementation
- ✅ No screen capture in any implementation
- ✅ Only executes when YOU press a hotkey
- ✅ Minimal, auditable code/macros

---

## Practical Recommendations

### For Your Work Computer: Use Keyboard Maestro

**Why:**
1. Already installed and approved
2. Most powerful and flexible
3. Visual editor is easier to audit
4. Professional tool = no questions from IT
5. Can show native menus (better UX)
6. Best error handling and safety features

**Setup time:** 5 minutes (see `keyboard-maestro-setup.md`)

**Complexity:** Low (visual drag-and-drop)

### Alternative: Use Alfred PowerPack

**If you prefer:**
- Keyword access (type `dev` in Alfred)
- More integrated with your existing Alfred workflow
- Simpler setup for basic triggers

**Setup time:** 5 minutes (see `alfred-setup.md`)

**Complexity:** Low (workflow editor)

### Fallback: Use Hammerspoon

**If you:**
- Want everything in version control
- Prefer code-based configuration
- Want identical setup on personal computer
- Don't want to set up visual tools

**Setup time:** 2 minutes (copy Lua file)

**Complexity:** Very low (pre-built config)

---

## Side-by-Side: Same Functionality, Different Tools

### Goal: Press ⌘+Shift+D to open dev environment menu

**Keyboard Maestro:**
```
1. Create macro "Dev Launcher"
2. Set trigger: Hotkey ⌘+Shift+D
3. Add action: Execute Shell Script in Terminal
   Script: ~/.local/bin/dev-launcher
4. Done
```

**Alfred:**
```
1. Create workflow "Dev Launcher"
2. Add Hotkey Input: ⌘+Shift+D
3. Add Run Script action:
   osascript -e 'tell application "Terminal"
     do script "~/.local/bin/dev-launcher"
   end tell'
4. Connect nodes
5. Done
```

**Hammerspoon:**
```lua
-- In ~/.hammerspoon/init.lua
hs.hotkey.bind({"cmd", "shift"}, "d", function()
    hs.osascript.applescript([[
        tell application "Terminal"
            do script "~/.local/bin/dev-launcher"
        end tell
    ]])
end)
```

**Result:** All three do the exact same thing, just different setup methods.

---

## My Specific Recommendation for You

Based on your situation:
- ✅ Work computer with sensitive data
- ✅ Already have KM and Alfred approved
- ✅ Want hotkey functionality
- ✅ Want to maintain dotfiles

**Primary choice: Keyboard Maestro**
- Set up two macros (5 minutes)
- Export macros to `~/dotfiles/environment-launcher/`
- Commit exported .kmmacros files to repo
- On new machine, double-click .kmmacros to import

**Secondary choice: Alfred PowerPack**
- Set up workflow (5 minutes)
- Export workflow to `~/dotfiles/environment-launcher/`
- On new machine, double-click .alfredworkflow to import

**Tertiary choice: Hammerspoon**
- Copy work-safe config to `~/.hammerspoon/init.lua`
- Already in your dotfiles, version controlled

**Bonus: Use all three!**

Why choose? Use different triggers for different contexts:
- **⌘+Shift+D**: Keyboard Maestro (most powerful)
- **Type `dev`**: Alfred (keyword access)
- **⌘+Shift+Alt+D**: Hammerspoon (backup/personal computer)

---

## Quick Start Commands

### Install Keyboard Maestro Macros

```bash
cd ~/dotfiles/environment-launcher
open keyboard-maestro-macros.kmmacros  # If you've exported them
```

Or follow: `keyboard-maestro-setup.md`

### Install Alfred Workflows

```bash
cd ~/dotfiles/environment-launcher
open alfred-workflows/dev-launcher.alfredworkflow  # If exported
```

Or follow: `alfred-setup.md`

### Install Hammerspoon Config

```bash
mkdir -p ~/.hammerspoon
cp ~/dotfiles/environment-launcher/hammerspoon-work-safe.lua ~/.hammerspoon/init.lua
```

Or use the original: `hammerspoon-setup.lua`

---

## Audit-Friendly Summary for IT

If IT asks what these automation tools do:

**Keyboard Maestro / Alfred / Hammerspoon:**
- Bind keyboard shortcuts to launch terminal scripts
- ⌘+Shift+D opens development environment menu
- ⌘+Shift+C runs Docker cleanup
- No keylogging, screen capture, or file monitoring
- Only executes when user presses hotkey
- Scripts launch containerized development environments
- Minimal, single-purpose configuration

**The scripts themselves:**
- `dev-launcher`: Interactive menu for Docker containers/VMs
- Uses standard Docker commands (docker run)
- Uses Parallels commands (prlctl) for VMs
- All containers are isolated from host system
- No network access to internal systems
- No mounting of sensitive directories

---

## Final Recommendation

**Go with Keyboard Maestro.**

It's the most powerful, you already have it licensed and approved, and the visual interface makes it easy to audit and maintain. You'll set it up once and never think about it again.

But honestly? All three are fine. Pick whichever matches your workflow preference.
