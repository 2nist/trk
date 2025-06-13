-- hex_chord_builder.lua
-- Linear chord progression builder (v0) - Will be upgraded to hex grid in future
-- Phase 2 - Songbase UI Module
-- Implementation date: May 26, 2025
local hex_chord_builder = {}
-- Constants
local ROOT_NOTES = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
local QUALITIES = {"maj", "min", "dim", "aug", "sus2", "sus4", "7", "maj7", "min7", "dim7", "half-dim7"}
local EXTENSIONS = {"(none)", "9", "11", "13", "6", "6/9", "add9", "add11"}
local INVERSIONS = {"root", "1st", "2nd", "3rd"}
local MODES = {"Major", "Minor", "Dorian", "Phrygian", "Lydian", "Mixolydian", "Locrian"}
-- Module state
local state = {
  ctx = nil,
  progression = {},
  selected_chord_idx = nil,
  key = "C",
  mode = "Major",  new_chord = {
    root = "C", 
    quality = "maj", 
    extension = "(none)", 
    inversion = "root", 
    duration_beats = 4
  },
  preview_playing = false,
  chord_width = 500, -- Width of chord entry row
  ui_state = nil -- Reference to the global UI state
}
-- Clone a chord object
local function clone_chord(chord)
  return {
    root = chord.root,
    quality = chord.quality,
    extension = chord.extension,
    inversion = chord.inversion,
    duration_beats = chord.duration_beats
  }
end
-- Convert chord to string representation
local function chord_to_string(chord)
  local str = chord.root .. chord.quality
  if chord.extension and chord.extension ~= "(none)" then
    str = str .. chord.extension
  end
  if chord.inversion ~= "root" then
    str = str .. "/" .. chord.inversion
  end
  return str
end
-- Calculate total beats in progression
function hex_chord_builder.calculate_total_beats(progression)
  local total = 0
  for _, chord in ipairs(progression) do
    total = total + chord.duration_beats
  end
  return total
end
-- Generate theory suggestion for a chord in current key context
function hex_chord_builder.generate_theory_suggestions(chord, key, mode)
  -- Basic implementation - will be enhanced with progression_engine.lua
  local suggestions = {}
  
  -- Convert chord to roman numeral in current key
  local root_idx = 1
  local key_idx = 1
  
  for i, note in ipairs(ROOT_NOTES) do
    if note == chord.root then root_idx = i end
    if note == key then key_idx = i end
  end
  
  -- Calculate degree (1-based)
  local degree = ((root_idx - key_idx) % 12) + 1
  local roman_numerals = {"I", "II", "III", "IV", "V", "VI", "VII"}
  local degree_name = roman_numerals[((degree - 1) % 7) + 1]
  
  -- Make lowercase for minor chords
  if chord.quality == "min" or chord.quality == "dim" then
    degree_name = degree_name:lower()
  end
  
  -- Add suggestion
  table.insert(suggestions, "Degree: " .. degree_name .. " in " .. key .. " " .. mode)
  
  -- Add common next chords (simplified)
  if chord.quality == "maj" then
    table.insert(suggestions, "Common next: IV, V, vi")
  elseif chord.quality == "min" then
    table.insert(suggestions, "Common next: V, VII")
  end
  
  return table.concat(suggestions, "\n")
end
-- Send progression to section editor
function hex_chord_builder.send_progression_to_section_editor(progression)
  -- Check if Section Editor module is available in ui_state
  if not state.ui_state or not state.ui_state.views or not state.ui_state.views.section_editor then
    reaper.ShowConsoleMsg("⚠️ Section Editor module not loaded\n")
    return false
  end
  
  -- If section_editor doesn't have receive_chord_progression function, add it
  if not state.ui_state.views.section_editor.receive_chord_progression then
    reaper.ShowConsoleMsg("⚠️ Section Editor missing receive_chord_progression function\n")
    return false
  end
  
  -- Convert internal progression format to JCRD chord format
  local jcrd_chords = {}
  local beat_position = 0
  
  for _, chord in ipairs(progression) do
    local jcrd_chord = {
      symbol = chord_to_string(chord),
      root = chord.root,
      quality = chord.quality,
      beat = beat_position,
      duration = chord.duration_beats
    }
      -- Add extensions if present
    if chord.extension and chord.extension ~= "(none)" then
      jcrd_chord.extensions = {chord.extension}
    end
    
    -- Add inversion if not in root position
    if chord.inversion ~= "root" then
      jcrd_chord.inversion = chord.inversion
    end
    
    table.insert(jcrd_chords, jcrd_chord)
    beat_position = beat_position + chord.duration_beats
  end
  
  -- Send to section editor using its API
  return state.ui_state.views.section_editor.receive_chord_progression(jcrd_chords)
