# Sketch Mode for REAPER

A Lua script-based system for creating quick musical sketches in REAPER.

## Features

- One-click setup of a dedicated sketch environment
- Specialized tracks for different instrument types
- Chord detection with Scaler 3 integration
- Smart MIDI routing for efficient workflow
- Creation of sub-projects for organizing ideas
- Promotion of sketches back to the main arrangement

## Installation

1. Run the `deploy.sh` script to install the Sketch Mode scripts to your REAPER Scripts directory

   ```bash
   ./deploy.sh
   ```

2. In REAPER, go to Actions > Show action list
3. Click on "New..." and select "Load ReaScript"
4. Browse to the SketchMode directory in your REAPER Scripts folder and select each script
5. Assign keyboard shortcuts or toolbar buttons to the scripts

## Usage

### Activate Sketch Mode

Run the `Activate_Sketch_Mode.lua` script to set up a new sketch environment with:

- Specialized tracks (Chord Detector, Drum Sketch, Bass Sketch, etc.)
- Scaler 3 plugin loaded on the Chord Detector track
- MIDI routing from Scaler to Chord and Melody tracks
- Default tempo and time signature
- Loop region set to 32 bars
- "Sketches" folder created for storing sketch subprojects

### Create New Sketch Section

Run the `New_Sketch_Section.lua` script to:

- Create a subproject at the current cursor position
- Save the subproject in the Sketches folder
- Open the subproject in a new tab for focused work

### Promote to Arrangement

When working in a sketch subproject:

1. Select items you want to move to the main arrangement
2. Run the `Promote_To_Arrangement.lua` script
3. The selected items will be copied to the main project at the current cursor position

## Testing

To test the scripts without affecting your REAPER installation:

```bash
lua test_sketch_mode.lua
```

## Requirements

- REAPER 6.0 or higher
- Scaler 3 plugin (optional but recommended)

## License

MIT License
