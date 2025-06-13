-- test_project_manager_ui.lua
-- Test script to verify the project_manager UI rendering

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

-- Mock ImGui functions specifically for this test
local ui_log = {}
local function log_ui_call(fname, ...)
    local args = {...}
    local args_str = {}
    for i, arg in ipairs(args) do
        if type(arg) == "string" then
            table.insert(args_str, '"' .. arg .. '"')
        else
            table.insert(args_str, tostring(arg))
        end
    end
    table.insert(ui_log, fname .. "(" .. table.concat(args_str, ", ") .. ")")
end

-- Simple ImGui mocks that log calls
reaper.ImGui_CreateContext = function(name) log_ui_call("ImGui_CreateContext", name); return {} end
reaper.ImGui_DestroyContext = function() log_ui_call("ImGui_DestroyContext") end
reaper.ImGui_Begin = function() log_ui_call("ImGui_Begin"); return true end
reaper.ImGui_End = function() log_ui_call("ImGui_End") end
reaper.ImGui_Text = function(ctx, text) log_ui_call("ImGui_Text", text) end
reaper.ImGui_Button = function() log_ui_call("ImGui_Button"); return false end
reaper.ImGui_BeginChild = function() log_ui_call("ImGui_BeginChild"); return true end
reaper.ImGui_EndChild = function() log_ui_call("ImGui_EndChild") end
reaper.ImGui_Separator = function() log_ui_call("ImGui_Separator") end
reaper.ImGui_SameLine = function() log_ui_call("ImGui_SameLine") end

-- Important test functions
reaper.ImGui_GetContentRegionAvail = function(ctx) 
    log_ui_call("ImGui_GetContentRegionAvail")
    return 400, 300 -- Return width and height
end

reaper.ImGui_SetNextItemWidth = function(ctx, width)
    log_ui_call("ImGui_SetNextItemWidth", width)
    -- Check if width is a function call result
    if type(width) == "function" then
        error("SetNextItemWidth called with function result, should be a number")
    end
end

reaper.ImGui_InputText = function() log_ui_call("ImGui_InputText"); return false, "" end
reaper.ImGui_Selectable = function() log_ui_call("ImGui_Selectable"); return false end
reaper.ImGui_IsItemHovered = function() log_ui_call("ImGui_IsItemHovered"); return false end

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

-- Try to load project_manager module
local success, project_manager
success, project_manager = pcall(function() 
    return require("ui.project_manager") 
end)

if not success or not project_manager then
    print("✗ Failed to load project_manager module: " .. tostring(project_manager))
    return
end

print("✓ Successfully loaded project_manager module")

-- Initialize module
local ctx = {}
if not project_manager.init(ctx) then
    print("✗ Failed to initialize project_manager")
    return
end

print("✓ Successfully initialized project_manager")

-- Test the draw function
print("Testing draw function...")
local ok, err = pcall(function()
    project_manager.draw(ctx, {})
end)

if ok then
    print("✓ Successfully called project_manager.draw without errors")
else
    print("✗ Error in project_manager.draw: " .. tostring(err))
end

-- Display ImGui call log
print("\nImGui call log:")
for i, call in ipairs(ui_log) do
    print(i .. ": " .. call)
end

print("\n✓ Test completed!")
