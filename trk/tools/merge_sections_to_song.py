# merge_sections_to_song.py
import json, sys, os
from pathlib import Path
import argparse

def merge_sections(paths, output):
    full_song = {
        "title": "Untitled Composition",
        "artist": "Unknown",
        "bpm": 120,
        "sections": [],
    }

    time_cursor = 0
    for path in paths:
        with open(path) as f:
            data = json.load(f)
            for section in data.get("sections", []):
                section["start_ms"] = time_cursor
                time_cursor += section.get("duration_ms", 4000)
                full_song["sections"].append(section)

    with open(output, "w") as f:
        json.dump(full_song, f, indent=2)
    print(f"✅ Merged {len(paths)} sections → {output}")

def parse_args():
    parser = argparse.ArgumentParser(description="Merge multiple .jcrd sections into one full song file.")
    parser.add_argument("input_files", nargs='+', help="Section files to merge")
    parser.add_argument("output", help="Output .jcrd path")
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()
    merge_sections(args.input_files, args.output)
