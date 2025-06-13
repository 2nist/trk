-- imgui_constants_test.lua
-- Test to check how ImGui constants are implemented

-- Path to enhanced_virtual_reaper.lua
local script_path = "c:/Users/CraftAuto-Sales/AppData/Roaming/REAPER/Scripts/EnviREAment/EnviREAment"
package.path = script_path .. "/?.lua;" .. package.path

-- Create mock reaper if needed
if not reaper then
  reaper = {}
  reaper.ShowConsoleMsg = function(msg) print(msg) end
  reaper.GetResourcePath = function() return "c:/Users/CraftAuto-Sales/AppData/Roaming/REAPER" end
end

print("Loading enhanced_virtual_reaper.lua...")

-- Try to load the virtual reaper module
local virt_reaper_loader = loadfile(script_path .. "/enhanced_virtual_reaper.lua")
if not virt_reaper_loader then
  print("ERROR: Could not load enhanced_virtual_reaper.lua")
  return
end

-- Safely execute the module in a protected environment
local status, virt_reaper = pcall(virt_reaper_loader)
if not status then
  print("ERROR: Failed to execute enhanced_virtual_reaper.lua: " .. tostring(virt_reaper))
  return
end

print("Successfully loaded virtual REAPER environment")

-- Initialize the virtual REAPER
if virt_reaper.init then
  print("Initializing virtual REAPER...")
  virt_reaper.init()
else
  print("ERROR: init function not found in virtual REAPER")
  return
end

-- Test ImGui constants
print("\nTesting ImGui constants...")
print("ImGui_Cond_FirstUseEver type: " .. type(reaper.ImGui_Cond_FirstUseEver))
if type(reaper.ImGui_Cond_FirstUseEver) == "function" then
  print("ImGui_Cond_FirstUseEver() returns: " .. type(reaper.ImGui_Cond_FirstUseEver()))
  print("Value: " .. tostring(reaper.ImGui_Cond_FirstUseEver()))
end

print("ImGui_WindowFlags_MenuBar type: " .. type(reaper.ImGui_WindowFlags_MenuBar))
if type(reaper.ImGui_WindowFlags_MenuBar) == "function" then
  print("ImGui_WindowFlags_MenuBar() returns: " .. type(reaper.ImGui_WindowFlags_MenuBar()))
  print("Value: " .. tostring(reaper.ImGui_WindowFlags_MenuBar()))
end

-- Try the SetNextWindowSize function
print("\nTesting ImGui_SetNextWindowSize...")
if reaper.ImGui_CreateContext then
  local ctx = reaper.ImGui_CreateContext("Test")
  if reaper.ImGui_SetNextWindowSize then
    print("Calling ImGui_SetNextWindowSize...")
    -- The problem: when calling SetNextWindowSize with Cond_FirstUseEver, 
    -- it passes the function itself, not the function's return value
    local result = pcall(function()
      reaper.ImGui_SetNextWindowSize(ctx, 800, 600, reaper.ImGui_Cond_FirstUseEver)
    end)
    print("Call succeeded: " .. tostring(result))
  else
    print("ImGui_SetNextWindowSize not found")
  end
else
  print("ImGui_CreateContext not found")
end

print("Test completed")
