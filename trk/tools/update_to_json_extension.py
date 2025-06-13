#!/usr/bin/env python3
"""
Update chordify_midi_to_jcrd_1.py to save files with .json extension instead of .jcrd.
This resolves the inconsistency between file extensions used in the codebase.
"""

import os
from pathlib import Path
import re


def update_chordify_script():
    """Update the chordify script to use .json extension"""
    script_path = (
        Path(__file__).resolve().parent / "chordify_midi_to_jcrd_1.py"
    )

    if not script_path.exists():
        print(f"Error: Script not found at {script_path}")
        return False

    with open(script_path, "r") as f:
        content = f.read()

    # Replace .jcrd references with .json
    new_content = re.sub(r'\.jcrd"', '.json"', content)
    new_content = re.sub(r"\.jcrd\)", ".json)", new_content)
    new_content = re.sub(r'f"{base}\.jcrd"', 'f"{base}.json"', new_content)

    if content == new_content:
        print("No changes needed in the script.")
        return False

    with open(script_path, "w") as f:
        f.write(new_content)

    print(f"Updated {script_path} to use .json extension")
    return True


def main():
    """Update scripts to consistently use .json extension"""
    print("Updating scripts to use .json extension consistently...")

    changes = update_chordify_script()

    if changes:
        print("\nScripts updated successfully.")
        print(
            "Now files will be saved with the .json extension, consistent with the rest of the codebase."
        )
    else:
        print(
            "\nNo changes were made. The script may already use .json or was not found."
        )


if __name__ == "__main__":
    main()
