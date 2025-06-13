#!/usr/bin/env python3
"""
Beatles JCRD Chord Chart Generator

This script creates a human-readable chord chart from a Beatles JCRD file.
"""

import os
import json
import sys
import math
from pathlib import Path

def format_time(time_in_seconds):
    """Format time in seconds to MM:SS.ms format."""
    minutes = int(time_in_seconds // 60)
    seconds = int(time_in_seconds % 60)
    ms = int((time_in_seconds % 1) * 100)
    return f"{minutes:02d}:{seconds:02d}.{ms:02d}"

def create_chord_chart(jcrd_data):
    """Create a readable chord chart from JCRD data."""
    metadata = jcrd_data.get("metadata", {})
    sections = jcrd_data.get("sections", [])
    
    # Generate the header
    chart = []
    chart.append("=" * 60)
    chart.append(f"Title: {metadata.get('title', 'Unknown')}")
    chart.append(f"Artist: {metadata.get('artist', 'Unknown')}")
    chart.append(f"Album: {metadata.get('album', 'Unknown')}")
    chart.append(f"Key: {metadata.get('key', 'Unknown')}")
    chart.append(f"Tempo: {metadata.get('tempo', 'Unknown')} BPM")
    chart.append(f"Time Signature: {metadata.get('time_signature', '4/4')}")
    chart.append("=" * 60)
    chart.append("")
    
    # Process each section
    for i, section in enumerate(sections, 1):
        section_name = section.get("name", f"Section {i}")
        start_time = section.get("start_time", 0)
        end_time = section.get("end_time", 0)
        chords = section.get("chords", [])
        
        # Add section header
        chart.append(f"[ {section_name.upper()} ]  ({format_time(start_time)} - {format_time(end_time)})")
        chart.append("-" * 60)
        
        # If no chords, note that
        if not chords:
            chart.append("No chords in this section")
            chart.append("")
            continue
        
        # Create a visual representation of chord progression
        # We'll do this by creating a grid representation
        
        # Calculate measures based on tempo (assuming 4/4 for simplicity)
        if metadata.get("tempo") and metadata.get("time_signature", "4/4") == "4/4":
            tempo = float(metadata.get("tempo"))
            beats_per_measure = 4
            beat_duration = 60 / tempo
            measure_duration = beat_duration * beats_per_measure
            section_duration = end_time - start_time
            
            # Simple visual timeline with chord positions
            timeline = []
            for measure in range(math.ceil(section_duration / measure_duration)):
                measure_start = start_time + (measure * measure_duration)
                measure_end = measure_start + measure_duration
                
                # Find chords in this measure
                measure_chords = []
                for chord in chords:
                    chord_start = chord.get("start_time", 0)
                    if measure_start <= chord_start < measure_end:
                        measure_chords.append(chord)
                
                if measure_chords:
                    # Format measure with chords
                    measure_text = f"Measure {measure+1}: "
                    for chord in measure_chords:
                        beat = ((chord.get("start_time", 0) - measure_start) / beat_duration) + 1
                        measure_text += f"[Beat {beat:.1f}: {chord.get('chord', 'Unknown')}] "
                    timeline.append(measure_text)
                else:
                    # No new chords in this measure
                    timeline.append(f"Measure {measure+1}: (continues)")
            
            chart.extend(timeline)
        
        # Also provide a simple chord sequence
        chart.append("")
        chart.append("Chord sequence:")
        
        for j, chord in enumerate(chords, 1):
            chord_name = chord.get("chord", "Unknown")
            start = chord.get("start_time", 0)
            end = chord.get("end_time", 0)
            
            # Calculate relative position in the section
            rel_start = start - section.get("start_time", 0)
            rel_end = end - section.get("start_time", 0)
            
            chart.append(f"  {j}. {chord_name:4} {format_time(rel_start)} - {format_time(rel_end)} " +
                         f"(duration: {rel_end - rel_start:.2f}s)")
        
        chart.append("")
    
    return "\n".join(chart)

def main():
    """Main function to generate chord charts for Beatles JCRD files."""
    # Find the script directory and project root
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    beatles_dir = os.path.join(project_root, "data", "jcrd_library", "beatles")
    
    if not os.path.exists(beatles_dir):
        beatles_dir = r"c:\Users\CraftAuto-Sales\AppData\Roaming\REAPER\Scripts\songbase\data\jcrd_library\beatles"
    
    if not os.path.exists(beatles_dir):
        print(f"Beatles directory not found: {beatles_dir}")
        return
    
    # Get list of Beatles JCRD files
    jcrd_files = [f for f in os.listdir(beatles_dir) if f.endswith(".jcrd.json")]
    
    if not jcrd_files:
        print(f"No JCRD files found in the Beatles directory.")
        return
    
    print(f"Found {len(jcrd_files)} Beatles JCRD files.\n")
    
    for file_name in jcrd_files:
        file_path = os.path.join(beatles_dir, file_name)
        
        try:
            with open(file_path, 'r') as f:
                jcrd_data = json.load(f)
            
            chord_chart = create_chord_chart(jcrd_data)
            print(chord_chart)
            
            # Also save to a file
            chart_file = os.path.join(project_root, "data", "chord_charts", f"{file_name.replace('.jcrd.json', '_chart.txt')}")
            
            # Create the directory if it doesn't exist
            chart_dir = os.path.dirname(chart_file)
            os.makedirs(chart_dir, exist_ok=True)
            
            with open(chart_file, 'w') as f:
                f.write(chord_chart)
            
            print(f"Chord chart saved to: {chart_file}\n")
            
        except (json.JSONDecodeError, FileNotFoundError) as e:
            print(f"Error with file {file_name}: {str(e)}")

if __name__ == "__main__":
    print("\n=== Beatles JCRD Chord Chart Generator ===\n")
    main()
    print("\n=== Chart Generation Complete ===\n")
