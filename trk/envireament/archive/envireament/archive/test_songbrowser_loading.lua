-- test_songbrowser_loading.lua
-- Test the modified song browser with lazy loading

-- Create mock reaper global
reaper = {}
reaper.GetResourcePath = function() return "c:\\Users\\CraftAuto-Sales\\AppData\\Roaming\\REAPER" end
reaper.ShowConsoleMsg = function(msg) print(msg) end
reaper.defer = function(func) if func then func() end end -- Execute immediately in test

-- IMPORTANT FIX: Set ImGui constants as direct numbers, NOT functions
reaper.ImGui_Cond_FirstUseEver = 1 -- Add proper numeric constant
reaper.ImGui_WindowFlags_MenuBar = 1024 -- Add proper numeric constant
reaper.ImGui_TabBarFlags_None = 0
reaper.ImGui_Col_Text = function() return 0 end -- Keep as function since it's used as a function

-- Load EnviREAment virtual REAPER environment
local env_path = reaper.GetResourcePath() .. "/Scripts/EnviREAment/EnviREAment"
package.path = env_path .. "/?.lua;" .. package.path

-- Import the virtual REAPER environment
local virt_reaper = require("enhanced_virtual_reaper")
virt_reaper.init()

-- Set up a test environment
print("Setting up test environment...")
virt_reaper.mock_resource_path = reaper.GetResourcePath()

-- Override ImGui functions needed for testing
virt_reaper.mock_imgui_funcs()

-- Add missing ImGui constants
reaper.ImGui_Cond_FirstUseEver = 1 -- Add proper numeric constant
reaper.ImGui_WindowFlags_MenuBar = function() return 1024 end -- Return proper numeric constant

-- Add essential ImGui function mocks
reaper.ImGui_CreateContext = function(name) print("Creating context: " .. name); return {} end
reaper.ImGui_DestroyContext = function() end
reaper.ImGui_Begin = function() return true end
reaper.ImGui_End = function() end
reaper.ImGui_Text = function() end
reaper.ImGui_Button = function() return false end
reaper.ImGui_BeginTabBar = function() return true end
reaper.ImGui_EndTabBar = function() end
reaper.ImGui_BeginTabItem = function() return true end
reaper.ImGui_EndTabItem = function() end
reaper.ImGui_Separator = function() end
reaper.ImGui_BeginChild = function() return true end
reaper.ImGui_EndChild = function() end
reaper.ImGui_SameLine = function() end
reaper.ImGui_BeginMenuBar = function() return false end
reaper.ImGui_EndMenuBar = function() end
reaper.ImGui_BeginMenu = function() return false end
reaper.ImGui_EndMenu = function() end
reaper.ImGui_MenuItem = function() return false end
reaper.ImGui_GetContentRegionAvail = function() return 300, 300 end
reaper.ImGui_PushStyleColor = function() end
reaper.ImGui_PopStyleColor = function() end
reaper.ImGui_PushTextWrapPos = function() end
reaper.ImGui_PopTextWrapPos = function() end
reaper.ImGui_CollapsingHeader = function() return true end
reaper.ImGui_IsItemHovered = function() return false end
reaper.ImGui_IsMouseDoubleClicked = function() return false end
reaper.ImGui_InputText = function() return false end
reaper.ImGui_SetNextWindowSize = function(ctx, width, height, cond)
  print(string.format("Setting window size: %d x %d (cond: %s)", 
        width or 0, height or 0, type(cond) == "number" and cond or "invalid"))
  -- This is the critical function that was failing
  -- Make sure cond is a number and not a function
  if type(cond) ~= "number" then
    print("ERROR: ImGui_Cond_FirstUseEver should be a number, not a " .. type(cond))
  end
  return true
end

-- Run the songbase main script with the song browser as default module
local songbase_path = reaper.GetResourcePath() .. "\\Scripts\\songbase"
package.path = songbase_path .. "\\?.lua;" .. package.path

-- Print package path to debug
print("Package path: " .. package.path)
print("Looking for main.lua in: " .. songbase_path)

-- Directly check if main.lua exists
local function file_exists(path)
    local file = io.open(path, "r")
    if file then file:close() return true else return false end
end

if file_exists(songbase_path .. "/main.lua") then
    print("Found main.lua file")
else
    print("main.lua file NOT found!")
end

-- Try to load the main module
local success, main_module = pcall(function() return require("main") end)

if success and main_module and type(main_module.run) == "function" then
    print("Running main.run with song_browser as forced module")
    main_module.run({force_module = "song_browser"})
else
    print("Error loading or running main module: " .. tostring(main_module))
    
    -- Print what modules we can see
    print("Attempting to list files in songbase directory:")
    local pfile = io.popen('dir "' .. songbase_path .. '" /b')
    if pfile then
        for file in pfile:lines() do
            print("  - " .. file)
        end
        pfile:close()
    else
        print("Failed to list directory")
    end
end

-- Report test results
print("Test completed - Check console for loading pattern")
print("If the script completed without freezing, the lazy loading is working correctly")
