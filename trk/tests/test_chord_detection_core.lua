-- test_chord_detection_core.lua
-- Test just the core chord detection logic

-- Copy core functions from Simple_Chord_Detection.lua

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

local CONFIDENCE_THRESHOLD = 0.7

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

-- Test data: MIDI notes for various chords
local test_chords = {
  {name = "C Major", notes = {60, 64, 67}},  -- C, E, G
  {name = "D Minor", notes = {62, 65, 69}},  -- D, F, A
  {name = "G7", notes = {67, 71, 74, 77}},   -- G, B, D, F
  {name = "F Major 7", notes = {65, 69, 72, 76}}, -- F, A, C, E
  {name = "A Minor", notes = {57, 60, 64}},  -- A, C, E
  {name = "B Diminished", notes = {59, 62, 65}}, -- B, D, F
  {name = "C Augmented", notes = {60, 64, 68}},  -- C, E, G#
  {name = "D Sus4", notes = {62, 67, 69}},   -- D, G, A
  {name = "E Sus2", notes = {64, 66, 71}}    -- E, F#, B
}

print("Testing Chord Detection Core Functions")
print("=====================================")

local total_tests = 0
local successful_detections = 0

-- Test chord detection
for _, test in ipairs(test_chords) do
  total_tests = total_tests + 1
  print("\nTesting: " .. test.name)
  print("MIDI Notes: " .. table.concat(test.notes, ", "))
  
  local chord_result = detect_chord(test.notes)
  print("Detected: " .. chord_result.name)
  print("Confidence: " .. string.format("%.1f%%", chord_result.confidence * 100))
  print("Type: " .. chord_result.type)
  print("Quality: " .. chord_result.quality)
  print("Root: " .. chord_result.root_name)
  print("Intervals: " .. table.concat(chord_result.intervals or {}, ", "))
  
  if chord_result.confidence >= CONFIDENCE_THRESHOLD then
    successful_detections = successful_detections + 1
    print("✓ Detection successful")
  else
    print("✗ Below confidence threshold")
  end
end

print("\n\nSummary:")
print("========")
print("Total tests: " .. total_tests)
print("Successful detections: " .. successful_detections)
print("Success rate: " .. string.format("%.1f%%", (successful_detections / total_tests) * 100))

-- Test edge cases
print("\n\nTesting Edge Cases:")
print("==================")

-- Single note
local single_note_result = detect_chord({60})
print("Single note (C): " .. single_note_result.name .. " (confidence: " .. single_note_result.confidence .. ")")

-- No notes
local no_notes_result = detect_chord({})
print("No notes: " .. no_notes_result.name .. " (confidence: " .. no_notes_result.confidence .. ")")

-- Complex chord (not in templates)
local complex_chord_result = detect_chord({60, 64, 67, 70, 74}) -- C, E, G, Bb, D (C7add9)
print("Complex chord (C7add9): " .. complex_chord_result.name .. " (confidence: " .. string.format("%.1f%%", complex_chord_result.confidence * 100) .. ")")

print("\n✓ Core chord detection test completed!")
