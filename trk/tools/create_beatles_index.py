"""
Creates an index file for the Beatles JCRD dataset.

This script scans the Beatles JCRD files and creates an index file
that can be used by Songbase to browse and search the Beatles dataset.
"""

import os
import json
import glob
import sys
from datetime import datetime

# Define paths
REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
JCRD_DIR = os.path.join(REPO_ROOT, "data", "jcrd_library", "beatles_full")
INDEX_DIR = os.path.join(REPO_ROOT, "data", "metadata")
INDEX_FILE = os.path.join(INDEX_DIR, "beatles_index.json")

def create_index():
    """Create an index file for the Beatles JCRD dataset."""
    # Ensure the index directory exists
    os.makedirs(INDEX_DIR, exist_ok=True)
    
    if not os.path.exists(JCRD_DIR):
        print(f"JCRD directory not found: {JCRD_DIR}")
        return False
    
    # Find all JCRD files
    jcrd_files = glob.glob(os.path.join(JCRD_DIR, "*.jcrd.json"))
    if not jcrd_files:
        print("No JCRD files found.")
        return False
    
    print(f"Found {len(jcrd_files)} JCRD files.")
    
    # Create index data structure
    index = {
        "name": "Beatles Dataset",
        "description": "The Beatles Dataset containing chord and structure annotations from the Isophonics dataset",
        "version": "1.0",
        "date_created": datetime.now().isoformat(),
        "source": "Isophonics Beatles Dataset",
        "total_files": len(jcrd_files),
        "file_format": "jcrd.json",
        "categories": {
            "albums": {},
            "keys": {},
            "time_signatures": {}
        },
        "tracks": []
    }
    
    # Process each JCRD file
    for jcrd_file in jcrd_files:
        try:
            with open(jcrd_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # Get metadata
            metadata = data.get("metadata", {})
            title = metadata.get("title", "Unknown")
            artist = metadata.get("artist", "The Beatles")
            album = metadata.get("album", "Unknown")
            key = metadata.get("key", "Unknown")
            tempo = metadata.get("tempo", 120)
            time_signature = metadata.get("time_signature", "4/4")
            
            # Update albums category
            if album not in index["categories"]["albums"]:
                index["categories"]["albums"][album] = 0
            index["categories"]["albums"][album] += 1
            
            # Update keys category
            if key not in index["categories"]["keys"]:
                index["categories"]["keys"][key] = 0
            index["categories"]["keys"][key] += 1
            
            # Update time_signatures category
            if time_signature not in index["categories"]["time_signatures"]:
                index["categories"]["time_signatures"][time_signature] = 0
            index["categories"]["time_signatures"][time_signature] += 1
            
            # Create relative path
            rel_path = os.path.relpath(jcrd_file, os.path.join(REPO_ROOT, "data", "jcrd_library"))
            
            # Count sections and chords
            num_sections = len(data.get("sections", []))
            num_chords = len(data.get("chord_progression", []))
            
            # Add track to index
            track_info = {
                "id": os.path.splitext(os.path.basename(jcrd_file))[0],
                "title": title,
                "artist": artist,
                "album": album,
                "key": key,
                "tempo": tempo,
                "time_signature": time_signature,
                "path": rel_path.replace("\\", "/"),  # Ensure forward slashes for cross-platform compatibility
                "sections": num_sections,
                "chords": num_chords
            }
            
            index["tracks"].append(track_info)
            
        except Exception as e:
            print(f"Error processing {os.path.basename(jcrd_file)}: {e}")
    
    # Sort tracks by album and title
    index["tracks"].sort(key=lambda x: (x["album"], x["title"]))
    
    # Write index file
    with open(INDEX_FILE, 'w', encoding='utf-8') as f:
        json.dump(index, f, indent=2)
    
    print(f"Created index file: {INDEX_FILE}")
    print(f"Indexed {len(index['tracks'])} tracks")
    print(f"Found {len(index['categories']['albums'])} albums")
    
    return True

if __name__ == "__main__":
    if create_index():
        print("\nIndex creation successful.")
        sys.exit(0)
    else:
        print("\nIndex creation failed.")
        sys.exit(1)
