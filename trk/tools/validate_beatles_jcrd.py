"""
Validates Beatles JCRD files after extraction and conversion.

This script checks if the Beatles dataset was correctly extracted and converted to JCRD format.
It provides a summary of the converted files and performs basic validation on their structure.
"""

import os
import json
import glob
import sys
from collections import defaultdict

# Define paths
REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE_DIR = os.path.join(REPO_ROOT, "data", "source_archive", "beatles", "chords")
JCRD_DIR = os.path.join(REPO_ROOT, "data", "jcrd_library", "beatles_full")

def count_source_files():
    """Count the source annotation files."""
    if not os.path.exists(SOURCE_DIR):
        print(f"Source directory not found: {SOURCE_DIR}")
        return 0
        
    # Count all .lab files recursively
    lab_files = glob.glob(os.path.join(SOURCE_DIR, "**", "*.lab"), recursive=True)
    return len(lab_files)

def count_jcrd_files():
    """Count the converted JCRD files."""
    if not os.path.exists(JCRD_DIR):
        print(f"JCRD directory not found: {JCRD_DIR}")
        return 0
        
    # Count all .jcrd.json files
    jcrd_files = glob.glob(os.path.join(JCRD_DIR, "*.jcrd.json"))
    return len(jcrd_files)

def validate_jcrd_structure(file_path):
    """Validate the structure of a JCRD file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            
        # Check for required fields
        if "metadata" not in data:
            return False, "Missing 'metadata' field"
            
        if "sections" not in data and "chord_progression" not in data:
            return False, "Missing both 'sections' and 'chord_progression' fields"
            
        # Check metadata fields
        metadata = data["metadata"]
        required_metadata = ["title", "artist", "album"]
        for field in required_metadata:
            if field not in metadata:
                return False, f"Missing '{field}' in metadata"
                
        # Check sections if present
        if "sections" in data and data["sections"]:
            for section in data["sections"]:
                if "name" not in section:
                    return False, "Section missing 'name' field"
                if "chords" in section and not isinstance(section["chords"], list):
                    return False, "Section 'chords' field is not a list"
                    
        # Check chord progression if present
        if "chord_progression" in data and data["chord_progression"]:
            for chord in data["chord_progression"]:
                if "chord" not in chord:
                    return False, "Chord missing 'chord' field"
                    
        return True, "Valid"
    except Exception as e:
        return False, str(e)

def analyze_jcrd_files():
    """Analyze the JCRD files and return statistics."""
    if not os.path.exists(JCRD_DIR):
        print(f"JCRD directory not found: {JCRD_DIR}")
        return {}
        
    stats = {
        "total_files": 0,
        "valid_files": 0,
        "invalid_files": 0,
        "albums": defaultdict(int),
        "errors": [],
        "chord_types": defaultdict(int),
        "section_types": defaultdict(int),
    }
    
    # Get all JCRD files
    jcrd_files = glob.glob(os.path.join(JCRD_DIR, "*.jcrd.json"))
    stats["total_files"] = len(jcrd_files)
    
    # Analyze each file
    for file_path in jcrd_files:
        is_valid, message = validate_jcrd_structure(file_path)
        
        if is_valid:
            stats["valid_files"] += 1
            
            # Additional analysis on valid files
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                
            # Count albums
            if "metadata" in data and "album" in data["metadata"]:
                stats["albums"][data["metadata"]["album"]] += 1
                
            # Count chord types
            if "chord_progression" in data:
                for chord_item in data["chord_progression"]:
                    if "chord" in chord_item:
                        chord = chord_item["chord"]
                        stats["chord_types"][chord] += 1
            
            # Alternatively check sections for chords
            if "sections" in data:
                for section in data["sections"]:
                    # Count section types
                    if "name" in section:
                        stats["section_types"][section["name"]] += 1
                    
                    # Count chord types in sections
                    if "chords" in section:
                        for chord_item in section["chords"]:
                            if "chord" in chord_item:
                                chord = chord_item["chord"]
                                stats["chord_types"][chord] += 1
        else:
            stats["invalid_files"] += 1
            stats["errors"].append((os.path.basename(file_path), message))
    
    return stats

def print_validation_report():
    """Print a validation report for the Beatles JCRD files."""
    print("Beatles JCRD Validation Report")
    print("=============================\n")
    
    # Count source and JCRD files
    source_count = count_source_files()
    jcrd_count = count_jcrd_files()
    
    print(f"Source annotation files: {source_count}")
    print(f"Converted JCRD files: {jcrd_count}\n")
    
    # Check if conversion was successful
    if source_count == 0:
        print("ERROR: No source annotation files found.")
        print("Please check that the Beatles annotations were extracted correctly.")
        return False
    
    if jcrd_count == 0:
        print("ERROR: No converted JCRD files found.")
        print("Please run the conversion script to generate JCRD files.")
        return False
    
    # Analyze JCRD files
    stats = analyze_jcrd_files()
    
    print(f"Valid JCRD files: {stats['valid_files']} / {stats['total_files']}")
    print(f"Invalid JCRD files: {stats['invalid_files']} / {stats['total_files']}\n")
    
    if stats["invalid_files"] > 0:
        print("Invalid files:")
        for file_name, error in stats["errors"][:10]:  # Show only first 10 errors
            print(f"  - {file_name}: {error}")
        if len(stats["errors"]) > 10:
            print(f"  ... and {len(stats['errors']) - 10} more errors")
        print()
    
    # Print album statistics
    print("Albums:")
    for album, count in sorted(stats["albums"].items()):
        print(f"  - {album}: {count} tracks")
    print()
    
    # Print most common section types
    print("Most common section types:")
    for section_type, count in sorted(stats["section_types"].items(), key=lambda x: x[1], reverse=True)[:10]:
        print(f"  - {section_type}: {count} occurrences")
    print()
    
    # Print most common chord types
    print("Most common chord types:")
    for chord_type, count in sorted(stats["chord_types"].items(), key=lambda x: x[1], reverse=True)[:10]:
        print(f"  - {chord_type}: {count} occurrences")
    print()
    
    # Overall assessment
    if stats["valid_files"] == stats["total_files"] and stats["total_files"] > 0:
        print("✓ All JCRD files are valid.")
        return True
    elif stats["valid_files"] > 0:
        print("⚠ Some JCRD files are valid, but there are errors to fix.")
        return True
    else:
        print("✗ No valid JCRD files found.")
        return False

if __name__ == "__main__":
    success = print_validation_report()
    sys.exit(0 if success else 1)
