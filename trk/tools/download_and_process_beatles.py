#!/usr/bin/env python3
"""
Beatles Dataset Downloader and Converter

This script downloads, processes, and integrates the complete Beatles dataset into the Songbase system.
It handles downloading the annotations, organizing them, and converting them to JCRD format.

Usage:
    python download_and_process_beatles.py
"""

import os
import sys
import json
import zipfile
import requests
import shutil
from pathlib import Path
from tqdm import tqdm

# Add script directory to path to allow importing from parent directories
script_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(os.path.dirname(script_dir))
sys.path.append(parent_dir)

# Define paths
download_dir = os.path.join(parent_dir, "data", "source_archive", "beatles")
jcrd_target_dir = os.path.join(parent_dir, "data", "jcrd_library", "beatles")
temp_dir = os.path.join(parent_dir, "data", "staging_area", "beatles_processing")

# URLs for the Beatles dataset annotations
# The canonical source is the Isophonics website
DATASET_URLS = {
    "chords": "https://isophonics.net/files/annotations/The%20Beatles%20Annotations.zip",
    "beats": "https://isophonics.net/files/annotations/beat/The%20Beatles%20beat%20annotations.zip",
    "segments": "https://isophonics.net/files/annotations/segmentation/The%20Beatles%20segmentation%20annotations.zip",
    "keys": "https://isophonics.net/files/annotations/keys/The%20Beatles%20key%20annotations.zip",
}

def create_directories():
    """Create necessary directories if they don't exist."""
    os.makedirs(download_dir, exist_ok=True)
    os.makedirs(jcrd_target_dir, exist_ok=True)
    os.makedirs(temp_dir, exist_ok=True)
    print(f"Created directories:\n- {download_dir}\n- {jcrd_target_dir}\n- {temp_dir}")

def download_file(url, target_path):
    """Download a file with progress bar."""
    try:
        # Disable SSL verification as a last resort (not recommended for production)
        response = requests.get(url, stream=True, verify=False)
        response.raise_for_status()  # Raise exception for HTTP errors
        
        total_size = int(response.headers.get("content-length", 0))
        block_size = 1024  # 1 KB
        
        print(f"Downloading {os.path.basename(target_path)} ({total_size / 1024 / 1024:.2f} MB)...")
        
        with open(target_path, "wb") as f, tqdm(
            total=total_size, unit="B", unit_scale=True, unit_divisor=1024
        ) as progress_bar:
            for data in response.iter_content(block_size):
                f.write(data)
                progress_bar.update(len(data))
        
        return True
    
    except requests.RequestException as e:
        print(f"Error downloading {url}: {e}")
        
        # Provide alternative instructions
        print("\nAlternative download options:")
        print(f"1. Visit {url} manually in your browser")
        print(f"2. Download the file and save it as {target_path}")
        print(f"3. Then run this script again to continue processing")
        
        return False

def extract_zip(zip_path, extract_dir):
    """Extract a ZIP file."""
    try:
        with zipfile.ZipFile(zip_path, "r") as zip_ref:
            zip_ref.extractall(extract_dir)
        print(f"Extracted {zip_path} to {extract_dir}")
        return True
    
    except zipfile.BadZipFile as e:
        print(f"Error extracting {zip_path}: {e}")
        return False

def download_and_extract_datasets():
    """Download and extract all dataset files."""
    success = True
    
    for dataset_type, url in DATASET_URLS.items():
        # Create a subfolder for each type of annotation
        dataset_dir = os.path.join(download_dir, dataset_type)
        os.makedirs(dataset_dir, exist_ok=True)
        
        # Download the zip file
        zip_name = os.path.basename(url).replace("%20", "_")
        zip_path = os.path.join(dataset_dir, zip_name)
        
        if os.path.exists(zip_path):
            print(f"{zip_name} already exists, skipping download.")
        else:
            success = download_file(url, zip_path) and success
        
        # Extract the zip file
        if os.path.exists(zip_path):
            success = extract_zip(zip_path, dataset_dir) and success
    
    return success

def build_dataset_index():
    """Build a comprehensive index of all Beatles tracks with annotations."""
    print("Building Beatles dataset index...")
    
    # Find all available chord lab files
    chord_dir = os.path.join(download_dir, "chords")
    chord_files = []
    
    for root, dirs, files in os.walk(chord_dir):
        for file in files:
            if file.endswith(".lab"):
                rel_path = os.path.relpath(os.path.join(root, file), chord_dir)
                chord_files.append(rel_path)
    
    # Build track IDs and paths
    tracks = {}
    
    for chord_file in chord_files:
        # Get album name and track name from path
        try:
            parts = chord_file.split(os.sep)
            if len(parts) >= 3 and parts[0] == "The Beatles":
                album_name = parts[1]
                track_name = parts[2].replace(".lab", "")
                
                # Create a unique track ID
                track_id = f"{album_name}_{track_name}".replace(" ", "_").replace("-", "_")
                
                # Start building track paths
                chord_path = os.path.join("The Beatles", album_name, track_name + ".lab")
                
                # Find corresponding paths for other annotation types
                beat_path = find_annotation_path("beats", chord_path)
                segment_path = find_annotation_path("segments", chord_path)
                key_path = find_annotation_path("keys", chord_path)
                
                # Add to index
                tracks[track_id] = {
                    "album": album_name,
                    "track": track_name,
                    "annotations": {
                        "chords": os.path.join(chord_dir, chord_path) if chord_path else None,
                        "beats": os.path.join(download_dir, "beats", beat_path) if beat_path else None,
                        "segments": os.path.join(download_dir, "segments", segment_path) if segment_path else None,
                        "keys": os.path.join(download_dir, "keys", key_path) if key_path else None
                    }
                }
        except Exception as e:
            print(f"Error processing {chord_file}: {e}")
    
    # Save the index
    index_path = os.path.join(temp_dir, "beatles_index_full.json")
    with open(index_path, "w") as f:
        json.dump({"version": "1.0", "tracks": tracks}, f, indent=2)
    
    print(f"Created index with {len(tracks)} tracks at {index_path}")
    return index_path

