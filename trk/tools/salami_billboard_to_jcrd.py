"""
Convert McGill Billboard dataset to .jcrd format using SALAMI section annotations.
"""

import os
import json
import mirdata
import re
from typing import Dict, List, Optional, Tuple


def slugify(text: str) -> str:
    """Convert text to a URL-friendly slug."""
    return re.sub(r"[^a-z0-9]+", "_", text.lower()).strip("_")


def safe_float(value) -> float:
    """Convert a value to float, handling NumPy types."""
    try:
        if hasattr(value, "item"):
            return float(value.item())
        return float(value)
    except (ValueError, AttributeError):
        return 0.0


def map_salami_section(
    label: str, count: Dict[str, int]
) -> Tuple[str, str, str]:
    """Map SALAMI section labels to JCRD format."""
    label_lower = label.lower()

    # Track section counts for numbering (verse_1, verse_2, etc.)
    count[label_lower] = count.get(label_lower, 0) + 1
    section_num = count[label_lower]

    # Default values
    section_type = "Other"
    section_letter = "A"
    section_function = "Development"

    # Map common SALAMI labels to section types
    if "verse" in label_lower:
        section_type = "Verse"
        section_letter = "A"
        section_function = "Theme"
        if section_num > 1:
            section_letter = f"A{section_num}"
    elif "chorus" in label_lower:
        section_type = "Chorus"
        section_letter = "B"
        section_function = "Theme"
        if section_num > 1:
            section_letter = f"B{section_num}"
    elif "bridge" in label_lower:
        section_type = "Bridge"
        section_letter = "C"
        section_function = "Bridge"
    elif "intro" in label_lower:
        section_type = "Intro"
        section_letter = "I"
        section_function = "Exposition"
    elif "outro" in label_lower or "ending" in label_lower:
        section_type = "Outro"
        section_letter = "O"
        section_function = "Coda"
    elif "pre-chorus" in label_lower or "prechorus" in label_lower:
        section_type = "Pre-chorus"
        section_letter = "P"
        section_function = "Build-up"
    elif "instrumental" in label_lower:
        section_type = "Instrumental"
        section_letter = "S"
        section_function = "Development"
    elif "solo" in label_lower:
        section_type = "Solo"
        section_letter = "S"
        section_function = "Development"

    return section_type, section_letter, section_function


def get_section_chords(
    chord_data, start_time: float, end_time: float
) -> List[str]:
    """Get all chords that fall within a section's time range."""
    section_chords = []

    if (
        not chord_data
        or not hasattr(chord_data, "intervals")
        or not hasattr(chord_data, "labels")
    ):
        return ["N.C."]

    for (chord_start, chord_end), chord_label in zip(
        chord_data.intervals, chord_data.labels
    ):
        # Convert times to float if they're numpy values
        chord_start_val = safe_float(chord_start)
        chord_end_val = safe_float(chord_end)

        # Check if chord overlaps with section
        if chord_start_val < end_time and chord_end_val > start_time:
            section_chords.append(chord_label)

    return section_chords if section_chords else ["N.C."]


def convert_track_to_jcrd(track) -> Dict:
    """Convert a single track to JCRD format using SALAMI annotations."""
    jcrd = {
        "title": track.title or "Unknown Title",
        "artist": track.artist or "Unknown Artist",
        "bpm": 120,  # Default BPM since McGill doesn't include it
        "source": "McGill Billboard + SALAMI",
        "sections": [],
    }

    # Get SALAMI section data
    salami_data = getattr(track, "sections", None)
    if (
        not salami_data
        or not hasattr(salami_data, "intervals")
        or not hasattr(salami_data, "labels")
    ):
        print(f"⚠️ No SALAMI data for {track.title} by {track.artist}")
        return jcrd

    # Get chord data for filling in section chords
    chord_data = getattr(track, "chords_full", None)

    # Track section counts for proper numbering
    section_counts = {}

    # Process each section
    for i, ((start, end), label) in enumerate(
        zip(salami_data.intervals, salami_data.labels)
    ):
        # Convert times to float if they're numpy values
        start_val = safe_float(start)
        end_val = safe_float(end)

        if start_val >= end_val:
            print(
                f"⚠️ Skipping invalid section interval in {track.title} by {track.artist}"
            )
            continue

        # Map SALAMI label to JCRD section type
        section_type, section_letter, section_function = map_salami_section(
            label, section_counts
        )

        # Get chords for this section
        section_chords = get_section_chords(chord_data, start_val, end_val)

        # Create the section
        section = {
            "id": f"{section_type.lower()}_{section_counts[label.lower()]}",
            "start_ms": int(start_val * 1000),
            "duration_ms": int((end_val - start_val) * 1000),
            "chords": section_chords,
            "sectionType": section_type,
            "sectionLetter": section_letter,
            "sectionFunction": section_function,
            "sectionLabel": label,
            "tags": ["salami_annotated", "timing_confidence:high"],
        }

        jcrd["sections"].append(section)

    return jcrd


def convert_billboard_dataset(output_dir: str):
    """Convert the entire McGill Billboard dataset to JCRD format using SALAMI annotations."""
    print("Initializing McGill Billboard dataset...")
    dataset = mirdata.initialize("billboard")
    dataset.download()
    dataset.validate()

    os.makedirs(output_dir, exist_ok=True)
    print(f"Converting files to {output_dir}...")

    for track_id, track in dataset.load_tracks().items():
        try:
            jcrd = convert_track_to_jcrd(track)

            # Create filename from title and artist
            title_slug = slugify(track.title or "untitled")
            artist_slug = slugify(track.artist or "unknown_artist")
            filename = f"{title_slug}_{artist_slug}.json"
            output_path = os.path.join(output_dir, filename)

            with open(output_path, "w") as f:
                json.dump(jcrd, f, indent=2)
            print(f"✅ Converted: {track.title} by {track.artist}")

        except Exception as e:
            print(f"❌ Error processing {track_id}: {str(e)}")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="Convert McGill Billboard dataset to .jcrd using SALAMI annotations"
    )
    parser.add_argument(
        "--output_dir",
        default="mcgill_jcrd_salami",
        help="Directory to save .jcrd files",
    )
    args = parser.parse_args()
    convert_billboard_dataset(args.output_dir)
