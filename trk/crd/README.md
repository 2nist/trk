# Chord Tools Module (crd)

## Purpose

This module collects all chord detection and analysis scripts, providing a unified interface for chord-related operations.

## Usage

- Place all chord detection, analysis, and labeling scripts here.
- Scripts should output `.jcrd` files or region markers as needed.
- See individual script headers for requirements and outputs.

## Example Scripts

- `Simple_Chord_Detection.lua`: Basic chord detection from MIDI/audio.
- `Real_Time_Chord_Monitor.lua`: Live chord monitoring.
- `ReaChord_Live_Analyzer.lua`: Advanced chord analysis.
- `Label_Chords_From_MIDI_Items.lua`: Label MIDI items with chord names.
- `Audio_To_MIDI_Chord_Detection.lua`: Convert audio to MIDI chords.

## Integration

- Bass and Melody modules pull chord data from `.jcrd` outputs here.
