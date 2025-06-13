-- test_song_browser.lua
-- Direct test of the song_browser module to verify it loads

-- Create mock reaper global
reaper = {}
reaper.GetResourcePath = function() return "C:\\Users\\CraftAuto-Sales\\AppData\\Roaming\\REAPER" end
reaper.ShowConsoleMsg = function(msg) print(msg) end
reaper.defer = function(func) if func then func() end end -- Execute immediately in test

-- Set up constants
reaper.ImGui_Cond_FirstUseEver = 1 -- Add proper numeric constant
reaper.ImGui_WindowFlags_MenuBar = 1024 -- Add proper numeric constant
reaper.ImGui_TabBarFlags_None = 0
reaper.ImGui_Col_Text = 0

-- Simple ImGui mocks for testing
reaper.ImGui_CreateContext = function(name) print("Creating context: " .. name); return {} end
reaper.ImGui_DestroyContext = function() end
reaper.ImGui_Begin = function() return true end
reaper.ImGui_End = function() end
reaper.ImGui_Text = function(ctx, text) print("[UI] " .. tostring(text)) end
reaper.ImGui_Button = function() return false end
reaper.ImGui_BeginChild = function() return true end
reaper.ImGui_EndChild = function() end
reaper.ImGui_Separator = function() end
reaper.ImGui_InputText = function() return false, "" end
reaper.ImGui_Selectable = function() return false end
reaper.ImGui_IsItemHovered = function() return false end
reaper.ImGui_IsMouseDoubleClicked = function() return false end

-- Setup package path
local script_path = reaper.GetResourcePath() .. "\\Scripts\\songbase"
package.path = script_path .. "\\?.lua;" .. package.path

-- Utility functions
local function file_exists(path)
    local file = io.open(path, "r")
    if file then file:close() return true else return false end
end

-- Check if file exists
local song_browser_path = script_path .. "\\ui\\song_browser.lua"
if file_exists(song_browser_path) then
    print("✓ Found song_browser.lua at: " .. song_browser_path)
else
    print("✗ Cannot find song_browser.lua at: " .. song_browser_path)
    return false
end

-- Try to load the song_browser module
local success, song_browser
success, song_browser = pcall(function() 
    return require("ui.song_browser") 
end)

if success and song_browser then
    print("✓ Successfully loaded song_browser module")
    
    if type(song_browser.init) == "function" then
        print("✓ Module has init function")
    else
        print("✗ Module missing init function")
    end
    
    -- Try to initialize the module
    local ctx = {}
    if song_browser.init and song_browser.init(ctx) then
        print("✓ Successfully initialized song_browser")
    else
        print("✗ Failed to initialize song_browser")
    end
    
    -- Check final status
    print("✓ Song browser module loads successfully!")
else
    print("✗ Failed to load song_browser module: " .. tostring(song_browser))
end
