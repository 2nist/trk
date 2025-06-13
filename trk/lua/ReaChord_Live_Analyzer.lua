--[[
README / Integration Notes

🧠 ReaChord HUD + Deep Tracker (for REAPER)
This Lua script implements a two-layer chord detection and transcription system designed to work inside REAPER using ReaTune and ReaImGui.

===========================
🔁 Dual Layer System:
===========================
1. HUD Display (Always-On)
- Uses ReaTune's 'Detected pitch' param to determine the active note
- Buffers recent pitch data into a simple chord window
- Displays the detected chord in real time as a minimal, resizable, dockable HUD using ReaImGui

2. Deep Tracking Mode (Toggle)
- When activated, begins recording and analyzing buffered pitch data
- Intended for slower, more accurate transcription across time
- Generates a chord log and will eventually export to .jcrd format

===========================
🎛 Features:
===========================
- Live HUD chord display from ReaTune audio pitch
- Toggle: Start/Stop deep tracking session
- Toggle: Start/Stop MIDI chord transcription output to track
- Placeholder for analysis results and .jcrd metadata entry

===========================
🛠 For Agent/Developer Implementation:
===========================
- ⏱ Expand chord vocabulary to support complex voicings, slash chords, dim/aug, etc.
- 🎹 Add root detection and confidence estimation
- 📦 Improve MIDI export: support note durations, tagging, track naming
- 🗃 Implement segment-based analysis and time-aware chord tagging
- ✍️ Add UI for user metadata entry (title, section, key, tempo, etc.)
- 💾 Integrate export to .jcrd format for downstream harmony tooling
- 🔌 Optionally support VST-based audio-to-MIDI as an input source in future upgrades

===========================
🧪 How To Use:
===========================
1. Insert ReaTune FX on the desired audio track and make sure it’s analyzing pitch
2. Run this script in REAPER (Action List)
3. Chord HUD will display and update live
4. Use buttons to toggle tracking (deep buffer) or MIDI output to track
5. When tracking is stopped, a mock chord log appears for review (to be expanded)

--
ReaChord HUD + Deep Tracker (Scaffold)
This script sets up a ReaImGui-based HUD for real-time chord display from ReaTune pitch detection.
It also includes a toggle for deeper background analysis and MIDI output to the chord track.
]]--

local reaper = reaper
local ctx = reaper.ImGui_CreateContext("Chord HUD")
local font = nil
local fontSize = 24
local fontColor = {1.0, 1.0, 1.0, 1.0} -- RGBA
local bgColor = {0.0, 0.0, 0.0, 0.5}

-- State flags
local trackingActive = false
local midiOutActive = false
local chordLog = {} -- Will store detected chord objects {name, root_name, quality, confidence, notes, intervals, degrees, time, duration}
local chordWindow = {} -- Short buffer for HUD display (MIDI notes)
local chordDisplay = ""
local maxBufferSizeShort = 8 -- Max notes for HUD's immediate chord detection
local pitchBuffer = {} -- Longer buffer for deep tracking (raw pitch values or MIDI notes)
local maxPitchBufferDeep = 200 -- Example size for deep tracking buffer

-- Track selection & feedback
local g_target_track_input_num = {1} -- For ImGui_InputInt, 1-indexed
local g_target_track_obj = nil
local g_target_track_name = "None (Select or input #)"
local g_last_raw_pitch_val = nil
local g_last_midi_note = nil
local g_pitch_param_not_found_on_target = false -- New flag

-- User metadata
local projectMetadata = {
    title = "Untitled Project",
    section = "Main Section",
    tempo = 120,
    key = "C",
    timeSig = "4/4"
}
local showMetadataEditor = false

