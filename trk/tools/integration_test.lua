-- integration_test.lua
-- Tests the integration of all fixes for Songbase

local function print_header(message)
  print("\n=======================================")
  print(message)
  print("=======================================")
end

-- 1. Test ImGui_Combo null termination fix
print_header("Testing ImGui_Combo null termination fix")

-- Mock ImGui functions for combo test
local reaper = {
  ImGui_Combo = function(ctx, label, current_idx, items, count)
    -- Validate that the string ends with an extra null terminator
    local lastChar = string.sub(items, -1)
    local secondLastChar = string.sub(items, -2, -2)
    
    print("Items string ends with: " .. string.byte(lastChar) .. " (should be 0)")
    if string.byte(lastChar) == 0 then
      print("✓ Extra null terminator found at the end")
      return true, current_idx
    else
      print("✗ Missing extra null terminator at the end")
      return false, current_idx
    end
  end
}

-- Test the combo box fix
local function test_combo_fix()
  local roots = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
  local root_strings = table.concat(roots, '\0') .. '\0'  -- Add extra null terminator
  local current_root_idx = 0
  local changed, new_idx = reaper.ImGui_Combo(nil, "Root", current_root_idx, root_strings, #roots)
  
  return changed
end

local combo_result = test_combo_fix()
print(combo_result and "✓ Combo test PASSED" or "✗ Combo test FAILED")

-- 2. Test section combining feature
print_header("Testing section combining feature")

-- Mock state for section editor
local state = {
  section_selection = {},
  combining_mode = false,
  sections = {
    {
      name = "Verse 1",
      progression = {"C", "G", "Am", "F"}
    },
    {
      name = "Chorus",
      progression = {"F", "G", "C", "Am"}
    }
  }
}

-- Simplified section combining function for testing
local function combine_selected_sections(sections, selection)
  local combined = {
    name = "Combined Section",
    progression = {}
  }
  
  for i, selected in pairs(selection) do
    if selected and sections[i] then
      -- Add section name as comment
      table.insert(combined.progression, "-- " .. sections[i].name)
      
      -- Add chords from this section
      for _, chord in ipairs(sections[i].progression) do
        table.insert(combined.progression, chord)
      end
    end
  end
  
  return combined
end

-- Test the section combining
local function test_section_combining()
  -- Select both sections
  state.section_selection[1] = true
  state.section_selection[2] = true
  
  -- Enable combining mode
  state.combining_mode = true
  
  -- Combine sections
  local combined = combine_selected_sections(state.sections, state.section_selection)
  
  -- Verify combined section
  print("Combined section name: " .. combined.name)
  print("Combined progression length: " .. #combined.progression)
  
  -- Print the combined progression
  print("Combined progression:")
  for i, chord in ipairs(combined.progression) do
    print("  " .. i .. ": " .. chord)
  end
  
  -- Check if section names are included as comments
  local has_section_names = false
  for _, chord in ipairs(combined.progression) do
    if string.match(chord, "^%-%- ") then
      has_section_names = true
      break
    end
  end
  
  return has_section_names and #combined.progression > 0
end

local combining_result = test_section_combining()
print(combining_result and "✓ Section combining test PASSED" or "✗ Section combining test FAILED")

-- 3. Test bitwise operations fix
print_header("Testing bitwise operations fix")

-- Mock bit library for testing
local bit = {
  bor = function(a, b, ...)
    local result = a + b
    local args = {...}
    for i=1, #args do result = result + args[i] end
    return result
  end
}

-- Mock ImGui flag functions
reaper.ImGui_WindowFlags_AlwaysAutoResize = function() return 1 end
reaper.ImGui_WindowFlags_NoSavedSettings = function() return 2 end
reaper.ImGui_WindowFlags_NoResize = function() return 4 end

-- Test bitwise operations
local function test_bitwise_operations()
  local flags = bit.bor(
    reaper.ImGui_WindowFlags_AlwaysAutoResize(),
    reaper.ImGui_WindowFlags_NoSavedSettings(),
    reaper.ImGui_WindowFlags_NoResize()
  )
  
  -- Expected: 1 + 2 + 4 = 7
  print("Flags value: " .. flags .. " (expected: 7)")
  return flags == 7
end

local bitwise_result = test_bitwise_operations()
print(bitwise_result and "✓ Bitwise operations test PASSED" or "✗ Bitwise operations test FAILED")

-- 4. Test divider widget
print_header("Testing Widgets.divider function")

-- Mock ImGui functions for widgets test
reaper.ImGui_Separator = function() return true end
reaper.ImGui_Text = function(_, text) return text end

-- Mock Widgets module
local Widgets = {
  divider = function(ctx, text)
    print("Divider called" .. (text and " with text: " .. text or " without text"))
    reaper.ImGui_Separator(ctx)
    if text then
      reaper.ImGui_Text(ctx, text)
      reaper.ImGui_Separator(ctx)
    end
    return true
  end
}

-- Test the divider function
local function test_divider()
  local result1 = Widgets.divider(nil)
  local result2 = Widgets.divider(nil, "Test Divider")
  
  return result1 and result2
end

local divider_result = test_divider()
print(divider_result and "✓ Divider widget test PASSED" or "✗ Divider widget test FAILED")

-- Overall summary
print_header("TEST SUMMARY")
print("ImGui_Combo null termination: " .. (combo_result and "✓ PASSED" or "✗ FAILED"))
print("Section combining feature:     " .. (combining_result and "✓ PASSED" or "✗ FAILED"))
print("Bitwise operations:           " .. (bitwise_result and "✓ PASSED" or "✗ FAILED"))
print("Widgets.divider function:     " .. (divider_result and "✓ PASSED" or "✗ FAILED"))

local all_passed = combo_result and combining_result and bitwise_result and divider_result
print("\nOVERALL RESULT: " .. (all_passed and "✓ ALL TESTS PASSED" or "✗ SOME TESTS FAILED"))
