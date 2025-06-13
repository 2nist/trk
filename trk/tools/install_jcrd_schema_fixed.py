#!/usr/bin/env python3
"""
install_jcrd_schema_fixed.py - Create and install the JCRD schema file

This script creates a jcrd.schema.json file in the project root for reference.
"""

import json
import logging
import argparse
from pathlib import Path
import sys

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
)

# Define the JSON schema
JCRD_SCHEMA = {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "JCRD File",
    "description": "JCRD (JSON Chord) format for music analysis with section-based structure",
    "type": "object",
    "required": ["title", "artist", "bpm", "sections"],
    "properties": {
        "title": {"type": "string", "description": "Title of the song"},
        "artist": {
            "type": "string",
            "description": "Name of the performing artist",
        },
        "bpm": {"type": "number", "description": "Tempo in beats per minute"},
        "key": {
            "type": "string",
            "description": "Estimated or provided key of the song (e.g., 'C major', 'A minor')",
        },
        "source": {
            "type": "string",
            "description": "Source data trace (e.g., 'SALAMI + Music4All', 'McGill Billboard')",
        },
        "beat_times": {
            "type": "array",
            "description": "Optional global beat grid in milliseconds, for snapping in REAPER or MIDI export",
            "items": {"type": "number"},
        },
        "sections": {
            "type": "array",
            "description": "Array of song sections with chord progressions",
            "items": {
                "type": "object",
                "required": ["id", "start_ms", "duration_ms", "chords"],
                "properties": {
                    "id": {
                        "type": "string",
                        "description": "Unique identifier for the section (e.g., 'verse_1', 'chorus_2')",
                    },
                    "start_ms": {
                        "type": "number",
                        "description": "Start time in milliseconds",
                    },
                    "duration_ms": {
                        "type": "number",
                        "description": "Duration in milliseconds",
                    },
                    "chords": {
                        "type": "array",
                        "description": "Array of chord symbols",
                        "items": {"type": "string"},
                    },
                    "romanNumerals": {
                        "type": "array",
                        "description": "Optional array of Roman numeral chord functions",
                        "items": {"type": "string"},
                    },
                    "tags": {
                        "type": "array",
                        "description": "Flexible tag array for structural, inferred, or tooling metadata",
                        "items": {"type": "string"},
                    },
                    "sectionLabel": {
                        "type": "string",
                        "description": "Descriptive label for the section (e.g., 'verse', 'chorus', 'bridge')",
                    },
                    "sectionLetter": {
                        "type": "string",
                        "description": "Formal section letter from SALAMI format (e.g., 'A', 'B', 'C')",
                    },
                },
                "additionalProperties": True,
            },
        },
    },
    "additionalProperties": True,
}


def main():
    """Main function to install the schema file."""
    parser = argparse.ArgumentParser(
        description="Create and install the JCRD schema file"
    )
    parser.add_argument(
        "--force", action="store_true", help="Force overwrite if file exists"
    )
    parser.add_argument(
        "--output", "-o", type=str, help="Output path for schema file"
    )
    parser.add_argument(
        "--verbose", "-v", action="store_true", help="Enable verbose output"
    )
    args = parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    # Set paths
    script_dir = Path(__file__).parent
    target_path = (
        Path(args.output)
        if args.output
        else script_dir.parent / "jcrd.schema.json"
    )

    logging.info(f"Script directory: {script_dir}")
    logging.info(f"Target path: {target_path}")
    logging.info(f"Installing JCRD schema file to {target_path}")

    # Check if file exists
    if target_path.exists() and not args.force:
        logging.warning(
            f"Schema file already exists at {target_path}. Use --force to overwrite."
        )
        return 1

    # Write schema file
    try:
        with open(target_path, "w", encoding="utf-8") as f:
            json.dump(JCRD_SCHEMA, f, indent=2)
        logging.info(f"Schema file installed at {target_path}")

        # Verify the file was created
        if target_path.exists():
            logging.info(f"Schema file verified at {target_path}")
        else:
            logging.error(f"Schema file verification failed at {target_path}")

        return 0
    except Exception as e:
        logging.error(f"Error installing schema file: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
