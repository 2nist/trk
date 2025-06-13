--[[
  Test script for section editor combo fix
  This script loads directly in REAPER and tests the combo box functionality
]]

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

-- Function to test combos
function test_combo()
  -- Create ImGui context
  local ctx = reaper.ImGui_CreateContext('Combo Test')
  local open = true
  
  -- Main UI loop
  local function loop()
    open = reaper.ImGui_Begin(ctx, 'Section Editor Combo Test', true)
    if not open then return end
    
    reaper.ImGui_Text(ctx, "This tests the ImGui_Combo null-termination fix")
    
    reaper.ImGui_Separator(ctx)
    
    -- Original method (no extra null terminator)
    reaper.ImGui_Text(ctx, "1. Original version (may fail):")
    
    local roots = chord_functions.get_chord_roots()
    local current_root_idx = 1
    
    reaper.ImGui_Text(ctx, "Number of roots: " .. #roots)
    
    local success, err = pcall(function()
      local root_changed
      local root_strings = table.concat(roots, '\0')
      root_changed, current_root_idx = reaper.ImGui_Combo(ctx, "Root (Original)", current_root_idx, root_strings, #roots)
    end)
    
    if not success then
      reaper.ImGui_TextColored(ctx, 0xFF0000FF, "Error: " .. tostring(err))
    else
      reaper.ImGui_TextColored(ctx, 0xFF00FF00, "✓ No error (but might not display correctly)")
    end
    
    reaper.ImGui_Separator(ctx)
    
    -- Fixed method (with extra null terminator)
    reaper.ImGui_Text(ctx, "2. Fixed version (should work):")
    
    success, err = pcall(function()
      local root_changed
      local root_strings = table.concat(roots, '\0') .. '\0'
      root_changed, current_root_idx = reaper.ImGui_Combo(ctx, "Root (Fixed)", current_root_idx, root_strings, #roots)
    end)
    
    if not success then
      reaper.ImGui_TextColored(ctx, 0xFF0000FF, "Error: " .. tostring(err))
    else
      reaper.ImGui_TextColored(ctx, 0xFF00FF00, "✓ No error (should display correctly)")
    end
    
    reaper.ImGui_End(ctx)
  end
  
  -- Run the ImGui frame loop
  local function frame()
    reaper.ImGui_SetNextWindowSize(ctx, 400, 300, reaper.ImGui_Cond_Once())
    loop()
    
    if open then
      reaper.defer(frame)
    else
      reaper.ImGui_DestroyContext(ctx)
    end
  end
  
  reaper.defer(frame)
end

test_combo()
