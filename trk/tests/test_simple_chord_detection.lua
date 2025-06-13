-- test_simple_chord_detection.lua
-- Basic test for the Simple Chord Detection functions

-- Mock REAPER functions for testing
reaper = {
  ShowMessageBox = function(msg, title, type) print("REAPER MSG: " .. msg) end,
  GetProjectPath = function() return "/tmp" end,
  GetProjectName = function() return "test_project.RPP" end,
  Master_GetTempo = function() return 120 end,
  UpdateArrange = function() end,
  AddProjectMarker2 = function(proj, isrgn, pos, rgnend, name, wantidx, color)
    print(string.format("REGION: %.2f-%.2f %s (color: 0x%06X)", pos, rgnend, name, color))
  end,
  Undo_BeginBlock = function() end,
  Undo_EndBlock = function() end
}

-- Load the chord detection functions (excluding the REAPER-specific parts)
dofile("scripts/Simple_Chord_Detection.lua")

-- Test data: MIDI notes for various chords
local test_chords = {
  {name = "C Major", notes = {60, 64, 67}},  -- C, E, G
  {name = "D Minor", notes = {62, 65, 69}},  -- D, F, A
  {name = "G7", notes = {67, 71, 74, 77}},   -- G, B, D, F
  {name = "F Major 7", notes = {65, 69, 72, 76}}, -- F, A, C, E
  {name = "A Minor", notes = {57, 60, 64}},  -- A, C, E
  {name = "B Diminished", notes = {59, 62, 65}}, -- B, D, F
  {name = "C Augmented", notes = {60, 64, 68}},  -- C, E, G#
  {name = "D Sus4", notes = {62, 67, 69}},   -- D, G, A
  {name = "E Sus2", notes = {64, 66, 71}}    -- E, F#, B
}

print("Testing Simple Chord Detection Functions")
print("======================================")

-- Test chord detection
for _, test in ipairs(test_chords) do
  print("\nTesting: " .. test.name)
  print("MIDI Notes: " .. table.concat(test.notes, ", "))
  
  local chord_result = detect_chord(test.notes)
  print("Detected: " .. chord_result.name)
  print("Confidence: " .. string.format("%.1f%%", chord_result.confidence * 100))
  print("Type: " .. chord_result.type)
  print("Quality: " .. chord_result.quality)
  print("Root: " .. chord_result.root_name)
  
  -- Test region creation
  create_chord_region(0, 4, chord_result)
  
  -- Test JCRD data addition
  EXPORT_JCRD = true
  add_to_jcrd_data(0, 4, chord_result)
end

-- Test JCRD export
print("\n\nTesting JCRD Export")
print("==================")
print("JCRD Data Structure:")
print("Title: " .. jcrd_data.title)
print("Number of chords: " .. #jcrd_data.chords)

-- Simple test of JSON serialization
if #jcrd_data.chords > 0 then
  local first_chord = jcrd_data.chords[1]
  print("\nFirst chord entry:")
  print("  Name: " .. first_chord.name)
  print("  Root: " .. first_chord.root)
  print("  Quality: " .. first_chord.quality)
  print("  Time: " .. first_chord.time)
  print("  Duration: " .. first_chord.duration)
  print("  Confidence: " .. first_chord.confidence)
end

print("\n✓ Test completed successfully!")
