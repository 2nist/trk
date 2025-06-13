#!/usr/bin/env python3
"""
jams_to_jcrd.py - Convert JAMS files to .jcrd format

This script reads a JAMS file and converts its chord, beat, and optional section data
into the standardized .jcrd structure used for REAPER-based music arrangement tools.
"""

import json
import sys
import os
import argparse
import jams
import csv
import datetime
import re
import tempfile

def convert_jams_to_jcrd(jams_path):
    """
    Convert a JAMS file to JCRD format.
    
    Args:
        jams_path: Path to the JAMS file
        
    Returns:
        tuple: (jam, jcrd) - the JAMS object and the converted JCRD dictionary
    """
    # Workaround for JAMS schema: fix file_metadata.duration=None
    with open(jams_path, 'r', encoding='utf-8') as jf:
        jam_data = json.load(jf)
    
    if 'file_metadata' in jam_data and jam_data['file_metadata'].get('duration', 0) is None:
        jam_data['file_metadata']['duration'] = 0.0
    
    # Extract time signature if available
    time_signature = None
    
    # Fix chord annotation values, and filter annotations to include only known namespaces
    if 'annotations' in jam_data:
        filtered_annotations = []
        for ann in jam_data['annotations']:
            ns = ann.get('namespace', '').lower()
            
            # Only process known/handled namespaces (including timesig)
            if ns in ['chord', 'chord_roman', 'chord_harte', 'chord_mirex', 'key_mode', 'segment', 'beat', 'timesig']:
                # Process chord-like namespaces - ensure values are schema compliant
                if ns in ['chord', 'chord_roman', 'chord_harte', 'chord_mirex'] and 'data' in ann:
                    for datum in ann['data']:
                        val = datum.get('value')
                        # Always convert to object form for all chord-like namespaces
                        if isinstance(val, str):
                            val_str = val.strip()
                            # Handle 'N', 'NC', 'N.C.' as no chord
                            if val_str.upper() in ['N', 'NC', 'N.C.']:
                                datum['value'] = {'tonic': '', 'chord': ''}
                            # Handle 'Tonic:Chord' format (e.g., 'F#:I')
                            elif ':' in val_str:
                                tonic, chord = val_str.split(':', 1)
                                tonic = tonic.strip()
                                chord = chord.strip()
                                if re.match(r'^[A-G][b#]?$', tonic) and chord:
                                    datum['value'] = {'tonic': tonic, 'chord': chord}
                                else:
                                    datum['value'] = {'tonic': '', 'chord': ''}
                            else:
                                # If not parseable, set as no chord
                                datum['value'] = {'tonic': '', 'chord': ''}
                        elif isinstance(val, dict):
                            tonic = val.get('tonic', '')
                            chord = val.get('chord', '')
                            # Validate tonic and chord
                            if not (isinstance(tonic, str) and re.match(r'^[A-G][b#]?$|^$', tonic)):
                                datum['value']['tonic'] = ''
                            if not chord:
                                datum['value']['chord'] = ''
                        else:
                            # If value is not string or dict, set as no chord
                            datum['value'] = {'tonic': '', 'chord': ''}
                
                # Extract time signature from timesig namespace, if present
                elif ns == 'timesig' and 'data' in ann:
                    # Only take the first time signature for now
                    if ann['data'] and time_signature is None:
                        ts_val = ann['data'][0].get('value', {})
                        if isinstance(ts_val, dict) and 'numerator' in ts_val and 'denominator' in ts_val:
                            time_signature = f"{ts_val['numerator']}/{ts_val['denominator']}"
                
                # Add all known namespaces to filtered annotations
                filtered_annotations.append(ann)
        
        # Replace annotations with filtered ones
        jam_data['annotations'] = filtered_annotations
    
    # Write to a temp file for jams.load
    with tempfile.NamedTemporaryFile('w+', delete=False, suffix='.jams', encoding='utf-8') as tf:
        json.dump(jam_data, tf)
        temp_jams_path = tf.name
    
    # Load the modified JAMS file
    jam = jams.load(temp_jams_path)
    os.remove(temp_jams_path)
    
    # Initialize JCRD structure
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
    
    # Add time signature if available
    if time_signature:
        jcrd['time_signature'] = time_signature
        jcrd['tags'].append(f"time_signature:{time_signature}")
    
    # Extract beat times
    try:
        beats = jam.search(namespace='beat')[0]
        jcrd["beat_times"] = [float(b.time) * 1000 for b in beats]
    except:
        print(f"⚠️ No beat namespace found in {os.path.basename(jams_path)}")
    
    # Extract chords
    try:
        chords = jam.search(namespace='chord')[0]
    except:
        print(f"❌ No chord namespace found in {os.path.basename(jams_path)}")
        chords = None
    
    # Extract sections (if available)
    try:
        sections = jam.search(namespace='segment')[0]
    except:
        print(f"⚠️ No section namespace found in {os.path.basename(jams_path)}")
        sections = None
    
    # Build sections
    if sections:
        for i, s in enumerate(sections):
            start = int(s.time * 1000)
            duration = int(s.duration * 1000)
            chords_in_section = []
            if chords:
                for c in chords:
                    c_start = c.time * 1000
                    c_end = c_start + (c.duration * 1000)
                    if start <= c_start < start + duration:
                        chords_in_section.append(c.value)
            section = {
                "id": f"section_{i+1}",
                "start_ms": start,
                "duration_ms": duration,
                "chords": chords_in_section or ["N.C."],
                "sectionLabel": s.value or f"section_{i+1}",
                "tags": ["jams_converted"],
                "romanNumerals": []
            }
            jcrd["sections"].append(section)
    elif chords:
        for i, c in enumerate(chords):
            section = {
                "id": f"chord_{i+1}",
                "start_ms": int(c.time * 1000),
                "duration_ms": int(c.duration * 1000),
                "chords": [c.value],
                "sectionLabel": f"chord_{i+1}",
                "tags": ["chord_only"],
                "romanNumerals": []
            }
            jcrd["sections"].append(section)
    
    return jam, jcrd

