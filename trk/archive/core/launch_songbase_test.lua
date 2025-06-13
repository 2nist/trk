-- launch_songbase_test.lua
-- Simple launcher to test songbase main.lua in REAPER
-- This script can be run directly from REAPER

-- Print startup message
reaper.ShowConsoleMsg("\n🚀 Testing Songbase main.lua...\n")
reaper.ShowConsoleMsg(string.rep("=", 50) .. "\n")

-- Check if ReaImGui is available
if not reaper.ImGui_CreateContext then
    reaper.ShowMessageBox(
        "ReaImGui is required for Songbase.\n\n" ..
        "Please install ReaImGui via ReaPack:\n" ..
        "Extensions → ReaPack → Browse packages → search for 'ReaImGui'",
        "Songbase Test: Missing Dependency",
        0
    )
    return
end

-- Setup package path for songbase
local script_path = reaper.GetResourcePath() .. "\\Scripts\\songbase"
package.path = script_path .. "\\?.lua;" .. package.path
package.path = script_path .. "\\utils\\?.lua;" .. package.path
package.path = script_path .. "\\ui\\?.lua;" .. package.path

reaper.ShowConsoleMsg("✓ Package paths configured\n")
reaper.ShowConsoleMsg("✓ ReaImGui available\n")
reaper.ShowConsoleMsg("✓ Base path: " .. script_path .. "\n")

-- Check directory structure
local function check_file_exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

local function check_dir_exists(path)
  -- Normalize path separators for Windows
  local normalized_path = path:gsub("/", "\\")
  local cmd = 'dir "' .. normalized_path .. '" >nul 2>&1'
  return os.execute(cmd) == 0
end

reaper.ShowConsoleMsg("\n🔍 Checking file structure...\n")

-- Check main files
local files_to_check = {
    script_path .. "\\main.lua",
    script_path .. "\\config.lua",
    script_path .. "\\utils\\json.lua",
    script_path .. "\\utils\\file_operations.lua",
    script_path .. "\\ui\\song_browser.lua",
    script_path .. "\\ui\\hex_chord_builder.lua"
}

local all_files_exist = true
for _, file_path in ipairs(files_to_check) do
    if check_file_exists(file_path) then
        reaper.ShowConsoleMsg("✓ " .. file_path .. "\n")
    else
        reaper.ShowConsoleMsg("❌ Missing: " .. file_path .. "\n")
        all_files_exist = false
    end
end

-- Check directories
local dirs_to_check = {
    script_path .. "\\ui",
    script_path .. "\\utils", 
    script_path .. "\\datasets"
}

for _, dir_path in ipairs(dirs_to_check) do
    if check_dir_exists(dir_path) then
        reaper.ShowConsoleMsg("✓ Directory: " .. dir_path .. "\n")
    else
        reaper.ShowConsoleMsg("❌ Missing directory: " .. dir_path .. "\n")
        all_files_exist = false
    end
end

if not all_files_exist then
    reaper.ShowConsoleMsg("\n❌ Some required files/directories are missing!\n")
    reaper.ShowMessageBox(
        "Some required Songbase files are missing.\n" ..
        "Please check the console for details.",
        "Songbase Test: Missing Files",
        0
    )
    return
end

reaper.ShowConsoleMsg("\n✅ All required files found!\n")

-- Load main.lua
reaper.ShowConsoleMsg("\n🎵 Loading main.lua...\n")

-- Clear module cache for clean load
package.loaded.main = nil

local success, result = pcall(function()
    return dofile(script_path .. "\\main.lua")
end)

if success then
    reaper.ShowConsoleMsg("✅ SUCCESS: main.lua loaded and executed!\n")
    
    if type(result) == "table" and type(result.run) == "function" then
        reaper.ShowConsoleMsg("✓ Main module exports run function\n")
        reaper.ShowConsoleMsg("📝 Note: You can also call the run function programmatically\n")
    end
    
    reaper.ShowConsoleMsg("\n🎉 Songbase test completed successfully!\n")
    reaper.ShowConsoleMsg("The main application should now be running.\n")
    
else
    reaper.ShowConsoleMsg("❌ FAILED to load main.lua\n")
    reaper.ShowConsoleMsg("Error: " .. tostring(result) .. "\n")
    
    reaper.ShowMessageBox(
        "Failed to load main.lua:\n\n" .. tostring(result),
        "Songbase Test: Load Error",
        0
    )
end

reaper.ShowConsoleMsg(string.rep("=", 50) .. "\n")
