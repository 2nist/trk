"""
TOOLBOX:
name: Export .jcrd to MIDI
description: Converts chords in .jcrd files into a block-style MIDI sequence using PrettyMIDI.
arguments:
  --directory: Folder containing .jcrd files (default: mcgill_jcrd/)
  --output: Folder to save .mid files (default: export/midi/)
"""

import os
import sys
import json
import argparse
import pretty_midi
import sys


def chord_to_notes(ch):
    try:
        c = pretty_midi.chord_name_to_chord(ch)
        return c
    except Exception:
        return [60, 64, 67]  # fallback: C major


def create_midi_from_jcrd(jcrd, output_path, default_duration=1.0):
    pm = pretty_midi.PrettyMIDI()
    instrument = pretty_midi.Instrument(program=0)  # Acoustic Grand Piano
    time = 0.0

    bpm = jcrd.get("bpm", 120)
    seconds_per_beat = 60.0 / bpm

    for section in jcrd.get("sections", []):
        chords = section.get("chords", [])
        duration_sec = (
            section.get("duration_ms", default_duration * 1000) / 1000
        )
        chord_duration = duration_sec / max(len(chords), 1)

        for ch in chords:
            notes = chord_to_notes(ch)
            for pitch in notes:
                note = pretty_midi.Note(
                    velocity=100,
                    pitch=pitch,
                    start=time,
                    end=time + chord_duration,
                )
                instrument.notes.append(note)
            time += chord_duration

    pm.instruments.append(instrument)
    pm.write(output_path)


def main():
    parser = argparse.ArgumentParser(
        description="Export .jcrd chords to MIDI"
    )
    parser.add_argument(
        "--directory", default="mcgill_jcrd", help="Folder with .jcrd files"
    )
    parser.add_argument(
        "--output", default="export/midi", help="Folder to write .mid files"
    )
    parser.add_argument(
        "file", nargs="?", help="Single JCRD file to convert (optional)"
    )
    args = parser.parse_args()

    if args.file:
        # Process a single file
        if not os.path.exists(args.file):
            print(f"Error: File {args.file} not found.")
            return 1

        output_dir = os.path.join(os.path.dirname(args.file), "midi_export")
        os.makedirs(output_dir, exist_ok=True)

        output_name = (
            os.path.splitext(os.path.basename(args.file))[0] + ".mid"
        )
        out_path = os.path.join(output_dir, output_name)

        try:
            with open(args.file, "r") as f:
                jcrd = json.load(f)
            create_midi_from_jcrd(jcrd, out_path)
            print(f"🎹 Exported {args.file} to {out_path}")
            return 0
        except Exception as e:
            print(f"Error converting {args.file}: {e}")
            return 1
    else:
        # Process directory of files
        os.makedirs(args.output, exist_ok=True)

        for fname in sorted(os.listdir(args.directory)):
            if not fname.endswith(".json"):
                continue

            path = os.path.join(args.directory, fname)
            with open(path, "r") as f:
                jcrd = json.load(f)

            output_name = os.path.splitext(fname)[0] + ".mid"
            out_path = os.path.join(args.output, output_name)
            create_midi_from_jcrd(jcrd, out_path)
            print(f"🎹 Exported {output_name}")
        return 0


if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)
