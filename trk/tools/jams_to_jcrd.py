#!/usr/bin/env python3
"""
jams_to_jcrd.py - Convert JAMS files to .jcrd format

This script reads a JAMS file and converts its chord, beat, and optional section data
into the standardized .jcrd structure used for REAPER-based music arrangement tools.
"""

import json
import sys
import os
import re
import argparse
import csv
import copy
import datetime
import tempfile

# Maps for safe chord conversion
def safe_chord_value(val):
    """Convert any chord value to a schema-compatible string format"""
    # For 'N', 'NC', 'N.C.' values representing no chord
    if val is None:
        return "N.C."
        
    if isinstance(val, str) and val.upper() in ['N', 'NC', 'N.C.', 'NONE', '']:
        return "N.C."
        
    # Handle dictionary format from JAMS files
    if isinstance(val, dict):
        # Handle Roman numeral notation specifically
        if 'chord' in val and val['chord']:
            # Return just the chord part as a string
            return val['chord']
        
        # Extract components from chord dict
        root = val.get('root', '')
        quality = val.get('quality', '')
        bass = val.get('bass', '')
        
        # Handle specific formatting based on what's available
        if root and quality:
            chord_str = f"{root}{quality}"
            if bass and bass != root:
                chord_str += f"/{bass}"
            return chord_str
        else:
            return "N.C."
            
    # Handle Roman numeral format (e.g., "F#:I")
    elif isinstance(val, str) and ':' in val:
        tonic, chord = val.split(':', 1)
        # For Roman numerals, we convert to just the Roman part as a string
        if re.match(r'^[IiVv]+[a-z0-9]*$', chord.strip()):
            return chord.strip()
        # For normal chords with tonic prefix, format as proper chord
        else:
            return f"{tonic}{chord.strip()}"
            
    # If it's already a string and not handled above, return as is
    elif isinstance(val, str):
        return val if val else "N.C."
        
    # Default case for any other value types
    return "N.C."

def load_jams_file(jams_path):
    """Custom loader for JAMS files to bypass schema validation"""
    with open(jams_path, 'r', encoding='utf-8') as f:
        jam_data = json.load(f)
    
    # Create a class-like object to hold the JAMS data
    class JamsObj:
        def __init__(self, data):
            self.raw_data = data
            self.file_metadata = self._extract_file_metadata()
            self.annotations = self._extract_annotations()
            
        def _extract_file_metadata(self):
            class Metadata:
                def __init__(self, meta_data):
                    self.title = meta_data.get('title', '')
                    self.artist = meta_data.get('artist', '')
                    self.duration = meta_data.get('duration', 0.0) or 0.0
            
            return Metadata(self.raw_data.get('file_metadata', {}))
            
        def _extract_annotations(self):
            # Extract annotations without validation
            anns = []
            for ann_data in self.raw_data.get('annotations', []):
                class Annotation:
                    def __init__(self, data):
                        self.namespace = data.get('namespace', '')
                        self.data = []
                        # Extract each data point
                        for d in data.get('data', []):
                            class DataPoint:
                                def __init__(self, dp):
                                    self.time = float(dp.get('time', 0))
                                    self.duration = float(dp.get('duration', 0)) if dp.get('duration') is not None else 0
                                    self.value = dp.get('value', None)
                            
                            self.data.append(DataPoint(d))
                
                anns.append(Annotation(ann_data))
            
            return anns
        
        def search(self, namespace=None):
            """Find annotations by namespace"""
            results = []
            for ann in self.annotations:
                if namespace and ann.namespace == namespace:
                    results.append(ann)
            return results
    
    # Create and return the JAMS object
    return JamsObj(jam_data)

def convert_jams_to_jcrd(jams_path):
    """Convert a JAMS file to JCRD format"""
    # Load the JAMS file without validation
    try:
        jam = load_jams_file(jams_path)
    except Exception as e:
        raise Exception(f"Failed to load JAMS file: {e}")
    
    # Create JCRD structure
    jcrd = {
        "title": jam.file_metadata.title or "Unknown Title",
        "artist": jam.file_metadata.artist or "Unknown Artist",
        "bpm": 120,  # Default/fallback
        "key": "",
        "source": "JAMS Dataset",
        "beat_times": [],
        "sections": [],
        "tags": []
    }
    
    # Extract time signature if available
    time_signature = None
    try:
        for ann in jam.annotations:
            if ann.namespace == 'timesig':
                if len(ann.data) > 0:
                    ts_data = ann.data[0].value
                    if isinstance(ts_data, dict) and 'numerator' in ts_data and 'denominator' in ts_data:
                        time_signature = f"{ts_data['numerator']}/{ts_data['denominator']}"
                        break
    except Exception:
        pass  # Silently continue if time signature extraction fails
    
    if time_signature:
        jcrd['time_signature'] = time_signature
        jcrd['tags'].append(f"time_signature:{time_signature}")
    
    # Extract beat times
    beats = jam.search(namespace='beat')
    if beats:
        jcrd["beat_times"] = [float(b.time) * 1000 for b in beats[0].data]
    
    # Extract sections and chords
    sections = jam.search(namespace='segment')
    sections = sections[0] if sections else None
    
    # Find chord annotations
    chords = jam.search(namespace='chord')
    if not chords:
        chords = jam.search(namespace='chord_harte')
    if not chords:
        chords = jam.search(namespace='chord_mirex')
    if not chords:
        chords = jam.search(namespace='chord_roman')
    
    chords = chords[0] if chords else None
    
    # Build sections with proper schema-compliant values
    if sections and sections.data:
        for i, s in enumerate(sections.data):
            start = int(s.time * 1000)
            duration = int(s.duration * 1000) if s.duration else 1000  # Default 1s if no duration
            
            # Collect chords in this section
            chords_in_section = []
            if chords and chords.data:
                for c in chords.data:
                    c_start = c.time * 1000
                    if start <= c_start < start + duration:
                        # Ensure chord value is schema compliant
                        chord_value = safe_chord_value(c.value)
                        chords_in_section.append(chord_value)
            
            # Create section
            section = {
                "id": f"section_{i+1}",
                "start_ms": start,
                "duration_ms": duration,
                "chords": chords_in_section if chords_in_section else ["N.C."],
                "sectionLabel": s.value if s.value else f"section_{i+1}",
                "tags": ["jams_converted"],
                "romanNumerals": []
            }
            jcrd["sections"].append(section)
    elif chords and chords.data:
        # No sections, use chords directly
        for i, c in enumerate(chords.data):
            chord_value = safe_chord_value(c.value)
            section = {
                "id": f"chord_{i+1}",
                "start_ms": int(c.time * 1000),
                "duration_ms": int(c.duration * 1000) if c.duration else 1000,  # Default 1s if no duration
                "chords": [chord_value],
                "sectionLabel": f"chord_{i+1}",
                "tags": ["chord_only"],
                "romanNumerals": []
            }
            jcrd["sections"].append(section)
    else:
        # No sections or chords, create a dummy section
        section = {
            "id": "section_1",
            "start_ms": 0,
            "duration_ms": 60000,  # 1 minute
            "chords": ["N.C."],
            "sectionLabel": "section_1",
            "tags": ["empty_data"],
            "romanNumerals": []
        }
        jcrd["sections"].append(section)
    
    return jam, jcrd

