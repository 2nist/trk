#!/usr/bin/env python3
"""
irealpro_to_jcrd.py - Convert iReal Pro .ireal format to .jcrd format
This script supports basic extraction of chords, key, and section info from a single-song .ireal file.
"""

import argparse
import json
import re
import xml.etree.ElementTree as ET

def parse_ireal_file(filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    # Extract XML chunk between <score> tags
    match = re.search(r'<score.*?</score>', content, re.DOTALL)
    if not match:
        raise ValueError("Could not find <score> block in file.")

    xml_content = match.group(0)
    root = ET.fromstring(xml_content)

    title = root.attrib.get("title", "Untitled")
    composer = root.attrib.get("composer", "Unknown")
    key = root.attrib.get("key", "C")
    style = root.attrib.get("style", "Default")

    chords_raw = root.text.strip().split()
    chords = [c for c in chords_raw if c not in ("|", "||", "||:", ":||")]

    return {
        "title": title,
        "artist": composer,
        "key": key,
        "mode": "major" if "m" not in key.lower() else "minor",
        "bpm": 120,
        "source": "iRealPro",
        "style": style,
        "sections": [{
            "id": "section_1",
            "sectionLabel": "Main",
            "start_ms": 0,
            "duration_ms": len(chords) * 2000,
            "chords": chords,
            "romanNumerals": [],
            "tags": ["ireal", "converted"]
        }]
    }

def main():
    parser = argparse.ArgumentParser(description="Convert iReal Pro .ireal file to JCRD format")
    parser.add_argument("input", help="Path to input .ireal file")
    parser.add_argument("output", help="Path to output .jcrd JSON file")
    args = parser.parse_args()

    jcrd_data = parse_ireal_file(args.input)

    with open(args.output, "w", encoding="utf-8") as f:
        json.dump(jcrd_data, f, indent=2)

    print(f"✅ Saved .jcrd to {args.output}")

if __name__ == "__main__":
    main()
