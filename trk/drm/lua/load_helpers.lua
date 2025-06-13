--[[
Groove MIDI Player for REAPER
This script loads and plays a MIDI file from the Groove MIDI dataset.
]]

-- Get script directory
function get_script_path()
  local info = debug.getinfo(1, "S")
  local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
  return script_path
end

-- Path to the MIDI file
local script_path = get_script_path()
local midi_path = script_path .. "../data/jcrd_library/groove_midi/1_funk-groove1_138_beat_4-4.mid"

-- Normalize path for Windows
midi_path = midi_path:gsub("/", "\\"):gsub("\\\\", "\\")

-- Check if file exists
local function file_exists(name)
   local f = io.open(name, "r")
   if f ~= nil then io.close(f) return true else return false end
end

-- Function to load and play the MIDI file
function load_and_play_midi(file_path)
  if not file_exists(file_path) then
    reaper.ShowMessageBox("MIDI file not found: " .. file_path, "Error", 0)
    return
  end
  
  -- Insert new track
  reaper.InsertTrackAtIndex(0, true)
  local track = reaper.GetTrack(0, 0)
  
  -- Set track name
  reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "Groove MIDI Drum Pattern", true)
  
  -- Create new MIDI item
  local start_time = 0
  local item = reaper.CreateNewMIDIItemInProj(track, start_time, start_time + 30)
  
  -- Get the MIDI take
  local take = reaper.GetActiveTake(item)
  
  -- Import MIDI file
  reaper.BR_ImportMidiTakeFromFile(take, file_path)
  
  -- Set Drum Map Editor as default for this track
  reaper.SetMIDIEditorOption(0, "default_drummap", 1)
  
  -- Open MIDI editor
  reaper.Main_OnCommand(40153, 0) -- Open MIDI editor
  
  -- Play from start position
  reaper.SetEditCurPos(0, true, false)
  reaper.OnPlayButton()
  
  reaper.ShowMessageBox("Loaded MIDI file: " .. file_path, "Groove MIDI Player", 0)
end

-- Main function
function main()
  reaper.PreventUIRefresh(1)
  
  load_and_play_midi(midi_path)
  
  reaper.PreventUIRefresh(-1)
  reaper.UpdateArrange()
end

-- Execute script
main()
