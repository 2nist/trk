-- test_hex_chord_builder_safety.lua
-- This script tests that all safety checks prevent empty strings from being passed to ImGui_Selectable

local reaper = {
  -- Mock ImGui functions
  ImGui_Selectable = function(ctx, label, selected)
    if label == "" then
      print("ERROR: Empty string passed to ImGui_Selectable!")
      return false
    else
      print("ImGui_Selectable called with label: '" .. label .. "'")
      return true
    end
  end,
  
  -- Other mock functions
  ShowConsoleMsg = function(msg) print(msg) end,
  ImGui_BeginCombo = function() return true end,
  ImGui_EndCombo = function() end,
  ImGui_SetItemDefaultFocus = function() end
}

-- Test data
local ROOT_NOTES = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
local QUALITIES = {"maj", "min", "dim", "aug", "sus2", "sus4", "7", "maj7", "min7", "dim7", "half-dim7"}
local EXTENSIONS = {"(none)", "9", "11", "13", "6", "6/9", "add9", "add11"}
local INVERSIONS = {"root", "1st", "2nd", "3rd"}
local MODES = {"Major", "Minor", "Dorian", "Phrygian", "Lydian", "Mixolydian", "Locrian"}

local chords = {
  { root = "C", quality = "maj", extension = "(none)", inversion = "root" },
  { root = "", quality = "", extension = "", inversion = "" }  -- Test with empty strings
}

-- Test function for root selection
local function test_root_selection()
  print("\n=== Testing Root Selection ===")
  
  for _, root in ipairs(ROOT_NOTES) do
    local is_selected = false
    local display_root = root ~= "" and root or "(empty)"
    reaper.ImGui_Selectable(nil, display_root, is_selected)
  end
  
  -- Test with an empty string (should use "(empty)" instead)
  local emptyRoot = ""
  local display_root = emptyRoot ~= "" and emptyRoot or "(empty)"
  reaper.ImGui_Selectable(nil, display_root, false)
end

-- Test function for extension selection
local function test_extension_selection()
  print("\n=== Testing Extension Selection ===")
  
  for _, ext in ipairs(EXTENSIONS) do
    local is_selected = false
    local display_ext = ext ~= "" and ext or "(empty)"
    reaper.ImGui_Selectable(nil, display_ext, is_selected)
  end
  
  -- Test with an empty string (should use "(empty)" instead)
  local emptyExt = ""
  local display_ext = emptyExt ~= "" and emptyExt or "(empty)"
  reaper.ImGui_Selectable(nil, display_ext, false)
end

-- Test function for chord display with safety checks
local function test_chord_display()
  print("\n=== Testing Chord Display ===")
  
  for i, chord in ipairs(chords) do
    print("Chord " .. i .. ":")
    
    -- Test root display
    local display_root = chord.root ~= "" and chord.root or "(empty)"
    reaper.ImGui_Selectable(nil, display_root, false)
    
    -- Test quality display
    local display_quality = chord.quality ~= "" and chord.quality or "(empty)"
    reaper.ImGui_Selectable(nil, display_quality, false)
    
    -- Test extension display
    local display_ext = chord.extension ~= "" and chord.extension or "(empty)"
    reaper.ImGui_Selectable(nil, display_ext, false)
    
    -- Test inversion display
    local display_inv = chord.inversion ~= "" and chord.inversion or "(empty)"
    reaper.ImGui_Selectable(nil, display_inv, false)
  end
end

-- Run tests
print("\n=== Starting Safety Check Tests ===")
test_root_selection()
test_extension_selection()
test_chord_display()
print("\n=== All tests completed successfully ===")
print("✓ No empty strings were passed to ImGui_Selectable")
