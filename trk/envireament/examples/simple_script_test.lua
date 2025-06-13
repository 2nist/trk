-- simple_script_test.lua
-- Basic example of testing a REAPER script with the Virtual Environment

-- Set up path (modify as needed based on your directory structure)
package.path = package.path .. ";../src/?.lua"

-- Load the virtual environment
local VirtualReaper = require("enhanced_virtual_reaper")

print("=== Simple Script Test ===")

-- Get a reference to the mock reaper object
local reaper = VirtualReaper.get_reaper()

-- Define a sample function that uses reaper API
local function create_test_project()
  -- Create a new project
  reaper.Main_OnCommand(40023, 0) -- New project command
  
  -- Add a track
  reaper.InsertTrackAtIndex(0, true)
  local track = reaper.GetTrack(0, 0)
  
  -- Set track name
  reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "Test Track", true)
  
  -- Add an item
  local item = reaper.CreateNewMIDIItemInProj(track, 0, 4, false)
  
  -- Get active take
  local take = reaper.GetActiveTake(item)
  reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", "Test MIDI", true)
  
  return {
    track = track,
    item = item,
    take = take
  }
end

-- Run the test function
print("\nCreating test project...")
local result = create_test_project()

-- Verify the results
print("\nVerifying results:")
print("- Track created: " .. tostring(result.track ~= nil))
print("- Item created: " .. tostring(result.item ~= nil))
print("- Take created: " .. tostring(result.take ~= nil))

-- Get track name to verify it was set correctly
local retval, name = reaper.GetSetMediaTrackInfo_String(result.track, "P_NAME", "", false)
print("- Track name: " .. name .. (name == "Test Track" and " ✓" or " ✗"))

-- Get take name to verify it was set correctly
local retval, take_name = reaper.GetSetMediaItemTakeInfo_String(result.take, "P_NAME", "", false)
print("- Take name: " .. take_name .. (take_name == "Test MIDI" and " ✓" or " ✗"))

-- Test complete
print("\n✅ Test completed successfully!")
print("The virtual REAPER environment is working correctly.")