def main():
    parser = argparse.ArgumentParser(description="Convert a JAMS file to JCRD format, enriched with meta.csv and provenance.")
    parser.add_argument("input", help="Path to .jams file")
    parser.add_argument("output", nargs="?", help="Path to save .jcrd (.json) file. If omitted, will use 'Artist - Title.jcrd.json' in the same directory as input.")
    parser.add_argument("--meta", help="Path to meta.csv for enrichment", required=False)
    parser.add_argument("--partition", help="Partition name (e.g., rock-corpus)", required=False)
    parser.add_argument("--log", help="Path to log file", default="conversion_log.txt")
    args = parser.parse_args()

    # Load meta.csv if provided
    meta_lookup = {}
    if args.meta:
        with open(args.meta, newline='', encoding='utf-8') as metaf:
            reader = csv.DictReader(metaf)
            for row in reader:
                # Use jams_path as key for lookup
                meta_lookup[os.path.normpath(row['jams_path'])] = row

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
        
        # Provenance
        jcrd['source_file'] = args.input
        jcrd['conversion_date'] = datetime.datetime.now().isoformat()
        jcrd['partition'] = args.partition if args.partition else None

        # Determine output filename if not provided
        output_path = args.output
        if not output_path:
            # Sanitize artist and title for filename
            def sanitize(s):
                return ''.join(c for c in s if c.isalnum() or c in (' ', '-', '_')).rstrip()
            artist = sanitize(jcrd.get('artist', 'Unknown Artist'))
            title = sanitize(jcrd.get('title', 'Unknown Title'))
            base_dir = os.path.dirname(args.input)
            output_path = os.path.join(base_dir, f"{artist} - {title}.jcrd.json")

        with open(output_path, "w", encoding='utf-8') as f:
            json.dump(jcrd, f, indent=2)

        logmsg = f"SUCCESS: {args.input} -> {output_path} | title: {jcrd.get('title')} | artist: {jcrd.get('artist')} | partition: {jcrd.get('partition')}\n"
        print(f"✅ Saved JCRD to: {output_path}")
    except Exception as e:
        logmsg = f"FAIL: {args.input} | Error: {str(e)}\n"
        print(f"❌ Failed to convert {args.input}: {e}")

    # Logging
    with open(args.log, "a", encoding='utf-8') as logf:
        logf.write(logmsg)

if __name__ == "__main__":
    main()
