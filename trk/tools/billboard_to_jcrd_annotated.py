"""
Convert McGill Billboard dataset to .jcrd format using the dataset's existing section annotations.
"""

import os
import json
import mirdata
import re
from typing import Dict, List, Optional, Tuple


def slugify(text: str) -> str:
    """Convert text to a URL-friendly slug."""
    return re.sub(r"[^a-z0-9]+", "_", text.lower()).strip("_")


def get_section_info(label: str, section_num: int) -> Tuple[str, str, str]:
    """
    Map McGill Billboard section labels to JCRD section types.
    """
    label_lower = label.lower()

    # Default values
    section_type = "Other"
    section_letter = chr(65 + (section_num % 26))  # A, B, C, etc.
    section_function = "Development"

    # Map common section labels
    if "verse" in label_lower:
        section_type = "Verse"
        section_function = "Theme"
    elif "chorus" in label_lower:
        section_type = "Chorus"
        section_function = "Climax"
    elif "bridge" in label_lower:
        section_type = "Bridge"
        section_function = "Bridge"
    elif "intro" in label_lower:
        section_type = "Intro"
        section_function = "Exposition"
    elif "outro" in label_lower or "ending" in label_lower:
        section_type = "Outro"
        section_function = "Coda"
    elif "solo" in label_lower:
        section_type = "Solo"
        section_function = "Development"
    elif "pre-chorus" in label_lower or "pre chorus" in label_lower:
        section_type = "Pre-chorus"
        section_function = "Build-up"
    elif "instrumental" in label_lower:
        section_type = "Instrumental"
        section_function = "Development"

    # Assign section letter based on type to maintain consistency
    if section_type == "Verse":
        section_letter = "A"
    elif section_type == "Chorus":
        section_letter = "B"
    elif section_type == "Bridge":
        section_letter = "C"
    elif section_type == "Pre-chorus":
        section_letter = "P"

    # Add prime notation for repeated sections
    if any(
        x in label_lower for x in ["2", "3", "4", "ii", "iii", "iv", "repeat"]
    ):
        section_letter += "'"

    return section_type, section_letter, section_function


def safe_float(value) -> float:
    """Convert a value to float, handling NumPy types."""
    try:
        if hasattr(value, "item"):
            return float(value.item())
        return float(value)
    except (ValueError, AttributeError):
        return 0.0


def get_chords_in_interval(
    chord_data, start_time: float, end_time: float
) -> List[str]:
    """Get all chords that occur within a given time interval."""
    chords = []

    if not hasattr(chord_data, "intervals") or not hasattr(
        chord_data, "labels"
    ):
        return ["N.C."]

    for (chord_start, chord_end), chord_label in zip(
        chord_data.intervals, chord_data.labels
    ):
        # Convert times to float
        chord_start = safe_float(chord_start)
        chord_end = safe_float(chord_end)

        # Check if chord overlaps with section
        if chord_start < end_time and chord_end > start_time:
            chords.append(chord_label)

    return chords if chords else ["N.C."]


def convert_track_to_jcrd(track) -> Dict:
    """Convert a single track to JCRD format using the existing section annotations."""
    jcrd = {
        "title": track.title or "Unknown Title",
        "artist": track.artist or "Unknown Artist",
        "bpm": 120,  # Default BPM since McGill doesn't include it
        "source": "McGill Billboard",
        "sections": [],
    }

    # Get both section and chord data
    section_data = getattr(track, "sections", None)
    chord_data = getattr(track, "chords_full", None)

    if (
        section_data is None
        or not hasattr(section_data, "intervals")
        or not hasattr(section_data, "labels")
    ):
        # Create a simple empty section if no section data
        jcrd["sections"].append(
            {
                "id": "section_1",
                "start_ms": 0,
                "duration_ms": 0,
                "chords": ["N.C."],
                "sectionType": "Other",
                "sectionLetter": "A",
                "sectionFunction": "Development",
                "sectionLabel": "unknown section",
                "tags": ["no_section_data"],
            }
        )
        return jcrd

    # Process each section from the dataset
    section_count = {}  # Keep track of section counts for numbering

    for i, ((start, end), label) in enumerate(
        zip(section_data.intervals, section_data.labels)
    ):
        # Convert times to float and ms
        start_time = safe_float(start)
        end_time = safe_float(end)

        if start_time >= end_time:
            continue

        # Get section info
        section_type, section_letter, section_function = get_section_info(
            label, i
        )

        # Update section count and create ID
        section_count[section_type] = section_count.get(section_type, 0) + 1
        section_id = f"{section_type.lower()}_{section_count[section_type]}"

        # Get chords for this section
        section_chords = get_chords_in_interval(
            chord_data, start_time, end_time
        )

        # Create section
        section = {
            "id": section_id,
            "start_ms": int(start_time * 1000),
            "duration_ms": int((end_time - start_time) * 1000),
            "chords": section_chords,
            "sectionType": section_type,
            "sectionLetter": section_letter,
            "sectionFunction": section_function,
            "sectionLabel": label,
            "tags": ["mcgill_annotated", "timing_confidence:high"],
        }

        jcrd["sections"].append(section)

    return jcrd


def convert_billboard_dataset(output_dir: str):
    """Convert the entire McGill Billboard dataset to JCRD format."""
    # Initialize and download dataset
    print("Initializing McGill Billboard dataset...")
    dataset = mirdata.initialize("billboard")
    dataset.download()
    dataset.validate()

    # Create output directory
    os.makedirs(output_dir, exist_ok=True)
    print(f"Converting files to {output_dir}...")

    success_count = 0
    error_count = 0

    # Process each track
    for track_id, track in dataset.load_tracks().items():
        try:
            jcrd = convert_track_to_jcrd(track)

            # Create filename from title and artist
            title_slug = slugify(track.title or "untitled")
            artist_slug = slugify(track.artist or "unknown_artist")
            filename = f"{title_slug}_{artist_slug}.json"
            output_path = os.path.join(output_dir, filename)

            # Save the file
            with open(output_path, "w") as f:
                json.dump(jcrd, f, indent=2)
            print(f"✅ Converted: {track.title} by {track.artist}")
            success_count += 1

        except Exception as e:
            print(f"❌ Error processing {track_id}: {str(e)}")
            error_count += 1

    print(
        f"\nConversion complete! Successfully converted {success_count} files."
    )
    if error_count > 0:
        print(f"Failed to convert {error_count} files.")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="Convert McGill Billboard dataset to .jcrd"
    )
    parser.add_argument(
        "--output_dir",
        default="mcgill_jcrd_annotated",
        help="Directory to save .jcrd files",
    )
    args = parser.parse_args()
    convert_billboard_dataset(args.output_dir)
