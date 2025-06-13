#!/usr/bin/env python3
"""
chord_annotation_to_jcrd.py - Convert time-aligned chord annotations (e.g., .lab, .tsv) into .jcrd format
Supports formats like:
0.000 2.307 G:maj
2.307 4.655 C:maj
"""

import argparse
import json
import os

def parse_chord_file(filepath):
    # This function will be modified later to produce a list of chord events
    # suitable for the top-level "chords" array in our target JCRD structure.
    # For now, it keeps the structure that creates "sections" for each chord.
    chord_events = []
    with open(filepath, "r") as f:
        for i, line in enumerate(f):
            parts = line.strip().split()
            if len(parts) != 3:
                continue
            start_sec, end_sec, chord_label = parts
            
            # For direct conversion to the target JCRD chord structure:
            chord_event = {
                "time": float(start_sec),
                "duration": round(float(end_sec) - float(start_sec), 6), # Using 6 decimal places for precision
                "chord": chord_label
            }
            chord_events.append(chord_event)
    return chord_events

def convert_to_jcrd(input_file, title=None):
    filename = os.path.basename(input_file)
    default_title = os.path.splitext(filename)[0]
    
    # Prepare metadata
    metadata = {
        "title": title or default_title,
        "artist": "Unknown", # Placeholder
        "key": "", # Placeholder, could be inferred or passed as arg later
        "tempo": 120, # Placeholder, could be inferred or passed as arg later
        "source_format": "Chord Annotation File",
        "source_file": filename
    }

    # Parse the chord file into a list of chord events
    parsed_chord_events = parse_chord_file(input_file)

    # Construct the JCRD content
    jcrd_content = {
        "metadata": metadata,
        "chords": parsed_chord_events,
        "beats": [], # Placeholder, not typically in simple chord annotation files
        "sections": [] # Placeholder, could be derived or passed as arg later if needed
    }
    return jcrd_content

def main():
    parser = argparse.ArgumentParser(description="Convert a chord annotation file (e.g., .lab, .tsv) to JCRD format.")
    parser.add_argument("input", help="Path to input chord annotation file (e.g., .lab, .tsv)")
    parser.add_argument("output", help="Path to output .jcrd file")
    parser.add_argument("--title", help="Song title for JCRD metadata (optional)")
    # Future arguments could include --artist, --key, --tempo if they can't be inferred

    args = parser.parse_args()

    # Ensure output directory exists
    output_dir = os.path.dirname(args.output)
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir)
        print(f"Created output directory: {output_dir}")

    jcrd_data = convert_to_jcrd(args.input, args.title)

    with open(args.output, "w") as f:
        json.dump(jcrd_data, f, indent=2)

    print(f"Successfully converted '{args.input}' to '{args.output}'")

if __name__ == "__main__":
    main()