end
-- Build chord notes (array of MIDI note numbers)
function hex_chord_builder.build_chord_notes(chord)
  -- This is a simplified version - would use theory engine in full implementation
  local root_values = {
    C = 60, ["C#"] = 61, D = 62, ["D#"] = 63, E = 64,
    F = 65, ["F#"] = 66, G = 67, ["G#"] = 68, 
    A = 69, ["A#"] = 70, B = 71
  }
  
  local root_value = root_values[chord.root] or 60
  local notes = {root_value} -- Start with root
  
  -- Add chord tones based on quality
  if chord.quality == "maj" then
    table.insert(notes, root_value + 4)  -- Major third
    table.insert(notes, root_value + 7)  -- Perfect fifth
  elseif chord.quality == "min" then
    table.insert(notes, root_value + 3)  -- Minor third
    table.insert(notes, root_value + 7)  -- Perfect fifth
  elseif chord.quality == "dim" then
    table.insert(notes, root_value + 3)  -- Minor third
    table.insert(notes, root_value + 6)  -- Diminished fifth
  elseif chord.quality == "aug" then
    table.insert(notes, root_value + 4)  -- Major third
    table.insert(notes, root_value + 8)  -- Augmented fifth
  elseif chord.quality == "sus4" then
    table.insert(notes, root_value + 5)  -- Perfect fourth
    table.insert(notes, root_value + 7)  -- Perfect fifth
  elseif chord.quality == "sus2" then
    table.insert(notes, root_value + 2)  -- Major second
    table.insert(notes, root_value + 7)  -- Perfect fifth
  end
  
  -- Add 7th if in the quality
  if chord.quality:find("7") then
    if chord.quality == "maj7" then
      table.insert(notes, root_value + 11) -- Major seventh
    elseif chord.quality == "dim7" then
      table.insert(notes, root_value + 9)  -- Diminished seventh
    else
      table.insert(notes, root_value + 10) -- Minor seventh
    end
  end
  
  -- Handle extensions (simplified)
  if chord.extension == "9" then
    table.insert(notes, root_value + 14) -- 9th
  elseif chord.extension == "11" then
    table.insert(notes, root_value + 17) -- 11th
  elseif chord.extension == "13" then
    table.insert(notes, root_value + 21) -- 13th
  end
  
  -- Handle inversions (simplified)
  if chord.inversion == "1st" and #notes >= 2 then
    notes[1] = notes[1] + 12 -- Move root up an octave
    table.sort(notes)
  elseif chord.inversion == "2nd" and #notes >= 3 then
    notes[1] = notes[1] + 12 -- Move root up an octave
    notes[2] = notes[2] + 12 -- Move third up an octave
    table.sort(notes)
  elseif chord.inversion == "3rd" and #notes >= 4 then
    notes[1] = notes[1] + 12 -- Move root up an octave
    notes[2] = notes[2] + 12 -- Move third up an octave
    notes[3] = notes[3] + 12 -- Move fifth up an octave
    table.sort(notes)
  end
  
  return notes
end
-- Preview the given chord or current progression
function hex_chord_builder.preview(chord_to_preview)
  if not reaper or not reaper.MIDIEditor_GetActive then
    reaper.ShowConsoleMsg("⚠️ MIDI playback not available\n")
    return
  end
  
  -- Stop any existing preview
  if state.preview_playing then
    -- Stop MIDI notes (implementation depends on your MIDI interface)
    state.preview_playing = false
  end
  
  -- Preview a single chord or the full progression
  local notes_to_play = {}
  
  if chord_to_preview then
    -- Single chord preview
    notes_to_play = hex_chord_builder.build_chord_notes(chord_to_preview)
    reaper.ShowConsoleMsg("Previewing chord: " .. chord_to_string(chord_to_preview) .. "\n")
  else
    -- Full progression preview 
    state.preview_playing = true
    reaper.ShowConsoleMsg("Previewing full progression...\n")
    -- Implementation would connect to REAPER's MIDI playback API
  end
  
  -- Actual MIDI playing would be implemented here
