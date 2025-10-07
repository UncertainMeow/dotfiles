# Keyboard Maestro Setup for Environment Launcher

Keyboard Maestro is the most powerful option and is already installed on your work computer.

## Quick Setup (5 minutes)

### Macro 1: Dev Environment Launcher (⌘+Shift+D)

1. **Open Keyboard Maestro Editor**
2. **Create New Macro** named "Dev Environment Launcher"
3. **Set trigger:** Hot Key Trigger → ⌘⇧D
4. **Add action:** "Execute a Shell Script"
   - Script:
     ```bash
     export PATH=/usr/local/bin:/opt/homebrew/bin:$PATH
     ~/.local/bin/dev-launcher
     ```
   - Execute in: Terminal.app (or Ghostty if it's in the dropdown)
   - ✅ Display results in a window (optional)
5. **Save**

### Macro 2: Docker Cleanup (⌘+Shift+C)

1. **Create New Macro** named "Docker Cleanup"
2. **Set trigger:** Hot Key Trigger → ⌘⇧C
3. **Add action:** "Execute a Shell Script"
   - Script:
     ```bash
     export PATH=/usr/local/bin:/opt/homebrew/bin:$PATH
     docker system prune -f
     ```
   - Execute in: Terminal.app
   - ✅ Display results in a notification
4. **Save**

## Advanced: Interactive Menu in KM (No Terminal Required)

Keyboard Maestro can show its own menu, so you don't even need a terminal window:

### Enhanced Dev Launcher with Native Menu

1. **Create New Macro** named "Dev Menu (Native)"
2. **Set trigger:** Hot Key Trigger → ⌘⇧D
3. **Add action:** "Prompt for User Input"
   - Type: Dropdown
   - Options:
     - NixOS Learning Environment
     - K3s Cluster
     - Python Dev
     - Node.js Dev
     - Rust Dev
     - Docker Cleanup
     - Parallels - Windows
     - Parallels - Ubuntu
   - Store result in variable: selectedEnv
4. **Add action:** "Switch or Case"
   - Case: "NixOS Learning Environment"
     - Action: Execute Shell Script in Terminal
       ```bash
       docker run -it nixos/nix
       ```
   - Case: "K3s Cluster"
     - Action: Execute Shell Script in Terminal
       ```bash
       docker run -it rancher/k3s:latest
       ```
   - Case: "Python Dev"
     - Action: Execute Shell Script in Terminal
       ```bash
       docker run -it python:3.12
       ```
   - Case: "Docker Cleanup"
     - Action: Execute Shell Script
       ```bash
       docker system prune -f
       ```
     - Display in notification
   - Case: "Parallels - Windows"
     - Action: Execute Shell Script
       ```bash
       prlctl start "Windows 11" && prlctl console "Windows 11"
       ```
   - (Add more cases as needed)

## Benefits of Keyboard Maestro Approach

✅ **Professional:** Clearly a work-approved tool
✅ **Visual:** Easy to audit what each macro does
✅ **Powerful:** Can show native menus, notifications, dialogs
✅ **Integrated:** Better macOS integration than Hammerspoon
✅ **Exportable:** Can export macros as .kmmacros files for backup
✅ **Conditional:** Can check if Docker is running before executing

## Optional: Safety Guardrails

### Add Confirmation for Destructive Actions

For Docker cleanup:

1. **Before Execute Shell Script action, add:**
   - Action: "Display Text"
   - Title: "Confirm Cleanup"
   - Text: "This will remove unused Docker containers and images. Continue?"
   - Buttons: "Yes", "Cancel"
2. **Add condition:** "If the button is Yes"
   - Then: Execute cleanup
   - Else: Cancel

### Add Environment Detection

Only run certain macros on work vs personal computer:

1. **Add condition at start of macro:**
   - Action: "If All Conditions Met"
   - Condition: "Environment Variable WORK_MODE is true"
   - Then: Show work-safe options
   - Else: Show all options

## Export for Backup

In Keyboard Maestro:
1. Select your macros
2. **File → Export Macros**
3. Save to: `~/dotfiles/environment-launcher/keyboard-maestro-macros.kmmacros`
4. Commit to repo (it's just XML, safe to share)

## Integration with Existing Dotfiles

Your `dev-launcher` script still works, KM just triggers it:

```bash
# Keyboard Maestro calls this
~/.local/bin/dev-launcher

# Which uses fzf to show interactive menu
# Just like before, but triggered by KM instead of Hammerspoon
```

## Recommendation

**Start with Simple (Macro 1 above)**, then optionally enhance with native menu later.

The simple version just triggers your existing `dev-launcher` script, so it's a drop-in replacement for Hammerspoon.