-- Chord Definitions (to be expanded significantly)
local NOTE_NAMES = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
local CHORD_TEMPLATES = {
  {pattern = {0, 4, 7}, name_suffix = "", quality = "major", degrees = {1, 3, 5}},
  {pattern = {0, 3, 7}, name_suffix = "m", quality = "minor", degrees = {1, "b3", 5}},
  {pattern = {0, 4, 7, 11}, name_suffix = "maj7", quality = "major7", degrees = {1, 3, 5, 7}},
  {pattern = {0, 3, 7, 10}, name_suffix = "m7", quality = "minor7", degrees = {1, "b3", 5, "b7"}},
  {pattern = {0, 4, 7, 10}, name_suffix = "7", quality = "dominant7", degrees = {1, 3, 5, "b7"}},
  {pattern = {0, 3, 6}, name_suffix = "dim", quality = "diminished", degrees = {1, "b3", "b5"}},
  {pattern = {0, 4, 8}, name_suffix = "aug", quality = "augmented", degrees = {1, 3, "#5"}},
  {pattern = {0, 5, 7}, name_suffix = "sus4", quality = "sus4", degrees = {1, 4, 5}},
  {pattern = {0, 2, 7}, name_suffix = "sus2", quality = "sus2", degrees = {1, 2, 5}},
  -- More complex chords to be added here
}
local CONFIDENCE_THRESHOLD = 0.6 -- Minimum confidence to consider a chord detected

-- JCRD data structure
local jcrd_data = {
  version = "1.0",
  title = "",
  artist = "", -- Consider adding artist field to metadata
  key = "",
  tempo = 120,
  time_signature = "4/4",
  chords = {}
}

-- Load default font
function LoadFont()
  font = reaper.ImGui_CreateFont("sans-serif", fontSize)
  reaper.ImGui_Attach(ctx, font)
end

-- Poll pitch from ReaTune on selected track
function PollReaTunePitch()
  -- local track = reaper.GetSelectedTrack(0, 0) -- Old way
  local track = g_target_track_obj -- New way: use globally set target track

  if not track then
    reaper.ShowConsoleMsg("ReaChord: No target track set for PollReaTunePitch.\n")
    g_last_raw_pitch_val = nil
    g_pitch_param_not_found_on_target = false -- Reset flag
    return nil
  end
  
  g_pitch_param_not_found_on_target = false -- Reset flag at start of successful poll attempt on a track
  local fxCount = reaper.TrackFX_GetCount(track)
  if fxCount == 0 then
    reaper.ShowConsoleMsg("ReaChord: Target track '" .. g_target_track_name .. "' has no FX.\n")
    g_last_raw_pitch_val = nil
    return nil
  end

  for i = 0, fxCount - 1 do
    local retval, fxName = reaper.TrackFX_GetFXName(track, i, "")
    if fxName and fxName:match("ReaTune") then
      reaper.ShowConsoleMsg("ReaChord: ReaTune found at FX slot " .. i .. " on target track: " .. g_target_track_name .. ". Listing its parameters:\n")
      local pitch_param_idx = -1
      local detected_param_name = ""
      local found_pitch_param = false

      for p_idx = 0, reaper.TrackFX_GetNumParams(track, i) - 1 do
          local _, cur_val, min_val, max_val, mid_val, param_name_ret, _ = reaper.TrackFX_GetParamEx(track, i, p_idx) -- Use GetParamEx for more info
          local current_param_name = reaper.TrackFX_GetParamName(track, i, p_idx, "") -- Get name separately for safety
          reaper.ShowConsoleMsg(string.format("  Param #%d: '%s' (Current: %.3f, Range: %.3f-%.3f)\n", p_idx, current_param_name, cur_val, min_val, max_val))
          
          if current_param_name == "Detected pitch (semitones above C-1)" then
              pitch_param_idx = p_idx
              detected_param_name = current_param_name
              found_pitch_param = true
              break 
          elseif current_param_name == "Pitch" then 
              pitch_param_idx = p_idx
              detected_param_name = current_param_name
              found_pitch_param = true 
              -- Don't break, prefer the longer name if found later
          end
      end

      if found_pitch_param then
        reaper.ShowConsoleMsg("ReaChord: Using pitch parameter '" .. detected_param_name .. "' at index " .. pitch_param_idx .. ".\n")
        local pitch_normalized = reaper.TrackFX_GetParam(track, i, pitch_param_idx)
        g_last_raw_pitch_val = pitch_normalized * 127.0
        return g_last_raw_pitch_val
      else
        reaper.ShowConsoleMsg("ReaChord: Could NOT find a suitable pitch parameter (e.g., 'Detected pitch (semitones above C-1)' or 'Pitch') in this ReaTune instance. See list above.\n")
        g_pitch_param_not_found_on_target = true -- Set flag
      end
    end
  end
  reaper.ShowConsoleMsg("ReaChord: ReaTune not found, or if found, its pitch parameter was not identified on target track: " .. g_target_track_name .. ".\n")
  if not g_pitch_param_not_found_on_target then -- Only set if ReaTune was found but param was not
      -- This case means ReaTune itself wasn't found by name match
      reaper.ShowConsoleMsg("ReaChord: Make sure ReaTune is on the track and its name contains 'ReaTune'.\n")
  end
  g_last_raw_pitch_val = nil
  return nil