end
-- Render a single chord input row
function hex_chord_builder.render_chord_row(ctx, idx, chord)
  local is_selected = (idx == state.selected_chord_idx)
  local style_pushed = false -- Track if we pushed a style

  -- Background color for selected chord
  if is_selected and reaper.ImGui_PushStyleColor then
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBg(), 0x2A4D6AFF)
    style_pushed = true -- Mark that we pushed
  end

  -- Chord position number
  reaper.ImGui_Text(ctx, idx .. ".")
  reaper.ImGui_SameLine(ctx)
  
  -- Root note dropdown
  local root_changed = false
  reaper.ImGui_SetNextItemWidth(ctx, 50) -- Corrected function name
  if reaper.ImGui_BeginCombo(ctx, "##root" .. idx, chord.root) then
    for _, root in ipairs(ROOT_NOTES) do
      local is_selected = (root == chord.root)
      if reaper.ImGui_Selectable(ctx, root, is_selected) then
        chord.root = root
        root_changed = true
      end
      if is_selected then
        reaper.ImGui_SetItemDefaultFocus(ctx)
      end
    end
    reaper.ImGui_EndCombo(ctx)
  end
  reaper.ImGui_SameLine(ctx)
  
  -- Quality dropdown
  local quality_changed = false
  reaper.ImGui_SetNextItemWidth(ctx, 80) -- Corrected function name
  if reaper.ImGui_BeginCombo(ctx, "##quality" .. idx, chord.quality) then
    for _, quality in ipairs(QUALITIES) do      local is_selected = (quality == chord.quality)
      -- Safety check for empty strings
      local display_quality = quality ~= "" and quality or "(empty)"
      if reaper.ImGui_Selectable(ctx, display_quality, is_selected) then
        chord.quality = quality
        quality_changed = true
      end
      if is_selected then
        reaper.ImGui_SetItemDefaultFocus(ctx)
      end
    end
    reaper.ImGui_EndCombo(ctx)
  end
  reaper.ImGui_SameLine(ctx)
  
  -- Extension dropdown
  local ext_changed = false
  reaper.ImGui_SetNextItemWidth(ctx, 60) -- Corrected function name
  if reaper.ImGui_BeginCombo(ctx, "##ext" .. idx, chord.extension or "") then
    for _, ext in ipairs(EXTENSIONS) do
      local is_selected = (ext == chord.extension)
      if reaper.ImGui_Selectable(ctx, ext, is_selected) then
        chord.extension = ext
        ext_changed = true
      end
      if is_selected then
        reaper.ImGui_SetItemDefaultFocus(ctx)
      end
    end
    reaper.ImGui_EndCombo(ctx)
  end
  reaper.ImGui_SameLine(ctx)
  
  -- Inversion dropdown
  local inv_changed = false
  reaper.ImGui_SetNextItemWidth(ctx, 70) -- Corrected function name
  if reaper.ImGui_BeginCombo(ctx, "##inv" .. idx, chord.inversion) then
    for _, inv in ipairs(INVERSIONS) do      local is_selected = (inv == chord.inversion)
      -- Safety check for empty strings
      local display_inv = inv ~= "" and inv or "(empty)"
      if reaper.ImGui_Selectable(ctx, display_inv, is_selected) then
        chord.inversion = inv
        inv_changed = true
      end
      if is_selected then
        reaper.ImGui_SetItemDefaultFocus(ctx)
      end
    end
    reaper.ImGui_EndCombo(ctx)
  end
  reaper.ImGui_SameLine(ctx)
  
  -- Duration input
  reaper.ImGui_SetNextItemWidth(ctx, 50) -- Corrected function name
  local current_duration_val = chord.duration_beats
  local value_changed_flag_duration = false -- Default value
  -- reaper.ImGui_InputInt returns: widget_active (bool), new_value (number), input_str (string), value_changed_flag (bool/number/nil)
  local _, new_duration_from_input = reaper.ImGui_InputInt(ctx, "##duration" .. idx, current_duration_val)
  
  local actual_duration_field_changed = false -- This will be our reliable Lua boolean flag
  if type(value_changed_flag_duration) == "number" then
    actual_duration_field_changed = (value_changed_flag_duration == 1)
  elseif type(value_changed_flag_duration) == "boolean" then
    actual_duration_field_changed = value_changed_flag_duration -- true or false
  end -- if nil or 0 (for numeric), it remains false or becomes false, which is correct
  if actual_duration_field_changed then
    chord.duration_beats = math.max(1, new_duration_from_input) -- Use the new value from input
  end
  reaper.ImGui_SameLine(ctx)
  
  -- Preview button
  if reaper.ImGui_Button(ctx, "▶##" .. idx) then
    hex_chord_builder.preview(chord)
  end
  reaper.ImGui_SameLine(ctx)
  
  -- Delete button
  if reaper.ImGui_Button(ctx, "X##" .. idx) then
    if style_pushed and reaper.ImGui_PopStyleColor then -- Pop if we pushed
        reaper.ImGui_PopStyleColor(ctx)
        style_pushed = false -- Avoid double pop
    end
    table.remove(state.progression, idx)
    if state.selected_chord_idx == idx then
      state.selected_chord_idx = nil
    elseif state.selected_chord_idx and idx and state.selected_chord_idx > idx then -- Added nil check for selected_chord_idx and idx
      state.selected_chord_idx = state.selected_chord_idx - 1
    end
    return true -- Signal that chord was deleted
  end

  -- End style color if pushed
  if style_pushed and reaper.ImGui_PopStyleColor then
    reaper.ImGui_PopStyleColor(ctx)
  end

  -- Selection handling:
  -- root_changed, quality_changed, ext_changed, inv_changed are Lua booleans (true/false).
  -- actual_duration_field_changed is now a Lua boolean (true/false).
  
  local item_is_clicked = reaper.ImGui_IsItemClicked(ctx) -- Assuming this returns a Lua boolean as per docs.
  -- All variables in this condition should now be proper Lua booleans
  if item_is_clicked or root_changed or quality_changed or 
     ext_changed or inv_changed or actual_duration_field_changed then
    state.selected_chord_idx = idx
    return true -- Signal UI change
  end
  
  return false
