-- NOTE: ImGui argument errors are handled by the enhanced virtual environment mock. Static analysis errors for ImGui calls can be ignored in this environment.
-- section_editor.lua
-- JCRD Section and chord editing interface
-- Phase 2 - Songbase UI Module
local section_editor = {}
-- Load dependencies
local success, json = pcall(function() return require("utils.json") end)
if not success then
  json = {decode = function() return {} end, encode = function() return "{}" end}
  reaper.ShowConsoleMsg("Error loading JSON module: " .. tostring(json) .. "\n")
end
local success, file_ops = pcall(function() return require("utils.file_operations") end)
if not success then
  file_ops = {}
  reaper.ShowConsoleMsg("Error loading file_operations module: " .. tostring(file_ops) .. "\n")
end
-- Module state
local state = {
  ctx = nil,
  song = nil,
  song_path = nil,
  is_modified = false,
  selected_section = nil,
  selected_chord = nil,
  error = nil,
  loading = false,
  section_selection = {}, -- For tracking which sections are selected for combining
  combining_mode = false  -- Flag to indicate when we're in section combining mode
}
-- Chord editing helpers
local chord_functions = {
  -- Parse a chord string to its components
  parse_chord = function(chord_str)
    -- Basic implementation - would need enhancing for real use
    local root = chord_str:match("^([A-G][#b]?)")
    local quality = chord_str:match("^[A-G][#b]?(.+)")
    
    return {
      root = root or "",
      quality = quality or "",
      full = chord_str
    }
  end,
  
  -- Format chord components to a chord string
  format_chord = function(root, quality)
    return root .. quality
  end,
  
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
      "9", -- Dominant 9th
      "maj9", -- Major 9th
      "m9", -- Minor 9th
      "dim7", -- Diminished 7th
      "m7b5", -- Half-diminished
      "7sus4", -- Dominant 7th suspended 4th
      "add9", -- Added 9th
      "madd9", -- Minor added 9th
    }
  end
}
-- Load a song from file
local function load_song(path)
  state.loading = true
  state.error = nil
  
  if not path or not file_ops.file_exists or not file_ops.file_exists(path) then
    state.error = "Invalid file path"
    state.loading = false
    return false
  end
  
  local content = file_ops.read_file and file_ops.read_file(path) or nil
  if not content then
    state.error = "Could not read file"
    state.loading = false
    return false
  end
  
  local success, data = pcall(function() return json.decode(content) end)
  if not success or not data then
    state.error = "Invalid JSON format"
    state.loading = false
    return false
  end
    state.song = data
  state.song_path = path
  state.is_modified = false
  state.selected_section = nil
  state.selected_chord = nil
  state.section_selection = {}
  state.combining_mode = false
  state.loading = false
  
  return true
end
-- Test helper function (only for test scripts)
function section_editor.test_load_song(song_data)
  if not song_data then
    state.error = "No song data provided for testing"
    return false
  end
  
  state.song = song_data
  state.song_path = "test_song.jcrd"
  state.is_modified = false
  state.selected_section = 1
  state.selected_chord = nil
  state.section_selection = {}
  state.combining_mode = false
  state.loading = false
  
  return true
end
-- Save a song to file
local function save_song()
  if not state.song or not state.song_path then
    state.error = "No song to save"
    return false
  end
  
  local content = json.encode(state.song)
  if not content then
    state.error = "Failed to encode JSON"
    return false
  end
  
  local success = file_ops.write_file and file_ops.write_file(state.song_path, content) or false
  if not success then
    state.error = "Failed to write file"
    return false
  end
  
  state.is_modified = false
  return true
