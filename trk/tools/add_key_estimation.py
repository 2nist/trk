"""
TOOLBOX:
name: Add Key Estimation
description: Analyzes chords in .jcrd files and estimates the key using Music21. Adds "key" field to the song if missing.
arguments:
  --directory: Folder containing .jcrd files (default: mcgill_jcrd/)
"""

import os
import json
import argparse
from music21 import key, chord, stream


def estimate_key_from_chords(chord_list):
    try:
        s = stream.Stream()
        for ch in chord_list:
            try:
                s.append(chord.Chord(ch))
            except Exception:
                continue
        return s.analyze("key").name
    except Exception as e:
        print(f"Key estimation error: {e}")
        return "Unknown"


def collect_chords(data):
    all_chords = []
    for section in data.get("sections", []):
        all_chords.extend(section.get("chords", []))
    return all_chords


def main():
    parser = argparse.ArgumentParser(description="Add key to .jcrd files")
    parser.add_argument(
        "--directory",
        default="mcgill_jcrd",
        help="Directory with .jcrd files",
    )
    args = parser.parse_args()

    for filename in sorted(os.listdir(args.directory)):
        if not filename.endswith(".json"):
            continue

        fpath = os.path.join(args.directory, filename)
        with open(fpath, "r") as f:
            data = json.load(f)

        if "key" not in data or not data["key"]:
            chords = collect_chords(data)
            detected_key = estimate_key_from_chords(chords)
            data["key"] = detected_key
            with open(fpath, "w") as f:
                json.dump(data, f, indent=2)
            print(f"✅ Added key '{detected_key}' to {filename}")


if __name__ == "__main__":
    main()