end
-- Render chord theory suggestions for currently selected chord
function hex_chord_builder.render_chord_suggestions(ctx)
  if not state.selected_chord_idx or not state.progression[state.selected_chord_idx] then
    reaper.ImGui_Text(ctx, "Select a chord to see suggestions")
    return
  end
  
  local chord = state.progression[state.selected_chord_idx]
  local suggestions = hex_chord_builder.generate_theory_suggestions(chord, state.key, state.mode)
  
  -- Display chord symbol
  local chord_symbol = chord_to_string(chord)
  reaper.ImGui_Text(ctx, "Selected: " .. chord_symbol)
  
  -- Display suggestions
  reaper.ImGui_Separator(ctx)
  reaper.ImGui_Text(ctx, "Suggestions:")
  reaper.ImGui_Text(ctx, suggestions)
end
-- Initialize the module
function hex_chord_builder.init(ctx, ui_state_param)
  state.ctx = ctx
  state.ui_state = ui_state_param
  
  -- Create default empty progression if none exists
  if #state.progression == 0 then
    -- Start with I-IV-V in C major    table.insert(state.progression, { root = "C", quality = "maj", extension = "(none)", inversion = "root", duration_beats = 4 })
    table.insert(state.progression, { root = "F", quality = "maj", extension = "(none)", inversion = "root", duration_beats = 4 })
    table.insert(state.progression, { root = "G", quality = "maj", extension = "(none)", inversion = "root", duration_beats = 4 })
    table.insert(state.progression, { root = "C", quality = "maj", extension = "(none)", inversion = "root", duration_beats = 4 })
  end
  
  return true
