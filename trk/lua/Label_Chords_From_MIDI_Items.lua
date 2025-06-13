-- Label_Chords_From_MIDI_Items.lua
-- Detects chords from selected MIDI items and labels them as regions on the REAPER timeline

-- Function to detect chord from MIDI notes
function detect_chord(midi_notes)
  -- Placeholder: Implement chord detection logic here
  -- Example: Return "Cmaj7" for a C major 7th chord
  return "Cmaj7"
end

-- Function to label chords as regions
function label_chords_from_midi_items()
  local num_items = reaper.CountSelectedMediaItems(0)
  if num_items == 0 then
    reaper.ShowMessageBox("No MIDI items selected.", "Error", 0)
    return
  end

  for i = 0, num_items - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    local take = reaper.GetActiveTake(item)
    if take and reaper.TakeIsMIDI(take) then
      -- Get MIDI notes (placeholder logic)
      local midi_notes = {} -- Replace with actual MIDI note extraction

      -- Detect chord
      local chord_name = detect_chord(midi_notes)

      -- Get item position and length
      local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      local item_end = item_start + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")

      -- Add region with chord name
      reaper.AddProjectMarker2(0, true, item_start, item_end, chord_name, -1, 0)
    end
  end

  reaper.UpdateArrange()
end

-- Main execution
reaper.Undo_BeginBlock()
label_chords_from_midi_items()
reaper.Undo_EndBlock("Label Chords from MIDI Items", -1)