def main():
    parser = argparse.ArgumentParser(description="Convert a JAMS file to JCRD format, enriched with meta.csv and provenance.")
    parser.add_argument("input", help="Path to .jams file")
    parser.add_argument("output", nargs="?", help="Path to save .jcrd (.json) file. If omitted, will use 'Title_Artist.jcrd.json' in the same directory as input.")
    parser.add_argument("--meta", help="Path to meta.csv for enrichment", required=False)
    parser.add_argument("--partition", help="Partition name (e.g., rock-corpus)", required=False)
    parser.add_argument("--out-dir", help="Directory to save the output file (if specified, output will be saved as Title_Artist.jcrd.json in this directory)", required=False)
    parser.add_argument("--log", help="Path to log file", default="conversion_log.txt")
    args = parser.parse_args()

    # Load meta.csv if provided
    meta_lookup = {}
    if args.meta:
        try:
            with open(args.meta, newline='', encoding='utf-8') as metaf:
                reader = csv.DictReader(metaf)
                for row in reader:
                    # Use jams_path as key for lookup
                    meta_lookup[os.path.normpath(row['jams_path'])] = row
        except Exception as e:
            print(f"Warning: Could not load meta.csv: {e}")

    # Convert and enrich
    try:
        jam, jcrd = convert_jams_to_jcrd(args.input)
        
        # Enrich with meta.csv if available
        meta_row = None
        if meta_lookup:
            # Try to match by jams_path (normalize for Windows paths)
            input_norm = os.path.normpath(args.input)
            for k, v in meta_lookup.items():
                if os.path.normpath(v['jams_path']) == input_norm or os.path.basename(v['jams_path']) == os.path.basename(args.input):
                    meta_row = v
                    break
                    
        if meta_row:
            jcrd['title'] = meta_row.get('title', jcrd['title']) or jcrd['title']
            jcrd['artist'] = meta_row.get('performers', jcrd.get('artist', 'Unknown Artist')) or jcrd.get('artist', 'Unknown Artist')
            jcrd['release_year'] = meta_row.get('release_year', None)
            jcrd['meta_id'] = meta_row.get('id', None)
            
        # Add provenance
        jcrd['source_file'] = args.input
        jcrd['conversion_date'] = datetime.datetime.now().isoformat()
        jcrd['partition'] = args.partition if args.partition else None        # Determine output filename
        output_path = args.output
        if not output_path:
            # Sanitize title and artist for filename
            def sanitize(s):
                return ''.join(c for c in s if c.isalnum() or c in (' ', '-', '_')).rstrip()
            
            title = sanitize(jcrd.get('title', 'Unknown Title'))
            artist = sanitize(jcrd.get('artist', 'Unknown Artist'))
            
            # Replace spaces with underscores for better filename format
            title = title.replace(' ', '_')
            artist = artist.replace(' ', '_')
            
            # Use output directory if specified, otherwise use same directory as input
            base_dir = args.out_dir if args.out_dir else os.path.dirname(args.input)
            
            # Create output directory if it doesn't exist
            if not os.path.exists(base_dir):
                os.makedirs(base_dir, exist_ok=True)
                
            output_path = os.path.join(base_dir, f"{title}_{artist}.jcrd.json")

        with open(output_path, "w", encoding='utf-8') as f:
            json.dump(jcrd, f, indent=2)

        logmsg = f"SUCCESS: {args.input} -> {output_path} | title: {jcrd.get('title')} | artist: {jcrd.get('artist')} | partition: {jcrd.get('partition')}\n"
        print(f"Success! Saved JCRD to: {output_path}")
    except Exception as e:
        logmsg = f"FAIL: {args.input} | Error: {str(e)}\n"
        print(f"Failed to convert {args.input}: {e}")

    # Logging
    with open(args.log, "a", encoding='utf-8') as logf:
        logf.write(logmsg)

if __name__ == "__main__":
    main()