end
-- Combine multiple selected sections into a single section
local function combine_selected_sections()
  if not state.song or not state.song.sections then
    state.error = "No sections available to combine"
    return false
  end
  
  -- Get the indices of selected sections in order
  local selected_indices = {}
  for i, selected in pairs(state.section_selection) do
    if selected and state.song.sections[i] then
      table.insert(selected_indices, i)
    end
  end
  
  -- Sort indices in ascending order
  table.sort(selected_indices)
  
  if #selected_indices < 2 then
    state.error = "Select at least two sections to combine"
    return false
  end
  
  -- Create the new combined section
  local combined_section = {
    name = "Combined Section",
    chords = {},
    beats_per_chord = state.song.sections[selected_indices[1]].beats_per_chord or 4
  }
  
  -- Build the new name by combining selected section names
  local combined_names = {}
  for _, idx in ipairs(selected_indices) do
    local section = state.song.sections[idx]
    if section.name and section.name ~= "" then
      table.insert(combined_names, section.name)
    end
  end
  
  if #combined_names > 0 then
    combined_section.name = table.concat(combined_names, " + ")
    -- Trim if too long
    if #combined_section.name > 64 then
      combined_section.name = string.sub(combined_section.name, 1, 61) .. "..."
    end
  end
  
  -- Combine chords from all selected sections
  for _, idx in ipairs(selected_indices) do
    local section = state.song.sections[idx]
    if section.chords and #section.chords > 0 then
      -- Add section name as comment if combining more than one section
      if #selected_indices > 1 then
        -- Insert section name as separator if not the first section
        if #combined_section.chords > 0 then
          table.insert(combined_section.chords, "-- " .. (section.name or ("Section " .. idx)))
        end
      end
      
      -- Add all chords from this section
      for _, chord in ipairs(section.chords) do
        table.insert(combined_section.chords, chord)
      end
    end
  end
  
  -- Insert the new combined section
  table.insert(state.song.sections, combined_section)
  
  -- Remove the original sections in reverse order to avoid index shifts
  table.sort(selected_indices, function(a, b) return a > b end)
  for _, idx in ipairs(selected_indices) do
    table.remove(state.song.sections, idx)
  end
    -- Select the new combined section
  state.selected_section = #state.song.sections
  state.selected_chord = nil
  state.is_modified = true
  
  -- Clear section selection
  state.section_selection = {}
  
  return true
end
-- Initialize module
function section_editor.init(ctx, ui_state)
  state.ctx = ctx
  return true
end
-- Draw section list
local function draw_sections(ctx)
  if not state.song or not state.song.sections then
    reaper.ImGui_Text(ctx, "No sections available")
    return
  end
  
  -- Section combining mode toggle
  if reaper.ImGui_Button(ctx, state.combining_mode and "Cancel Combining" or "Combine Sections") then
    state.combining_mode = not state.combining_mode
    -- Clear selection when toggling mode
    if state.combining_mode then
      state.section_selection = {}
    end
  end
  
  -- Combine button (only active when in combining mode and at least 2 sections selected)
  if state.combining_mode then
    reaper.ImGui_SameLine(ctx)
    local selected_count = 0
    for _, selected in pairs(state.section_selection) do
      if selected then selected_count = selected_count + 1 end
    end
    
    local can_combine = selected_count >= 2
    if not can_combine then
      reaper.ImGui_BeginDisabled(ctx)
    end
    
    if reaper.ImGui_Button(ctx, "Confirm Combine") and can_combine then
      combine_selected_sections()
      state.combining_mode = false -- Exit combining mode after combining
    end
    
    if not can_combine then
      reaper.ImGui_EndDisabled(ctx)
    end
    
    reaper.ImGui_Text(ctx, "Select at least 2 sections to combine (" .. selected_count .. " selected)")
    reaper.ImGui_Separator(ctx)
  end
  
  for i, section in ipairs(state.song.sections) do
    local is_selected = state.selected_section == i
    local name = section.name or ("Section " .. i)
    local length = #(section.chords or {})
    local label = name .. " (" .. length .. " chords)##" .. i
    
    if state.combining_mode then
      -- In combining mode, show checkboxes for each section
      local selected = state.section_selection[i] or false
      local selection_changed
      selection_changed, selected = reaper.ImGui_Checkbox(ctx, label, selected)
      if selection_changed then
        state.section_selection[i] = selected
      end
    else
      -- Normal selection mode
      if reaper.ImGui_Selectable(ctx, label, is_selected) then
        state.selected_section = i
        state.selected_chord = nil
      end
    end
    
    -- Drag reordering (placeholder)
    if reaper.ImGui_IsItemActive(ctx) and reaper.ImGui_IsMouseDragging(ctx, 0) then
      -- Not implemented yet
    end
  end
  
  -- Add section button (disabled during combining mode)
  if not state.combining_mode then
    if reaper.ImGui_Button(ctx, "Add Section") then
      if not state.song.sections then
        state.song.sections = {}
      end
      
      table.insert(state.song.sections, {
        name = "New Section",
        chords = {},
        beats_per_chord = 4
      })
      
      state.selected_section = #state.song.sections
      state.is_modified = true
    end
  end