end
-- Draw the UI
function hex_chord_builder.draw(ctx, ui_state_param)
  state.ui_state = ui_state_param
  
  -- Main header
  -- reaper.ImGui_PushFont(ctx, ui_state_param.fonts.header) -- Bypassed due to global font bypass
  reaper.ImGui_Text(ctx, "Chord Progression Builder")
  -- reaper.ImGui_PopFont(ctx) -- Bypassed
  reaper.ImGui_Text(ctx, "Build chord progressions and send them to the Section Editor")
  
  -- Key and mode selection
  reaper.ImGui_Separator(ctx)
  reaper.ImGui_Text(ctx, "Progression Key:")
  reaper.ImGui_SameLine(ctx)
  
  -- Key dropdown
  reaper.ImGui_SetNextItemWidth(ctx, 70) -- Corrected function name
  if reaper.ImGui_BeginCombo(ctx, "##key", state.key) then
    for _, root in ipairs(ROOT_NOTES) do      local is_selected = (root == state.key)
      -- Safety check for empty strings
      local display_root = root ~= "" and root or "(empty)"
      if reaper.ImGui_Selectable(ctx, display_root, is_selected) then
        state.key = root
      end
      if is_selected then
        reaper.ImGui_SetItemDefaultFocus(ctx)
      end
    end
    reaper.ImGui_EndCombo(ctx)
  end
  
  -- Mode dropdown
  reaper.ImGui_SameLine(ctx)
  reaper.ImGui_SetNextItemWidth(ctx, 120) -- Corrected function name
  if reaper.ImGui_BeginCombo(ctx, "##mode", state.mode) then
    for _, mode in ipairs(MODES) do      local is_selected = (mode == state.mode)
      -- Safety check for empty strings
      local display_mode = mode ~= "" and mode or "(empty)"
      if reaper.ImGui_Selectable(ctx, display_mode, is_selected) then
        state.mode = mode
      end
      if is_selected then
        reaper.ImGui_SetItemDefaultFocus(ctx)
      end
    end
    reaper.ImGui_EndCombo(ctx)
  end
  
  -- Total beats counter
  local total_beats = hex_chord_builder.calculate_total_beats(state.progression)
  local window_width = 800 -- Placeholder for window width
  reaper.ImGui_SameLine(ctx, window_width - 150)
  reaper.ImGui_Text(ctx, "Total: " .. total_beats .. " beats")
  
  -- Chord list header
  reaper.ImGui_Separator(ctx)
  reaper.ImGui_Text(ctx, "#")
  reaper.ImGui_SameLine(ctx, 30)
  reaper.ImGui_Text(ctx, "Root")
  reaper.ImGui_SameLine(ctx, 80)
  reaper.ImGui_Text(ctx, "Quality")
  reaper.ImGui_SameLine(ctx, 160)
  reaper.ImGui_Text(ctx, "Ext")
  reaper.ImGui_SameLine(ctx, 220)
  reaper.ImGui_Text(ctx, "Inv")
  reaper.ImGui_SameLine(ctx, 290)
  reaper.ImGui_Text(ctx, "Beats")
  reaper.ImGui_SameLine(ctx, 340)
  reaper.ImGui_Text(ctx, "Actions")
  -- Chord list
  reaper.ImGui_Separator(ctx)
  if reaper.ImGui_BeginChild() then
    local ui_changed = false
    for i, chord in ipairs(state.progression) do
      ui_changed = hex_chord_builder.render_chord_row(ctx, i, chord) or ui_changed
    end
    reaper.ImGui_EndChild(ctx)
  end
  
  -- Action buttons
  if reaper.ImGui_Button(ctx, "+ Add Chord") then
    local new_chord = clone_chord(state.new_chord)
    table.insert(state.progression, new_chord)
    state.selected_chord_idx = #state.progression
  end
  
  reaper.ImGui_SameLine(ctx)
  if reaper.ImGui_Button(ctx, "Preview Progression") then
    hex_chord_builder.preview() -- Preview full progression
  end
  
  reaper.ImGui_SameLine(ctx)
  if reaper.ImGui_Button(ctx, "Send to Section Editor") then
    local success = hex_chord_builder.send_progression_to_section_editor(state.progression)
    if success then
      reaper.ShowConsoleMsg("✓ Sent progression to Section Editor\n")
    end
  end
  
  reaper.ImGui_SameLine(ctx)
  if reaper.ImGui_Button(ctx, "Reset") then
    state.progression = {}
    state.selected_chord_idx = nil
    hex_chord_builder.init(ctx, state.ui_state) -- Reinitialize with defaults
  end
  -- Theory suggestions panel
  reaper.ImGui_Separator(ctx)
  if reaper.ImGui_BeginChild() then
    hex_chord_builder.render_chord_suggestions(ctx)
    reaper.ImGui_EndChild(ctx)
  end
  
  return true
end
-- Cleanup resources
function hex_chord_builder.shutdown()
  -- Stop any ongoing previews
  if state.preview_playing then
    -- Stop MIDI playback
    state.preview_playing = false
  end
  
  return true
end
return hex_chord_builder
