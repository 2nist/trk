#!/usr/bin/env python3
"""
Beatles JCRD Library Validator

This script validates the complete Beatles JCRD library and provides statistics about
the dataset integration. It can also display detailed information about individual songs.
"""

import os
import json
import sys
import argparse
from pathlib import Path
from datetime import timedelta
from collections import defaultdict

def format_time(seconds):
    """Format seconds to MM:SS.ms format."""
    minutes = int(seconds // 60)
    seconds_part = int(seconds % 60)
    ms = int((seconds % 1) * 100)
    return f"{minutes:02d}:{seconds_part:02d}.{ms:02d}"

def get_jcrd_files(jcrd_dir):
    """Get all JCRD files in a directory."""
    return [f for f in os.listdir(jcrd_dir) if f.endswith(".jcrd.json")]

def analyze_jcrd_file(file_path):
    """Analyze a JCRD file and return statistics."""
    with open(file_path, "r", encoding='utf-8') as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError:
            return {"error": "Invalid JSON"}
    
    stats = {
        "title": data.get("metadata", {}).get("title", "Unknown"),
        "artist": data.get("metadata", {}).get("artist", "Unknown"),
        "album": data.get("metadata", {}).get("album", "Unknown"),
        "key": data.get("metadata", {}).get("key", "Unknown"),
        "tempo": data.get("metadata", {}).get("tempo", 0),
        "sections": len(data.get("sections", [])),
        "section_names": set(),
        "chord_count": len(data.get("chord_progression", [])),
        "unique_chords": set(),
        "duration": 0
    }
    
    # Get section names and total duration
    max_time = 0
    for section in data.get("sections", []):
        stats["section_names"].add(section.get("name", "Unknown"))
        end_time = section.get("end_time", 0)
        if end_time > max_time:
            max_time = end_time
    
    stats["duration"] = max_time
    
    # Get unique chords
    for chord in data.get("chord_progression", []):
        stats["unique_chords"].add(chord.get("chord", "N"))
    
    return stats

def display_file_details(file_path):
    """Display detailed information about a JCRD file."""
    try:
        with open(file_path, "r", encoding='utf-8') as f:
            data = json.load(f)
        
        meta = data.get("metadata", {})
        sections = data.get("sections", [])
        chords = data.get("chord_progression", [])
        
        print("\n" + "=" * 80)
        print(f"FILE: {os.path.basename(file_path)}")
        print("=" * 80)
        
        # Display metadata
        print(f"Title:      {meta.get('title', 'Unknown')}")
        print(f"Artist:     {meta.get('artist', 'Unknown')}")
        print(f"Album:      {meta.get('album', 'Unknown')}")
        print(f"Key:        {meta.get('key', 'Unknown')}")
        print(f"Tempo:      {meta.get('tempo', 'Unknown')} BPM")
        print(f"Time Sig:   {meta.get('time_signature', 'Unknown')}")
        print(f"Tags:       {', '.join(meta.get('tags', []))}")
        print(f"Source:     {meta.get('source', 'Unknown')}")
        
        # Find song duration
        max_time = 0
        for section in sections:
            end_time = section.get("end_time", 0)
            if end_time > max_time:
                max_time = end_time
                
        print(f"Duration:   {format_time(max_time)} ({max_time:.2f}s)")
        
        # Display sections
        print("\nSECTIONS:")
        print("-" * 80)
        print(f"{'#':<3} {'Name':<15} {'Start':<10} {'End':<10} {'Duration':<10} {'Chords'}")
        print("-" * 80)
        
        for i, section in enumerate(sections):
            name = section.get("name", "Unknown")
            start = section.get("start_time", 0)
            end = section.get("end_time", 0)
            duration = end - start
            section_chords = section.get("chords", [])
            
            print(f"{i+1:<3} {name:<15} {format_time(start):<10} {format_time(end):<10} " +
                 f"{duration:.2f}s{' ':<5} {len(section_chords)}")
        
        # Display chord progression summary
        print("\nCHORD PROGRESSION:")
        print(f"Total chords: {len(chords)}")
        
        # Count chord frequencies
        chord_counts = defaultdict(int)
        for chord in chords:
            chord_name = chord.get("chord", "N")
            chord_counts[chord_name] += 1
        
        # Display most common chords
        print("\nMost common chords:")
        for chord, count in sorted(chord_counts.items(), key=lambda x: x[1], reverse=True)[:10]:
            percentage = (count / len(chords)) * 100 if chords else 0
            print(f"{chord:<5}: {count} occurrences ({percentage:.1f}%)")
        
        # Display sample of the chord progression
        print("\nChord progression sample (first 10):")
        for i, chord in enumerate(chords[:10]):
            time = chord.get("time", 0)
            name = chord.get("chord", "N")
            duration = chord.get("duration", 0)
            print(f"{i+1:<3} {format_time(time):<8} {name:<5} ({duration:.2f}s)")
        
        if len(chords) > 10:
            print(f"... and {len(chords)-10} more chords")
        
        print("\n" + "=" * 80)
        return True
    
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

def analyze_library(jcrd_dir):
    """Analyze the entire JCRD library and provide statistics."""
    jcrd_files = get_jcrd_files(jcrd_dir)
    
    if not jcrd_files:
        print(f"No JCRD files found in {jcrd_dir}")
        return False
    
    print(f"Found {len(jcrd_files)} JCRD files in the Beatles library")
    
    # Collect statistics
    total_sections = 0
    total_chords = 0
    total_duration = 0
    all_section_names = set()
    all_chord_types = set()
    albums = defaultdict(int)
    keys = defaultdict(int)
    tempos = []
    
    for file_name in jcrd_files:
        file_path = os.path.join(jcrd_dir, file_name)
        stats = analyze_jcrd_file(file_path)
        
        if "error" in stats:
            print(f"Error in {file_name}: {stats['error']}")
            continue
        
        total_sections += stats["sections"]
        total_chords += stats["chord_count"]
        total_duration += stats["duration"]
        all_section_names.update(stats["section_names"])
        all_chord_types.update(stats["unique_chords"])
        albums[stats["album"]] += 1
        keys[stats["key"]] += 1
        
        if stats["tempo"] > 0:
            tempos.append(stats["tempo"])
    
    # Calculate averages
    avg_sections = total_sections / len(jcrd_files) if jcrd_files else 0
    avg_chords = total_chords / len(jcrd_files) if jcrd_files else 0
    avg_duration = total_duration / len(jcrd_files) if jcrd_files else 0
    avg_tempo = sum(tempos) / len(tempos) if tempos else 0
    
    # Display statistics
    print("\n" + "=" * 80)
    print("BEATLES JCRD LIBRARY STATISTICS")
    print("=" * 80)
    print(f"Total songs:           {len(jcrd_files)}")
    print(f"Total sections:        {total_sections}")
    print(f"Total chords:          {total_chords}")
    print(f"Total duration:        {format_time(total_duration)} ({total_duration/60:.2f} minutes)")
    print(f"Average sections/song: {avg_sections:.2f}")
    print(f"Average chords/song:   {avg_chords:.2f}")
    print(f"Average song duration: {format_time(avg_duration)} ({avg_duration:.2f} seconds)")
    print(f"Average tempo:         {avg_tempo:.2f} BPM")
    
    print("\nUnique section types:")
    for section in sorted(all_section_names):
        print(f"  - {section}")
    
    print("\nUnique chord types:")
    for chord in sorted(all_chord_types):
        print(f"  - {chord}")
    
    print("\nAlbums:")
    for album, count in sorted(albums.items(), key=lambda x: x[1], reverse=True):
        print(f"  - {album}: {count} songs")
    
    print("\nKeys:")
    for key, count in sorted(keys.items(), key=lambda x: x[1], reverse=True):
        print(f"  - {key}: {count} songs")
    
    return True

def main():
    parser = argparse.ArgumentParser(description="Validate and analyze Beatles JCRD library")
    parser.add_argument("--file", help="Display details for a specific JCRD file")
    parser.add_argument("--all", action="store_true", help="Analyze the entire JCRD library")
    parser.add_argument("--sample", type=int, default=5, help="Number of files to sample (default: 5)")
    parser.add_argument("--expanded", action="store_true", help="Use the expanded Beatles directory")
    args = parser.parse_args()
    
    # Find the script directory and project root
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    
    # Determine which directory to use
    if args.expanded:
        jcrd_dir = os.path.join(project_root, "data", "jcrd_library", "beatles_expanded")
    else:
        jcrd_dir = os.path.join(project_root, "data", "jcrd_library", "beatles")
    
    # If direct file path is provided
    if args.file and os.path.exists(args.file):
        return display_file_details(args.file)
    
    # Check if directory exists
    if not os.path.exists(jcrd_dir):
        # Try with different paths
        alt_paths = [
            os.path.join(project_root, "data", "jcrd_library", "beatles"),
            os.path.join(project_root, "data", "jcrd_library", "beatles_expanded"),
            os.path.join("c:\\Users\\CraftAuto-Sales\\AppData\\Roaming\\REAPER\\Scripts", "data", "jcrd_library", "beatles"),
            os.path.join("c:\\Users\\CraftAuto-Sales\\AppData\\Roaming\\REAPER\\Scripts", "data", "jcrd_library", "beatles_expanded")
        ]
        
        for path in alt_paths:
            if os.path.exists(path):
                jcrd_dir = path
                print(f"Using alternative Beatles directory: {jcrd_dir}")
                break
        else:
            print(f"Beatles JCRD directory not found at any of these locations:")
            for path in alt_paths:
                print(f" - {path}")
            return 1
    
    # Handle specific file
    if args.file:
        file_path = os.path.join(jcrd_dir, args.file)
        if not file_path.endswith(".jcrd.json"):
            file_path += ".jcrd.json"
        
        if not os.path.exists(file_path):
            print(f"File not found: {file_path}")
            return 1
        
        display_file_details(file_path)
        return 0
    
    # Analyze entire library
    if args.all:
        analyze_library(jcrd_dir)
        return 0
    
    # Default: show summary and sample a few files
    jcrd_files = get_jcrd_files(jcrd_dir)
    
    if not jcrd_files:
        print(f"No JCRD files found in {jcrd_dir}")
        return 1
    
    print(f"Found {len(jcrd_files)} Beatles JCRD files")
    
    # Display sample files
    sample_size = min(args.sample, len(jcrd_files))
    sample_files = jcrd_files[:sample_size]
    
    for file_name in sample_files:
        display_file_details(os.path.join(jcrd_dir, file_name))
    
    print(f"\nShowing {sample_size} of {len(jcrd_files)} files")
    print(f"To see more files, use --sample N")
    print(f"To see library statistics, use --all")
    print(f"To see details for a specific file, use --file FILENAME")
    
    return 0

if __name__ == "__main__":
    print("\n=== Beatles JCRD Library Validator ===\n")
    sys.exit(main())
