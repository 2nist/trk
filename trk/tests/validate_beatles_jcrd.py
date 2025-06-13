#!/usr/bin/env python3
"""
Beatles JCRD File Validator

This script validates and displays the contents of Beatles JCRD files.
It doesn't rely on any GUI, only on basic Python functionality.
"""

import os
import json
import sys
from pathlib import Path

def format_jcrd_info(jcrd_data, file_name):
    """Format JCRD data as readable text."""
    text = f"File: {file_name}\n"
    text += "----------------------------------------\n"
    
    metadata = jcrd_data.get("metadata", {})
    if metadata:
        text += f"Title: {metadata.get('title', 'Unknown')}\n"
        text += f"Artist: {metadata.get('artist', 'Unknown')}\n"
        text += f"Album: {metadata.get('album', 'Unknown')}\n"
        text += f"Key: {metadata.get('key', 'Unknown')}\n"
        text += f"Tempo: {metadata.get('tempo', 'Unknown')}\n"
        text += f"Time Signature: {metadata.get('time_signature', 'Unknown')}\n"
        
        if "tags" in metadata:
            text += f"Tags: {', '.join(metadata['tags'])}\n"
    
    sections = jcrd_data.get("sections", [])
    text += f"\nSections: {len(sections)}\n"
    
    for i, section in enumerate(sections, 1):
        text += f"  {i}. {section.get('name', 'Unnamed')} "
        text += f"({section.get('start_time', 0)} - {section.get('end_time', 0)})\n"
        
        chords = section.get("chords", [])
        text += f"    Chords: {len(chords)}\n"
        
        for j, chord in enumerate(chords, 1):
            text += f"      {j}. {chord.get('chord', 'Unknown')} "
            text += f"({chord.get('start_time', 0)} - {chord.get('end_time', 0)})\n"
    
    text += "----------------------------------------\n\n"
    return text

def main():
    """Main function to validate Beatles JCRD files."""
    # Find the script directory and project root
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)  # songbase root
    
    # Path to Beatles JCRD files - try multiple possible locations
    beatles_dir = os.path.join(project_root, "data", "jcrd_library", "beatles")
    
    if not os.path.exists(beatles_dir):
        # Try with absolute path
        beatles_dir = r"c:\Users\CraftAuto-Sales\AppData\Roaming\REAPER\Scripts\songbase\data\jcrd_library\beatles"
    
    print(f"Looking for Beatles JCRD files in: {beatles_dir}")
    
    # Check if the directory exists
    if not os.path.exists(beatles_dir):
        print(f"Directory doesn't exist: {beatles_dir}")
        return
    
    # Get list of Beatles JCRD files
    jcrd_files = [f for f in os.listdir(beatles_dir) if f.endswith(".jcrd.json")]
    
    if not jcrd_files:
        print("No JCRD files found in the Beatles directory.")
    else:
        print(f"Found {len(jcrd_files)} Beatles JCRD files.\n")
        
        # Analyze each file
        for file_name in jcrd_files:
            file_path = os.path.join(beatles_dir, file_name)
            
            try:
                with open(file_path, 'r') as f:
                    content = f.read()
                    jcrd_data = json.loads(content)
                    info = format_jcrd_info(jcrd_data, file_name)
                    print(info)
            except (json.JSONDecodeError, FileNotFoundError) as e:
                print(f"Error with file {file_name}: {str(e)}")
    
    # Try to validate a specific file
    specific_file = os.path.join(beatles_dir, "0111.jcrd.json")
    print(f"\nTrying to validate specific file: {specific_file}")
    
    try:
        with open(specific_file, 'r') as f:
            content = f.read()
            print(f"File content (first 500 chars):\n{content[:500]}...\n")
            
            jcrd_data = json.loads(content)
            print("Successfully parsed specific file!")
            
            # Additional validation
            if "metadata" in jcrd_data and "sections" in jcrd_data:
                print("File structure is valid (has metadata and sections).")
                
                # Count total chords
                total_chords = sum(len(section.get("chords", [])) for section in jcrd_data.get("sections", []))
                print(f"Total chords in the song: {total_chords}")
                
                # Check for minimum required fields
                metadata = jcrd_data["metadata"]
                required_fields = ["title", "artist", "key", "tempo"]
                missing = [field for field in required_fields if field not in metadata]
                
                if missing:
                    print(f"Missing required metadata fields: {', '.join(missing)}")
                else:
                    print("All required metadata fields are present.")
            else:
                print("File structure is invalid (missing metadata or sections).")
                
    except (json.JSONDecodeError, FileNotFoundError) as e:
        print(f"Error with specific file: {str(e)}")
    
    print("\n--- Validation Complete ---")

if __name__ == "__main__":
    main()
