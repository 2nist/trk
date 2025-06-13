-- Simple_Chord_Detection.lua
-- Fast, low-CPU chord detection for REAPER using a single MIDI or ReaTune track
-- Labels detected chords as regions on the timeline and exports .jcrd compatible data

-- CONFIGURATION
local TRACK_NAME = "Chord Detection" -- Name of the track to analyze (set this to your MIDI or ReaTune output track)
local CONFIDENCE_THRESHOLD = 0.7
local EXPORT_JCRD = true -- Set to true to export .jcrd file
local PROJECT_TITLE = "Chord Detection Export" -- Title for the .jcrd file

-- Chord templates (triads, 7ths, basic extensions) - ordered by complexity (most complex first)
local CHORD_TEMPLATES = {
  {pattern = {0, 4, 7, 11}, name = "maj7", type = "major", quality = "major7", degrees = {1, 3, 5, 7}},
  {pattern = {0, 3, 7, 10}, name = "min7", type = "minor", quality = "minor7", degrees = {1, "b3", 5, "b7"}},
  {pattern = {0, 4, 7, 10}, name = "7", type = "dominant", quality = "dominant7", degrees = {1, 3, 5, "b7"}},
  {pattern = {0, 4, 7}, name = "maj", type = "major", quality = "major", degrees = {1, 3, 5}},
  {pattern = {0, 3, 7}, name = "min", type = "minor", quality = "minor", degrees = {1, "b3", 5}},
  {pattern = {0, 3, 6}, name = "dim", type = "diminished", quality = "diminished", degrees = {1, "b3", "b5"}},
  {pattern = {0, 4, 8}, name = "aug", type = "augmented", quality = "augmented", degrees = {1, 3, "#5"}},
  {pattern = {0, 5, 7}, name = "sus4", type = "suspended", quality = "sus4", degrees = {1, 4, 5}},
  {pattern = {0, 2, 7}, name = "sus2", type = "suspended", quality = "sus2", degrees = {1, 2, 5}}
}

local CHORD_COLORS = {
  major = 0x00FF00,     -- Green
  minor = 0x0000FF,     -- Blue
  dominant = 0xFF8000,  -- Orange
  diminished = 0xFF0000, -- Red
  augmented = 0xFF00FF, -- Magenta
  suspended = 0xFFFF00, -- Yellow
  unknown = 0x808080    -- Gray
}

-- Storage for JCRD export data
local jcrd_data = {
  version = "1.0",
  title = PROJECT_TITLE,
  artist = "",
  key = "C",
  tempo = 120,
  time_signature = "4/4",
  chords = {}
}

-- Helper: Find track by name
function find_track_by_name(name)
  for i = 0, reaper.CountTracks(0) - 1 do
    local track = reaper.GetTrack(0, i)
    local _, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    if track_name == name then
      return track
    end
  end
  return nil
end

-- Extract MIDI notes from all items on a track
function extract_midi_notes_from_track(track)
  local all_notes = {}
  local num_items = reaper.CountTrackMediaItems(track)
  for i = 0, num_items - 1 do
    local item = reaper.GetTrackMediaItem(track, i)
    local take = reaper.GetActiveTake(item)
    if take and reaper.TakeIsMIDI(take) then
      local notes = extract_midi_notes_from_take(take)
      for _, note in ipairs(notes) do
        table.insert(all_notes, note)
      end
    end
  end
  return all_notes
end

-- Extract MIDI notes from a take
function extract_midi_notes_from_take(take)
  local midi_notes = {}
  local _, midi_string = reaper.MIDI_GetAllEvts(take)
  local active_notes = {}
  local pos = 1
  while pos < #midi_string do
    local offset, flags, msg, next_pos = string.unpack("i4Bs4", midi_string, pos)
    local status = msg:byte(1) >> 4
    local note = msg:byte(2)
    local velocity = msg:byte(3)
    if status == 9 and velocity > 0 then -- Note-on
      active_notes[note] = true
    elseif status == 8 or (status == 9 and velocity == 0) then -- Note-off
      active_notes[note] = nil
    end
    pos = next_pos
  end
  for note, _ in pairs(active_notes) do
    table.insert(midi_notes, note)
  end
  return midi_notes
