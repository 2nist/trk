-- test_imgui_combo.lua
-- Test specifically for the ImGui_Combo function

-- Mock chord functions and combo tests
local chord_functions = {
  -- Get all valid chord roots
  get_chord_roots = function()
    return {"C", "C#", "Db", "D", "D#", "Eb", "E", "F", "F#", "Gb", "G", "G#", "Ab", "A", "A#", "Bb", "B"}
  end,
  
  -- Get all valid chord qualities
  get_chord_qualities = function()
    return {
      "",  -- Major
      "m", -- Minor
      "7", -- Dominant 7th
      "maj7", -- Major 7th
      "m7", -- Minor 7th
      "dim", -- Diminished
      "aug", -- Augmented
      "sus4", -- Suspended 4th
      "sus2", -- Suspended 2nd
      "6", -- Major 6th
      "m6", -- Minor 6th
    }
  end
}

-- Create function to test old version (without extra null terminator)
local function test_original_combo()
  print("\n=== Testing original combo (no added null terminator) ===")
  
  local roots = chord_functions.get_chord_roots()
  local root_strings = table.concat(roots, '\0')
  
  -- Check characters at the end
  local last_char = string.byte(root_strings:sub(-1))
  local second_last_char = string.byte(root_strings:sub(-2, -2))
  
  print("Last char code: " .. last_char)
  print("Second-to-last char code: " .. second_last_char)
  print("Last char is null: " .. tostring(last_char == 0))
  
  -- Count null characters
  local null_count = 0
  for i=1, #root_strings do
    if root_strings:sub(i, i) == '\0' then
      null_count = null_count + 1
    end
  end
  
  print("Number of null characters: " .. null_count)
  print("Number of roots: " .. #roots)
end

-- Create function to test fixed version (with extra null terminator)
local function test_fixed_combo()
  print("\n=== Testing fixed combo (with added null terminator) ===")
  
  local roots = chord_functions.get_chord_roots()
  local root_strings = table.concat(roots, '\0') .. '\0'
  
  -- Check characters at the end
  local last_char = string.byte(root_strings:sub(-1))
  local second_last_char = string.byte(root_strings:sub(-2, -2))
  
  print("Last char code: " .. last_char)
  print("Second-to-last char code: " .. second_last_char)
  print("Last char is null: " .. tostring(last_char == 0))
  
  -- Count null characters
  local null_count = 0
  for i=1, #root_strings do
    if root_strings:sub(i, i) == '\0' then
      null_count = null_count + 1
    end
  end
  
  print("Number of null characters: " .. null_count)
  print("Number of roots: " .. #roots)
  
  -- Try to parse the items
  local items = {}
  local pos = 1
  while pos <= #root_strings do
    local null_pos = root_strings:find('\0', pos)
    if not null_pos then break end
    
    local item = root_strings:sub(pos, null_pos - 1)
    if item ~= "" then
      table.insert(items, item)
    end
    pos = null_pos + 1
  end
  
  print("Parsed items: " .. table.concat(items, ", "))
  print("Number of parsed items: " .. #items)
end

-- Run tests
print("Testing ImGui combo string formatting...")
test_original_combo()
test_fixed_combo()
print("\nTest complete")
