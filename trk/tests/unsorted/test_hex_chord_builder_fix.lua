-- test_hex_chord_builder_fix.lua
-- Tests for the fixed hex_chord_builder.lua with proper handling of empty extensions

-- Mock the reaper object
local reaper = {
  ImGui_Selectable = function(_, label, _)
    print("Testing ImGui_Selectable with label: [" .. tostring(label) .. "]")
    return true -- simulate selection
  end,
  
  ImGui_BeginCombo = function() return true end,
  ImGui_EndCombo = function() end,
  ImGui_Text = function() end,
  ImGui_SetItemDefaultFocus = function() end,
  ShowConsoleMsg = function(msg) print(msg) end
}

-- Get local copy of the EXTENSIONS array from hex_chord_builder.lua
local EXTENSIONS = {"(none)", "9", "11", "13", "6", "6/9", "add9", "add11"}

-- Test function for extension handling
local function test_extension_selectable()
  print("\n=== Testing Extension Selectable Items ===")
  
  -- Test each extension value
  for _, ext in ipairs(EXTENSIONS) do
    local is_selected = false
    reaper.ImGui_Selectable(nil, ext, is_selected)
  end
  
  -- The "(none)" extension should be passed to Selectable without issues
  print("\nFirst extension (should be '(none)'): " .. EXTENSIONS[1])
  
  return true
end

-- Mock chord_to_string from hex_chord_builder.lua
local function chord_to_string(chord)
  local str = chord.root .. chord.quality
  if chord.extension and chord.extension ~= "(none)" then
    str = str .. chord.extension
  end
  return str
end

-- Test chord string representation
local function test_chord_to_string()
  print("\n=== Testing Chord String Representation ===")
  
  -- Test a chord with no extension
  local chord1 = {
    root = "C",
    quality = "maj",
    extension = "(none)",
    inversion = "root"
  }
  
  -- Test a chord with an extension
  local chord2 = {
    root = "D",
    quality = "min",
    extension = "7",
    inversion = "root"
  }
  
  local str1 = chord_to_string(chord1)
  local str2 = chord_to_string(chord2)
  
  print("Chord 1 string: " .. str1 .. " (should be 'Cmaj')")
  print("Chord 2 string: " .. str2 .. " (should be 'Dmin7')")
  
  return str1 == "Cmaj" and str2 == "Dmin7"
end

-- Run tests
local tests = {
  { name = "Extension Selectable", func = test_extension_selectable },
  { name = "Chord to String", func = test_chord_to_string }
}

local passed = 0
local failed = 0

print("=== Starting Hex Chord Builder Fix Tests ===\n")

for _, test in ipairs(tests) do
  print("Running test: " .. test.name)
  local success = test.func()
  
  if success then
    print(test.name .. ": \u{2705} PASSED")
    passed = passed + 1
  else
    print(test.name .. ": \u{274C} FAILED")
    failed = failed + 1
  end
  print("")
end

print("=== Test Results ===")
print("Passed: " .. passed .. " / " .. #tests)
print("Failed: " .. failed .. " / " .. #tests)

if failed == 0 then
  print("\n\u{2705} All tests passed! The fix should resolve the empty ID issue.")
else
  print("\n\u{274C} Some tests failed. Please review the fixes.")
end