end

-- Convert pitch to rounded MIDI note number
function GetMidiNoteFromPitch(pitchValue)
  if not pitchValue then
    g_last_midi_note = nil -- Clear last known note
    return nil
  end
  if pitchValue < 0 or pitchValue > 127 then
    reaper.ShowConsoleMsg("ReaChord: GetMidiNoteFromPitch received out-of-range pitchValue: " .. pitchValue .. "\n")
    g_last_midi_note = nil
    return nil
  end
  local midiNote = math.floor(pitchValue + 0.5)
  -- reaper.ShowConsoleMsg("ReaChord: Converted pitch " .. pitchValue .. " to MIDI note: " .. midiNote .. "\n")
  g_last_midi_note = midiNote -- Store for GUI
  return midiNote
end

-- Add note to rolling buffer for HUD
function AddNoteToHudBuffer(note)
  if not note then return end
  table.insert(chordWindow, note) -- Add to the end
  if #chordWindow > maxBufferSizeShort then
    table.remove(chordWindow, 1) -- Remove from the beginning
  end
end

-- Add note to pitch buffer for deep tracking
function AddNoteToDeepBuffer(note)
  if not note then return end
  if trackingActive then
    table.insert(pitchBuffer, {note = note, time = reaper.GetCursorPosition()}) -- Store with timestamp
    if #pitchBuffer > maxPitchBufferDeep then
      table.remove(pitchBuffer, 1)
    end
  end
end

function table_contains(tbl, value)
  for _, v in ipairs(tbl) do
    if v == value then return true end
  end
  return false
end

function normalize_to_intervals(midi_notes_collection)
  if not midi_notes_collection or #midi_notes_collection == 0 then return {}, nil end
  
  local unique_notes = {}
  for _, note_val in ipairs(midi_notes_collection) do
    if not table_contains(unique_notes, note_val) then
      table.insert(unique_notes, note_val)
    end
  end
  if #unique_notes == 0 then return {}, nil end

  table.sort(unique_notes)
  local root_note_midi = unique_notes[1]
  local root_note_chroma = root_note_midi % 12
  
  local intervals = {}
  for _, note_val in ipairs(unique_notes) do
    local interval = (note_val - root_note_midi) % 12
    if not table_contains(intervals, interval) then
      table.insert(intervals, interval)
    end
  end
  table.sort(intervals)
  return intervals, root_note_chroma, root_note_midi, unique_notes
end

-- Enhanced chord detection
function DetectChord(notes_to_analyze) -- Expects a simple array of MIDI notes
  if not notes_to_analyze or #notes_to_analyze < 1 then -- Allow single note for root display
    return { name = "N.C.", root_name = "?", quality = "none", confidence = 0, notes = {}, intervals = {}, degrees = {} }
  end

  local intervals, root_chroma, root_midi, unique_notes_sorted = normalize_to_intervals(notes_to_analyze)
  
  if not root_chroma then -- Should not happen if notes_to_analyze is not empty
      return { name = "Error", root_name = "?", quality = "error", confidence = 0, notes = {}, intervals = {}, degrees = {} }
  end

  local root_name = NOTE_NAMES[root_chroma + 1]
  local best_match = {
    name = root_name .. "?", -- Default if no template matches
    root_name = root_name,
    quality = "unknown",
    confidence = 0.1, -- Small confidence for just seeing notes
    notes = unique_notes_sorted,
    intervals = intervals,
    degrees = {}
  }

  if #unique_notes_sorted == 1 then -- Single note, display as root
      best_match.name = root_name
      best_match.quality = "single"
      best_match.confidence = 0.5 
      return best_match
  end
  
  if #intervals == 0 and #unique_notes_sorted > 0 then -- Should mean only one unique chroma
     intervals = {0} -- Treat as a single root interval
  end


  for _, template in ipairs(CHORD_TEMPLATES) do
    local matches = 0
    local total_template_notes = #template.pattern
    
    for _, pattern_interval in ipairs(template.pattern) do
      if table_contains(intervals, pattern_interval) then
        matches = matches + 1
      end
    end
    
    local current_confidence = 0
    if total_template_notes > 0 then
        current_confidence = matches / total_template_notes
    end

    -- Penalize for extra notes not in template (simple penalty)
    local extra_notes = #intervals - matches
    if extra_notes > 0 then
        current_confidence = current_confidence - (extra_notes * 0.15) -- Penalty factor
    end
    current_confidence = math.max(0, current_confidence) -- Ensure confidence is not negative

    if current_confidence > best_match.confidence and current_confidence >= CONFIDENCE_THRESHOLD then
      best_match = {
        name = root_name .. template.name_suffix,
        root_name = root_name,
        quality = template.quality,
        confidence = current_confidence,
        notes = unique_notes_sorted,
        intervals = intervals, -- The actual intervals from the input notes
        degrees = template.degrees
      }
    end
  end
  
  return best_match
