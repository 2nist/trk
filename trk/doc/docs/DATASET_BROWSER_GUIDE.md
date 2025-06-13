# Dataset Browser UI - User Guide

## Overview
The Dataset Browser UI provides a graphical interface for converting various music datasets to JCRD (JSON Chord and Region Data) format within REAPER.

## Features

### 🎯 **Smart Dataset Detection**
- **McGill Billboard (SALAMI)**: Chord progressions + structural analysis
- **RWC Popular Music**: Beat tracking + chord annotations  
- **ChoCo (JAMS)**: JAMS format conversion to JCRD
- **Isophonics**: Chord annotations (coming soon)
- **ChordLab**: Chord annotation dataset (coming soon)

### 📁 **Intelligent Path Browsing**
- **Default Paths**: Automatically suggests `Documents/datasets/[dataset_name]/`
- **Quick Path Buttons**: One-click access to common dataset locations
- **Smart Validation**: Checks for expected file types before processing
- **File Type Guidance**: Shows exactly what files each dataset should contain

### 🔧 **Processing Options**
- **Validate JCRD**: Check converted files for format compliance
- **Key Estimation**: Add automatic key detection to chord progressions
- **MIDI Export**: Convert processed data to MIDI files for DAW import

### 💡 **Built-in Help**
- **Dataset Tips**: Expandable sections with download links and setup instructions
- **File Structure Examples**: Shows typical folder organization for each dataset
- **Validation Feedback**: Real-time path checking with helpful error messages

## Usage Instructions

### 1. **Launch the Browser**
```lua
-- In REAPER, run this script:
Scripts/songbase/launch_dataset_browser.lua
```

### 2. **Select Dataset Type**
- Choose from the dropdown menu
- Status indicators show which datasets are ready: ✅ = Ready, ⚠️ = Coming Soon

### 3. **Browse to Dataset Folder**
- **Manual Entry**: Type the path directly
- **Browse Button**: Use folder picker (requires js_ReaScriptAPI extension)
- **Quick Paths**: Click suggested folder buttons
- **Reset**: Return to default suggestion

### 4. **Configure Processing**
- ✅ **Validate JCRD files**: Recommended for quality assurance
- 🔑 **Add key estimation**: Adds harmonic analysis
- 🎵 **Export to MIDI**: Creates MIDI files for DAW import

### 5. **Process Dataset**
- Button becomes active when path is valid and dataset is ready
- Progress shown in REAPER console
- Creates organized output folders (jcrd/, midi/)

## Expected Dataset Structures

### McGill Billboard (SALAMI)
```
datasets/mcgill_billboard/
├── The Beatles/
│   ├── Come Together/
│   │   ├── chord.txt
│   │   └── salami_chords.txt
│   └── Hey Jude/
└── ...
```

### RWC Popular Music  
```
datasets/rwc_popular/
├── RM-P001/
│   ├── RM-P001.beat
│   └── RM-P001.chord
├── RM-P002/
└── ...
```

### ChoCo (JAMS)
```
datasets/choco/
├── annotations/
│   ├── song_001.jams
│   ├── song_002.jams
│   └── ...
└── ...
```

## Requirements
- **REAPER 6.0+**
- **ReaImGui** extension (for UI)
- **js_ReaScriptAPI** extension (for folder picker, optional)
- **Python 3.7+** (for processing scripts)

## Troubleshooting

### "Cannot Process" Button
- ❌ **Path Invalid**: Check that folder exists and contains expected files
- ⚠️ **Dataset Not Ready**: Some integrations are still in development
- 📁 **No Path**: Specify a valid dataset folder

### Missing Extensions
- Install **ReaImGui** and **js_ReaScriptAPI** from ReaPack
- Restart REAPER after installation

### Python Errors
- Ensure Python is in system PATH
- Check REAPER console for detailed error messages
- Verify dataset folder contains expected file types

## Output Structure
```
your_dataset_folder/
├── original_files/          # Your original dataset
├── jcrd/                   # Converted JCRD files
│   ├── song1.jcrd
│   └── song2.jcrd
└── midi/                   # Exported MIDI files (if enabled)
    ├── song1.mid
    └── song2.mid
```

## Next Steps
1. **Import MIDI**: Use REAPER's "Insert > Media File" to import generated MIDI
2. **Use JCRD Data**: Load .jcrd files with other songbase tools
3. **Regional Export**: Use `export_jcrd_to_reaper_regions.py` for section markers

---
*For technical details, see the source code in `Scripts/songbase/ui_dataset_browser.lua`*
