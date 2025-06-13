#!/usr/bin/env python3
"""
Sample Beatles Dataset Converter

This script uses the existing sample Beatles data to demonstrate how the full integration works.
It creates JCRD files from the sample data provided in the tests folder.

Usage:
    python convert_sample_beatles.py
"""

import os
import json
import sys
import re
from pathlib import Path

# Add script directory to path to allow importing from parent directory
script_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(os.path.dirname(script_dir))
sys.path.append(parent_dir)

# Define paths
source_dir = os.path.join(parent_dir, "tests", "resources", "mir_datasets", "beatles", "annotations")
target_dir = os.path.join(parent_dir, "data", "jcrd_library", "beatles_expanded")
sample_index_path = os.path.join(parent_dir, "tests", "indexes", "beatles_index_1.2_sample.json")

# If the standard paths don't exist, try these paths
if not os.path.exists(os.path.dirname(target_dir)):
    # Try different paths for target directory
    target_dir = os.path.join("c:\\Users\\CraftAuto-Sales\\AppData\\Roaming\\REAPER\\Scripts\\songbase", "data", "jcrd_library", "beatles_expanded")

# Print debug information
print(f"Source directory: {source_dir}")
print(f"Sample index path: {sample_index_path}")

# Set the correct paths if standard paths don't work
if not os.path.exists(sample_index_path):
    # Try alternate path
    sample_index_path = os.path.join(script_dir, "..", "..", "songbase", "tests", "indexes", "beatles_index_1.2_sample.json")
    print(f"Trying alternate index path: {sample_index_path}")
    
    if not os.path.exists(sample_index_path):
        # Hard-code the path as a last resort
        sample_index_path = r"c:\Users\CraftAuto-Sales\AppData\Roaming\REAPER\Scripts\songbase\tests\indexes\beatles_index_1.2_sample.json"
        print(f"Using hard-coded path: {sample_index_path}")

# Ensure the target directory exists
os.makedirs(target_dir, exist_ok=True)

def read_annotations(file_path):
    """Read annotation files like chord, key, and sections."""
    annotations = []
    if not os.path.exists(file_path):
        print(f"Warning: File {file_path} does not exist.")
        return annotations
    
    with open(file_path, "r") as f:
        for line in f.readlines():
            line = line.strip()
            if line and not line.startswith("#"):
                parts = line.split()
                if len(parts) >= 3:
                    start_time = float(parts[0])
                    end_time = float(parts[1])
                    label = " ".join(parts[2:])
                    annotations.append({
                        "start_time": start_time,
                        "end_time": end_time,
                        "label": label
                    })
    return annotations

def read_beats(file_path):
    """Read beat annotations."""
    beats = []
    if not os.path.exists(file_path):
        print(f"Warning: File {file_path} does not exist.")
        return beats
    
    with open(file_path, "r") as f:
        for line in f.readlines():
            line = line.strip()
            if line and not line.startswith("#"):
                parts = line.split()
                if len(parts) >= 1:
                    time = float(parts[0])
                    position = int(parts[1]) if len(parts) > 1 else 1
                    beats.append({
                        "time": time,
                        "position": position
                    })
    return beats

def convert_chord_label(label):
    """Convert a chord label to a simplified format."""
    # This is a simplified conversion. A more complete conversion would
    # handle all chord types and extensions.
    label = label.replace(":", "")  # Remove colons
    
    # Map chord qualities
    if "min" in label or "m" in label:
        quality = "m"
    elif "maj" in label or "M" in label:
        quality = "M"
    elif "dim" in label:
        quality = "dim"
    elif "aug" in label:
        quality = "aug"
    elif "sus" in label:
        quality = "sus"
    else:
        quality = ""  # Major is implied if no quality specified
    
    # Extract root note
    match = re.match(r"([A-G][#b]?)", label)
    if match:
        root = match.group(1)
    else:
        root = "N"  # No chord
    
    return f"{root}{quality}"

def estimate_tempo(beats):
    """Estimate tempo from beat annotations."""
    if not beats or len(beats) < 2:
        return 120  # Default tempo
    
    # Calculate average time between beats
    beat_times = [beat["time"] for beat in beats]
    intervals = [beat_times[i+1] - beat_times[i] for i in range(len(beat_times)-1)]
    avg_interval = sum(intervals) / len(intervals)
    
    # Convert to BPM
    tempo = 60 / avg_interval if avg_interval > 0 else 120
    
    return round(tempo)

def fix_path(rel_path):
    """Fix path to work with our directory structure."""
    if not rel_path:
        return None
        
    # The paths in the index are like "annotations/chordlab/The Beatles/..."
    # But our source directory already includes "annotations", so we need to extract just
    # the parts we need: "chordlab/The Beatles/..."
    
    # Split off the initial "annotations/" prefix
    if rel_path.startswith("annotations/"):
        parts = rel_path[len("annotations/"):].split('/', 1)
    else:
        parts = rel_path.split('/', 1)
        
    if len(parts) < 1:
        return None
        
    anno_type = parts[0]  # e.g., "chordlab"
    remaining_path = parts[1] if len(parts) > 1 else ""  # e.g., "The Beatles/..."
    
    # Try the standard path first
    fixed_path = os.path.join(source_dir, anno_type, remaining_path)
    
    # If that doesn't exist, try a hard-coded path
    if not os.path.exists(fixed_path):
        fixed_path = os.path.join(r"c:\Users\CraftAuto-Sales\AppData\Roaming\REAPER\Scripts\songbase", "tests", "resources", "mir_datasets", "beatles", "annotations", anno_type, remaining_path)
        print(f"Trying alternative path: {fixed_path}")
    
    return fixed_path

