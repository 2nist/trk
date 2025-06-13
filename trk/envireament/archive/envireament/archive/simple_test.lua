-- simple_test.lua
-- Simple test to identify ImGui freezing issues

-- Create basic reaper global
reaper = {}

-- Add essential functions
reaper.ShowConsoleMsg = function(msg) print(msg) end
reaper.GetResourcePath = function() return "c:/Users/CraftAuto-Sales/AppData/Roaming/REAPER" end

-- Add minimal ImGui functions
reaper.ImGui_CreateContext = function(name) 
  print("Creating ImGui context: " .. (name or "unnamed"))
  return {} 
end
reaper.ImGui_DestroyContext = function() end
reaper.ImGui_Begin = function() return true end
reaper.ImGui_End = function() end
reaper.ImGui_Text = function(_, text) print("UI Text: " .. tostring(text)) end
reaper.ImGui_Button = function() return false end

-- Add constants as numbers (not functions)
reaper.ImGui_WindowFlags_MenuBar = function() return 1 end
reaper.ImGui_Cond_FirstUseEver = function() return 1 end
reaper.ImGui_SetNextWindowSize = function(ctx, width, height, cond)
  print(string.format("SetNextWindowSize: %s, %s, %s", 
        tostring(width), tostring(height), tostring(cond)))
  -- Check if cond is a function (this is the problem we're looking for)
  if type(cond) == "function" then
    print("ERROR: Condition is a function, not a number!")
    print("This is the issue causing freezing - ImGui constants should return numbers not be functions themselves")
  end
end

-- Try to load main.lua but only print the results, don't execute
print("Will attempt to load main.lua")

-- Define the path
local script_path = reaper.GetResourcePath() .. "/Scripts/songbase"
package.path = script_path .. "/?.lua;" .. package.path

-- Load but don't execute the problematic code
local main_loader = loadfile(script_path .. "/main.lua")
if main_loader then
  print("Successfully loaded main.lua file - but not executing")
  print("This shows the file can be found and parsed")
else
  print("Failed to load main.lua file")
end

-- Success message
print("Simple test completed successfully")
