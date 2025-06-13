#!/usr/bin/env python3
"""
Convert Beatles Annotations to JCRD Format

This script converts the extracted Beatles annotations to JCRD format.
It processes all albums and songs in the Beatles dataset.
"""

import os
import sys
import json
import re
import argparse
from pathlib import Path
from collections import defaultdict

def read_annotations(file_path):
    """Read annotation files like chord, key, and sections."""
    annotations = []
    if not os.path.exists(file_path):
        print(f"Warning: File {file_path} does not exist.")
        return annotations
    
    with open(file_path, "r", encoding='utf-8', errors='ignore') as f:
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
    
    with open(file_path, "r", encoding='utf-8', errors='ignore') as f:
        for line in f.readlines():
            line = line.strip()
            if line and not line.startswith("#"):
                parts = line.split()
                if parts:
                    try:
                        time = float(parts[0])
                        try:
                            position = int(parts[1]) if len(parts) > 1 and parts[1].isdigit() else 1
                        except (ValueError, IndexError):
                            position = 1
                        
                        beats.append({
                            "time": time,
                            "position": position
                        })
                    except (ValueError, IndexError) as e:
                        print(f"Warning: Could not parse beat line '{line}': {e}")
                        continue
    return beats

def convert_chord_label(label):
    """Convert a chord label to a simplified format."""
    # Handle "N" (no chord) case
    if label == "N":
        return "N"
    
    # Extract root note
    match = re.match(r"([A-G][b#]?)", label)
    if not match:
        return "N"  # Default to N if no root found
    
    root = match.group(1)
    
    # Extract chord quality
    quality = ""
    if ":min" in label or ":m" in label:
        quality = "m"
    elif ":maj" in label or ":M" in label:
        quality = "maj"
    elif ":dim" in label:
        quality = "dim"
    elif ":aug" in label:
        quality = "aug"
    elif ":sus" in label:
        quality = "sus"
    
    # Extract extensions/additions
    extensions = ""
    if "7" in label:
        extensions = "7"
    elif "6" in label:
        extensions = "6"
    elif "9" in label:
        extensions = "9"
    
    return f"{root}{quality}{extensions}"

def estimate_tempo(beats):
    """Estimate tempo from beat annotations."""
    if not beats or len(beats) < 2:
        return 120  # Default tempo
    
    # Calculate average time between beats
    beat_times = [beat["time"] for beat in beats]
    intervals = [beat_times[i+1] - beat_times[i] for i in range(len(beat_times)-1)]
    
    # Filter out outliers (e.g., long pauses)
    filtered_intervals = [i for i in intervals if i < 2.0]  # Ignore intervals > 2s
    
    if not filtered_intervals:
        return 120
    
    avg_interval = sum(filtered_intervals) / len(filtered_intervals)
    
    # Convert to BPM
    tempo = 60 / avg_interval if avg_interval > 0 else 120
    
    return round(tempo)

def extract_key_from_annotations(key_annotations):
    """Extract the key from key annotations."""
    if not key_annotations:
        return "C"  # Default key
    
    # Use the key with the longest duration
    key_durations = defaultdict(float)
    for key_anno in key_annotations:
        duration = key_anno["end_time"] - key_anno["start_time"]
        key_durations[key_anno["label"]] += duration
    
    if key_durations:
        return max(key_durations.items(), key=lambda x: x[1])[0]
    
    return "C"  # Default key