def find_annotation_path(anno_type, chord_path):
    """Find corresponding annotation path for a given chord path."""
    anno_dir = os.path.join(download_dir, anno_type)
    if not os.path.exists(anno_dir):
        return None
    
    # Try exact match
    if os.path.exists(os.path.join(anno_dir, chord_path)):
        return chord_path
    
    # Try matching album and track name
    parts = chord_path.split(os.sep)
    if len(parts) >= 3:
        album_name = parts[1]
        track_name = parts[2].replace(".lab", "")
        
        # Search for files that contain the album and track name
        for root, dirs, files in os.walk(anno_dir):
            for file in files:
                if track_name in file and (album_name in root or album_name in file):
                    return os.path.relpath(os.path.join(root, file), anno_dir)
    
    return None

def read_annotations(file_path):
    """Read annotation files like chord, key, and sections."""
    annotations = []
    if not os.path.exists(file_path):
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
        return beats
    
    with open(file_path, "r") as f:
        for line in f.readlines():
            line = line.strip()
            if line and not line.startswith("#"):
                parts = line.split()
                if parts:
                    time = float(parts[0])
                    position = int(parts[1]) if len(parts) > 1 else 1
                    beats.append({
                        "time": time,
                        "position": position
                    })
    return beats

def convert_chord_label(label):
    """Convert a chord label to a simplified format."""
    import re
    
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

def convert_to_jcrd(track_id, track_data, index_data):
    """Convert a track to JCRD format."""
    # Extract paths
    chord_path = track_data["annotations"]["chords"]
    beat_path = track_data["annotations"]["beats"]
    segment_path = track_data["annotations"]["segments"]
    key_path = track_data["annotations"]["keys"]
    
    if not chord_path or not os.path.exists(chord_path):
        print(f"Skipping {track_id}: Chord annotations not found")
        return None
    
    # Read annotation data
    chords_data = read_annotations(chord_path)
    beats_data = read_beats(beat_path) if beat_path and os.path.exists(beat_path) else []
    segments_data = read_annotations(segment_path) if segment_path and os.path.exists(segment_path) else []
    keys_data = read_annotations(key_path) if key_path and os.path.exists(key_path) else []
    
    if not chords_data:
        print(f"Skipping {track_id}: No chord data found")
        return None
    
    # Extract metadata
    album = track_data["album"]
    title = track_data["track"]
    
    # Determine song key
    key = "Unknown"
    if keys_data:
        # Use the key with the longest duration
        key_durations = {}
        for key_anno in keys_data:
            duration = key_anno["end_time"] - key_anno["start_time"]
            if key_anno["label"] not in key_durations:
                key_durations[key_anno["label"]] = duration
            else:
                key_durations[key_anno["label"]] += duration
        
        if key_durations:
            key = max(key_durations.items(), key=lambda x: x[1])[0]
    
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
    
    # Create JCRD structure
    jcrd = {
        "metadata": {
            "title": title,
            "artist": "The Beatles",
            "album": album,
            "key": key,
            "tempo": estimate_tempo(beats_data) if beats_data else 120,
            "time_signature": "4/4",  # Default time signature
            "tags": ["beatles", "rock", album.lower().replace(" ", "_")],
            "source": "Isophonics Beatles Dataset"
        },
        "sections": sections,
        "chord_progression": chord_progression
    }
    
    return jcrd

def process_tracks(index_path):
    """Process all tracks in the index and convert to JCRD."""
    print("Converting Beatles tracks to JCRD format...")
    
    with open(index_path, "r") as f:
        index_data = json.load(f)
    
    total_tracks = len(index_data["tracks"])
    converted = 0
    
    for track_id, track_data in tqdm(index_data["tracks"].items(), total=total_tracks):
        jcrd_data = convert_to_jcrd(track_id, track_data, index_data)
        
        if jcrd_data:
            # Create safe filename
            safe_track_id = track_id.replace("/", "_").replace("\\", "_").replace(":", "_")
            output_path = os.path.join(jcrd_target_dir, f"{safe_track_id}.jcrd.json")
            
            # Save JCRD file
            with open(output_path, "w") as f:
                json.dump(jcrd_data, f, indent=2)
            
            converted += 1
    
    print(f"Successfully converted {converted}/{total_tracks} tracks to JCRD format")
    return converted

def main():
    """Main function to download and process the Beatles dataset."""
    print("=" * 80)
    print("Beatles Dataset Downloader and Converter")
    print("=" * 80)
    
    # Create directories
    create_directories()
    
    # Download and extract datasets
    print("\nStep 1: Downloading and extracting datasets...")
    if not download_and_extract_datasets():
        print("Error: Failed to download or extract one or more datasets.")
        return 1
    
    # Build dataset index
    print("\nStep 2: Building dataset index...")
    index_path = build_dataset_index()
    
    # Process tracks
    print("\nStep 3: Converting tracks to JCRD format...")
    converted = process_tracks(index_path)
    
    if converted > 0:
        print(f"\nSuccessfully converted {converted} Beatles tracks to JCRD format!")
        print(f"JCRD files are located in: {jcrd_target_dir}")
    else:
        print("\nError: No tracks were converted.")
        return 1
    
    return 0

if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