end


-- Optional: send MIDI chord event to track
function SendChordAsMidi(detected_chord)
  if not midiOutActive or not detected_chord or not detected_chord.notes or #detected_chord.notes == 0 then return end
  
  local selected_track = reaper.GetSelectedTrack(0, 0) -- Get first selected track
  if not selected_track then
    -- Try to find or create a track named "Chord MIDI Output"
    for i = 0, reaper.CountTracks(0) - 1 do
        local tr = reaper.GetTrack(0, i)
        local _, name = reaper.GetSetMediaTrackInfo_String(tr, "P_NAME", "", false)
        if name == "Chord MIDI Output" then
            selected_track = tr
            break
        end
    end
    if not selected_track then
        selected_track = reaper.CreateTrack(0, false) -- Insert new track at the end
        reaper.GetSetMediaTrackInfo_String(selected_track, "P_NAME", "Chord MIDI Output", true)
    end
  end
  
  if not selected_track then return end -- Still no track, give up

  local item_start_time = reaper.GetCursorPosition()
  local item_end_time = item_start_time + reaper.TimeMap_GetMeasureInfo(0, reaper.TimeMap_GetTimeSigAtTime(0, item_start_time)).measure_len -- Duration of one measure
  
  -- Check for existing MIDI item to append to, or create new
  local last_item_idx = reaper.CountTrackMediaItems(selected_track) - 1
  local midi_item
  if last_item_idx >= 0 then
      local temp_item = reaper.GetTrackMediaItem(selected_track, last_item_idx)
      local item_pos = reaper.GetMediaItemInfo_Value(temp_item, "D_POSITION")
      local item_len = reaper.GetMediaItemInfo_Value(temp_item, "D_LENGTH")
      -- If cursor is within a small threshold of the end of the last item, extend it
      if math.abs(item_pos + item_len - item_start_time) < 0.1 then
          -- For simplicity, we'll just create a new item for each chord change for now
          -- Extending items and managing overlaps can get complex.
          -- reaper.SetMediaItemInfo_Value(temp_item, "D_LENGTH", item_start_time + (item_end_time - item_start_time) - item_pos)
          -- midi_item = temp_item
      end
  end

  if not midi_item then
      midi_item = reaper.CreateNewMIDIItemInProj(selected_track, item_start_time, item_end_time, false)
  end

  if not midi_item then return end
  local take = reaper.GetActiveTake(midi_item) -- Use GetActiveTake
  if not take then return end

  -- Clear existing notes in this new/reused item for this segment
  -- reaper.MIDI_DeleteAllEvts(take) -- Be careful with this if reusing items

  local note_start_ppq = 0 -- Start notes at the beginning of the item
  local note_duration_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, item_end_time - item_start_time) - note_start_ppq
  
  for _, note_val in ipairs(detected_chord.notes) do
    reaper.MIDI_InsertNote(take, false, false, note_start_ppq, note_duration_ppq, 0, note_val, 100, false) -- chan=0, vel=100
  end
  reaper.MIDI_Sort(take) -- Sort notes by time, then pitch
  reaper.UpdateArrange()
end

