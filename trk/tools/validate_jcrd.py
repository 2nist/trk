# TOOLBOX:
# name: JCRD Validator & Fixer
# description: Validates and fixes JCRD files in a directory, saving results to another directory.
# arguments:
#   --input_dir: Source directory containing .jcrd files
#   --output_dir: Destination directory for fixed .jcrd files
#   --default-bpm: Default BPM if missing
#   --default-beats: Default beats per section if missing

import json
from pathlib import Path
from datetime import datetime

VALID_SECTION_TYPES = {
    "Verse",
    "Chorus",
    "Bridge",
    "Intro",
    "Outro",
    "Solo",
    "Instrumental",
    "Transition",
    "Fade-out",
    "Pre-chorus",
    "Post-chorus",
    "Break",
    "Interlude",
    "Tag",
    "Head",
    "Other",
}

VALID_SECTION_FUNCTIONS = {
    "Theme",
    "Development",
    "Exposition",
    "Transition",
    "Build-up",
    "Climax",
    "Release",
    "Bridge",
    "Coda",
    "Recapitulation",
    "Other",
}


def validate_and_fix_jcrd(
    input_dir, output_dir, default_bpm=120, default_beats=64
):
    input_dir = Path(input_dir)
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Input directory: {input_dir} (exists: {input_dir.exists()})")
    print(f"Output directory: {output_dir} (exists: {output_dir.exists()})")

    # List all files in the input directory
    all_files = list(input_dir.glob("*"))
    print(f"Found {len(all_files)} total files in input directory:")
    for f in all_files[:10]:  # Show first 10 files
        print(f"  - {f}")
    if len(all_files) > 10:
        print(f"  ... and {len(all_files) - 10} more")

    # Check for JSON files (the actual format we're using)
    json_files = list(input_dir.glob("*.json"))
    print(f"Found {len(json_files)} .json files in input directory")

    report = []
    if json_files:
        print("Processing JSON files...")
        for file_path in json_files:
            print(f"Processing JSON file: {file_path}")
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    data = json.load(f)

                changed = False
                bpm = data.get("bpm", default_bpm)
                ms_per_beat = 60000 / bpm

                # Print file structure for debugging (first file only)
                if len(report) == 0:
                    print(f"\nExample file structure for {file_path.name}:")
                    print(f"- Keys: {list(data.keys())}")
                    print(f"- Has sections: {'sections' in data}")
                    if "sections" in data:
                        print(
                            f"- Number of sections: {len(data['sections'])}"
                        )
                        if data["sections"]:
                            print(
                                f"- First section keys: {list(data['sections'][0].keys())}"
                            )

                # Validate required top-level fields
                if "title" not in data:
                    data["title"] = "Unknown Title"
                    changed = True
                if "artist" not in data:
                    data["artist"] = "Unknown Artist"
                    changed = True
                if "bpm" not in data:
                    data["bpm"] = default_bpm
                    changed = True  # Validate and fix sections
                for i, section in enumerate(data.get("sections", [])):
                    # Add missing required fields
                    if "start_ms" not in section:
                        section["start_ms"] = int(
                            i * default_beats * ms_per_beat
                        )
                        section["tags"] = section.get("tags", []) + [
                            "timing_missing",
                            "auto_duration",
                        ]
                        section["timing_confidence"] = "low"
                        changed = True

                    if "duration_ms" not in section:
                        section["duration_ms"] = int(
                            default_beats * ms_per_beat
                        )
                        section["tags"] = section.get("tags", []) + [
                            "timing_missing",
                            "auto_duration",
                        ]
                        section["timing_confidence"] = "low"
                        changed = True

                    if "id" not in section:
                        section["id"] = f"section_{i+1}"
                        changed = True

                    # Add/fix SALAMI fields if missing or invalid
                    if (
                        "sectionType" not in section
                        or section["sectionType"] not in VALID_SECTION_TYPES
                    ):
                        section["sectionType"] = "Other"
                        changed = True

                    if (
                        "sectionFunction" not in section
                        or section["sectionFunction"]
                        not in VALID_SECTION_FUNCTIONS
                    ):
                        section["sectionFunction"] = "Other"
                        changed = True

                    if "sectionLabel" not in section:
                        section["sectionLabel"] = f"section {i+1}"
                        changed = True

                    if (
                        "sectionLetter" not in section
                        or not section["sectionLetter"].strip()
                    ):
                        # Generate basic section letter (A, B, C, etc.)
                        section["sectionLetter"] = chr(65 + (i % 26))  # A-Z
                        changed = True  # Validate section letter format (A, A', B, etc.)
                    elif (
                        not section["sectionLetter"]
                        .replace("'", "")
                        .isalpha()
                    ):
                        section["sectionLetter"] = chr(65 + (i % 26))
                        changed = True

                    # Ensure chords array exists
                    if "chords" not in section:
                        section["chords"] = ["N.C."]  # No Chord
                        section["tags"] = section.get("tags", []) + [
                            "missing_chords"
                        ]
                        changed = True

                    # Optional: Validate chords are strings
                    if not all(isinstance(c, str) for c in section["chords"]):
                        section["chords"] = [
                            str(c) for c in section["chords"]
                        ]
                        changed = True

                if changed:
                    data["processed_by"] = "validate_jcrd.py"
                    data["fixed_at"] = datetime.utcnow().isoformat() + "Z"
                    output_path = output_dir / file_path.name
                    with open(output_path, "w", encoding="utf-8") as f:
                        json.dump(data, f, indent=2)
                    report.append(
                        f"[{file_path.name}] FIXED and saved to {output_path}"
                    )
                else:
                    report.append(f"[{file_path.name}] Already valid.")
            except Exception as e:
                print(f"Error processing {file_path}: {e}")
                report.append(f"[{file_path.name}] ERROR: {e}")
    else:
        print("No JSON files found to process!")

    # Print the report to ensure visibility
    print("\nValidation Report:")
    for line in report:
        print(line)

    print(
        f"\nProcessed {len(json_files)} files. Results saved in: {output_dir}"
    )
    return report


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Validate JCRD files")
    parser.add_argument(
        "--input_dir", required=True, help="Directory containing .jcrd files"
    )
    parser.add_argument(
        "--output_dir",
        required=True,
        help="Directory to save fixed .jcrd files",
    )
    parser.add_argument(
        "--default-bpm", type=int, default=120, help="Default BPM if missing"
    )
    parser.add_argument(
        "--default-beats",
        type=int,
        default=64,
        help="Default beats per section if missing",
    )
    args = parser.parse_args()

    print(f"\n=== JCRD Validator ===")
    print(f"Starting validation with:")
    print(f"- Input directory: {args.input_dir}")
    print(f"- Output directory: {args.output_dir}")
    print(f"- Default BPM: {args.default_bpm}")
    print(f"- Default beats: {args.default_beats}\n")

    results = validate_and_fix_jcrd(
        args.input_dir, args.output_dir, args.default_bpm, args.default_beats
    )

    print("\nValidation complete!")