def convert_to_jcrd(album_name, track_name, chord_path, beat_path, segment_path, key_path, output_dir):
    """Convert a track's annotations to JCRD format."""
    # Read annotation data
    chords_data = read_annotations(chord_path) if os.path.exists(chord_path) else []
    beats_data = read_beats(beat_path) if beat_path and os.path.exists(beat_path) else []
    segments_data = read_annotations(segment_path) if segment_path and os.path.exists(segment_path) else []
    keys_data = read_annotations(key_path) if key_path and os.path.exists(key_path) else []
    
    if not chords_data:
        print(f"Warning: No chord data for {track_name}")
        return False
    
    # Calculate song end time
    end_time = max([chord["end_time"] for chord in chords_data]) if chords_data else 0
    
    # Create chord progression list
    chord_progression = []
    for chord in chords_data:
        chord_progression.append({
            "time": chord["start_time"],
            "chord": convert_chord_label(chord["label"]),
            "duration": chord["end_time"] - chord["start_time"]
        })
    
    # Determine song key
    key = extract_key_from_annotations(keys_data)
    
    # Create sections with embedded chords
    sections = []
    if segments_data:
        for segment in segments_data:
            section = {
                "name": segment["label"],
                "start_time": segment["start_time"],
                "end_time": segment["end_time"],
                "chords": []
            }
            
            # Add chords that fall within this section
            for chord in chords_data:
                if chord["start_time"] >= segment["start_time"] and chord["end_time"] <= segment["end_time"]:
                    section["chords"].append({
                        "chord": convert_chord_label(chord["label"]),
                        "start_time": chord["start_time"],
                        "end_time": chord["end_time"]
                    })
            
            sections.append(section)
    else:
        # If no sections, create a single main section
        sections.append({
            "name": "Main",
            "start_time": 0.0,
            "end_time": end_time,
            "chords": [
                {
                    "chord": convert_chord_label(chord["label"]),
                    "start_time": chord["start_time"],
                    "end_time": chord["end_time"]
                }
                for chord in chords_data
            ]
        })
    
    # Clean up track and album names
    clean_album = album_name.replace("_-_", " - ")
    clean_track = track_name.replace("_-_", " - ").replace(".lab", "")
    
    # Create unique track ID
    track_id = f"{album_name}_{track_name}".replace(".lab", "")
      # Create JCRD structure
    jcrd = {
        "metadata": {
            "title": clean_track,
            "artist": "The Beatles",
            "album": clean_album,
            "key": key,
            "tempo": estimate_tempo(beats_data) if beats_data else 120,
            "time_signature": "4/4",  # Default time signature for Beatles
            "tags": ["beatles", "rock", clean_album.lower().replace(" ", "_").replace("'", "")],
            "source": "Isophonics Beatles Dataset"
        },
        "sections": sections,
        "chord_progression": chord_progression
    }
    
    # Add beat information if available
    if beats_data:
        beats_list = []
        for beat in beats_data:
            beats_list.append({
                "time": beat["time"],
                "position": beat["position"]
            })
        jcrd["beats"] = beats_list
    
    # Save to JCRD file
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, f"{track_id}.jcrd.json")
    
    with open(output_path, "w", encoding='utf-8') as f:
        json.dump(jcrd, f, indent=2)
    
    print(f"Created JCRD file: {output_path}")
    return True

def process_beatles_dataset(source_dir, output_dir):
    """Process all Beatles albums and tracks."""
    # Define paths to annotation directories
    chord_dir = os.path.join(source_dir, "chordlab", "The Beatles")
    beat_dir = os.path.join(source_dir, "beat", "The Beatles")
    segment_dir = os.path.join(source_dir, "seglab", "The Beatles")
    key_dir = os.path.join(source_dir, "keylab", "The Beatles")
    
    # Check if directories exist
    if not os.path.exists(chord_dir):
        print(f"Error: Chord directory not found: {chord_dir}")
        return False
    
    # Process each album
    albums = os.listdir(chord_dir)
    total_tracks = 0
    converted_tracks = 0
    
    print(f"Found {len(albums)} albums")
    
    for album_name in albums:
        album_chord_dir = os.path.join(chord_dir, album_name)
        if not os.path.isdir(album_chord_dir):
            continue
            
        tracks = [f for f in os.listdir(album_chord_dir) if f.endswith(".lab")]
        print(f"Processing album '{album_name}' with {len(tracks)} tracks")
        
        total_tracks += len(tracks)
        
        for track_name in tracks:
            chord_path = os.path.join(chord_dir, album_name, track_name)
            beat_path = os.path.join(beat_dir, album_name, track_name.replace(".lab", ".txt"))
            segment_path = os.path.join(segment_dir, album_name, track_name)
            key_path = os.path.join(key_dir, album_name, track_name)
            
            if convert_to_jcrd(album_name, track_name, chord_path, beat_path, segment_path, key_path, output_dir):
                converted_tracks += 1
    
    print(f"\nSummary:")
    print(f"  Total tracks: {total_tracks}")
    print(f"  Converted tracks: {converted_tracks}")
    
    return converted_tracks > 0

def main():
    parser = argparse.ArgumentParser(description="Convert Beatles annotations to JCRD format")
    parser.add_argument("--source", default="data/source_archive/beatles/chords", help="Source directory for Beatles annotations")
    parser.add_argument("--output", default="data/jcrd_library/beatles_full", help="Output directory for JCRD files")
    
    args = parser.parse_args()
    
    print(f"Source directory: {args.source}")
    print(f"Output directory: {args.output}")
    
    if process_beatles_dataset(args.source, args.output):
        print("Conversion completed successfully!")
        return 0
    else:
        print("Conversion failed.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