end

-- Normalize notes to intervals
function normalize_to_intervals(midi_notes)
  if #midi_notes == 0 then return {} end
  table.sort(midi_notes)
  local root = midi_notes[1] % 12
  local intervals = {}
  for _, note in ipairs(midi_notes) do
    local interval = (note - midi_notes[1]) % 12
    if not table_contains(intervals, interval) then
      table.insert(intervals, interval)
    end
  end
  table.sort(intervals)
  return intervals, root
end

function table_contains(tbl, value)
  for _, v in ipairs(tbl) do
    if v == value then return true end
  end
  return false
end

-- Chord detection
function detect_chord(midi_notes)
  if #midi_notes < 2 then
    return {
      name = "Unknown", 
      confidence = 0, 
      type = "unknown", 
      quality = "unknown",
      root = nil,
      root_name = "Unknown",
      degrees = {},
      notes = midi_notes
    }
  end
  
  local intervals, root = normalize_to_intervals(midi_notes)
  local note_names = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
  local root_name = note_names[root + 1]
  
  local best_match = {
    name = "Unknown", 
    confidence = 0, 
    type = "unknown",
    quality = "unknown",
    root = root,
    root_name = root_name,
    degrees = {},
    notes = midi_notes
  }
  
  for _, template in ipairs(CHORD_TEMPLATES) do
    local matches = 0
    local total_pattern_notes = #template.pattern
    local total_intervals = #intervals
    
    -- Count matching intervals
    for _, pattern_note in ipairs(template.pattern) do
      if table_contains(intervals, pattern_note) then
        matches = matches + 1
      end
    end
    
    -- Calculate confidence with preference for exact matches
    local pattern_confidence = matches / total_pattern_notes
    local completeness = matches / total_intervals  -- How much of the actual chord is covered
    
    -- Prefer exact matches: if pattern matches exactly and no extra notes, boost confidence
    local is_exact_match = (matches == total_pattern_notes and total_intervals == total_pattern_notes)
    local adjusted_confidence = pattern_confidence
    
    if is_exact_match then
      adjusted_confidence = 1.0  -- Perfect match
    elseif matches == total_pattern_notes then
      adjusted_confidence = pattern_confidence * 0.95  -- Pattern complete but extra notes present
    end
    
    if adjusted_confidence > best_match.confidence and adjusted_confidence >= CONFIDENCE_THRESHOLD then
      best_match = {
        name = root_name .. template.name,
        confidence = adjusted_confidence,
        type = template.type,
        quality = template.quality,
        root = root,
        root_name = root_name,
        degrees = template.degrees,
        notes = midi_notes,
        intervals = intervals
      }
    end
  end
  
  return best_match
end

-- Create region with chord label and color
function create_chord_region(start_time, end_time, chord_result)
  local color = CHORD_COLORS[chord_result.type] or CHORD_COLORS.unknown
  local region_name = chord_result.name
  if chord_result.confidence then
    region_name = string.format("%s (%.0f%%)", chord_result.name, chord_result.confidence * 100)
  end
  reaper.AddProjectMarker2(0, true, start_time, end_time, region_name, -1, color)
end

-- Add chord to JCRD data
function add_to_jcrd_data(start_time, end_time, chord_result)
  if not EXPORT_JCRD then return end
  
  local chord_entry = {
    time = start_time,
    duration = end_time - start_time,
    name = chord_result.name,
    root = chord_result.root_name,
    quality = chord_result.quality,
    confidence = chord_result.confidence,
    degrees = chord_result.degrees,
    notes = chord_result.notes,
    intervals = chord_result.intervals or {}
  }
  
  table.insert(jcrd_data.chords, chord_entry)
end

