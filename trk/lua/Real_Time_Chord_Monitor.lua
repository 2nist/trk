-- Real_Time_Chord_Monitor.lua
-- Real-time chord detection monitoring with GUI feedback
-- Works with the multi-band detection system

local script_name = "Real-Time Chord Monitor"
local chord_history = {}
local current_chord = {name = "No Input", confidence = 0, type = "unknown"}
local last_update = 0
local update_interval = 0.5 -- Update every 500ms
local max_history = 20

-- GUI Configuration
local gui = {
  window_flags = reaper.ImGui_WindowFlags_NoCollapse() | reaper.ImGui_WindowFlags_AlwaysAutoResize(),
  chord_colors = {
    major = 0x00AA00FF,      -- Green
    minor = 0x0066AAFF,      -- Blue  
    dominant = 0xAA6600FF,   -- Orange
    diminished = 0xAA0000FF, -- Red
    augmented = 0xAA00AAFF,  -- Magenta
    suspended = 0xAAAA00FF,  -- Yellow
    unknown = 0x666666FF     -- Gray
  },
  font_sizes = {
    title = 24,
    chord = 32,
    details = 16,
    history = 14
  }
}

-- Detection configuration - matches Multi_Band_Chord_Detection.lua
local CONFIG = {
  bands = {
    low = {track_name = "Low_Band_Analysis", freq_range = "80-300Hz"},
    mid = {track_name = "Mid_Band_Analysis", freq_range = "300-2000Hz"},  
    high = {track_name = "High_Band_Analysis", freq_range = "2000-8000Hz"}
  },
  detection_methods = {
    reatune = {weight = 0.4, track_suffix = "_ReaTune"},
    reafack = {weight = 0.3, track_suffix = "_ReaRack"},
    keyfinder = {weight = 0.3, track_suffix = "_KeyFinder"}
  },
  confidence_threshold = 0.6
}

-- Initialize ImGui context
local ctx = reaper.ImGui_CreateContext(script_name)

-- Helper function to find track by name
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

-- Get current MIDI notes from a track
function get_current_midi_notes(track)
  if not track then return {} end
  
  local notes = {}
  local num_items = reaper.CountTrackMediaItems(track)
  
  for i = 0, num_items - 1 do
    local item = reaper.GetTrackMediaItem(track, i)
    local take = reaper.GetActiveTake(item)
    
    if take and reaper.TakeIsMIDI(take) then
      -- Get item time info
      local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      local item_length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
      local item_end = item_pos + item_length
      local current_time = reaper.GetPlayPosition()
      
      -- Only analyze items that are currently playing or recently played
      if current_time >= item_pos and current_time <= item_end + 1.0 then
        local item_notes = extract_active_midi_notes(take, current_time - item_pos)
        for _, note in ipairs(item_notes) do
          table.insert(notes, note)
        end
      end
    end
  end
  
  return notes
end

-- Extract currently active MIDI notes from a take at a specific time
function extract_active_midi_notes(take, time_pos)
  local notes = {}
  local _, midi_string = reaper.MIDI_GetAllEvts(take)
  local active_notes = {}
  local current_time = 0
  
  local pos = 1
  while pos < #midi_string do
    local offset, flags, msg, next_pos = string.unpack("i4Bs4", midi_string, pos)
    current_time = current_time + (offset / reaper.TimeMap_GetDividedBpmAtTime(0))
    
    if current_time > time_pos then break end
    
    local status = msg:byte(1) >> 4
    local note = msg:byte(2)
    local velocity = msg:byte(3)
    
    if status == 9 and velocity > 0 then -- Note-on
      active_notes[note] = current_time
    elseif status == 8 or (status == 9 and velocity == 0) then -- Note-off
      active_notes[note] = nil
    end
    
    pos = next_pos
  end
  
  -- Return notes that are still active at the requested time
  for note, start_time in pairs(active_notes) do
    if start_time <= time_pos then
      table.insert(notes, note)
    end
  end
  
  return notes
end

