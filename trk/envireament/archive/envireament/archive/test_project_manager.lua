-- test_project_manager.lua
-- Direct test of the project_manager module to verify it loads

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

-- Simple ImGui mocks
reaper.ImGui_CreateContext = function(name) print("Creating context: " .. name); return {} end
reaper.ImGui_DestroyContext = function() end
reaper.ImGui_Begin = function() return true end
reaper.ImGui_End = function() end
reaper.ImGui_Text = function(ctx, text) print("[UI] " .. tostring(text)) end

-- Setup package path
local script_path = reaper.GetResourcePath() .. "\\Scripts\\songbase"
package.path = script_path .. "\\?.lua;" .. package.path

-- Utility functions
local function file_exists(path)
    local file = io.open(path, "r")
    if file then file:close() return true else return false end
end

-- Check if file exists
local project_manager_path = script_path .. "\\ui\\project_manager.lua"
if file_exists(project_manager_path) then
    print("✓ Found project_manager.lua at: " .. project_manager_path)
else
    print("✗ Cannot find project_manager.lua at: " .. project_manager_path)
    return false
end

-- Try to load the project_manager module
local success, project_manager
success, project_manager = pcall(function() 
    return require("ui.project_manager") 
end)

if success and project_manager then
    print("✓ Successfully loaded project_manager module")
    
    if type(project_manager.init) == "function" then
        print("✓ Module has init function")
    else
        print("✗ Module missing init function")
    end
    
    if type(project_manager.draw) == "function" then
        print("✓ Module has draw function")
    else
        print("✗ Module missing draw function")
    end
    
    -- Try to initialize the module
    local ctx = {}
    if project_manager.init(ctx) then
        print("✓ Successfully initialized project_manager")
    else
        print("✗ Failed to initialize project_manager")
    end
    
    -- Check final status
    print("✓ Project manager module loads successfully!")
else
    print("✗ Failed to load project_manager module: " .. tostring(project_manager))
end
