#!/usr/bin/env python3
"""
Copy JCRD files from mcgill_jcrd_salami to mcgill_jcrd directory.

This script helps populate the mcgill_jcrd directory with validated
JCRD files from the SALAMI dataset. You can use this as an example
of manipulating JCRD files between directories.
"""

import os
import shutil
import json
from pathlib import Path


def copy_files(source_dir, target_dir, count=10, filter_key=None):
    """
    Copy a subset of JCRD files from source to target directory.

    Args:
        source_dir: Path to source directory
        target_dir: Path to target directory
        count: Number of files to copy (default 10)
        filter_key: Optional key that must be present in the JCRD file
    """
    # Ensure target directory exists
    os.makedirs(target_dir, exist_ok=True)

    # Get list of JSON files in source directory
    files = [f for f in os.listdir(source_dir) if f.endswith(".json")]

    # Track number of files copied
    copied = 0

    print(f"Looking for JCRD files in {source_dir}...")

    # Copy files to target directory
    for filename in files:
        if copied >= count:
            break

        source_path = os.path.join(source_dir, filename)
        target_path = os.path.join(target_dir, filename)

        # Check for filter_key if specified
        if filter_key:
            try:
                with open(source_path, "r") as f:
                    data = json.load(f)
                if filter_key not in data:
                    continue
            except Exception as e:
                print(f"Error reading {filename}: {e}")
                continue

        # Copy the file
        shutil.copy2(source_path, target_path)
        copied += 1
        print(f"Copied {filename} to {target_dir}")

    print(f"Copied {copied} files to {target_dir}")


if __name__ == "__main__":
    # Set base paths
    base_dir = Path(__file__).resolve().parent.parent
    source_dir = os.path.join(base_dir, "jcrddatasets", "mcgill_jcrd_salami")
    target_dir = os.path.join(base_dir, "jcrddatasets", "mcgill_jcrd")

    # Copy files without filtering
    copy_files(source_dir, target_dir, count=10, filter_key=None)