end
-- Draw chord list for the selected section
local function draw_chords(ctx)
  if not state.song or not state.song.sections or not state.selected_section or
     not state.song.sections[state.selected_section] then
    reaper.ImGui_Text(ctx, "Select a section to edit chords")
    return
  end
  
  local section = state.song.sections[state.selected_section]
  
  -- Section properties
  local name_changed
  name_changed, section.name = reaper.ImGui_InputText(ctx, "Section Name", section.name or "", 64)
  if name_changed then
    state.is_modified = true
  end
  
  -- Beats per chord
  local bpc_changed
  bpc_changed, section.beats_per_chord = reaper.ImGui_InputInt(ctx, "Beats per Chord", section.beats_per_chord or 4, 1)
  if bpc_changed then
    section.beats_per_chord = math.max(1, section.beats_per_chord)
    state.is_modified = true
  end
  
  reaper.ImGui_Separator(ctx)
  
  -- Chord list
  reaper.ImGui_Text(ctx, "Chords:")
  
  if not section.chords or #section.chords == 0 then
    reaper.ImGui_Text(ctx, "No chords in this section")
  else
    for i, chord in ipairs(section.chords) do
      local is_selected = state.selected_chord == i
      local chord_text = chord or "N.C."
      
      if reaper.ImGui_Selectable(ctx, i .. ": " .. chord_text, is_selected) then
        state.selected_chord = i
      end
      
      -- Drag reordering (placeholder)
      if reaper.ImGui_IsItemActive(ctx) and reaper.ImGui_IsMouseDragging(ctx, 0) then
        -- Not implemented yet
      end
    end
  end
  
  -- Add chord button
  if reaper.ImGui_Button(ctx, "Add Chord") then
    if not section.chords then
      section.chords = {}
    end
    
    table.insert(section.chords, "C")
    state.selected_chord = #section.chords
    state.is_modified = true
  end
