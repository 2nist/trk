#!/usr/bin/env python3
"""
standardize_section_labels.py - Standardize section labels across the McGill JCRD dataset

This script standardizes section labels in the McGill JCRD files by normalizing names
and applying a consistent format. It uses the canonical mapping extracted from the
SALAMI dataset to ensure consistent naming.
"""

import os
import re
import json
import logging
import argparse
from pathlib import Path
import sys
from difflib import SequenceMatcher

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("standardize_labels.log"),
        logging.StreamHandler(sys.stdout),
    ],
)

# Standard mapping for section labels (based on SALAMI analysis)
# This will be populated from the canonical mapping file
STANDARD_MAPPINGS = {}


def load_canonical_mapping(mapping_file):
    """Load the canonical section label mapping."""
    try:
        with open(mapping_file, "r", encoding="utf-8") as f:
            data = json.load(f)

        # Extract the canonical mapping
        canonical_mapping = data.get("canonical_mapping", {})

        # Create standardized mappings for letters to labels
        letter_to_label = {}
        for letter, mappings in canonical_mapping.items():
            if mappings:
                # Use the most common label for each section letter
                primary_label = mappings[0]["label"]
                letter_to_label[letter] = primary_label

        # Create standardized mappings for labels to letters
        label_to_letter = {}
        for pair in data.get("pairs", []):
            if isinstance(pair, list) and len(pair) == 2:
                letter_label, count = pair
                if ":" in letter_label:
                    letter, label = letter_label.split(":", 1)
                    # Only add if it's not already in the dictionary or has a higher count
                    if (
                        label not in label_to_letter
                        or count > label_to_letter[label][1]
                    ):
                        label_to_letter[label] = (letter, count)

        return {
            "letter_to_label": letter_to_label,
            "label_to_letter": {
                label: letter
                for label, (letter, _) in label_to_letter.items()
            },
        }
    except Exception as e:
        logging.error(
            f"Error loading canonical mapping from {mapping_file}: {e}"
        )
        return {"letter_to_label": {}, "label_to_letter": {}}


def normalize_section_label(label):
    """Normalize a section label by removing special chars and standardizing name."""
    if not label:
        return "unknown"

    # Convert to lowercase and remove special characters
    normalized = label.lower().strip()
    normalized = re.sub(r"[^\w\s]", "", normalized)
    normalized = re.sub(r"\s+", " ", normalized).strip()

    # Map common variations to standard labels
    common_variations = {
        "intro": ["intro", "introduction", "opening"],
        "verse": ["verse", "vers"],
        "chorus": ["chorus", "refrain", "hook"],
        "bridge": ["bridge", "middle eight", "middle 8"],
        "outro": ["outro", "coda", "ending", "end", "fadeout", "fade out"],
        "instrumental": [
            "instrumental",
            "inst",
            "solo",
            "guitar solo",
            "instru",
        ],
        "pre-chorus": ["pre-chorus", "pre chorus", "prechorus"],
        "post-chorus": ["post-chorus", "post chorus", "postchorus"],
        "interlude": ["interlude", "break", "transition"],
    }

    for standard, variations in common_variations.items():
        if normalized in variations:
            return standard

    # If not matched, return the normalized original
    return normalized