-- Simplified chord detection for real-time use
function detect_chord_simple(midi_notes)
  if #midi_notes == 0 then
    return {name = "No Input", confidence = 0, type = "unknown"}
  end
  
  if #midi_notes == 1 then
    local note_names = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
    local note_name = note_names[(midi_notes[1] % 12) + 1]
    return {name = note_name, confidence = 0.8, type = "note"}
  end
  
  -- Normalize to intervals
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
  
  -- Simple chord templates for real-time detection
  local templates = {
    {pattern = {0, 4, 7}, name = "maj", type = "major"},
    {pattern = {0, 3, 7}, name = "min", type = "minor"},
    {pattern = {0, 4, 7, 10}, name = "7", type = "dominant"},
    {pattern = {0, 4, 7, 11}, name = "maj7", type = "major"},
    {pattern = {0, 3, 7, 10}, name = "min7", type = "minor"},
    {pattern = {0, 3, 6}, name = "dim", type = "diminished"},
    {pattern = {0, 4, 8}, name = "aug", type = "augmented"},
    {pattern = {0, 5, 7}, name = "sus4", type = "suspended"},
    {pattern = {0, 2, 7}, name = "sus2", type = "suspended"}
  }
  
  local best_match = {name = "Unknown", confidence = 0, type = "unknown"}
  
  for _, template in ipairs(templates) do
    local matches = 0
    for _, pattern_note in ipairs(template.pattern) do
      if table_contains(intervals, pattern_note) then
        matches = matches + 1
      end
    end
    
    local confidence = matches / #template.pattern
    if confidence > best_match.confidence and confidence >= 0.7 then
      local note_names = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
      local root_name = note_names[root + 1]
      best_match = {
        name = root_name .. template.name,
        confidence = confidence,
        type = template.type,
        intervals = intervals,
        root = root
      }
    end
  end
  
  return best_match
end

function table_contains(tbl, value)
  for _, v in ipairs(tbl) do
    if v == value then return true end
  end
  return false
end

-- Real-time chord detection
function update_chord_detection()
  local current_time = reaper.time_precise()
  if current_time - last_update < update_interval then
    return
  end
  
  last_update = current_time
  
  -- Collect MIDI notes from all detection tracks
  local all_notes = {}
  local source_count = 0
  
  for band_name, band_config in pairs(CONFIG.bands) do
    for method_name, method_config in pairs(CONFIG.detection_methods) do
      local track_name = band_config.track_name .. method_config.track_suffix
      local track = find_track_by_name(track_name)
      
      if track then
        local notes = get_current_midi_notes(track)
        if #notes > 0 then
          for _, note in ipairs(notes) do
            table.insert(all_notes, note)
          end
          source_count = source_count + 1
        end
      end
    end
  end
  
  -- Detect chord from combined notes
  if #all_notes > 0 then
    local new_chord = detect_chord_simple(all_notes)
    
    -- Update confidence based on source count
    new_chord.confidence = new_chord.confidence * math.min(1.0, source_count / 3)
    new_chord.source_count = source_count
    new_chord.note_count = #all_notes
    
    if new_chord.confidence >= CONFIG.confidence_threshold then
      current_chord = new_chord
      
      -- Add to history
      table.insert(chord_history, 1, {
        time = current_time,
        chord = new_chord.name,
        confidence = new_chord.confidence
      })
      
      -- Limit history size
      while #chord_history > max_history do
        table.remove(chord_history)
      end
    end
  else
    current_chord = {name = "No Input", confidence = 0, type = "unknown", source_count = 0, note_count = 0}
  end
end

