"""
TOOLBOX:
name: Add Roman Numerals
description: Uses Music21 to analyze chords in each section of a .jcrd file and annotate with functional harmony.
arguments:
  --directory: Folder of .jcrd files (default: mcgill_jcrd/)
"""

import os
import json
import argparse
from music21 import roman, key, chord


def analyze_chords_to_roman(chords, key_signature):
    try:
        k = key.Key(key_signature)
        roman_numerals = []
        for ch in chords:
            try:
                c = chord.Chord(ch)
                rn = roman.romanNumeralFromChord(c, k)
                roman_numerals.append(str(rn.figure))
            except Exception:
                roman_numerals.append("?")
        return roman_numerals
    except Exception as e:
        print(f"Key error: {e}")
        return ["?"] * len(chords)


def main():
    parser = argparse.ArgumentParser(
        description="Add Roman numerals to .jcrd sections"
    )
    parser.add_argument(
        "--directory", default="mcgill_jcrd", help="Folder of .jcrd files"
    )
    args = parser.parse_args()

    for filename in sorted(os.listdir(args.directory)):
        if not filename.endswith(".json"):
            continue

        fpath = os.path.join(args.directory, filename)
        with open(fpath, "r") as f:
            data = json.load(f)

        song_key = data.get("key", "C")

        updated = False
        for section in data.get("sections", []):
            if "romanNumerals" not in section or not section["romanNumerals"]:
                chords = section.get("chords", [])
                section["romanNumerals"] = analyze_chords_to_roman(
                    chords, song_key
                )
                updated = True

        if updated:
            with open(fpath, "w") as f:
                json.dump(data, f, indent=2)
            print(f"✅ Updated Roman numerals in {filename}")


if __name__ == "__main__":
    main()