-- Export JCRD file
function export_jcrd_file()
  if not EXPORT_JCRD or #jcrd_data.chords == 0 then return end
  
  -- Get project path and create filename
  local project_path = reaper.GetProjectPath()
  if project_path == "" then
    project_path = reaper.GetResourcePath() .. "/UserProjects"
  end
  
  local project_name = reaper.GetProjectName(0)
  if project_name == "" then
    project_name = "chord_detection_export"
  else
    -- Remove .RPP extension if present
    project_name = project_name:gsub("%.RPP$", ""):gsub("%.rpp$", "")
  end
  
  local filename = project_path .. "/" .. project_name .. ".jcrd"
  
  -- Get project tempo and time signature
  local tempo = reaper.Master_GetTempo()
  jcrd_data.tempo = tempo
  
  -- Simple JSON serialization
  local function serialize_value(value)
    if type(value) == "string" then
      return '"' .. value:gsub('"', '\\"') .. '"'
    elseif type(value) == "number" then
      return tostring(value)
    elseif type(value) == "boolean" then
      return value and "true" or "false"
    elseif type(value) == "table" then
      if #value > 0 then -- Array
        local items = {}
        for _, v in ipairs(value) do
          table.insert(items, serialize_value(v))
        end
        return "[" .. table.concat(items, ",") .. "]"
      else -- Object
        local items = {}
        for k, v in pairs(value) do
          table.insert(items, '"' .. k .. '":' .. serialize_value(v))
        end
        return "{" .. table.concat(items, ",") .. "}"
      end
    else
      return "null"
    end
  end
  
  local json_content = serialize_value(jcrd_data)
  
  -- Write to file
  local file = io.open(filename, "w")
  if file then
    file:write(json_content)
    file:close()
    reaper.ShowMessageBox("JCRD file exported to:\n" .. filename, "Export Complete", 0)
  else
    reaper.ShowMessageBox("Failed to write JCRD file to:\n" .. filename, "Export Error", 0)
  end
end

-- Main detection function
function run_simple_chord_detection()
  local track = find_track_by_name(TRACK_NAME)
  if not track then
    reaper.ShowMessageBox("Track '" .. TRACK_NAME .. "' not found. Please set the correct track name.", "Error", 0)
    return
  end
  
  local num_items = reaper.CountTrackMediaItems(track)
  if num_items == 0 then
    reaper.ShowMessageBox("No MIDI items found on the selected track.", "Error", 0)
    return
  end
  
  -- Clear previous regions if any
  local num_markers = reaper.CountProjectMarkers(0)
  for i = num_markers - 1, 0, -1 do
    local _, is_region, _, _, name = reaper.EnumProjectMarkers(i)
    if is_region and string.find(name, "%%%)$") then -- Remove regions that end with confidence percentage
      reaper.DeleteProjectMarker(0, i, is_region)
    end
  end
  
  -- Reset JCRD data
  jcrd_data.chords = {}
  jcrd_data.title = PROJECT_TITLE
  
  local detected_count = 0
  
  for i = 0, num_items - 1 do
    local item = reaper.GetTrackMediaItem(track, i)
    local take = reaper.GetActiveTake(item)
    
    if take and reaper.TakeIsMIDI(take) then
      local midi_notes = extract_midi_notes_from_take(take)
      local chord_result = detect_chord(midi_notes)
      
      local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      local item_end = item_start + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
      
      if chord_result.confidence >= CONFIDENCE_THRESHOLD then
        create_chord_region(item_start, item_end, chord_result)
        add_to_jcrd_data(item_start, item_end, chord_result)
        detected_count = detected_count + 1
      end
    end
  end
  
  reaper.UpdateArrange()
  
  -- Export JCRD file if enabled
  if EXPORT_JCRD and detected_count > 0 then
    export_jcrd_file()
  end
  
  reaper.ShowMessageBox(string.format("Detected %d chords with confidence >= %.0f%%", 
                                     detected_count, CONFIDENCE_THRESHOLD * 100), 
                       "Chord Detection Complete", 0)
end

-- Main execution
reaper.Undo_BeginBlock()
run_simple_chord_detection()
reaper.Undo_EndBlock("Simple Chord Detection", -1)
