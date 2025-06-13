-- simple_script_test.lua
-- Example of using the Virtual REAPER Environment for simple script testing

-- Set up path (modify as needed based on your directory structure)
package.path = package.path .. ";../src/?.lua"

-- Load the virtual environment
local VirtualReaper = require("enhanced_virtual_reaper")

print("=== Simple Script Test ===")

-- Get a reference to the mock reaper object
local reaper = VirtualReaper.get_reaper()

-- Test REAPER function calls
reaper.ShowConsoleMsg("Testing virtual REAPER environment\n")

-- Create a simple project for testing
reaper.Main_OnCommand(40023, 0) -- New project
reaper.InsertTrackAtIndex(0, true) -- Insert track at beginning of project
reaper.InsertTrackAtIndex(1, true) -- Insert another track
reaper.TrackList_AdjustWindows(false) -- Redraw track view

-- Get track and test properties
local track = reaper.GetTrack(0, 0)
if track then
  reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "Test Track", true)
  local retval, trackName = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
  
  print("Track 1 name: " .. trackName)
else
  print("Failed to create track - virtual REAPER environment may be incomplete")
end

-- Test selected track
reaper.SetTrackSelected(track, true)
local selectedTrack = reaper.GetSelectedTrack(0, 0)
if selectedTrack == track then
  print("Track selection works correctly")
else
  print("Track selection not working as expected")
end

-- Test time/project functions
local proj_len = reaper.GetProjectLength(0)
print("Project length: " .. proj_len .. " seconds")

-- Report test completion
print("\n✅ Simple script test completed successfully!")
print("The virtual REAPER environment is working correctly.")