-- GUI rendering function
function draw_gui()
  reaper.ImGui_SetNextWindowSize(ctx, 400, 600, reaper.ImGui_Cond_FirstUseEver)
  
  local visible, open = reaper.ImGui_Begin(ctx, script_name, true, gui.window_flags)
  if visible then
    
    -- Title
    reaper.ImGui_TextColored(ctx, 0xFFFFFFFF, "Real-Time Chord Detection")
    
    reaper.ImGui_Separator(ctx)
    
    -- Current chord display
    local chord_color = gui.chord_colors[current_chord.type] or gui.chord_colors.unknown
    
    -- Main chord name
    reaper.ImGui_TextColored(ctx, chord_color, current_chord.name)
    
    -- Confidence and details
    if current_chord.confidence > 0 then
      local confidence_text = string.format("Confidence: %.0f%%", current_chord.confidence * 100)
      reaper.ImGui_TextColored(ctx, 0xCCCCCCFF, confidence_text)
      
      if current_chord.source_count then
        local source_text = string.format("Sources: %d | Notes: %d", 
          current_chord.source_count or 0, current_chord.note_count or 0)
        reaper.ImGui_TextColored(ctx, 0x999999FF, source_text)
      end
    end
    
    reaper.ImGui_Separator(ctx)
    
    -- Control buttons
    if reaper.ImGui_Button(ctx, "Clear History") then
      chord_history = {}
    end
    
    reaper.ImGui_SameLine(ctx)
    if reaper.ImGui_Button(ctx, "Reset Detection") then
      current_chord = {name = "No Input", confidence = 0, type = "unknown"}
    end
    
    reaper.ImGui_Separator(ctx)
    
    -- Settings
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Text(ctx, "Settings:")
    
    local changed, new_interval = reaper.ImGui_SliderDouble(ctx, "Update Rate (s)", update_interval, 0.1, 2.0)
    if changed then
      update_interval = new_interval
    end
    
    local changed2, new_threshold = reaper.ImGui_SliderDouble(ctx, "Confidence Threshold", CONFIG.confidence_threshold, 0.1, 1.0)
    if changed2 then
      CONFIG.confidence_threshold = new_threshold
    end
    
    reaper.ImGui_Separator(ctx)
    
    -- Chord history
    reaper.ImGui_Text(ctx, "Recent Chords:")
    if #chord_history == 0 then
      reaper.ImGui_TextColored(ctx, 0x666666FF, "No chord history")
    else
      for i, entry in ipairs(chord_history) do
        local time_str = string.format("%.1fs ago", reaper.time_precise() - entry.time)
        local chord_str = string.format("%s (%.0f%%)", entry.chord, entry.confidence * 100)
        
        reaper.ImGui_TextColored(ctx, 0xAAAAAAFF, time_str)
        reaper.ImGui_SameLine(ctx)
        reaper.ImGui_TextColored(ctx, 0xFFFFFFFF, chord_str)
      end
    end
    
    -- System status
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Text(ctx, "System Status:")
    local detection_tracks = 0
    local total_tracks = 0
    
    for band_name, band_config in pairs(CONFIG.bands) do
      for method_name, method_config in pairs(CONFIG.detection_methods) do
        total_tracks = total_tracks + 1
        local track_name = band_config.track_name .. method_config.track_suffix
        local track = find_track_by_name(track_name)
        if track then
          detection_tracks = detection_tracks + 1
          local status_text = string.format("✓ %s", track_name)
          reaper.ImGui_TextColored(ctx, 0x00AA00FF, status_text)
        else
          local status_text = string.format("✗ %s (missing)", track_name)
          reaper.ImGui_TextColored(ctx, 0xAA0000FF, status_text)
        end
      end
    end
    
    reaper.ImGui_Separator(ctx)
    local status_summary = string.format("Detection tracks: %d/%d active", detection_tracks, total_tracks)
    local status_color = detection_tracks == total_tracks and 0x00AA00FF or 0xAAAA00FF
    reaper.ImGui_TextColored(ctx, status_color, status_summary)
    
    reaper.ImGui_End(ctx)
  end
  
  if open then
    update_chord_detection()
    reaper.defer(draw_gui)
  else
    reaper.ImGui_DestroyContext(ctx)
  end
end

-- Initialize and start GUI
function main()
  if not reaper.ImGui_CreateContext then
    reaper.ShowMessageBox("This script requires ReaImGui extension", "Error", 0)
    return
  end
  
  -- Verify setup
  local setup_ok = true
  local missing_tracks = {}
  
  for band_name, band_config in pairs(CONFIG.bands) do
    for method_name, method_config in pairs(CONFIG.detection_methods) do
      local track_name = band_config.track_name .. method_config.track_suffix
      if not find_track_by_name(track_name) then
        table.insert(missing_tracks, track_name)
        setup_ok = false
      end
    end
  end
  
  if not setup_ok then
    local msg = "Some detection tracks are missing:\n\n" .. 
                table.concat(missing_tracks, "\n") .. "\n\n" ..
                "Please run Setup_Multi_Band_Detection.lua first."
    reaper.ShowMessageBox(msg, "Setup Required", 0)
    return
  end
  
  draw_gui()
end

-- Run the script
main()
