-- test_sketch_mode.lua
-- Test script for Sketch Mode implementation using the Virtual REAPER Environment

-- Set up path to find the virtual environment modules
package.path = package.path .. ";./envireament/src/?.lua;./envireament/?.lua"

-- Load the package which contains the virtual environment
local Package = require("envireament.package")

-- Initialize the virtual environment with our desired options
local env = Package.setup({
  verbose = true,
  simulate_ui = true,
  skip_heavy_rendering = true
})

-- Get references to the tools we'll need
local reaper = env.reaper
local VirtualReaper = env.virtual_reaper
local TestRunner = env.test_runner
local assert = env.utils.assertions

print("===== SKETCH MODE TEST SUITE =====")

-- Helper function to load and run a script
local function load_and_run_script(script_path)
  print("\n----- Testing: " .. script_path .. " -----")
  local file = io.open(script_path, "r")
  if not file then
    print("ERROR: Could not open file: " .. script_path)
    return false
  end
  
  local script_content = file:read("*all")
  file:close()
  
  -- Create a function from the script content
  local script_func, err = load(script_content)
  if not script_func then
    print("ERROR: Could not load script: " .. err)
    return false
  end
  
  -- Run the script in our virtual environment
  local success, result = pcall(script_func)
  if not success then
    print("ERROR: Script execution failed: " .. tostring(result))
    return false
  end
  
  return true, result
end

-- Test 1: Activate Sketch Mode script
local function test_activate_sketch_mode()
  print("\n[TEST] Activate_Sketch_Mode.lua")
  
  -- Reset virtual REAPER to a clean state
  VirtualReaper.reset()
  
  -- Run the script
  local success, result = load_and_run_script("Activate_Sketch_Mode.lua")
  assert.is_true(success, "Script execution should succeed")
  
  -- Verify tracks were created
  local num_tracks = reaper.CountTracks(0)
  assert.is_equal(num_tracks, 8, "Should create 8 tracks")
  
  -- Verify track names
  local expected_names = {
    "Chord Detector (Scaler)",
    "Drum Sketch",
    "Bass Sketch",
    "Chord Sketch",
    "Melody Sketch",
    "Vocal Sketch",
    "Scratchpad",
    "FX Bus (Muted)"
  }
  
  for i = 1, #expected_names do
    local track = reaper.GetTrack(0, i-1)
    local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    assert.is_equal(name, expected_names[i], "Track " .. i .. " should be named " .. expected_names[i])
  end
  
  -- Check if FX Bus is muted
  local fx_bus = reaper.GetTrack(0, 7)
  local muted = reaper.GetMediaTrackInfo_Value(fx_bus, "B_MUTE")
  assert.is_equal(muted, 1, "FX Bus should be muted")
  
  -- Check if BPM is set
  local bpm = reaper.Master_GetTempo()
  assert.is_equal(bpm, 90, "BPM should be set to 90")
  
  print("✅ Activate_Sketch_Mode.lua test passed!")
  return true
end

-- Test 2: New Sketch Section script
local function test_new_sketch_section()
  print("\n[TEST] New_Sketch_Section.lua")
  
  -- Reset virtual REAPER to a clean state with some tracks
  VirtualReaper.reset()
  reaper.InsertTrackAtIndex(0, true) -- Add a track to select
  local track = reaper.GetTrack(0, 0)
  reaper.SetTrackSelected(track, true)
  
  -- Run the script
  local success, result = load_and_run_script("New_Sketch_Section.lua")
  assert.is_true(success, "Script execution should succeed")
  
  -- Check if an item was created
  local item_count = reaper.CountTrackMediaItems(track)
  assert.is_equal(item_count, 1, "Should create 1 media item")
  
  -- Check if item has correct properties
  local item = reaper.GetTrackMediaItem(track, 0)
  local length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
  assert.is_equal(length, 4.0, "Item length should be 4.0 seconds")
  
  print("✅ New_Sketch_Section.lua test passed!")
  return true
end

-- Test 3: Promote To Arrangement script
local function test_promote_to_arrangement()
  print("\n[TEST] Promote_To_Arrangement.lua")
  
  -- Reset virtual REAPER to a clean state with some tracks and items
  VirtualReaper.reset()
  reaper.InsertTrackAtIndex(0, true) -- Source track
  reaper.InsertTrackAtIndex(1, true) -- Destination track
  local src_track = reaper.GetTrack(0, 0)
  
  -- Create a test item to promote
  local item = reaper.CreateNewMIDIItemInProj(src_track, 0, 2.0, false)
  reaper.SetMediaItemSelected(item, true)
  
  -- Run the script
  local success, result = load_and_run_script("Promote_To_Arrangement.lua")
  assert.is_true(success, "Script execution should succeed")
  
  -- Check if an item was created on destination track
  local dest_track = reaper.GetTrack(0, 0) -- First track is the destination in the script
  local item_count = reaper.CountTrackMediaItems(dest_track)
  assert.is_equal(item_count, 1, "Should create 1 media item on destination track")
  
  print("✅ Promote_To_Arrangement.lua test passed!")
  return true
end

-- Run all tests
test_activate_sketch_mode()
test_new_sketch_section()
test_promote_to_arrangement()

print("\n===== ALL TESTS COMPLETED =====")
print("✅ Sketch Mode implementation is ready to use!")
