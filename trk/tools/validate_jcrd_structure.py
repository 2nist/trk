"""
TOOLBOX:
name: Validate .jcrd File Structure
description: Validates presence and consistency of title, artist, bpm, sections, chords, romanNumerals, key, and optional beat_times.
arguments:
  --directory: Folder with .jcrd files (default: mcgill_jcrd/)
"""

import os
import json
import argparse


def validate_file(path):
    try:
        with open(path, "r") as f:
            data = json.load(f)

        filename = os.path.basename(path)
        results = []

        if not data.get("title"):
            results.append("missing title")
        if not data.get("artist"):
            results.append("missing artist")
        if not isinstance(data.get("bpm"), (int, float)):
            results.append("invalid bpm")
        if "key" not in data:
            results.append("missing key")

        sections = data.get("sections", [])
        if not sections:
            results.append("no sections")
        else:
            for i, sec in enumerate(sections):
                if "start_ms" not in sec or "duration_ms" not in sec:
                    results.append(f"section {i} missing timing")
                chords = sec.get("chords", [])
                if not chords:
                    results.append(f"section {i} has no chords")
                roman = sec.get("romanNumerals", [])
                if roman and len(roman) != len(chords):
                    results.append(
                        f"section {i} mismatch chords/romanNumerals"
                    )

        beat_times = data.get("beat_times", [])
        if beat_times and not isinstance(beat_times, list):
            results.append("beat_times present but malformed")

        return filename, results

    except Exception as e:
        return os.path.basename(path), [f"exception: {e}"]


def main():
    parser = argparse.ArgumentParser(
        description="Validate .jcrd file structure"
    )
    parser.add_argument(
        "--directory",
        default="mcgill_jcrd",
        help="Folder containing .jcrd files",
    )
    args = parser.parse_args()

    files = [f for f in os.listdir(args.directory) if f.endswith(".json")]
    print(f"Validating {len(files)} files...\n")

    for fname in sorted(files):
        path = os.path.join(args.directory, fname)
        filename, issues = validate_file(path)
        if not issues:
            print(f"✅ {filename}")
        else:
            print(f"❌ {filename} → " + "; ".join(issues))


if __name__ == "__main__":
    main()
