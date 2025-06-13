# Simple Chord Detection - Quick Setup Guide

This script provides fast, low-CPU chord detection from MIDI data in REAPER and can export .jcrd files for use with other applications.

## Features

- **Single-source detection**: Analyzes one MIDI track (much simpler than multi-band approach)
- **Timeline regions**: Creates colored regions showing detected chords with confidence percentages
- **.jcrd export**: Exports chord data in JSON format compatible with chord analysis tools
- **Low CPU usage**: Processes existing MIDI data without real-time analysis
- **Confidence scoring**: Only shows chords above a configurable threshold

## Quick Setup

### Method 1: MIDI Input Track
1. Create a new track and name it "Chord Detection"
2. Record MIDI directly to this track using a MIDI keyboard
3. Run the script to analyze the recorded MIDI

### Method 2: ReaTune Audio-to-MIDI
1. Create a new track and name it "Chord Detection"
2. Insert ReaTune on your audio source track
3. Route ReaTune's MIDI output to the "Chord Detection" track
4. Play your audio to generate MIDI data
5. Run the script to analyze the generated MIDI

### Method 3: Scaler Plugin
1. Create a new track and name it "Chord Detection"
2. Insert Scaler 2 on your audio source track
3. Set Scaler to output MIDI to the "Chord Detection" track
4. Let Scaler detect chords and output MIDI
5. Run the script to analyze Scaler's MIDI output

## Configuration Options

Edit the script configuration at the top:

```lua
local TRACK_NAME = "Chord Detection" -- Change this to match your track name
local CONFIDENCE_THRESHOLD = 0.7     -- Minimum confidence (0.0 to 1.0)
local EXPORT_JCRD = true             -- Set to false to disable .jcrd export
local PROJECT_TITLE = "My Song"      -- Title for the .jcrd file
```

## Supported Chord Types

- **Major triads**: C, D, E, etc.
- **Minor triads**: Cm, Dm, Em, etc.
- **7th chords**: C7, Cmaj7, Cm7, etc.
- **Diminished**: Cdim
- **Augmented**: Caug
- **Suspended**: Csus2, Csus4

## Output Files

### Timeline Regions
- Color-coded regions appear on the REAPER timeline
- Each region shows the chord name and confidence percentage
- Colors indicate chord type (green=major, blue=minor, orange=dominant7, etc.)

### .jcrd File
When `EXPORT_JCRD = true`, the script creates a JSON file containing:
- **Chord timing**: Start time and duration for each chord
- **Chord details**: Root note, quality, confidence score
- **Metadata**: Project title, tempo, time signature
- **Raw data**: MIDI notes and intervals for each detection

Example .jcrd content:
```json
{
  "version": "1.0",
  "title": "My Song",
  "tempo": 120,
  "chords": [
    {
      "time": 0.0,
      "duration": 2.0,
      "name": "Cmaj",
      "root": "C",
      "quality": "major",
      "confidence": 1.0,
      "degrees": [1, 3, 5],
      "notes": [60, 64, 67]
    }
  ]
}
```

## Workflow Tips

1. **For best results**: Ensure your MIDI data has clear chord changes (not overlapping notes)
2. **Audio sources**: Use ReaTune with polyphonic mode for complex audio
3. **Timing**: The script analyzes each MIDI item separately, so split items at chord changes
4. **Confidence tuning**: Lower the threshold to catch more chords (but with potential false positives)

## Troubleshooting

- **"Track not found"**: Make sure the track name exactly matches `TRACK_NAME` in the script
- **No detections**: Check that your MIDI items contain actual note data
- **Low confidence**: Try lowering `CONFIDENCE_THRESHOLD` or ensure cleaner MIDI input
- **Missing chords**: The script only detects basic chord types - complex extensions may not be recognized

## Integration with Other Tools

The exported .jcrd file can be used with:
- Chord analysis software
- Music theory applications
- Custom scripts for further processing
- Import into other DAWs or notation software

This approach provides a much simpler alternative to the multi-band system while still delivering accurate chord detection and professional export capabilities.
