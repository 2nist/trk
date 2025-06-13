# Dataset Browser Workflow Guide

## 🎯 **Overview**
The Dataset Browser is a comprehensive tool for converting music research datasets into JCRD (JSON Chord and Region Data) format, making them compatible with REAPER and other music analysis tools.

## 📋 **Complete Workflow**

### **Phase 1: Setup & Selection**
```
1. Launch Dataset Browser
   ├── Load from: Scripts/songbase/launch_dataset_browser.lua
   ├── Check extensions: ReaImGui, js_ReaScriptAPI (optional)
   └── Review workflow overview in UI

2. Choose Dataset Type
   ├── ✅ Ready: McGill Billboard, RWC Popular, ChoCo JAMS
   ├── ⚠️ Coming Soon: Isophonics, ChordLab
   └── Review dataset description and file requirements
```

### **Phase 2: Path Configuration**
```
3. Locate Dataset Files
   ├── Option A: Browse button (recommended)
   │   ├── Uses intelligent starting directory
   │   ├── Context-aware folder picker
   │   └── Validates selection automatically
   │
   ├── Option B: Quick path buttons
   │   ├── Documents/datasets (auto-created path)
   │   ├── Downloads folder
   │   └── Desktop folder
   │
   └── Option C: Manual entry
       ├── Type or paste full path
       ├── Use forward slashes: C:/path/to/dataset
       └── Hit Enter to validate

4. Verify Path Validation
   ├── ✅ Green: Directory found with expected files
   ├── ❌ Red: Path issues or missing files
   └── ℹ️ Info: Guidance on what to look for
```

### **Phase 3: Processing Options**
```
5. Configure Processing Steps
   ├── 🔍 Search Filter (optional)
   │   └── Filter specific artists/songs during processing
   │
   ├── ✅ Validate JCRD Files
   │   ├── Recommended for all datasets
   │   ├── Checks format compliance
   │   └── Reports data quality issues
   │
   ├── 🔑 Add Key Estimation
   │   ├── Harmonic analysis algorithm
   │   ├── Detects tonal centers
   │   └── Enhances chord progressions
   │
   └── 🎵 Export to MIDI
       ├── Creates standard MIDI files
       ├── Preserves timing and chord data
       └── Compatible with all DAWs
```

### **Phase 4: Execution & Results**
```
6. Process Dataset
   ├── Validates all prerequisites
   ├── Shows progress in REAPER console
   ├── Creates organized output structure
   └── Reports success/failure for each step

7. Review Output Structure
   your_dataset_folder/
   ├── original_files/          # Untouched source data
   ├── jcrd/                   # Converted JCRD files
   │   ├── artist1_song1.jcrd
   │   ├── artist1_song2.jcrd
   │   └── ...
   └── midi/                   # Exported MIDI files (if enabled)
       ├── artist1_song1.mid
       ├── artist1_song2.mid
       └── ...
```

## 🎵 **Dataset-Specific Workflows**

### **McGill Billboard (SALAMI)**
```
Expected Structure:
artist_name/
├── song_title/
│   ├── chord.txt           # Chord progressions
│   └── salami_chords.txt   # Structural annotations

Workflow:
1. Download from McGill Billboard Project
2. Extract to Documents/datasets/mcgill_billboard/
3. Point browser to extracted folder
4. Enable validation + key estimation
5. Process → Creates JCRD with structure + chords
```

### **RWC Popular Music Database**
```
Expected Structure:
RM-P001/
├── RM-P001.beat           # Beat tracking data
└── RM-P001.chord          # Chord annotations

Workflow:
1. Obtain RWC dataset (license required)
2. Extract to Documents/datasets/rwc_popular/
3. Point browser to folder with RM-P### subdirectories
4. Enable MIDI export for rhythm data
5. Process → Creates JCRD with precise timing
```

### **ChoCo (JAMS Format)**
```
Expected Structure:
annotations/
├── song_001.jams          # Complete JAMS annotation
├── song_002.jams
└── ...

Workflow:
1. Download ChoCo dataset
2. Extract to Documents/datasets/choco/
3. Point browser to folder containing .jams files
4. Enable all options for comprehensive conversion
5. Process → Creates rich JCRD with multiple annotation layers
```

## 🔧 **Troubleshooting Common Issues**

### **Path Problems**
```
❌ "Directory does not exist"
   → Double-check folder path spelling
   → Use forward slashes: C:/path/not/path
   → Ensure you're pointing to the dataset root

❌ "Path is not valid or does not contain expected files"
   → Check dataset extraction was complete
   → Verify folder structure matches expectations
   → Look for hidden or nested folders
```

### **Processing Failures**
```
❌ "Tool chain runner not available"
   → Ensure tool_chain_runner.lua is in Scripts/songbase/
   → Check file permissions
   → Verify Python installation

❌ "Python script failed"
   → Check Python is in system PATH
   → Verify required Python packages installed
   → Review console output for specific errors
```

### **Extension Issues**
```
⚠️ "Install js_ReaScriptAPI extension"
   → Open REAPER → Extensions → ReaPack → Browse packages
   → Search for "js_ReaScriptAPI"
   → Install and restart REAPER

⚠️ "ReaImGui extension required"
   → Install from ReaPack: "Dear ImGui"
   → Required for the graphical interface
```

## 📈 **Advanced Usage Tips**

### **Batch Processing**
```
1. Organize multiple datasets in subfolders:
   datasets/
   ├── mcgill_billboard/
   ├── rwc_popular/
   └── choco/

2. Process each dataset separately
3. Use consistent output naming
4. Combine results for large-scale analysis
```

### **Custom Validation**
```
1. Enable validation for all datasets
2. Review console output for warnings
3. Fix data quality issues before MIDI export
4. Use validation reports for research quality control
```

### **REAPER Integration**
```
1. After processing, in REAPER:
   Insert → Media File → Select .mid files
2. For regions: Run export_jcrd_to_reaper_regions.py
3. For analysis: Use other songbase tools with .jcrd files
4. For research: Export data for external analysis tools
```

## 🎯 **Best Practices**

### **Organization**
- Create dedicated datasets folder in Documents
- Use consistent naming conventions
- Keep original data separate from processed files
- Document your processing settings for reproducibility

### **Quality Control**
- Always enable validation for production work
- Review console output for warnings
- Test with small dataset subsets first
- Verify MIDI exports in your DAW

### **Performance**
- Process large datasets in smaller batches
- Close other REAPER projects during processing
- Monitor disk space for output files
- Use SSD storage for faster I/O operations

---

**📞 Support**: Check console output for detailed error messages  
**🔄 Updates**: New dataset integrations added regularly  
**🎼 Integration**: Works seamlessly with all REAPER songbase tools
