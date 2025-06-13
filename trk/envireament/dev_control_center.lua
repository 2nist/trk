-- dev_control_center.lua
-- Main EnviREAment Development Control Center
-- Entry point for all UI development, testing, and theme inspection

-- Get script directory with fallback
local script_path = ""
local info = debug.getinfo(1, "S")
if info and info.source then
    script_path = info.source:match("@?(.*[/\\])")
end
if not script_path or script_path == "" then
    script_path = "./"
end
print("ℹ️ Script base path: " .. script_path)

-- Adjust package.path to allow requiring modules from subdirectories of /envireament/
local original_package_path = package.path
package.path = script_path .. "?.lua;"
             .. script_path .. "tools/?.lua;"
             .. script_path .. "widgets/?.lua;"
             .. script_path .. "panels/?.lua;"
             .. original_package_path -- Keep original paths as well

print("ℹ️ Updated package.path: " .. package.path)

-- Load the enhanced virtual REAPER environment
print("🔍 Loading enhanced virtual REAPER environment...")
local enhanced_virtual_reaper_path = script_path .. "tools/enhanced_virtual_reaper.lua"
local load_func, load_err = loadfile(enhanced_virtual_reaper_path)

if load_func then
    print("✅ Enhanced virtual REAPER loaded successfully")
    local exec_success, exec_result = pcall(load_func)
    if not exec_success then
        print("🔴 Error executing enhanced_virtual_reaper.lua: " .. tostring(exec_result))
        return
    end
else
    print("🔴 Failed to load enhanced_virtual_reaper.lua: " .. tostring(load_err))
    return
end

-- Check if virtual REAPER environment was loaded
print("🔍 Checking virtual REAPER environment...")
if not _G.reaper then
    print("🔴 No global 'reaper' object found. Virtual environment may not have loaded correctly.")
    return
else
    print("✅ Virtual REAPER environment available")
end

-- Now, _G.reaper should be the virtual reaper object.
-- The panel UI will use this global reaper.

-- Enhanced dev control center with live theme integration
local function load_theme_tools()
    local success, theme_switcher = pcall(require, "tools.theme_switcher")
    if success then
        print("🎨 Theme switcher loaded successfully")
        theme_switcher.init()
        
        -- Show available themes
        print("   Available themes:")
        local presets = theme_switcher.get_available_presets()
        for i, preset in ipairs(presets) do
            print("     " .. i .. ". " .. preset.name)
        end
        
        return theme_switcher
    else
        print("⚠️ Theme switcher not available: " .. tostring(theme_switcher))
        return nil
    end
end

-- Initialize theme tools
local theme_switcher = load_theme_tools()

print("🚀 Launching Dev Control Center Panel UI (dofile panels/dev_panel.lua)...")
local panel_dofile_path = script_path .. "panels/dev_panel.lua"
local panel_load_success, panel_error_message = pcall(dofile, panel_dofile_path)

-- Handle any errors that occurred during panel execution
if not panel_load_success then
    local msg = "🔴 Error launching EnviREAment Dev Control Center Panel UI:\n" .. tostring(panel_error_message) .. "\n"
    if _G.reaper and _G.reaper.ShowConsoleMsg then
        _G.reaper.ShowConsoleMsg(msg)
        _G.reaper.ShowConsoleMsg("📝 Please check the panel script (panels/dev_panel.lua) and virtual environment setup.\n")
    else
        print(msg)
        print("📝 Please check the panel script (panels/dev_panel.lua) and virtual environment setup.")
    end
else
    print("✅ Dev Control Center Panel UI launched.")
end
