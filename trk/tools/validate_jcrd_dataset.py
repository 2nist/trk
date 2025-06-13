"""
TOOLBOX:
name: Validate .jcrd Files
description: Scans a directory of .jcrd files and logs any missing fields or malformed sections.
arguments:
  --directory: Folder to validate (default: mcgill_jcrd/)
"""

import os
import json
import argparse


def validate_jcrd_file(filepath):
    errors = []
    try:
        with open(filepath, "r") as f:
            data = json.load(f)

        if "title" not in data or not data["title"]:
            errors.append("Missing title")
        if "artist" not in data or not data["artist"]:
            errors.append("Missing artist")
        if "sections" not in data or not isinstance(data["sections"], list):
            errors.append("Missing or invalid sections array")
        else:
            for i, section in enumerate(data["sections"]):
                if "start_ms" not in section:
                    errors.append(f"Section {i+1} missing start_ms")
                if "duration_ms" not in section:
                    errors.append(f"Section {i+1} missing duration_ms")
                if "chords" not in section or not isinstance(
                    section["chords"], list
                ):
                    errors.append(f"Section {i+1} missing chords[]")
    except Exception as e:
        errors.append(f"Parse error: {e}")

    return errors


def main():
    parser = argparse.ArgumentParser(description="Validate .jcrd files")
    parser.add_argument(
        "--directory",
        default="mcgill_jcrd",
        help="Directory containing .jcrd files",
    )
    args = parser.parse_args()

    files = [f for f in os.listdir(args.directory) if f.endswith(".json")]
    total = len(files)
    broken = 0

    for filename in sorted(files):
        path = os.path.join(args.directory, filename)
        issues = validate_jcrd_file(path)
        if issues:
            print(f"❌ {filename}")
            for issue in issues:
                print(f"   - {issue}")
            broken += 1

    print(f"\n✅ Checked {total} files. {broken} issue(s) found.")


if __name__ == "__main__":
    main()
