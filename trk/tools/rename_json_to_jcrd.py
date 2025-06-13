#!/usr/bin/env python3
"""
Rename all .json JCRD files to use .jcrd extension.
This script will search specified directories and rename files.
"""

import os
import argparse
import shutil
from pathlib import Path


def rename_jcrd_files(directory, dry_run=False):
    """
    Rename .json files to .jcrd in the specified directory
    """
    directory = Path(directory)
    if not directory.exists():
        print(f"Directory does not exist: {directory}")
        return

    renamed = 0

    # Find all .json files
    for json_file in directory.glob("*.json"):
        # Check if the file actually contains JCRD data
        try:
            with open(json_file, "r") as f:
                content = f.read(500)  # Read just enough to check format
                if '"title":' in content and (
                    '"sections":' in content or '"bpm":' in content
                ):
                    # This looks like a JCRD file
                    jcrd_file = json_file.with_suffix(".jcrd")

                    if not dry_run:
                        # First make a copy, then remove the original
                        shutil.copy2(json_file, jcrd_file)
                        os.remove(json_file)

                    print(
                        f"{'Would rename' if dry_run else 'Renamed'}: {json_file.name} → {jcrd_file.name}"
                    )
                    renamed += 1
        except Exception as e:
            print(f"Error processing {json_file}: {e}")

    return renamed


def main():
    parser = argparse.ArgumentParser(
        description="Rename JCRD .json files to use .jcrd extension"
    )
    parser.add_argument(
        "--directory", required=True, help="Directory containing JCRD files"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be renamed without making changes",
    )
    args = parser.parse_args()

    count = rename_jcrd_files(args.directory, args.dry_run)
    action = "Would rename" if args.dry_run else "Renamed"
    print(f"\n{action} {count} files in {args.directory}")

    if not args.dry_run and count > 0:
        print(
            "\nIMPORTANT: You will need to update any scripts that expect .json files to look for .jcrd files."
        )


if __name__ == "__main__":
    main()
