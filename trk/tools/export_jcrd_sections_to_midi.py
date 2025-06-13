"""
TOOLBOX:
name: Export .jcrd Sections to MIDI
description: Converts each section in .jcrd files into separate labeled MIDI files using PrettyMIDI.
arguments:
  --directory: Folder containing .jcrd files (default: mcgill_jcrd/)
  --output: Folder to save per-section MIDI files (default: export/midi_sections/)
"""

import os
import json
import argparse
import pretty_midi


def chord_to_notes(ch):
    try:
        c = pretty_midi.chord_name_to_chord(ch)
        return c
    except Exception:
        return [60, 64, 67]  # fallback: C major


def create_midi_from_section(chords, bpm, duration_ms):
    pm = pretty_midi.PrettyMIDI()
    instrument = pretty_midi.Instrument(program=0)  # Acoustic Grand Piano
    time = 0.0
    seconds_per_beat = 60.0 / bpm
    duration_sec = duration_ms / 1000
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
    return pm


def main():
    parser = argparse.ArgumentParser(
        description="Export each section of .jcrd to individual MIDI files"
    )
    parser.add_argument(
        "--directory",
        default="mcgill_jcrd",
        help="Directory with .jcrd files",
    )
    parser.add_argument(
        "--output",
        default="export/midi_sections",
        help="Output folder for MIDI files",
    )
    args = parser.parse_args()

    os.makedirs(args.output, exist_ok=True)

    for fname in sorted(os.listdir(args.directory)):
        if not fname.endswith(".json"):
            continue

        path = os.path.join(args.directory, fname)
        with open(path, "r") as f:
            jcrd = json.load(f)

        title = jcrd.get("title", os.path.splitext(fname)[0]).replace(
            " ", "_"
        )
        bpm = jcrd.get("bpm", 120)

        for idx, section in enumerate(jcrd.get("sections", [])):
            chords = section.get("chords", [])
            duration_ms = section.get("duration_ms", 4000)
            section_id = section.get("id", f"section{idx}")
            midi = create_midi_from_section(chords, bpm, duration_ms)
            out_filename = f"{title}__{section_id}.mid"
            out_path = os.path.join(args.output, out_filename)
            midi.write(out_path)
            print(f"🎹 Exported {out_filename}")


if __name__ == "__main__":
    main()