end
-- Draw chord editor
local function draw_chord_editor(ctx)
  if not state.song or not state.song.sections or not state.selected_section or
     not state.selected_chord or not state.song.sections[state.selected_section] or
     not state.song.sections[state.selected_section].chords or
     not state.song.sections[state.selected_section].chords[state.selected_chord] then
    reaper.ImGui_Text(ctx, "Select a chord to edit")
    return
  end
  
  local section = state.song.sections[state.selected_section]
  local chord = section.chords[state.selected_chord]
  local chord_parts = chord_functions.parse_chord(chord)
  
  reaper.ImGui_Text(ctx, "Editing Chord " .. state.selected_chord .. " in " .. section.name)
  reaper.ImGui_Separator(ctx)
  
  -- Direct chord text editing
  local chord_changed
  chord_changed, chord = reaper.ImGui_InputText(ctx, "Chord", chord, 16)
  if chord_changed then
    section.chords[state.selected_chord] = chord
    state.is_modified = true
  end
  
  reaper.ImGui_Separator(ctx)
  
  -- Root note selection
  local roots = chord_functions.get_chord_roots()
  local current_root = chord_parts.root or "C"
  local current_root_idx = 1
  
  for i, root in ipairs(roots) do
    if root == current_root then
      current_root_idx = i
      break
    end
  end
    local root_changed
  -- Ensure the string is properly null-terminated
  local root_strings = table.concat(roots, '\0') .. '\0'
  root_changed, current_root_idx = reaper.ImGui_Combo(ctx, "Root", current_root_idx, root_strings, #roots)
  
  -- Chord quality selection
  local qualities = chord_functions.get_chord_qualities()
  local current_quality = chord_parts.quality or ""
  local current_quality_idx = 1
  
  for i, quality in ipairs(qualities) do
    if quality == current_quality then
      current_quality_idx = i
      break
    end
  end
  
  local quality_changed
  -- Ensure the string is properly null-terminated
  local quality_strings = table.concat(qualities, '\0') .. '\0'
  quality_changed, current_quality_idx = reaper.ImGui_Combo(ctx, "Quality", current_quality_idx, quality_strings, #qualities)
  
  -- Update chord if root or quality changed
  if root_changed or quality_changed then
    local new_root = roots[current_root_idx]
    local new_quality = qualities[current_quality_idx]
    section.chords[state.selected_chord] = chord_functions.format_chord(new_root, new_quality)
    state.is_modified = true
  end
  
  reaper.ImGui_Separator(ctx)
  
  -- Delete chord button
  local delete_pressed = reaper.ImGui_Button(ctx, "Delete Chord")
  if delete_pressed then
    table.remove(section.chords, state.selected_chord)
    if #section.chords == 0 or state.selected_chord > #section.chords then
      state.selected_chord = nil
    end
    state.is_modified = true
  end
end
-- Draw the module UI
function section_editor.draw(ctx, ui_state)
  -- Main title
  reaper.ImGui_PushFont(ctx, ui_state.fonts.header)
  reaper.ImGui_Text(ctx, "Section Editor")
  reaper.ImGui_PopFont(ctx)
  
  -- File operations
  if reaper.ImGui_Button(ctx, "Load Song") then
    local retval, file_path = reaper.GetUserFileNameForRead("", "Select JCRD File", "*.jcrd;*.json")
    if retval then
      load_song(file_path)
    end
  end
  
  reaper.ImGui_SameLine(ctx)
  if reaper.ImGui_Button(ctx, "Save", 80) and state.song_path then
    save_song()
  end
  
  reaper.ImGui_SameLine(ctx)
  if reaper.ImGui_Button(ctx, "Save As", 80) then
    local retval, file_path = reaper.GetUserFileNameForWrite("", "Save JCRD File", "*.jcrd")
    if retval then
      state.song_path = file_path
      save_song()
    end
  end
  
  -- Display song info
  if state.song then
    reaper.ImGui_SameLine(ctx)
    reaper.ImGui_Text(ctx, "Editing: " .. (state.song.title or "Untitled") .. 
                           " by " .. (state.song.artist or "Unknown"))
    
    if state.is_modified then
      reaper.ImGui_SameLine(ctx)
      reaper.ImGui_Text(ctx, "(Modified)")
    end
  end
  
  -- Show loading state
  if state.loading then
    reaper.ImGui_SameLine(ctx)
    reaper.ImGui_Text(ctx, "Loading...")
  end
  
  -- Show error if any
  if state.error then
    local style_pushed = false
    if reaper.ImGui_PushStyleColor then
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), 0xFF5555FF)
      style_pushed = true
    end
    reaper.ImGui_Text(ctx, "Error: " .. state.error)
    if style_pushed then
      reaper.ImGui_PopStyleColor(ctx)
    end
  end
  
  reaper.ImGui_Separator(ctx)
  
  if not state.song then
    reaper.ImGui_Text(ctx, "Please load a song to begin editing")
    return true
  end
  
  -- Split view for sections, chords, and chord editor
  local avail_width = reaper.ImGui_GetContentRegionAvail(ctx)
  local section_width = avail_width * 0.25
  local chord_width = avail_width * 0.35
    -- Sections panel
  if reaper.ImGui_BeginChild(ctx, "sections_panel", section_width, 0, 1) then
    draw_sections(ctx)
    reaper.ImGui_EndChild(ctx)
  end
    -- Chords panel
  reaper.ImGui_SameLine(ctx)
  if reaper.ImGui_BeginChild(ctx, "chords_panel", chord_width, 0, 1) then
    draw_chords(ctx)
    reaper.ImGui_EndChild(ctx)
  end
    -- Chord editor panel
  reaper.ImGui_SameLine(ctx)
  if reaper.ImGui_BeginChild(ctx, "chord_editor", 0, 0, 1) then
    draw_chord_editor(ctx)
    reaper.ImGui_EndChild(ctx)
  end
  
  return true
end
-- Shutdown function
function section_editor.shutdown()
  -- Prompt to save if modified
  if state.is_modified then
    local result = reaper.ShowMessageBox(
      "You have unsaved changes. Save before closing?",
      "Save Changes?",
      3 -- Yes/No/Cancel
    )
    
    if result == 6 then -- Yes
      save_song()
    elseif result == 2 then -- Cancel
      return false
    end
  end
  
  return true
end
-- Receive chord progression from another module (like hex_chord_builder)
function section_editor.receive_chord_progression(chords)
  -- Ensure there's a current section to add chords to
  if not state.song or not state.song.sections or not state.selected_section or
     not state.song.sections[state.selected_section] then
    reaper.ShowConsoleMsg("⚠️ No section selected to receive chord progression\n")
    return false
  end
  
  local section = state.song.sections[state.selected_section]
  
  -- Ensure the section has a chords array
  if not section.chords then
    section.chords = {}
  end
  
  -- Process and add each chord
  for _, chord in ipairs(chords) do
    -- Convert from JCRD chord format to simple chord symbol
    local chord_symbol = chord.symbol or chord.root .. (chord.quality or "")
    
    -- Add the chord to the section
    table.insert(section.chords, chord_symbol)
    
    -- Mark song as modified
    state.is_modified = true
  end
  
  reaper.ShowConsoleMsg("✓ Added " .. #chords .. " chords to section '" .. 
                       (section.name or "Unnamed") .. "'\n")
  
  return true
end
return section_editor
