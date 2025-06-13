"""
TOOLBOX:
name: Export REAPER Regions
description: Converts .jcrd sections into REAPER marker region format (.txt) with start time, duration, and label.
arguments:
  --directory: Folder with .jcrd files (default: mcgill_jcrd/)
  --output: Folder to save region .txt files (default: export/reaper_regions/)
"""

import os
import json
import argparse

def write_reaper_region_file(jcrd_data, out_path):
    lines = []
    for section in jcrd_data.get("sections", []):
        start_ms = section.get("start_ms")
        duration_ms = section.get("duration_ms")
        label = section.get("id", "section")

        if start_ms is None or duration_ms is None:
            continue

        start_sec = start_ms / 1000
        end_sec = (start_ms + duration_ms) / 1000
        lines.append(f"{start_sec:.6f}	{end_sec:.6f}	{label}")

    with open(out_path, "w") as f:
        f.write("
".join(lines))

def main():
    parser = argparse.ArgumentParser(description="Export .jcrd sections to REAPER region format")
    parser.add_argument("--directory", default="mcgill_jcrd", help="Directory with .jcrd files")
    parser.add_argument("--output", default="export/reaper_regions", help="Output folder for .txt files")
    args = parser.parse_args()

    os.makedirs(args.output, exist_ok=True)

    for fname in sorted(os.listdir(args.directory)):
        if not fname.endswith(".json"):
            continue

        path = os.path.join(args.directory, fname)
        with open(path, "r") as f:
            jcrd = json.load(f)

        title = jcrd.get("title", os.path.splitext(fname)[0]).replace(" ", "_")
        out_file = os.path.join(args.output, f"{title}_regions.txt")
        write_reaper_region_file(jcrd, out_file)
        print(f"📍 Exported REAPER regions for {title}")

if __name__ == "__main__":
    main()
