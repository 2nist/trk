-- midi_helpers.lua
-- Helper functions for MIDI operations

local midi_helpers = {}

-- Convert MIDI note number to note name
function midi_helpers.note_number_to_name(note_num)
    if type(note_num) ~= "number" then return "?" end
    
    local notes = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
    local octave = math.floor(note_num / 12) - 1
    local note_idx = (note_num % 12) + 1
    
    return notes[note_idx] .. octave
end

-- Convert note name to MIDI note number
function midi_helpers.note_name_to_number(note_name)
    if type(note_name) ~= "string" then return nil end
    
    local notes = {C = 0, ["C#"] = 1, D = 2, ["D#"] = 3, E = 4, F = 5, 
                   ["F#"] = 6, G = 7, ["G#"] = 8, A = 9, ["A#"] = 10, B = 11}
    
    local note_part = note_name:match("^([A-G]#?)") or ""
    local octave_part = note_name:match("(-?%d+)$") or "4"
    
    local note_val = notes[note_part]
    local octave_val = tonumber(octave_part)
    
    if not note_val or not octave_val then
        return nil
    end
    
    return note_val + (octave_val + 1) * 12
end

-- Get note velocity as a percentage
function midi_helpers.velocity_to_percentage(velocity)
    if type(velocity) ~= "number" then return 0 end
    
    return math.floor((velocity / 127) * 100)
end

-- Convert percentage to MIDI velocity
function midi_helpers.percentage_to_velocity(percentage)
    if type(percentage) ~= "number" then return 0 end
    
    return math.floor((percentage / 100) * 127)
end

-- Format duration in seconds to beats based on BPM
function midi_helpers.seconds_to_beats(seconds, bpm)
    if type(seconds) ~= "number" or type(bpm) ~= "number" then
        return 0
    end
    
    -- beats = seconds * (beats/minute) / (seconds/minute)
    return seconds * bpm / 60
end

-- Convert beats to seconds based on BPM
function midi_helpers.beats_to_seconds(beats, bpm)
    if type(beats) ~= "number" or type(bpm) ~= "number" then
        return 0
    end
    
    -- seconds = beats * (seconds/minute) / (beats/minute)
    return beats * 60 / bpm
end

-- Create a simple MIDI note
function midi_helpers.create_note(note_num, velocity, start_time, duration)
    return {
        type = "note",
        note = note_num,
        velocity = velocity or 100,
        start_time = start_time or 0,
        duration = duration or 1
    }
end

return midi_helpers