-- Main GUI Loop
function Main()
  reaper.ImGui_PushFont(ctx, font)
  reaper.ImGui_SetNextWindowBgAlpha(ctx, bgColor[4]) -- Linter might flag, usually fine

  local hud_visible, hud_open = reaper.ImGui_Begin(ctx, "Chord Detection HUD", true,
      reaper.ImGui_WindowFlags_NoCollapse() |
      -- reaper.ImGui_WindowFlags_AlwaysAutoResize() | -- Let's remove this for now to allow manual resize
      reaper.ImGui_WindowFlags_NoScrollbar())

  if hud_visible then
    -- Track Selection UI
    reaper.ImGui_Text(ctx, "Target Track:")
    reaper.ImGui_SameLine(ctx, 0)
    local track_num_changed
    track_num_changed, g_target_track_input_num[1] = reaper.ImGui_InputInt(ctx, "##TrackNumInput", g_target_track_input_num[1], 1, 1, reaper.ImGui_InputTextFlags_CharsDecimal())
    reaper.ImGui_SameLine(ctx, 0)
    reaper.ImGui_Text(ctx, "(" .. g_target_track_name .. ")")

    if track_num_changed or g_target_track_obj == nil then
        local track_idx_0_based = g_target_track_input_num[1] - 1
        if track_idx_0_based >= 0 and track_idx_0_based < reaper.CountTracks(0) then
            g_target_track_obj = reaper.GetTrack(0, track_idx_0_based)
            if g_target_track_obj then
                local _, name = reaper.GetSetMediaTrackInfo_String(g_target_track_obj, "P_NAME", "", false)
                g_target_track_name = string.format("%d: %s", g_target_track_input_num[1], name or "Unnamed")
            else
                g_target_track_obj = nil -- Should not happen if CountTracks was correct
                g_target_track_name = "Error getting track"
            end
        else
            g_target_track_obj = nil
            g_target_track_name = "Track # out of range"
        end
        -- If still no valid track object (e.g. on first run or invalid input), try to default to selected track
        if g_target_track_obj == nil then
            local selected_track = reaper.GetSelectedTrack(0,0)
            if selected_track then
                g_target_track_obj = selected_track
                local track_number_1_based = -1
                -- Find the 1-based index of the selected track
                for i=0, reaper.CountTracks(0)-1 do
                    if reaper.GetTrack(0,i) == selected_track then
                        track_number_1_based = i+1
                        break
                    end
                end
                if track_number_1_based ~= -1 then
                    g_target_track_input_num[1] = track_number_1_based
                    local _, name = reaper.GetSetMediaTrackInfo_String(g_target_track_obj, "P_NAME", "", false)
                    g_target_track_name = string.format("%d (Selected): %s", track_number_1_based, name or "Unnamed")
                else
                     g_target_track_name = "Selected track not found by index" -- Should be rare
                end
            else
                g_target_track_name = "None (Select or input #)"
            end
        end
    end
    reaper.ImGui_Separator(ctx)

    -- Polling and Display
    local pitchVal = PollReaTunePitch() -- This will now use g_target_track_obj and update g_last_raw_pitch_val
    local midiNote = GetMidiNoteFromPitch(pitchVal) -- This will update g_last_midi_note

    reaper.ImGui_Text(ctx, string.format("Raw Pitch: %.2f", g_last_raw_pitch_val or -1.0))
    reaper.ImGui_Text(ctx, string.format("MIDI Note: %s", g_last_midi_note or "N/A"))
    reaper.ImGui_Separator(ctx)

    if g_pitch_param_not_found_on_target then
        reaper.ImGui_Text(ctx, "ReaTune found, but pitch param not identified!")
        reaper.ImGui_Text(ctx, "Console shows params for: " .. g_target_track_name)
        reaper.ImGui_Text(ctx, "Ensure it's the correct REAPER ReaTune plugin.")
        reaper.ImGui_Separator(ctx)
    end

    AddNoteToHudBuffer(midiNote)
    AddNoteToDeepBuffer(midiNote)

    local detected_hud_chord = DetectChord(chordWindow)
    chordDisplay = string.format("%s (%.0f%%)", detected_hud_chord.name, detected_hud_chord.confidence * 100)
    
    reaper.ImGui_Text(ctx, "Chord: " .. chordDisplay)
    reaper.ImGui_Separator(ctx)

    if reaper.ImGui_Button(ctx, trackingActive and "Stop Deep Tracking" or "Start Deep Tracking") then
      trackingActive = not trackingActive
      if trackingActive then StartTracking() else StopTracking() end
    end
    reaper.ImGui_SameLine(ctx, 0)
    if reaper.ImGui_Button(ctx, midiOutActive and "Stop MIDI Out" or "Start MIDI Out") then
      midiOutActive = not midiOutActive
      -- If starting MIDI out, and we have a chord, send it immediately
      if midiOutActive and detected_hud_chord and detected_hud_chord.name ~= "N.C." then
         SendChordAsMidi(detected_hud_chord)
      end
    end
    
    if reaper.ImGui_Button(ctx, "Edit Metadata") then
        showMetadataEditor = true
    end
  end
  reaper.ImGui_End(ctx) -- Moved ImGui_End to be called unconditionally after ImGui_Begin
  
  -- Handle MIDI output if active and chord changes
  if midiOutActive then
      local current_detected_chord = DetectChord(chordWindow) -- Re-detect for current state
      -- Basic logic: send MIDI if chord name changes from previous HUD display, or if it's the first send.
      -- This needs a bit more robust state to track last sent chord.
      -- For now, let's assume SendChordAsMidi is called when MIDI out is toggled on,
      -- and potentially on significant chord changes later.
      -- A more robust way: in AddNoteToHudBuffer, if midiOutActive and DetectChord result changes significantly, call SendChordAsMidi.
      -- For now, it's mainly manual via the toggle or if we add periodic sending.
  end


  if showMetadataEditor then
    DrawMetadataEditor()
  end

  reaper.ImGui_PopFont(ctx)

  if hud_open then
    reaper.defer(Main)
  else
    reaper.ImGui_DestroyContext(ctx)
    -- reaper.ImGui_DestroyFont(font) -- Assuming font is managed by context or needs explicit destroy if not
  end
