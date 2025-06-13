"""
Groove MIDI Dataset Explorer and Organizer

This script extracts, analyzes, and organizes MIDI files from the Groove MIDI Dataset.
It can:
1. List all available MIDI files in the dataset
2. Extract MIDI files to a target directory with an organized structure by style, tempo, and drummer
3. Generate statistics and visualizations of drum patterns
4. Create a comprehensive index for all available MIDI drum patterns
5. Convert MIDI files to JCRD format for integration with Songbase
6. Prepare files for use in REAPER with appropriate project files
"""

import os
import sys
import json
import shutil
import argparse
import re
import csv
import datetime
import logging
from pathlib import Path
import pretty_midi
import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger("groove_midi_explorer")

# Define path constants
REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TEST_RESOURCES = r"C:\\Users\\CraftAuto-Sales\\Downloads\\e-gmd-v1.0.0-midi\\e-gmd-v1.0.0"
MIDI_OUTPUT_DIR = os.path.join(REPO_ROOT, "data", "midi", "e-gmd")
JCRD_OUTPUT_DIR = os.path.join(REPO_ROOT, "data", "jcrd_library", "e-gmd")
METADATA_DIR = os.path.join(REPO_ROOT, "data", "metadata", "e-gmd")
INFO_CSV = os.path.join(TEST_RESOURCES, "e-gmd-v1.0.0.csv")

# Define MIDI drum mapping
DRUM_MAPPING = {
    36: "Kick",
    38: "Snare",
    40: "Snare (Rim)",
    37: "Snare (X-Stick)",
    48: "Tom 1",
    50: "Tom 1 (Rim)",
    45: "Tom 2",
    47: "Tom 2 (Rim)",
    43: "Tom 3",
    58: "Tom 3 (Rim)",
    46: "HH Open",
    26: "HH Open (Pedal)",
    42: "HH Closed",
    22: "HH Closed (Pedal)",
    44: "HH Pedal",
    49: "Crash 1",
    55: "Splash",
    57: "Crash 2",
    51: "Ride",
    59: "Ride (Bell)",
    53: "Ride (Cup)"
}

