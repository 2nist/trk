# rock_corpus_mel_to_jcrd.py
import json
import sys
import os

def convert_mel_to_jcrd(mel_path, jcrd_path):
    """
    Converts a Rock Corpus .mel file to JCRD format (potentially focusing on metadata or a simplified representation).
    Melody conversion to JCRD chords is non-trivial and might be out of scope
    or require an intermediate MIDI conversion.
    This stub will focus on creating a basic JCRD with metadata.
    """
    mel_data = {} # Placeholder
    with open(mel_path, 'r') as f:
        lines = f.readlines()
        title_line = next((line for line in lines if line.startswith('%')), None)
        title = title_line.strip().lstrip('%').strip() if title_line else os.path.splitext(os.path.basename(mel_path))[0]
        mel_data['title'] = title
        # Further parsing of .mel content would go here if needed

    jcrd_content = {
        "metadata": {
            "title": mel_data.get("title", "Unknown Title"),
            "artist": "Unknown Artist",
            "key": "C", # Placeholder
            "tempo": 120, # Placeholder
            "source_format": "RockCorpus MEL",
            "notes": "This JCRD was generated from a .mel file. Melody data is not directly converted to chords here."
        },
        "chords": [],
        "beats": [],
        "sections": []
    }

    with open(jcrd_path, 'w') as f:
        json.dump(jcrd_content, f, indent=2)
    print(f"Converted (metadata-only) {mel_path} to {jcrd_path}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python rock_corpus_mel_to_jcrd.py <input_mel_file> <output_jcrd_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    if not os.path.exists(input_file):
        print(f"Error: Input file {input_file} not found.")
        sys.exit(1)

    convert_mel_to_jcrd(input_file, output_file)
