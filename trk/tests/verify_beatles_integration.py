#!/usr/bin/env python3
"""
Beatles Dataset Integration Verifier

This script checks if the Beatles dataset is properly integrated with the Songbase JCRD library.
It doesn't rely on ImGui, only on basic Python functionality.
"""

import os
import json
import sys
from pathlib import Path

def check_jcrd_structure():
    """Check if the JCRD library structure is correct."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    
    # Check if data directory exists
    data_dir = os.path.join(project_root, "data")
    if not os.path.exists(data_dir):
        print(f"❌ Data directory not found: {data_dir}")
        return False
    
    # Check if jcrd_library directory exists
    jcrd_dir = os.path.join(data_dir, "jcrd_library")
    if not os.path.exists(jcrd_dir):
        print(f"❌ JCRD library directory not found: {jcrd_dir}")
        return False
    
    # Check if Beatles directory exists
    beatles_dir = os.path.join(jcrd_dir, "beatles")
    if not os.path.exists(beatles_dir):
        print(f"❌ Beatles directory not found: {beatles_dir}")
        return False
    
    # Check if there are JCRD files in the Beatles directory
    jcrd_files = [f for f in os.listdir(beatles_dir) if f.endswith(".jcrd.json")]
    if not jcrd_files:
        print(f"❌ No JCRD files found in Beatles directory: {beatles_dir}")
        return False
    
    print(f"✅ JCRD library structure is correct")
    print(f"  - Data directory: {data_dir}")
    print(f"  - JCRD library directory: {jcrd_dir}")
    print(f"  - Beatles directory: {beatles_dir}")
    print(f"  - Found {len(jcrd_files)} JCRD files in Beatles directory")
    
    return True

def verify_beatles_jcrd_files():
    """Verify the Beatles JCRD files."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    beatles_dir = os.path.join(project_root, "data", "jcrd_library", "beatles")
    
    # Get list of Beatles JCRD files
    jcrd_files = [f for f in os.listdir(beatles_dir) if f.endswith(".jcrd.json")]
    
    all_valid = True
    
    for file_name in jcrd_files:
        file_path = os.path.join(beatles_dir, file_name)
        
        try:
            with open(file_path, 'r') as f:
                jcrd_data = json.load(f)
            
            # Check if it has the required structure
            if "metadata" not in jcrd_data:
                print(f"❌ Missing metadata in {file_name}")
                all_valid = False
                continue
                
            if "sections" not in jcrd_data:
                print(f"❌ Missing sections in {file_name}")
                all_valid = False
                continue
            
            # Check if it has the required metadata fields
            metadata = jcrd_data["metadata"]
            required_fields = ["title", "artist", "key", "tempo", "time_signature"]
            missing = [field for field in required_fields if field not in metadata]
            
            if missing:
                print(f"❌ Missing metadata fields in {file_name}: {', '.join(missing)}")
                all_valid = False
                continue
            
            # Check if artist is The Beatles
            if metadata.get("artist") != "The Beatles":
                print(f"❌ Artist is not 'The Beatles' in {file_name}: {metadata.get('artist')}")
                all_valid = False
                continue
                
            # Count sections and chords
            sections = jcrd_data["sections"]
            chord_count = sum(len(section.get("chords", [])) for section in sections)
            
            print(f"✅ Valid JCRD file: {file_name}")
            print(f"  - Title: {metadata.get('title')}")
            print(f"  - Album: {metadata.get('album')}")
            print(f"  - Key: {metadata.get('key')}")
            print(f"  - Tempo: {metadata.get('tempo')}")
            print(f"  - Sections: {len(sections)}")
            print(f"  - Total Chords: {chord_count}")
            
        except (json.JSONDecodeError, FileNotFoundError) as e:
            print(f"❌ Error with file {file_name}: {str(e)}")
            all_valid = False
    
    return all_valid

def check_songbase_integration():
    """Check if the Beatles dataset is properly integrated with Songbase."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    
    # Check for dataset browser config
    ui_dataset_browser = os.path.join(project_root, "tools", "ui_dataset_browser_cleaned.lua")
    
    if not os.path.exists(ui_dataset_browser):
        print(f"❌ Dataset browser not found: {ui_dataset_browser}")
        return False
    
    # Check if the dataset browser includes Beatles dataset
    try:
        with open(ui_dataset_browser, 'r') as f:
            content = f.read()
            
        if "Beatles" in content and "beatles" in content:
            print(f"✅ Dataset browser includes references to Beatles dataset")
        else:
            print(f"❌ Dataset browser doesn't reference the Beatles dataset")
            return False
    except FileNotFoundError:
        print(f"❌ Could not read dataset browser file: {ui_dataset_browser}")
        return False
    
    return True

def main():
    """Main function to verify the Beatles dataset integration."""
    print("\n=== Beatles Dataset Integration Verifier ===\n")
    
    # Check JCRD structure
    print("Checking JCRD library structure...")
    if not check_jcrd_structure():
        print("\nJCRD library structure check failed. Please fix the issues above.")
    else:
        print("\nVerifying Beatles JCRD files...")
        if verify_beatles_jcrd_files():
            print("\n✅ All Beatles JCRD files are valid")
        else:
            print("\n❌ Some Beatles JCRD files have issues")
        
        print("\nChecking Songbase integration...")
        if check_songbase_integration():
            print("\n✅ Beatles dataset is properly integrated with Songbase")
        else:
            print("\n❌ Beatles dataset integration with Songbase has issues")
    
    print("\n=== Verification Complete ===")

if __name__ == "__main__":
    main()