def standardize_jcrd_file(jcrd_path, mappings, dry_run=False):
    """Standardize section labels in a JCRD file."""
    try:
        with open(jcrd_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        # Check if we need to add/update section letters
        sections = data.get("sections", [])
        updated = 0

        letter_to_label = mappings.get("letter_to_label", {})
        label_to_letter = mappings.get("label_to_letter", {})

        for i, section in enumerate(sections):
            # Get current values
            current_label = section.get("sectionLabel", "").lower()
            current_letter = section.get("sectionLetter", "")

            # Normalize the label
            normalized_label = normalize_section_label(current_label)

            # Update section label if it's not normalized
            if (
                normalized_label != current_label
                and normalized_label != "unknown"
            ):
                section["sectionLabel"] = normalized_label
                updated += 1
                current_label = (
                    normalized_label  # Update for letter assignment
                )

            # Assign or update section letter
            if not current_letter and current_label in label_to_letter:
                # No letter but we have a mapping for this label
                section["sectionLetter"] = label_to_letter[current_label]
                updated += 1
            elif current_letter and current_letter in letter_to_label:
                # Has letter but label doesn't match canonical mapping
                canonical_label = letter_to_label[current_letter]
                if normalized_label != canonical_label:
                    # Only suggest an update if the current label doesn't seem right
                    # This is to avoid overriding manually corrected labels
                    similarity = SequenceMatcher(
                        None, normalized_label, canonical_label
                    ).ratio()
                    if similarity < 0.5:  # Only suggest if quite different
                        logging.info(
                            f"In {jcrd_path}: Section {section.get('id')} has letter {current_letter} but label '{normalized_label}', "
                            f"canonical label would be '{canonical_label}' (not auto-changed)"
                        )

            elif not current_letter:
                # No letter and no mapping, assign based on standard patterns
                if normalized_label == "intro":
                    section["sectionLetter"] = "A"
                elif normalized_label == "verse":
                    section["sectionLetter"] = "B"
                elif normalized_label == "chorus":
                    section["sectionLetter"] = "C"
                elif normalized_label == "bridge":
                    section["sectionLetter"] = "D"
                elif normalized_label == "outro":
                    section["sectionLetter"] = "E"
                else:
                    # Fallback: assign sequential letters
                    section["sectionLetter"] = chr(
                        65 + (i % 26)
                    )  # A, B, C, ...

                updated += 1

        # Save the updated file
        if updated > 0 and not dry_run:
            with open(jcrd_path, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2)
            logging.info(
                f"Updated {jcrd_path} with {updated} standardized section elements"
            )
        elif updated > 0:
            logging.info(
                f"Would update {jcrd_path} with {updated} standardized section elements (dry run)"
            )

        return updated
    except Exception as e:
        logging.error(f"Error standardizing {jcrd_path}: {e}")
        return 0


def standardize_all_jcrd_files(jcrd_dir, mappings, dry_run=False):
    """Standardize section labels in all JCRD files."""
    updated_files = 0
    total_files = 0

    for filename in os.listdir(jcrd_dir):
        if not filename.endswith(".json"):
            continue

        total_files += 1
        jcrd_path = os.path.join(jcrd_dir, filename)

        if standardize_jcrd_file(jcrd_path, mappings, dry_run) > 0:
            updated_files += 1

    logging.info(f"Standardized {updated_files}/{total_files} files")
    return updated_files, total_files


def main():
    parser = argparse.ArgumentParser(
        description="Standardize section labels in McGill JCRD files"
    )
    parser.add_argument(
        "--mapping",
        help="Canonical mapping file",
        default="salami_section_labels.json",
    )
    parser.add_argument(
        "--dry-run", action="store_true", help="Don't actually update files"
    )
    parser.add_argument(
        "--verbose", "-v", action="store_true", help="Enable verbose logging"
    )
    args = parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    # Set paths
    script_dir = Path(__file__).parent
    jcrd_dir = script_dir.parent / "mcgill_jcrd"
    mapping_file = script_dir / args.mapping

    if not jcrd_dir.exists():
        logging.error(f"JCRD directory not found: {jcrd_dir}")
        return 1

    # Default mappings if no file found
    mappings = {
        "letter_to_label": {
            "A": "intro",
            "B": "verse",
            "C": "chorus",
            "D": "bridge",
            "E": "outro",
        },
        "label_to_letter": {
            "intro": "A",
            "verse": "B",
            "chorus": "C",
            "bridge": "D",
            "outro": "E",
            "instrumental": "F",
            "interlude": "G",
            "pre-chorus": "H",
            "post-chorus": "I",
            "solo": "J",
        },
    }

    if mapping_file.exists():
        loaded_mappings = load_canonical_mapping(mapping_file)
        # Update default mappings with loaded ones
        mappings["letter_to_label"].update(
            loaded_mappings.get("letter_to_label", {})
        )
        mappings["label_to_letter"].update(
            loaded_mappings.get("label_to_letter", {})
        )
        logging.info(
            f"Loaded canonical mapping with {len(mappings['letter_to_label'])} section letters"
        )
    else:
        logging.warning(f"Canonical mapping file not found: {mapping_file}")
        logging.warning("Using default standardization mappings")

    # Standardize all files
    updated_files, total_files = standardize_all_jcrd_files(
        jcrd_dir, mappings, args.dry_run
    )

    # Print summary
    logging.info("=" * 80)
    logging.info(f"Summary: {updated_files}/{total_files} files standardized")

    return 0


if __name__ == "__main__":
    sys.exit(main())