def load_metadata_from_csv():
    """Load metadata from the info.csv file."""
    metadata_by_path = {}
    
    if not os.path.exists(INFO_CSV):
        logger.error(f"Error: CSV file not found at {INFO_CSV}")
        return metadata_by_path
    
    try:
        with open(INFO_CSV, 'r', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                # Use the MIDI filename as the key
                # Ensure the path is constructed correctly for E-GMD
                # The 'midi_filename' in e-gmd-v1.0.0.csv is already relative to the dataset root
                midi_path = os.path.join(TEST_RESOURCES, row['midi_filename'])
                metadata_by_path[midi_path] = {
                    'drummer': row['drummer'],
                    'session': row['session'],
                    'id': row['id'],
                    'style': row['style'],
                    'bpm': int(row['bpm']) if row['bpm'].isdigit() else None,
                    'beat_type': row['beat_type'],
                    'time_signature': row['time_signature'],
                    'duration': float(row['duration']) if row['duration'] else None,
                    'split': row['split']
                }
        logger.info(f"Loaded metadata for {len(metadata_by_path)} MIDI files from info.csv")
    except Exception as e:
        logger.error(f"Error loading info.csv: {e}")
    
    return metadata_by_path

def find_groove_midi_files():
    """Find all Groove MIDI files in the test resources directory."""
    # groove_path = os.path.join(TEST_RESOURCES, "groove_midi") # Original logic for subfolder
    groove_path = TEST_RESOURCES # E-GMD MIDI files are directly in subfolders of TEST_RESOURCES
    if not os.path.exists(groove_path):
        logger.error(f"Error: E-GMD dataset not found at {groove_path}") # Updated message
        return []
    
    midi_files = []
    for root, _, files in os.walk(groove_path): # Ensure os.walk is used correctly
        for file in files:
            if file.endswith((".mid", ".midi")): # Accept both .mid and .midi
                midi_files.append(os.path.join(root, file))
    
    logger.info(f"Found {len(midi_files)} MIDI files in {groove_path}")
    return midi_files

def analyze_midi_file(midi_path):
    """Analyze a MIDI file and return statistics."""
    try:
        midi_data = pretty_midi.PrettyMIDI(midi_path)
        
        # Extract basic information
        file_info = {
            "path": midi_path,
            "filename": os.path.basename(midi_path),
            "duration": midi_data.get_end_time(),
            "num_instruments": len(midi_data.instruments),
            "time_signature_changes": len(midi_data.time_signature_changes),
            "tempo_changes": len(midi_data.get_tempo_changes()[0]),
            "drum_events": 0,
            "drum_notes": defaultdict(int),
            "beat_density": 0,
            "unique_drums": set()
        }
        
        # Extract drum-specific information
        for instrument in midi_data.instruments:
            if instrument.is_drum:
                file_info["drum_events"] += len(instrument.notes)
                for note in instrument.notes:
                    file_info["drum_notes"][note.pitch] += 1
                    file_info["unique_drums"].add(note.pitch)
        
        file_info["unique_drums"] = list(file_info["unique_drums"])
        if file_info["duration"] > 0:
            file_info["beat_density"] = file_info["drum_events"] / file_info["duration"]
        
        # Extract style information from filename
        filename_parts = os.path.basename(midi_path).split('_')
        if len(filename_parts) >= 2:
            file_info["style"] = filename_parts[1] if "groove" not in filename_parts[1] else filename_parts[0]
            
        # Extract tempo information from filename
        for part in filename_parts:
            if part.isdigit():
                file_info["tempo"] = int(part)
                break
        
        return file_info
    
    except Exception as e:
        print(f"Error analyzing {midi_path}: {e}")
        return {"path": midi_path, "error": str(e)}

def extract_midi_file(midi_path, output_dir, csv_metadata=None):
    """Extract a MIDI file to the specified output directory with an organized structure."""
    if csv_metadata is None:
        csv_metadata = {}
    
    # First try to get info from CSV metadata
    metadata = csv_metadata.get(midi_path, {})
    
    # Get file info for organization
    info = analyze_midi_file(midi_path)
    
    # Determine style (prefer CSV data)
    style = metadata.get("style", "unknown")
    if style == "unknown" or "/" in style:
        # If there's a / in the style, it might be "category/style" format, so extract just the category
        if "/" in style:
            style = style.split("/")[0]
        
        # If still unknown, try to get from filename or analysis
        if style == "unknown":
            filename = os.path.basename(midi_path)
            for potential_style in ["funk", "rock", "jazz", "soul", "hiphop", "latin", "afrobeat"]:
                if potential_style in filename.lower():
                    style = potential_style
                    break
    
    # Determine drummer (prefer CSV data)
    drummer = metadata.get("drummer", "unknown")
    if drummer == "unknown":
        # Try to get from path
        if "drummer" in midi_path:
            drummer_match = re.search(r'drummer(\d+)', midi_path)
            if drummer_match:
                drummer = f"drummer{drummer_match.group(1)}"
    
    # Get tempo (prefer CSV data, then MIDI file, then filename)
    tempo = metadata.get("bpm")
    if not tempo:
        try:
            midi_data = pretty_midi.PrettyMIDI(midi_path)
            # Get the first tempo change event
            tempo_changes = midi_data.get_tempo_changes()
            if len(tempo_changes[0]) > 0:
                tempo = int(tempo_changes[1][0])  # Get the first tempo value
            else:
                # Try to extract from filename
                filename = os.path.basename(midi_path)
                tempo_match = re.search(r'(\d+)(?:_beat|_bpm)', filename)
                if tempo_match:
                    tempo = int(tempo_match.group(1))
                else:
                    tempo = 120  # Default tempo
        except Exception as e:
            logger.warning(f"Error getting tempo from MIDI: {e}")
            tempo = 120  # Default tempo
    
    # Create organized directory structure based on style and tempo range
    tempo_range = "unknown_tempo"
    if isinstance(tempo, (int, float)):
        if tempo < 80:
            tempo_range = "slow_under_80bpm"
        elif tempo < 100:
            tempo_range = "medium_80_to_100bpm"
        elif tempo < 120:
            tempo_range = "medium_100_to_120bpm"
        elif tempo < 140:
            tempo_range = "fast_120_to_140bpm"
        else:
            tempo_range = "very_fast_over_140bpm"
    
    # Get beat type
    beat_type = metadata.get("beat_type", "unknown")
    if beat_type == "unknown":
        filename = os.path.basename(midi_path)
        if "beat" in filename:
            beat_type = "beat"
        elif "fill" in filename:
            beat_type = "fill"
        elif "groove" in filename:
            beat_type = "groove"
    
    # Create style-based directory
    style_dir = os.path.join(output_dir, style)
    os.makedirs(style_dir, exist_ok=True)
    
    # Create tempo-range subdirectory
    tempo_dir = os.path.join(style_dir, tempo_range)
    os.makedirs(tempo_dir, exist_ok=True)
    
    # Create more descriptive filename
    original_filename = os.path.basename(midi_path)
    base_filename = os.path.splitext(original_filename)[0]
    
    # Ensure tempo and drummer info are in the filename
    new_filename = f"{drummer}_{tempo}bpm_{beat_type}_{base_filename}.mid"
    
    # Remove any problematic characters and duplications
    new_filename = new_filename.replace('/', '_').replace('\\', '_').replace('__', '_')
    
    # Create the final path and extract the file
    dest_path = os.path.join(tempo_dir, new_filename)
    shutil.copy(midi_path, dest_path)
    logger.info(f"Extracted: {dest_path}")
    
    # Get time signature
    time_signature = metadata.get("time_signature", "4-4").replace("-", "/")
    
    # Create JSON metadata for this file
    file_metadata = {
        "filename": new_filename,
        "original_path": midi_path,
        "output_path": dest_path,
        "style": style,
        "drummer": drummer,
        "tempo": tempo,
        "tempo_range": tempo_range,
        "beat_type": beat_type,
        "time_signature": time_signature,
        "duration": metadata.get("duration") or info.get("duration", 0),
        "num_beats": info.get("drum_events", 0),
        "beat_density": info.get("beat_density", 0),
        "extracted_time": datetime.datetime.now().isoformat()
    }
    
    # Write individual metadata file
    metadata_dir = os.path.join(METADATA_DIR, style, tempo_range)
    os.makedirs(metadata_dir, exist_ok=True)
    metadata_path = os.path.join(metadata_dir, f"{os.path.splitext(new_filename)[0]}.json")
    
    with open(metadata_path, 'w', encoding='utf-8') as f:
        json.dump(file_metadata, f, indent=2)
    
    return dest_path, file_metadata

def create_master_index(metadata_list, output_path):
    """Create a master index of all extracted MIDI files."""
    # Group by style and tempo range
    index = {
        "total_patterns": len(metadata_list),
        "styles": defaultdict(lambda: {
            "count": 0,
            "tempo_ranges": defaultdict(lambda: {
                "count": 0,
                "patterns": []
            })
        })
    }
    
    # Add each pattern to the appropriate category
    for metadata in metadata_list:
        style = metadata["style"]
        tempo_range = metadata["tempo_range"]
        
        # Update counts
        index["styles"][style]["count"] += 1
        index["styles"][style]["tempo_ranges"][tempo_range]["count"] += 1
        
        # Add pattern info
        pattern_info = {
            "filename": metadata["filename"],
            "path": metadata["output_path"],
            "drummer": metadata["drummer"],
            "tempo": metadata["tempo"],
            "beat_type": metadata["beat_type"],
            "time_signature": metadata["time_signature"],
            "duration": metadata["duration"]
        }
        
        index["styles"][style]["tempo_ranges"][tempo_range]["patterns"].append(pattern_info)
    
    # Convert defaultdicts to regular dicts for JSON serialization
    index_dict = {
        "total_patterns": index["total_patterns"],
        "styles": {}
    }
    
    for style, style_data in index["styles"].items():
        index_dict["styles"][style] = {
            "count": style_data["count"],
            "tempo_ranges": {}
        }
        
        for tempo_range, range_data in style_data["tempo_ranges"].items():
            index_dict["styles"][style]["tempo_ranges"][tempo_range] = {
                "count": range_data["count"],
                "patterns": range_data["patterns"]
            }
    
    # Create metadata directory if it doesn't exist
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    # Write index file
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(index_dict, f, indent=2)
    
    logger.info(f"Created master index at {output_path} with {len(metadata_list)} patterns")
    return output_path

def convert_to_jcrd(midi_path, output_dir):
    """Convert a MIDI drum file to JCRD format."""
    try:
        midi_data = pretty_midi.PrettyMIDI(midi_path)
        
        # Extract basic information
        filename = os.path.basename(midi_path)
        filename_parts = filename.split('_')
        
        # Parse metadata from filename
        style = "unknown"
        tempo = 120
        drummer_id = "unknown"
        beat_type = "unknown"
        
        # Try to parse information from filename
        for part in filename_parts:
            if part.startswith("drummer"):
                drummer_id = part
            elif part in ["funk", "rock", "jazz", "latin", "afrobeat", "soul", "hiphop"]:
                style = part
            elif part.isdigit():
                tempo = int(part)
            elif part.startswith("groove") or part.startswith("beat") or part.startswith("fill"):
                beat_type = part
        
        # Create sections based on beats
        sections = []
        current_time = 0
        section_duration = 4  # Default 4-bar sections
        while current_time < midi_data.get_end_time():
            end_time = min(current_time + section_duration, midi_data.get_end_time())
            sections.append({
                "name": f"Section {len(sections) + 1}",
                "start": current_time,
                "end": end_time
            })
            current_time = end_time
        
        # Extract drum hits as chords
        chords = []
        for instrument in midi_data.instruments:
            if instrument.is_drum:
                # Group notes by time (within a small threshold)
                note_groups = defaultdict(list)
                for note in instrument.notes:
                    # Round to nearest 10ms
                    time_key = round(note.start * 100) / 100
                    note_groups[time_key].append(note)
                
                # Create chord events for each time point
                for time, notes in note_groups.items():
                    # Create a chord name based on the drum hits
                    hits = []
                    for note in notes:
                        if note.pitch in DRUM_MAPPING:
                            hits.append(DRUM_MAPPING[note.pitch])
                    
                    if hits:
                        main_hit = hits[0]
                        chord_name = main_hit
                        if len(hits) > 1:
                            chord_name = f"{main_hit}+{len(hits)-1}"
                        
                        chords.append({
                            "time": time,
                            "chord": chord_name,
                            "duration": 0.25,  # Default duration
                            "drum_hits": hits
                        })
        
        # Sort chords by time
        chords.sort(key=lambda x: x["time"])
        
        # Create JCRD structure
        jcrd_data = {
            "metadata": {
                "title": os.path.splitext(filename)[0],
                "artist": f"Drummer {drummer_id}",
                "source": "Groove MIDI Dataset",
                "style": style,
                "tempo": tempo,
                "time_signature": "4/4",  # Default
                "beat_type": beat_type,
                "tags": [style, beat_type, drummer_id]
            },
            "sections": sections,
            "chord_progression": chords,
            "drum_mapping": DRUM_MAPPING
        }
        
        # Save to file
        os.makedirs(output_dir, exist_ok=True)
        output_path = os.path.join(output_dir, f"{os.path.splitext(filename)[0]}.jcrd.json")
        
        with open(output_path, "w") as f:
            json.dump(jcrd_data, f, indent=2)
        
        print(f"Converted to JCRD: {output_path}")
        return output_path
    
    except Exception as e:
        print(f"Error converting {midi_path} to JCRD: {e}")
        return None

def visualize_midi(midi_path, output_dir=None):
    """Create a piano roll visualization of a MIDI drum file."""
    try:
        midi_data = pretty_midi.PrettyMIDI(midi_path)
        
        plt.figure(figsize=(12, 8))
        
        # Only visualize drum tracks
        for i, instrument in enumerate(midi_data.instruments):
            if instrument.is_drum:
                # Get a piano roll representation
                piano_roll = instrument.get_piano_roll(fs=100)
                
                # Only show drum notes (between 35 and 60)
                drum_roll = np.zeros((128, piano_roll.shape[1]))
                for note_num in range(35, 61):
                    if note_num in DRUM_MAPPING:
                        if np.any(piano_roll[note_num] > 0):
                            drum_roll[note_num] = piano_roll[note_num]
                
                # Plot the drum roll
                plt.imshow(drum_roll[35:61], aspect='auto', origin='lower', 
                          interpolation='nearest', cmap='viridis')
                
                # Add labels for drum notes
                yticks = []
                yticklabels = []
                for note_num in range(35, 61):
                    if note_num in DRUM_MAPPING:
                        yticks.append(note_num - 35)
                        yticklabels.append(f"{note_num}: {DRUM_MAPPING.get(note_num, '')}")
                
                plt.yticks(yticks, yticklabels)
                
                # Add time markers
                times = np.arange(0, midi_data.get_end_time(), 1.0)
                plt.xticks(times * 100, [f"{t:.1f}" for t in times])
                
                plt.xlabel("Time (s)")
                plt.title(f"Drum Pattern: {os.path.basename(midi_path)}")
                
                if output_dir:
                    os.makedirs(output_dir, exist_ok=True)
                    output_path = os.path.join(output_dir, f"{os.path.splitext(os.path.basename(midi_path))[0]}_visualization.png")
                    plt.savefig(output_path, dpi=150, bbox_inches='tight')
                    print(f"Saved visualization to {output_path}")
                else:
                    plt.show()
                
                plt.close()
                return True
        
        print(f"No drum tracks found in {midi_path}")
        return False
    
    except Exception as e:
        print(f"Error visualizing {midi_path}: {e}")
        return False

def prepare_for_reaper(midi_path, output_dir):
    """
    Prepare a MIDI file for use in REAPER.
    This includes:
    1. Copying the file to the output directory
    2. Creating a .RPP (REAPER project file) template
    3. Adding markers for different sections/patterns
    """
    filename = os.path.basename(midi_path)
    base_name = os.path.splitext(filename)[0]
    output_midi_path = os.path.join(output_dir, filename)
    
    # Copy the MIDI file
    print(f"Copying {filename} to {output_dir}")
    shutil.copy2(midi_path, output_midi_path)
    
    # Analyze the file to get info for the RPP
    info = analyze_midi_file(midi_path)
    
    # Extract tempo from the file name if available
    # Format is often: "drummer_style_tempo_beat_meter.mid"
    parts = base_name.split('_')
    tempo = 120  # Default tempo
    for part in parts:
        if part.isdigit() and 40 <= int(part) <= 240:
            tempo = int(part)
            break
    
    style = info.get("style", "unknown")
    duration = info.get("duration", 0)
    
    # Try to get tempo from MIDI file itself if available
    try:
        midi_data = pretty_midi.PrettyMIDI(midi_path)
        tempos = midi_data.get_tempo_changes()
        if tempos[0].size > 0:
            # Use last tempo in file if multiple tempos exist
            midi_tempo = int(tempos[1][-1])
            if 40 <= midi_tempo <= 240:  # Reasonable tempo range
                tempo = midi_tempo
    except Exception as e:
        print(f"Warning: Could not read tempo from MIDI: {e}")
    
    # Create a simple REAPER project file
    rpp_path = os.path.join(output_dir, f"{base_name}.rpp")
    
    # Find relative path for the MIDI file
    rel_midi_path = os.path.relpath(output_midi_path, os.path.dirname(rpp_path))
    
    # Basic RPP template - simple but functional
    rpp_content = f"""<REAPER_PROJECT 0.1 "6.0" 1680191288
  TEMPO {tempo} 4 4
  RIPPLE 0
  MARKER 1 0 "Start" "" 1 R
  MARKER 2 {duration} "End" "" 1 R
  <TRACK {{CF186C8F-6103-04D7-9D83-F3445F9D76D3}}
    NAME "Groove MIDI: {base_name}"
    VOLPAN 1 0 -1 -1 1
    <ITEM {{FD720303-0AEC-47B8-A7C2-E6AF3C7468F2}}
      POSITION 0
      SNAPOFFS 0
      LENGTH {duration}
      LOOP 1
      NAME "{filename}"
      <SOURCE MIDI
        FILE "{rel_midi_path}"
      >
    >
  >
>
"""
    
    with open(rpp_path, "w") as f:
        f.write(rpp_content)
    
    print(f"Created REAPER project: {rpp_path}")
    
    return output_midi_path, rpp_path

def main():
    parser = argparse.ArgumentParser(description="Groove MIDI Dataset Explorer and Extractor")
    parser.add_argument("--list", action="store_true", help="List all available MIDI files")
    parser.add_argument("--extract", action="store_true", help="Extract MIDI files to output directory with organized structure")
    parser.add_argument("--visualize", action="store_true", help="Create visualizations of MIDI files")
    parser.add_argument("--style", help="Filter by style (funk, rock, jazz, etc.)")
    parser.add_argument("--drummer", help="Filter by drummer ID (drummer1, drummer2, etc.)")
    parser.add_argument("--output", default=MIDI_OUTPUT_DIR, 
                        help="Output directory for extracted MIDI files")
    parser.add_argument("--limit", type=int, help="Limit number of files processed")
    parser.add_argument("--create-index", action="store_true", 
                        help="Create a master index file of all available MIDI files")
    parser.add_argument("--index-path", default=os.path.join(METADATA_DIR, "e-gmd_index.json"),
                        help="Path to save the index file")
    parser.add_argument("--convert", action="store_true", help="Convert MIDI files to JCRD format (optional)")
    parser.add_argument("--prepare", action="store_true", help="Prepare MIDI files for use in REAPER (optional, creates RPP files)")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose logging")
    
    args = parser.parse_args()
    
    # Configure logging level
    if args.verbose:
        logger.setLevel(logging.DEBUG)
    
    # Load CSV metadata if available
    csv_metadata = load_metadata_from_csv()
    
    # Find all MIDI files
    midi_files = find_groove_midi_files()
    if not midi_files:
        logger.error("No Groove MIDI files found")
        return 1
    
    # Filter files
    filtered_files = midi_files
    if args.style:
        filtered_files = [f for f in filtered_files if args.style.lower() in f.lower()]
    if args.drummer:
        filtered_files = [f for f in filtered_files if args.drummer.lower() in f.lower()]
    if args.limit and args.limit > 0:
        filtered_files = filtered_files[:args.limit]
    
    logger.info(f"Found {len(filtered_files)} MIDI files matching criteria")
    
    # Process files
    if args.list:
        logger.info("\nAvailable MIDI files:")
        for i, file in enumerate(filtered_files):
            info = analyze_midi_file(file)
            
            # Try to get metadata from CSV first
            csv_info = csv_metadata.get(file, {})
            style = csv_info.get("style", info.get("style", "unknown"))
            tempo = csv_info.get("bpm", info.get("tempo", "unknown"))
            duration = csv_info.get("duration", info.get("duration", 0))
            
            print(f"{i+1}. {os.path.basename(file)} - Style: {style}, "
                  f"Tempo: {tempo}, Duration: {duration:.2f}s")
    
    # Extract files and collect metadata
    extracted_metadata = []
    if args.extract:
        logger.info(f"\nExtracting files to {args.output}")
        os.makedirs(args.output, exist_ok=True)
        os.makedirs(METADATA_DIR, exist_ok=True)
        
        for file in filtered_files:
            _, metadata = extract_midi_file(file, args.output, csv_metadata)
            extracted_metadata.append(metadata)
    
    # Create master index
    if args.create_index and extracted_metadata:
        create_master_index(extracted_metadata, args.index_path)
    
    # Convert to JCRD if requested
    if args.convert:
        logger.info(f"\nConverting files to JCRD format")
        jcrd_dir = os.path.join(JCRD_OUTPUT_DIR, "jcrd")
        os.makedirs(jcrd_dir, exist_ok=True)
        
        # If we've extracted files, use those paths, otherwise use original files
        files_to_convert = [m["output_path"] for m in extracted_metadata] if extracted_metadata else filtered_files
        
        for file in files_to_convert:
            convert_to_jcrd(file, jcrd_dir)
    
    # Create visualizations if requested
    if args.visualize:
        logger.info("\nCreating visualizations")
        viz_dir = os.path.join(args.output, "visualizations")
        os.makedirs(viz_dir, exist_ok=True)
        
        # If we've extracted files, use those paths, otherwise use original files
        files_to_visualize = [m["output_path"] for m in extracted_metadata] if extracted_metadata else filtered_files
        
        for file in files_to_visualize:
            visualize_midi(file, viz_dir)
    
    # Prepare for REAPER if requested
    if args.prepare:
        logger.info("\nPreparing files for REAPER")
        reaper_dir = os.path.join(args.output, "reaper")
        os.makedirs(reaper_dir, exist_ok=True)
        
        # If we've extracted files, use those paths, otherwise use original files
        files_to_prepare = [m["output_path"] for m in extracted_metadata] if extracted_metadata else filtered_files
        
        for file in files_to_prepare:
            prepare_for_reaper(file, reaper_dir)
    
    logger.info("\nDone!")
    return 0

if __name__ == "__main__":
    sys.exit(main())