def enhance_sample_jcrd():
    """Enhance the sample JCRD file with more data for demonstration purposes."""
    # Load the sample index
    if not os.path.exists(sample_index_path):
        print(f"Error: Sample index file {sample_index_path} not found.")
        return False
    
    with open(sample_index_path, "r") as f:
        index_data = json.load(f)
    
    # Get the sample track information
    track_id = "0111"  # This is the sample track from the index
    if track_id not in index_data["tracks"]:
        print(f"Error: Track {track_id} not found in the sample index.")
        return False
    
    # Get annotation paths
    chords_path_rel = index_data["tracks"][track_id]["chords"][0]
    beats_path_rel = index_data["tracks"][track_id]["beat"][0]
    sections_path_rel = index_data["tracks"][track_id]["sections"][0]
    
    # Fix paths
    chords_path = fix_path(chords_path_rel)
    beats_path = fix_path(beats_path_rel)
    sections_path = fix_path(sections_path_rel)
    
    # Read annotation data
    chords_data = read_annotations(chords_path)
    beats_data = read_beats(beats_path)
    sections_data = read_annotations(sections_path)
    
    if not chords_data:
        print("Error: No chord data found.")
        return False
        
    # Extract metadata from path
    parts = chords_path_rel.split('/')
    title = "Do You Want To Know A Secret"
    album = "Please Please Me"
    
    if len(parts) >= 5:
        album_part = parts[-2]  # "01_-_Please_Please_Me"
        title_part = parts[-1].replace(".lab", "")  # "11_-_Do_You_Want_To_Know_A_Secret"
        album = album_part.replace("_-_", " - ")
        title = title_part.replace("_-_", " - ")
    
    # Now enhance the sample data
    # 1. Extend the section list with more sections
    extended_sections = sections_data.copy()
    
    # Add more sections to simulate a full song
    last_section = extended_sections[-1]
    last_end_time = last_section["end_time"]
    
    # Add verse sections
    extended_sections.append({
        "start_time": last_end_time,
        "end_time": last_end_time + 30.0,
        "label": "verse"
    })
    
    # Add chorus
    extended_sections.append({
        "start_time": last_end_time + 30.0,
        "end_time": last_end_time + 45.0,
        "label": "chorus"
    })
    
    # Add another verse
    extended_sections.append({
        "start_time": last_end_time + 45.0,
        "end_time": last_end_time + 75.0,
        "label": "verse"
    })
    
    # Add outro
    extended_sections.append({
        "start_time": last_end_time + 75.0,
        "end_time": last_end_time + 90.0,
        "label": "outro"
    })
    
    # 2. Add more chords
    extended_chords = chords_data.copy()
    
    # Define a typical Beatles chord progression for the added sections
    beatles_chords = [
        "E", "A", "B7", "E",  # Verse chords
        "A", "B7", "E", "C#m",  # More verse chords
        "A", "B", "E", "E7",  # Chorus chords
        "A", "B7", "G#m", "C#m"  # More chorus chords
    ]
    
    # Add these chords in the additional sections
    current_time = last_end_time
    chord_duration = 5.0  # 5 seconds per chord for demonstration
    
    for chord in beatles_chords:
        extended_chords.append({
            "start_time": current_time,
            "end_time": current_time + chord_duration,
            "label": chord
        })
        current_time += chord_duration
    
    # Create JCRD sections
    jcrd_sections = []
    
    for section in extended_sections:
        section_chords = []
        for chord in extended_chords:
            # If chord is within the section's time range
            if chord["start_time"] >= section["start_time"] and chord["end_time"] <= section["end_time"]:
                section_chords.append({
                    "chord": convert_chord_label(chord["label"]),
                    "start_time": chord["start_time"],
                    "end_time": chord["end_time"]
                })
        
        jcrd_sections.append({
            "name": section["label"],
            "start_time": section["start_time"],
            "end_time": section["end_time"],
            "chords": section_chords
        })
    
    # Create chord progression for entire song
    chord_progression = []
    for chord in extended_chords:
        chord_progression.append({
            "time": chord["start_time"],
            "chord": convert_chord_label(chord["label"]),
            "duration": chord["end_time"] - chord["start_time"]
        })
    
    # Create JCRD structure
    jcrd = {
        "metadata": {
            "title": title,
            "artist": "The Beatles",
            "album": album,
            "key": "E",  # The song is in E major
            "tempo": estimate_tempo(beats_data) if beats_data else 120,
            "time_signature": "4/4",  # Default time signature for Beatles
            "tags": ["beatles", "rock", "sample", "expanded"],
            "source": "Beatles Dataset (Enhanced Sample)"
        },
        "sections": jcrd_sections,
        "chord_progression": chord_progression
    }
    
    # Save to JCRD file
    output_path = os.path.join(target_dir, f"{track_id}_expanded.jcrd.json")
    
    with open(output_path, "w") as f:
        json.dump(jcrd, f, indent=2)
    
    print(f"Created enhanced sample JCRD file: {output_path}")
    return True

def main():
    """Main function to convert sample Beatles data."""
    print("=" * 80)
    print("Sample Beatles Dataset Converter")
    print("=" * 80)
    
    print("\nThis script will create an expanded version of the sample Beatles JCRD file.")
    print("It uses the existing sample data and adds more sections and chords to simulate a full song.")
    
    # Ensure the target directory exists
    os.makedirs(target_dir, exist_ok=True)
    print(f"Target directory: {target_dir}")
    
    # Process the sample file
    if enhance_sample_jcrd():
        print("\nSuccessfully created expanded sample Beatles JCRD file!")
        print("\nTo view the file details, run:")
        print(f"python tools/validate_full_beatles.py --file {os.path.join(target_dir, '0111_expanded.jcrd.json')}")
        return 0
    else:
        print("\nError creating expanded sample JCRD file.")
        return 1

if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
