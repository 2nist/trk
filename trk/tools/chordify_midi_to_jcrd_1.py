"""
TOOLBOX:
name: Chordify MIDI to JSON Converter
description: Converts Chordify-exported MIDI files into structured JSON format with section/chord analysis. Supports PDF metadata extraction.
arguments:
  --input: Path to input .mid file
  --output: Path to output .json file
  --title: Optional song title
  --artist: Optional artist name
  --pdf: Optional Chordify PDF for metadata
"""

import argparse
import os
import json
import sys
import pretty_midi
from collections import defaultdict

# PDF parsing
try:
    import PyPDF2
except ImportError:
    PyPDF2 = None


def extract_pdf_metadata(pdf_path):
    """Extract title, artist, and possibly section labels from Chordify PDF text."""
    if not PyPDF2:
        return {}, ["PyPDF2 not installed, skipping PDF metadata extraction."]
    meta = {}
    warnings = []
    try:
        with open(pdf_path, "rb") as f:
            reader = PyPDF2.PdfReader(f)
            text = "\n".join(
                page.extract_text() or "" for page in reader.pages
            )
        # Heuristic: look for title/artist in first 1-2 pages
        lines = text.splitlines()
        for line in lines[:10]:
            if not meta.get("title") and line.strip():
                meta["title"] = line.strip()
            elif not meta.get("artist") and line.strip():
                meta["artist"] = line.strip()
            if meta.get("title") and meta.get("artist"):
                break
        # Optionally: parse section/chord names from text
        # (not implemented here)
    except Exception as e:
        warnings.append(f"PDF parse error: {e}")
    return meta, warnings


def detect_chord(notes):
    pitch_classes = sorted(set(n.pitch % 12 for n in notes))
    if not pitch_classes:
        return "N.C."
    triads = {
        (0, 4, 7): "C",
        (2, 5, 9): "D",
        (4, 7, 11): "E",
        (5, 9, 0): "F",
        (7, 11, 2): "G",
        (9, 0, 4): "A",
        (11, 2, 5): "B",
    }
    for triad, name in triads.items():
        if all(pc in pitch_classes for pc in triad):
            return name
    return "+".join(str(pc) for pc in pitch_classes)


def parse_midi_chords(pm):
    """Parse MIDI file into sections with improved section detection"""
    from improved_section_detection import detect_sections

    return detect_sections(pm, min_beats_per_section=16)


def convert_midi_to_json(
    input_path, output_path, title="Unknown", artist="Unknown", pdf_path=None
):
    """Convert a MIDI file to JSON format with improved section detection"""
    # Process PDF metadata if available
    pdf_meta, pdf_warnings = (
        extract_pdf_metadata(pdf_path) if pdf_path else ({}, [])
    )
    if pdf_meta.get("title"):
        title = pdf_meta["title"]
    if pdf_meta.get("artist"):
        artist = pdf_meta["artist"]

    # Load and parse MIDI
    midi = pretty_midi.PrettyMIDI(input_path)
    # Extract tempo: microseconds per beat from MIDI
    us_per_beat_array = midi.get_tempo_changes()[1]
    us_per_beat = us_per_beat_array[0] if len(us_per_beat_array) > 0 else 500000
    # Convert microseconds per beat to BPM
    bpm_value = 60000000.0 / us_per_beat

    # Debugging output for tempo values
    print(f"Tempo changes (microseconds per beat): {us_per_beat_array}")
    print(f"Selected microseconds per beat: {us_per_beat}")
    print(f"Calculated BPM: {bpm_value}")

    # Sanity check for BPM
    if bpm_value < 40 or bpm_value > 300:
        print(f"Warning: Calculated BPM {bpm_value} is out of range. Falling back to 120 BPM.")
        bpm_value = 120

    sections = parse_midi_chords(midi)

    # Create JCRD data structure
    jcrd_data = {
        "title": title,
        "artist": artist,
        "bpm": int(round(bpm_value)),  # Tempo in BPM
        "source": "Chordify",
        "sections": [],
    }

    # Check for matching PDF
    base_name = os.path.splitext(os.path.basename(input_path))[0]
    possible_pdf = os.path.join("pdf", base_name + ".pdf")
    if os.path.exists(possible_pdf):
        jcrd_data["source_pdf"] = possible_pdf

    # Process sections with enhanced metadata
    for section in sections:
        # Copy over the section data, ensuring all required fields
        section_data = section.copy()
        # Add PDF metadata tag if applicable
        if pdf_meta:
            section_data.setdefault("tags", []).append("pdf_metadata")
        jcrd_data["sections"].append(section_data)

    # Save the result
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(jcrd_data, f, indent=2, ensure_ascii=False)
    print(f"✅ Saved JSON file to {output_path}")
    for w in pdf_warnings:
        print(f"[PDF] {w}")


def main():
    parser = argparse.ArgumentParser(
        description="Convert Chordify MIDI to .json"
    )
    # --input is required; we enforce manually to avoid bare SystemExit
    parser.add_argument(
        "--input",
        required=False,
        default=None,
        help="Path to input MIDI file (required)",
    )
    parser.add_argument(
        "--output",
        required=False,
        help="Path to save output JSON file (default: raw/<input>.json)",
    )
    parser.add_argument(
        "--title", default=None, help="Optional title for the song"
    )
    parser.add_argument("--artist", default=None, help="Optional artist name")
    parser.add_argument(
        "--pdf", default=None, help="Optional Chordify PDF for metadata"
    )
    parser.add_argument(
        "--fixed-length",
        action="store_true",
        help="Use fixed-length sections (optional, currently ignored)",
    )
    try:
        args = parser.parse_args()
    except SystemExit:
        print("Error: --input argument is required.")
        parser.print_help()
        sys.exit(1)

    input_path = args.input
    output_path = args.output
    # derive base name for default output and title fallback
    base = os.path.splitext(os.path.basename(input_path))[0]
    # Ensure input was provided
    if not args.input:
        print("Error: --input argument is required.")
        parser.print_help()
        sys.exit(1)
    # Default output to raw/<input>.json if not provided
    if not output_path:
        output_path = os.path.join("raw", f"{base}.json")
    # Fallback for title/artist from filename if not provided
    title = args.title or base
    artist = args.artist or "Unknown"
    convert_midi_to_json(input_path, output_path, title, artist, args.pdf)


if __name__ == "__main__":
    main()