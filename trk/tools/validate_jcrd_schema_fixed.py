#!/usr/bin/env python3
"""
validate_jcrd_schema_fixed.py - Validate all JCRD files against the schema

This script checks all JSON files in the mcgill_jcrd directory to ensure they
follow the standardized structure and reports any inconsistencies.
"""

import os
import json
import logging
import argparse
from pathlib import Path
import sys
import jsonschema

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("validate_jcrd_schema.log"),
        logging.StreamHandler(sys.stdout),
    ],
)

# Define the JSON schema for validation
JCRD_SCHEMA = {
    "type": "object",
    "required": ["title", "artist", "bpm", "sections"],
    "properties": {
        "title": {"type": "string"},
        "artist": {"type": "string"},
        "bpm": {"type": "number"},
        "key": {"type": "string"},
        "source": {"type": "string"},
        "beat_times": {"type": "array", "items": {"type": "number"}},
        "sections": {
            "type": "array",
            "items": {
                "type": "object",
                "required": ["id", "start_ms", "duration_ms", "chords"],
                "properties": {
                    "id": {"type": "string"},
                    "start_ms": {"type": "number"},
                    "duration_ms": {"type": "number"},
                    "chords": {"type": "array", "items": {"type": "string"}},
                    "romanNumerals": {
                        "type": "array",
                        "items": {"type": "string"},
                    },
                    "tags": {"type": "array", "items": {"type": "string"}},
                    "sectionLabel": {"type": "string"},
                    "sectionLetter": {"type": "string"},
                },
                "additionalProperties": True,
            },
        },
    },
    "additionalProperties": True,
}


def validate_jcrd_file(file_path):
    """Validate a single JCRD file against the schema."""
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        jsonschema.validate(instance=data, schema=JCRD_SCHEMA)

        # Additional validation beyond the schema
        errors = []

        # Check for empty required fields
        if not data.get("title"):
            errors.append("Empty title field")
        if not data.get("artist"):
            errors.append("Empty artist field")

        # Check for new schema requirements
        if "key" not in data:
            errors.append("Missing 'key' field (required in new schema)")
        if "beat_times" not in data:
            errors.append(
                "Missing 'beat_times' array (required in new schema)"
            )

        # Check for valid section IDs
        section_ids = set()
        for i, section in enumerate(data.get("sections", [])):
            section_id = section.get("id", "")
            if section_id in section_ids:
                errors.append(f"Duplicate section ID: {section_id}")
            section_ids.add(section_id)

            # Check for negative or invalid times
            if section.get("start_ms", 0) < 0:
                errors.append(
                    f"Section {section_id} has negative start_ms: {section.get('start_ms')}"
                )
            if section.get("duration_ms", 0) <= 0:
                errors.append(
                    f"Section {section_id} has zero or negative duration_ms: {section.get('duration_ms')}"
                )

            # Check for romanNumerals field
            if "romanNumerals" not in section:
                errors.append(
                    f"Section {section_id} missing 'romanNumerals' array (required in new schema)"
                )

            # Check for tags field
            if "tags" not in section:
                errors.append(
                    f"Section {section_id} missing 'tags' array (required in new schema)"
                )

        # Check for valid beat_times if present
        beat_times = data.get("beat_times", [])
        if beat_times:
            for i, time in enumerate(beat_times):
                if i > 0 and time <= beat_times[i - 1]:
                    errors.append(
                        f"Non-monotonic beat_times at index {i}: {time} <= {beat_times[i-1]}"
                    )

        if errors:
            logging.warning(
                f"{file_path}: Schema valid but found {len(errors)} logical errors"
            )
            for error in errors:
                logging.warning(f"  - {error}")
            return False, errors

        return True, []
    except json.JSONDecodeError as e:
        logging.error(f"{file_path}: Invalid JSON - {e}")
        return False, [f"Invalid JSON: {e}"]
    except jsonschema.exceptions.ValidationError as e:
        logging.error(f"{file_path}: Schema validation failed - {e.message}")
        return False, [f"Schema validation failed: {e.message}"]
    except Exception as e:
        logging.error(f"{file_path}: Error - {e}")
        return False, [f"Error: {e}"]


def validate_all_jcrd_files(directory):
    """Validate all JCRD files in a directory."""
    total_files = 0
    valid_files = 0
    invalid_files = 0

    issues = {}

    for root, _, files in os.walk(directory):
        for filename in files:
            if filename.endswith(".json"):
                total_files += 1
                file_path = os.path.join(root, filename)

                valid, errors = validate_jcrd_file(file_path)
                if valid:
                    valid_files += 1
                    logging.info(f"{file_path}: Valid")
                else:
                    invalid_files += 1
                    issues[file_path] = errors

    logging.info(
        f"Processed {total_files} files: {valid_files} valid, {invalid_files} invalid"
    )

    if invalid_files > 0:
        logging.info("\nSummary of issues:")
        for file_path, errors in issues.items():
            logging.info(
                f"{os.path.basename(file_path)}: {len(errors)} issues"
            )
            for error in errors[:5]:  # Show first 5 issues per file
                logging.info(f"  - {error}")
            if len(errors) > 5:
                logging.info(f"  - ... and {len(errors) - 5} more issues")

    return valid_files, invalid_files, total_files


def main():
    parser = argparse.ArgumentParser(
        description="Validate all JCRD files against the schema"
    )
    parser.add_argument(
        "--verbose", "-v", action="store_true", help="Enable verbose logging"
    )
    parser.add_argument(
        "--dir", type=str, help="Directory containing JCRD files"
    )
    parser.add_argument(
        "--file", type=str, help="Single JCRD file to validate"
    )
    args = parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    # Set paths
    script_dir = Path(__file__).parent

    if args.file:
        # Validate single file
        file_path = Path(args.file)
        if not file_path.exists():
            logging.error(f"File not found: {file_path}")
            return 1

        valid, errors = validate_jcrd_file(file_path)
        if valid:
            logging.info(f"{file_path} is valid")
            return 0
        else:
            logging.error(f"{file_path} is invalid:")
            for error in errors:
                logging.error(f"  - {error}")
            return 1
    else:
        # Validate all files in directory
        jcrd_dir = (
            Path(args.dir) if args.dir else script_dir.parent / "mcgill_jcrd"
        )

        if not jcrd_dir.exists():
            logging.error(f"Directory not found: {jcrd_dir}")
            return 1

        logging.info(f"Validating JCRD files in {jcrd_dir}")
        valid_files, invalid_files, total_files = validate_all_jcrd_files(
            jcrd_dir
        )

        # Print summary
        logging.info("=" * 80)
        logging.info(
            f"Summary: {valid_files}/{total_files} files valid ({invalid_files} invalid)"
        )

        return 0 if invalid_files == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