end

function DrawMetadataEditor()
    local meta_visible, meta_open = reaper.ImGui_Begin(ctx, "Project Metadata", showMetadataEditor, reaper.ImGui_WindowFlags_AlwaysAutoResize())
    if meta_visible then
        local changed
        changed, projectMetadata.title = reaper.ImGui_InputText(ctx, "Title", projectMetadata.title, 1024)
        changed, projectMetadata.section = reaper.ImGui_InputText(ctx, "Section", projectMetadata.section, 1024)
        changed, projectMetadata.key = reaper.ImGui_InputText(ctx, "Key", projectMetadata.key, 128)
        
        local tempo_val = {projectMetadata.tempo}
        if reaper.ImGui_InputInt(ctx, "Tempo", tempo_val, 1, 10) then
            projectMetadata.tempo = tempo_val[1]
        end

        local ts_val = {projectMetadata.timeSig}
        if reaper.ImGui_InputText(ctx, "Time Signature", ts_val[1], 128) then -- Using InputText for timeSig like "4/4"
             projectMetadata.timeSig = ts_val[1] -- ImGui_InputText for string doesn't return multiple values like number inputs
        end
        -- Need to get the string value correctly for ImGui_InputText
        -- For string input with ImGui, it's a bit more direct:
        -- local new_title, enter_pressed = reaper.ImGui_InputText(ctx, "Title", projectMetadata.title)
        -- if new_title ~= projectMetadata.title then projectMetadata.title = new_title end
        -- This part needs to be careful with how ImGui handles string returns in REAPER's API.
        -- The scaffold's original ImGui_InputText usage for strings is likely correct for REAPER's wrapper.

        if reaper.ImGui_Button(ctx, "Save Metadata") then
            showMetadataEditor = false -- Close editor
            -- Optionally, save to project extstate or a file here if needed persistently beyond script run
        end
        reaper.ImGui_SameLine(ctx,0)
        if reaper.ImGui_Button(ctx, "Cancel") then
            showMetadataEditor = false -- Close editor, changes are already live in the table
        end
    end
    reaper.ImGui_End(ctx)
    if not meta_open then showMetadataEditor = false end -- If user closes window via 'X'
end


-- Background tracking session setup
function StartTracking()
  pitchBuffer = {} -- Clear buffer for new session
  chordLog = {}    -- Clear previous log
  reaper.ShowConsoleMsg("Deep tracking started.\n")
