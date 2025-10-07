-- Hammerspoon Configuration for Environment Launcher
-- WORK-SAFE VERSION: Minimal, auditable, single-purpose
--
-- What this does:
--   1. Binds ⌘+Shift+D to open dev environment menu in terminal
--   2. Binds ⌘+Shift+C to run Docker cleanup
--   3. Shows notifications for user feedback
--
-- What this does NOT do:
--   - No keylogging
--   - No screen capture
--   - No file monitoring
--   - No network access
--   - No clipboard access
--   - No window management
--   - No automatic actions
--
-- Security: This script only executes when you press a hotkey.
-- It launches shell scripts in Terminal. That's it.

-- =============================================================================
-- CONFIGURATION
-- =============================================================================

-- Terminal application to use (change this to your preference)
local TERMINAL_APP = "Ghostty"  -- Options: "Terminal", "Ghostty", "iTerm"

-- Path to dev-launcher script
local DEV_LAUNCHER_PATH = os.getenv("HOME") .. "/.local/bin/dev-launcher"

-- =============================================================================
-- HELPER FUNCTIONS
-- =============================================================================

-- Function to launch script in terminal
local function launchInTerminal(command)
    if TERMINAL_APP == "Ghostty" then
        -- Launch in Ghostty
        hs.execute(string.format('open -a Ghostty -n --args -e "%s"', command))
    elseif TERMINAL_APP == "iTerm" then
        -- Launch in iTerm2
        local script = string.format([[
            tell application "iTerm"
                activate
                create window with default profile
                tell current session of current window
                    write text "%s"
                end tell
            end tell
        ]], command)
        hs.osascript.applescript(script)
    else
        -- Default: Launch in Terminal.app
        local script = string.format([[
            tell application "Terminal"
                activate
                do script "%s"
            end tell
        ]], command)
        hs.osascript.applescript(script)
    end
end

-- Function to show notification
local function notify(title, message)
    hs.notify.new({
        title = title,
        informativeText = message,
        autoWithdraw = true,
        withdrawAfter = 2
    }):send()
end

-- =============================================================================
-- HOTKEY BINDINGS
-- =============================================================================

-- ⌘+Shift+D: Open Dev Environment Launcher
hs.hotkey.bind({"cmd", "shift"}, "d", function()
    -- Check if dev-launcher exists
    local file = io.open(DEV_LAUNCHER_PATH, "r")
    if file then
        file:close()
        launchInTerminal(DEV_LAUNCHER_PATH)
        notify("🚀 Environment Launcher", "Opening development environment menu...")
    else
        notify("❌ Error", "dev-launcher script not found at: " .. DEV_LAUNCHER_PATH)
    end
end)

-- ⌘+Shift+C: Docker Cleanup
hs.hotkey.bind({"cmd", "shift"}, "c", function()
    -- Run docker cleanup
    hs.execute("docker system prune -f", function(exitCode, stdOut, stdErr)
        if exitCode == 0 then
            notify("🧹 Docker Cleanup", "Unused containers and images removed")
        else
            notify("❌ Docker Cleanup Failed", "Error: " .. (stdErr or "unknown error"))
        end
    end)
end)

-- =============================================================================
-- STARTUP
-- =============================================================================

-- Show notification that Hammerspoon is loaded
notify("Hammerspoon", "Dev environment hotkeys active")

-- Print to Hammerspoon console (for debugging)
print("✅ Hammerspoon dev environment launcher loaded")
print("📍 Terminal app: " .. TERMINAL_APP)
print("⌨️  Hotkeys:")
print("   ⌘+Shift+D: Open dev launcher")
print("   ⌘+Shift+C: Docker cleanup")

-- =============================================================================
-- AUDIT LOG
-- =============================================================================

-- Optional: Log hotkey usage (for audit purposes)
-- Uncomment if you want to track when hotkeys are pressed

--[[
local AUDIT_LOG = os.getenv("HOME") .. "/.hammerspoon-audit.log"

local function auditLog(action)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local log_entry = string.format("[%s] %s\n", timestamp, action)

    local file = io.open(AUDIT_LOG, "a")
    if file then
        file:write(log_entry)
        file:close()
    end
end

-- Add auditLog("Dev launcher opened") to hotkey functions if needed
--]]

-- =============================================================================
-- END OF CONFIGURATION
-- =============================================================================
