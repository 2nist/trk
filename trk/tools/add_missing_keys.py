#!/usr/bin/env python3
"""
Add key field to JCRD files that are missing it.

This script analyzes the chords in a JCRD file and determines the most likely key,
then adds or updates the "key" field in the file.
"""

import os
import json
import argparse
from pathlib import Path


# Simple key detection based on most common chords
def detect_key(chords):
    """
    Detect the most likely key based on chord prevalence.
    This is a very simplified approach - for production use,
    consider using a library like music21 for more accurate key detection.
    """
    if not chords:
        return "Unknown"

    # Count root notes in chords
    root_counts = {}
    for chord in chords:
        if chord == "N" or chord == "N.C.":
            continue

        # Extract root note from chord (e.g., "C:maj7" -> "C")
        root = (
            chord.split(":")[0]
            if ":" in chord
            else chord.split("_")[0] if "_" in chord else chord
        )

        # Handle special cases
        if root in ["N", "NC", "N.C."]:
            continue

        # Count occurrences
        root_counts[root] = root_counts.get(root, 0) + 1

    # Find most common root
    if not root_counts:
        return "Unknown"

    most_common_root = max(root_counts.items(), key=lambda x: x[1])[0]

    # Default to major for simplicity
    return f"{most_common_root} major"


def add_keys_to_jcrd_files(directory):
    """
    Add key field to all JCRD files in a directory.

    Args:
        directory: Path to directory containing JCRD files
    """
    # Ensure directory exists
    if not os.path.exists(directory):
        print(f"Directory not found: {directory}")
        return

    # Count files processed
    total_files = 0
    updated_files = 0

    # Process each JSON file
    for filename in os.listdir(directory):
        if not filename.endswith(".json"):
            continue

        total_files += 1
        file_path = os.path.join(directory, filename)

        try:
            # Load the JCRD file
            with open(file_path, "r") as f:
                data = json.load(f)

            # Skip if file already has a key field with content
            if data.get("key"):
                print(f"Skipping {filename}: Already has key '{data['key']}'")
                continue

            # Collect all chords from all sections
            all_chords = []
            for section in data.get("sections", []):
                all_chords.extend(section.get("chords", []))

            # Detect the key
            detected_key = detect_key(all_chords)

            # Add key to data
            data["key"] = detected_key

            # Save updated file
            with open(file_path, "w") as f:
                json.dump(data, f, indent=2)

            updated_files += 1
            print(f"Updated {filename}: Added key '{detected_key}'")

        except Exception as e:
            print(f"Error processing {filename}: {e}")

    print(
        f"\nProcessed {total_files} files. Updated {updated_files} files with key information."
    )


if __name__ == "__main__":
    # Parse command-line arguments
    parser = argparse.ArgumentParser(
        description="Add key field to JCRD files"
    )
    parser.add_argument(
        "--directory",
        default=None,
        help="Directory containing JCRD files (default: mcgill_jcrd)",
    )
    args = parser.parse_args()

    # Set directory based on arguments or default
    base_dir = Path(__file__).resolve().parent.parent
    target_dir = args.directory or os.path.join(
        base_dir, "jcrddatasets", "mcgill_jcrd"
    )

    # Process the directory
    add_keys_to_jcrd_files(target_dir)
