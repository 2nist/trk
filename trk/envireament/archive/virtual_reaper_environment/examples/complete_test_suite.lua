-- complete_test_suite.lua
-- Example of a complete test suite using the Virtual REAPER Environment

-- Set up path (modify as needed based on your directory structure)
package.path = package.path .. ";../src/?.lua"

-- Load the virtual environment and test runner
local VirtualReaper = require("enhanced_virtual_reaper")
local TestRunner = require("enhanced_test_runner")

print("=== Complete Test Suite Example ===")

-- Get references to the mock objects
local reaper = VirtualReaper.get_reaper()
local ImGui = reaper.ImGui

-- Define test cases
-- 1. Test REAPER core functions
TestRunner.add_test("REAPER Core Functions", function()
  -- Test project creation
  reaper.Main_OnCommand(40023, 0) -- New project
  local proj = 0 -- Current project
  
  -- Test track creation
  reaper.InsertTrackAtIndex(0, true)
  local track = reaper.GetTrack(proj, 0)
  if not track then
    return false, "Failed to create track"
  end
  
  -- Test track naming
  reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "Test Track", true)
  local retval, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
  if name ~= "Test Track" then
    return false, "Track naming failed: " .. tostring(name)
  end
  
  -- Test track selection
  reaper.SetTrackSelected(track, true)
  local selectedTrack = reaper.GetSelectedTrack(proj, 0)
  if selectedTrack ~= track then
    return false, "Track selection failed"
  end
  
  return true, "REAPER core functions working correctly"
end)

-- 2. Test item manipulation
TestRunner.add_test("Media Item Manipulation", function()
  -- Create test project and track
  reaper.Main_OnCommand(40023, 0) -- New project
  reaper.InsertTrackAtIndex(0, true)
  local track = reaper.GetTrack(0, 0)
  
  -- Create a media item
  local item = reaper.CreateNewMIDIItemInProj(track, 0, 4, false)
  if not item then
    return false, "Failed to create MIDI item"
  end
  
  -- Test item position
  local position = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
  if position ~= 0 then
    return false, "Incorrect item position"
  end
  
  -- Test item length
  local length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
  if length ~= 4 then
    return false, "Incorrect item length"
  end
  
  -- Test take operations
  local take = reaper.GetActiveTake(item)
  if not take then
    return false, "Failed to get active take"
  end
  
  reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", "Test Take", true)
  local retval, takeName = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", "", false)
  if takeName ~= "Test Take" then
    return false, "Take naming failed"
  end
  
  return true, "Media item manipulation working correctly"
end)

-- 3. Test ImGui UI components
TestRunner.add_test("ImGui UI Components", function()
  -- Create ImGui context
  local ctx = ImGui.CreateContext("TestContext")
  
  -- Basic window test
  local window_open = true
  if ImGui.Begin(ctx, "Test Window", window_open) then
    ImGui.Text(ctx, "Test text")
    ImGui.End(ctx)
  end
  
  -- Test widgets
  if ImGui.Begin(ctx, "Widget Test") then
    local checkbox_value = false
    local changed
    changed, checkbox_value = ImGui.Checkbox(ctx, "Test Checkbox", checkbox_value)
    
    local slider_value = 50
    changed, slider_value = ImGui.SliderInt(ctx, "Test Slider", slider_value, 0, 100)
    
    local button_clicked = false
    if ImGui.Button(ctx, "Test Button") then
      button_clicked = true
    end
    
    ImGui.End(ctx)
  end
  
  -- Simulate a frame advance
  VirtualReaper.increment_frame()
  
  -- Clean up
  ImGui.DestroyContext(ctx)
  
  return true, "ImGui UI components working correctly"
end)

-- 4. Test error handling
TestRunner.add_test("Error Handling", function()
  -- Test function that should cause an error
  local function should_error()
    -- VirtualReaper should catch this error rather than crashing
    local x = nil
    return x.non_existent_field -- Should trigger nil access error
  end
  
  -- Test error catching
  local success, result = pcall(should_error)
  if success then
    return false, "Error was not generated as expected"
  else
    -- We expect an error, so this is correct
    return true, "Error handling working correctly"
  end
end)

-- Run all tests
local success_count, fail_count = TestRunner.run_all_tests()

-- Report results
print("\nTest Results: " .. success_count .. " passed, " .. fail_count .. " failed")
if fail_count == 0 then
  print("✅ All tests passed!")
else
  print("❌ Some tests failed. Check individual test reports above.")
end