end

function StopTracking()
  reaper.ShowConsoleMsg("Deep tracking stopped. Analyzing buffer...\n")
  AnalyzeDeepBuffer()
  -- ShowChordLogDialog() -- This will be called after analysis populates chordLog
end

-- Basic analysis of the deep buffer
function AnalyzeDeepBuffer()
    chordLog = {} -- Reset for new analysis
    if #pitchBuffer == 0 then
        reaper.ShowMessageBox("Pitch buffer is empty. No analysis performed.", "Info", 0)
        ShowChordLogDialog() -- Still show dialog to allow saving metadata even if no chords
        return
    end

    -- Simple segmentation: new chord every X notes or Y seconds (placeholder logic)
    -- For a more robust approach, detect stable pitch segments, then chords.
    -- Current simple approach: take chunks of notes from pitchBuffer.
    local segment_size = maxBufferSizeShort * 2 -- How many notes to consider for one chord in deep analysis
    local current_segment_notes = {}
    local segment_start_time = pitchBuffer[1].time

    for i, data_point in ipairs(pitchBuffer) do
        table.insert(current_segment_notes, data_point.note)
        
        if #current_segment_notes >= segment_size or i == #pitchBuffer then
            if #current_segment_notes > 0 then
                local detected_segment_chord = DetectChord(current_segment_notes)
                if detected_segment_chord and detected_segment_chord.confidence >= CONFIDENCE_THRESHOLD then
                    local chord_entry = {
                        name = detected_segment_chord.name,
                        root_name = detected_segment_chord.root_name,
                        quality = detected_segment_chord.quality,
                        confidence = detected_segment_chord.confidence,
                        notes = detected_segment_chord.notes,
                        intervals = detected_segment_chord.intervals,
                        degrees = detected_segment_chord.degrees,
                        time = segment_start_time,
                        duration = data_point.time - segment_start_time
                    }
                    if chord_entry.duration <= 0 and i > 1 then -- If last point, use previous duration logic
                        chord_entry.duration = data_point.time - pitchBuffer[i-1].time
                    elseif chord_entry.duration <= 0 then
                         chord_entry.duration = 1.0 -- Default duration if only one point
                    end
                    table.insert(chordLog, chord_entry)
                end
            end
            current_segment_notes = {} -- Reset for next segment
            if i < #pitchBuffer then
                segment_start_time = pitchBuffer[i+1].time
            end
        end
    end
    reaper.ShowConsoleMsg("Analysis complete. " .. #chordLog .. " chords logged.\n")
    ShowChordLogDialog()
end


function ShowChordLogDialog()
  local log_display = {}
  for i, entry in ipairs(chordLog) do
    table.insert(log_display, string.format("Time: %.2fs, Chord: %s (%.0f%%), Dur: %.2fs", entry.time, entry.name, entry.confidence*100, entry.duration))
  end
  
  local message = "No chords detected or buffer empty."
  if #log_display > 0 then
      message = "Chord Log:\n" .. table.concat(log_display, "\n")
  end

  reaper.ShowMessageBox(message, "Deep Analysis Result", 0) -- Changed to info box (1 to 0)
  
  local ret = reaper.ShowMessageBox("Save chord session to JCRD file?", "Save Chord Session", 4) -- Yes/No
  if ret == 6 then -- Yes
    if not projectMetadata.title or projectMetadata.title == "" then
        reaper.ShowMessageBox("Project title is empty. Please set it via 'Edit Metadata' before saving.", "Metadata Required", 0)
        showMetadataEditor = true -- Prompt user to fill it
    else
        PrepareAndExportJCRD()
    end
  else -- No or Cancel
    -- pitchBuffer = {} -- Optionally clear pitch buffer after analysis display
    -- chordLog = {} -- Already cleared at start of StartTracking/AnalyzeDeepBuffer
  end
end

function PrepareAndExportJCRD()
    jcrd_data.title = projectMetadata.title
    jcrd_data.artist = "" -- Add to metadata UI if desired
    jcrd_data.key = projectMetadata.key
    jcrd_data.tempo = projectMetadata.tempo
    jcrd_data.time_signature = projectMetadata.timeSig
    jcrd_data.chords = {} -- Clear previous export data

    for _, logged_chord in ipairs(chordLog) do
        table.insert(jcrd_data.chords, {
            time = logged_chord.time,
            duration = logged_chord.duration,
            name = logged_chord.name,
            root = logged_chord.root_name,
            quality = logged_chord.quality,
            confidence = logged_chord.confidence,
            degrees = logged_chord.degrees,
            notes = logged_chord.notes,
            intervals = logged_chord.intervals
        })
    end

    if #jcrd_data.chords == 0 then
        reaper.ShowMessageBox("No chords were logged to export.", "JCRD Export", 0)
        return
    end
    ExportJCRDFile()
end

-- Helper for JSON serialization (basic)
function serialize_value_jcrd(value)
    local t = type(value)
    if t == "string" then
        -- Corrected gsub for escaping quotes and backslashes
        local escaped_value = value:gsub("\\", "\\\\"):gsub("\"", "\\\""):gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("\t", "\\t")
        return '"' .. escaped_value .. '"'
    elseif t == "number" then
        if value ~= value then return '"NaN"' end -- Handle NaN
        if value == math.huge then return '"Infinity"' end -- Handle Infinity
        if value == -math.huge then return '"-Infinity"' end -- Handle -Infinity
        return string.format("%.4f", value) -- Format numbers nicely
    elseif t == "boolean" then
        return tostring(value)
    elseif t == "table" then
        local s = {}
        local is_array = true
        local n = 0
        for k, _ in pairs(value) do
            n = n + 1
            if type(k) ~= "number" or k < 1 or k > n or math.floor(k) ~= k then 
                is_array = false 
                break 
            end
        end
        if n == 0 then is_array = true end

        if is_array then -- Array (handles empty array too)
            for i = 1, #value do
                table.insert(s, serialize_value_jcrd(value[i]))
            end
            return "[" .. table.concat(s, ",") .. "]"
        else -- Object
            for k, v in pairs(value) do
                table.insert(s, serialize_value_jcrd(tostring(k)) .. ":" .. serialize_value_jcrd(v))
            end
            return "{" .. table.concat(s, ",") .. "}"
        end
    elseif t == "nil" then
        return "null"
    else
        return '"' .. tostring(value) .. '"' -- Fallback for other types, treat as string
    end
end

function ExportJCRDFile()
  if not jcrd_data or (#jcrd_data.chords == 0 and not jcrd_data.title) then -- Allow export even with no chords if metadata exists
    reaper.ShowMessageBox("No chord data or metadata to export.", "JCRD Export Error", 0)
    return
  end

  local project_path = reaper.GetProjectPath()
  if project_path == "" then
    project_path = reaper.GetResourcePath() .. "/UserPlugins" 
  end
  
  local filename_base = jcrd_data.title:gsub("[^%w%s-_%.]", ""):gsub("%s+", "_") -- Allow period in filename
  if filename_base == "" then filename_base = "ReaChord_Export" end
  local filename = project_path .. "/" .. filename_base .. ".jcrd"

  -- Use a more direct way to build the JSON string to avoid issues with serialize_value_jcrd at the top level
  local parts = {}
  table.insert(parts, "{")

  local first_entry = true
  for key, val in pairs(jcrd_data) do
    if not first_entry then 
      table.insert(parts, ",") 
    end
    table.insert(parts, "\n  " .. serialize_value_jcrd(key) .. ": " .. serialize_value_jcrd(val))
    first_entry = false
  end
  table.insert(parts, "\n}")
  local json_content = table.concat(parts, "")
  
  local file = io.open(filename, "w")
  if file then
    file:write(json_content)
    file:close()
    reaper.ShowMessageBox("JCRD file exported to:\n" .. filename, "JCRD Export Complete", 0)
  else
    reaper.ShowMessageBox("Failed to write JCRD file to:\n" .. filename, "JCRD Export Error", 0)
  end
end


-- Initialization
LoadFont()
reaper.defer(Main)

reaper.atexit(function()
    if ctx then
        -- reaper.ImGui_DestroyFont(font) -- If font needs explicit destruction
        reaper.ImGui_DestroyContext(ctx)
        ctx = nil
        font = nil
    end
    reaper.ShowConsoleMsg("ReaChord HUD script exited.\n")
end)
