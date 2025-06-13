-- launch_songbase_simple.lua
-- Simplified launcher for Songbase - just loads and runs main.lua

reaper.ShowConsoleMsg("\n🚀 Songbase Simple Launcher\n")
reaper.ShowConsoleMsg(string.rep("=", 40) .. "\n")

-- Check ReaImGui
if not reaper.ImGui_CreateContext then
    reaper.ShowMessageBox(
        "ReaImGui is required for Songbase.\n\n" ..
        "Please install ReaImGui via ReaPack:\n" ..
        "Extensions → ReaPack → Browse packages → search for 'ReaImGui'",
        "Songbase: Missing Dependency",
        0
    )
    return
end

-- Setup paths
local script_path = reaper.GetResourcePath() .. "\\Scripts\\songbase"
package.path = script_path .. "\\?.lua;" .. package.path
package.path = script_path .. "\\utils\\?.lua;" .. package.path
package.path = script_path .. "\\ui\\?.lua;" .. package.path

reaper.ShowConsoleMsg("✓ ReaImGui available\n")
reaper.ShowConsoleMsg("✓ Base path: " .. script_path .. "\n")
reaper.ShowConsoleMsg("✓ Package paths configured\n")

-- Load and run main.lua
reaper.ShowConsoleMsg("\n🎵 Loading Songbase main.lua...\n")

local success, result = pcall(function()
    package.loaded.main = nil -- Clear cache
    return dofile(script_path .. "\\main.lua")
end)

if success then
    reaper.ShowConsoleMsg("✅ SUCCESS: Songbase loaded and running!\n")
    if type(result) == "table" and type(result.run) == "function" then
        reaper.ShowConsoleMsg("✓ Run function available for programmatic use\n")
    end
else
    reaper.ShowConsoleMsg("❌ FAILED to load main.lua\n")
    reaper.ShowConsoleMsg("Error: " .. tostring(result) .. "\n")
    reaper.ShowMessageBox(
        "Failed to load Songbase:\n\n" .. tostring(result),
        "Songbase Launch Error",
        0
    )
end

reaper.ShowConsoleMsg(string.rep("=", 40) .. "\n")
