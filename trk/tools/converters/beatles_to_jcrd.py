#!/usr/bin/env python3
"""
Beatles Dataset Converter

This script converts Beatles dataset annotations into JCRD format and saves them to the
jcrd_library directory. It uses the annotations found in the tests/resources directory.

Usage:
    python beatles_to_jcrd.py
"""

import os
import json
import sys
import re
import argparse
from pathlib import Path

# Add script directory to path to allow importing from parent directory
script_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(os.path.dirname(script_dir))
sys.path.append(parent_dir)

# Define paths
source_dir = os.path.join(parent_dir, "tests", "resources", "mir_datasets", "beatles", "annotations")
target_dir = os.path.join(parent_dir, "data", "jcrd_library", "beatles")
sample_index_path = os.path.join(parent_dir, "tests", "indexes", "beatles_index_1.2_sample.json")

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

def create_jcrd(track_id, track_data, index_data):
    """Create a JCRD file from track data."""
    # Try to extract title and album from chord path
    chords_path_rel = index_data["tracks"][track_id]["chords"][0] if "chords" in index_data["tracks"][track_id] else None
    
    if chords_path_rel:
        # Example path: annotations/chordlab/The Beatles/01_-_Please_Please_Me/11_-_Do_You_Want_To_Know_A_Secret.lab
        parts = chords_path_rel.split('/')
        if len(parts) >= 5:  # Has enough parts for album and title
            title_with_ext = parts[-1]  # "11_-_Do_You_Want_To_Know_A_Secret.lab"
            title = title_with_ext.replace(".lab", "").replace("_-_", " - ")
            album = parts[-2].replace("_-_", " - ")  # "01_-_Please_Please_Me"
        else:
            title = track_id
            album = "Unknown"
    else:
        title = track_id
        album = "Unknown"
    
    # Extract paths from the index
    try:
        chords_path_rel = index_data["tracks"][track_id]["chords"][0]
        beats_path_rel = index_data["tracks"][track_id]["beat"][0]
        keys_path_rel = index_data["tracks"][track_id]["keys"][0]
        sections_path_rel = index_data["tracks"][track_id]["sections"][0]
    except KeyError:
        print(f"Warning: Missing annotation paths for track {track_id}")
        return None
    
    # Debug print
    print(f"Track: {track_id}")
    print(f"Source dir: {source_dir}")
    print(f"Chord path from index: {chords_path_rel}")
    
    # Handle null paths in index
    if not chords_path_rel or not sections_path_rel:
        print(f"Warning: Missing required annotations for track {track_id}")
        return None
      # For the Beatles dataset, the paths in the index follow this format:
    # "annotations/chordlab/The Beatles/01_-_Please_Please_Me/11_-_Do_You_Want_To_Know_A_Secret.lab"
    # We need to extract just the relevant parts to build the correct path
    def fix_path(rel_path):
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
        
        fixed_path = os.path.join(source_dir, anno_type, remaining_path)
        print(f"Fixed path: {fixed_path}")
        return fixed_path
    
    chords_path = fix_path(chords_path_rel) if chords_path_rel else None
    beats_path = fix_path(beats_path_rel) if beats_path_rel else None
    keys_path = fix_path(keys_path_rel) if keys_path_rel else None
    sections_path = fix_path(sections_path_rel) if sections_path_rel else None
    
    # Check if the required files exist
    if not chords_path or not os.path.exists(chords_path):
        print(f"Warning: Chord annotations not found for track {track_id}")
        print(f"Attempted path: {chords_path}")
        return None
    
    # Read annotation data
    chords_data = read_annotations(chords_path) if chords_path and os.path.exists(chords_path) else []
    beats_data = read_beats(beats_path) if beats_path and os.path.exists(beats_path) else []
    keys_data = read_annotations(keys_path) if keys_path and os.path.exists(keys_path) else []
    sections_data = read_annotations(sections_path) if sections_path and os.path.exists(sections_path) else []
    
    # Create sections with chords
    jcrd_sections = []
    if sections_data and chords_data:
        for section in sections_data:
            section_chords = []
            for chord in chords_data:
                # If chord is within the section's time range
                if chord["start_time"] >= section["start_time"] and chord["end_time"] <= section["end_time"]:
                    section_chords.append({
                        "chord": convert_chord_label(chord["label"]),
                        "start_time": chord["start_time"] - section["start_time"],
                        "end_time": chord["end_time"] - section["start_time"]
                    })
            
            jcrd_sections.append({
                "name": section["label"],
                "start_time": section["start_time"],
                "end_time": section["end_time"],
                "chords": section_chords
            })
    elif chords_data:
        # If no sections but we have chords, create a single section
        jcrd_sections.append({
            "name": "Main",
            "start_time": chords_data[0]["start_time"],
            "end_time": chords_data[-1]["end_time"],
            "chords": [
                {
                    "chord": convert_chord_label(chord["label"]),
                    "start_time": chord["start_time"],
                    "end_time": chord["end_time"]
                }
                for chord in chords_data
            ]
        })
    
    # Determine key (use the most common key if multiple keys)
    key = "C"  # Default key
    if keys_data:
        # Simple heuristic: use the key with the longest duration
        key_durations = {}
        for key_anno in keys_data:
            duration = key_anno["end_time"] - key_anno["start_time"]
            if key_anno["label"] not in key_durations:
                key_durations[key_anno["label"]] = duration
            else:
                key_durations[key_anno["label"]] += duration
        
        if key_durations:
            key = max(key_durations.items(), key=lambda x: x[1])[0]
    
    # Create JCRD structure
    jcrd = {
        "metadata": {
            "title": title,
            "artist": "The Beatles",
            "album": album,
            "key": key,
            "tempo": estimate_tempo(beats_data) if beats_data else 120,
            "time_signature": "4/4",  # Default time signature
            "tags": ["beatles", "rock"],
            "source": "Beatles Dataset"
        },
        "sections": jcrd_sections
    }
    
    return jcrd

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

def main():
    # Load the sample index
    if not os.path.exists(sample_index_path):
        print(f"Error: Sample index file {sample_index_path} not found.")
        return
    
    with open(sample_index_path, "r") as f:
        index_data = json.load(f)
    
    # Process each track in the index
    for track_id in index_data["tracks"]:
        print(f"Processing track {track_id}...")
        jcrd_data = create_jcrd(track_id, index_data["tracks"][track_id], index_data)
        
        if jcrd_data:
            # Clean track_id for filename
            safe_track_id = track_id.replace("/", "_")
            output_path = os.path.join(target_dir, f"{safe_track_id}.jcrd.json")
            
            # Save to JCRD file
            with open(output_path, "w") as f:
                json.dump(jcrd_data, f, indent=2)
            
            print(f"Saved JCRD file to {output_path}")

if __name__ == "__main__":
    main()
    print("Conversion complete.")
