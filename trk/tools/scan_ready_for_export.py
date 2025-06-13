"""
TOOLBOX:
name: Scan Ready-for-Export Files
description: Scans .jcrd files to detect which ones are ready for export (valid title, artist, bpm, key, beat_times, chords, and matching romanNumerals).
arguments:
  --directory: Folder with .jcrd files (default: mcgill_jcrd/)
  --output_ready: Optional path to copy "ready" files (default: none)
  --output_log: Optional path to log report (default: ready_report.txt)
"""

import os
import json
import argparse
import shutil


def is_ready(jcrd):
    required = ["title", "artist", "bpm", "key", "sections"]
    for field in required:
        if not jcrd.get(field):
            return False, [f"missing {field}"]

    problems = []
    for i, section in enumerate(jcrd["sections"]):
        if "start_ms" not in section or "duration_ms" not in section:
            problems.append(f"section {i} missing timing")
        chords = section.get("chords", [])
        roman = section.get("romanNumerals", [])
        if not chords:
            problems.append(f"section {i} missing chords")
        elif roman and len(roman) != len(chords):
            problems.append(f"section {i} mismatch chords/romanNumerals")

    return (len(problems) == 0), problems


def main():
    parser = argparse.ArgumentParser(
        description="Scan .jcrd files for export readiness"
    )
    parser.add_argument(
        "--directory", default="mcgill_jcrd", help="Source directory"
    )
    parser.add_argument(
        "--output_ready",
        default=None,
        help="Folder to copy export-ready files",
    )
    parser.add_argument(
        "--output_log", default="ready_report.txt", help="Log file path"
    )
    args = parser.parse_args()

    (
        os.makedirs(args.output_ready, exist_ok=True)
        if args.output_ready
        else None
    )
    log_lines = []

    for fname in sorted(os.listdir(args.directory)):
        if not fname.endswith(".json"):
            continue

        path = os.path.join(args.directory, fname)
        with open(path, "r") as f:
            try:
                jcrd = json.load(f)
            except Exception as e:
                log_lines.append(f"❌ {fname} → failed to parse: {e}")
                continue

        ready, issues = is_ready(jcrd)
        if ready:
            log_lines.append(f"✅ {fname} → ready")
            if args.output_ready:
                shutil.copy2(path, os.path.join(args.output_ready, fname))
        else:
            log_lines.append(f"❌ {fname} → " + "; ".join(issues))

    with open(args.output_log, "w") as log:
        log.write("\n".join(log_lines))
    print(f"📋 Scan complete. Report saved to {args.output_log}")


if __name__ == "__main__":
    main()
