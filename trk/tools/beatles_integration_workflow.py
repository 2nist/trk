#!/usr/bin/env python3
"""
Beatles Dataset Integration Workflow

This script automates the process of integrating the Beatles dataset into Songbase.
It performs the following steps:
1. Extract the Beatles annotations from the tar.gz archive
2. Convert the annotations to JCRD format
3. Validate the converted JCRD files
4. Create an index file for the Beatles dataset
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path

# Define paths relative to this script
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(SCRIPT_DIR)

# Define paths for Beatles integration
SOURCE_ARCHIVE = os.path.join(REPO_ROOT, "data", "source_archive", "beatles", "chords")
OUTPUT_DIR = os.path.join(REPO_ROOT, "data", "jcrd_library", "beatles_full")

def print_header(message):
    """Print a section header."""
    print("\n" + "=" * 60)
    print(f" {message}")
    print("=" * 60 + "\n")

def extract_annotations(archive_path=None):
    """Extract the Beatles annotations from the tar.gz archive."""
    print_header("STEP 1: Extract Beatles Annotations")
    
    # Import the extract_beatles_annotations module
    sys.path.insert(0, SCRIPT_DIR)
    try:
        from extract_beatles_annotations import extract_tar_gz
    except ImportError:
        print("Error: Could not import extract_beatles_annotations.py")
        return False
    
    # If archive_path is not provided, look for it in default locations or prompt user
    if not archive_path:
        # Common locations to check
        possible_locations = [
            os.path.join(REPO_ROOT, "data", "The Beatles Annotations.tar.gz"),
            os.path.join(REPO_ROOT, "data", "source_archive", "The Beatles Annotations.tar.gz"),
            os.path.join(REPO_ROOT, "The Beatles Annotations.tar.gz")
        ]
        
        for location in possible_locations:
            if os.path.exists(location):
                archive_path = location
                print(f"Found archive at: {archive_path}")
                break
        
        if not archive_path:
            archive_path = input("Enter the full path to the Beatles Annotations tar.gz file: ")
    
    # Check if the archive exists
    if not os.path.exists(archive_path):
        print(f"Error: Archive not found at {archive_path}")
        return False
    
    print(f"Extracting {archive_path} to {SOURCE_ARCHIVE}")
    
    # Create the target directory
    os.makedirs(SOURCE_ARCHIVE, exist_ok=True)
    
    # Extract the archive
    success = extract_tar_gz(archive_path, SOURCE_ARCHIVE)
    
    if success:
        print("\nExtraction completed successfully.")
        return True
    else:
        print("\nExtraction failed.")
        return False

def convert_annotations():
    """Convert the Beatles annotations to JCRD format."""
    print_header("STEP 2: Convert Annotations to JCRD Format")
    
    # Check if the source directory exists
    if not os.path.exists(SOURCE_ARCHIVE):
        print(f"Error: Source directory not found: {SOURCE_ARCHIVE}")
        print("Please extract the Beatles annotations first.")
        return False
    
    # Run the conversion script
    convert_script = os.path.join(SCRIPT_DIR, "convert_beatles_annotations.py")
    if not os.path.exists(convert_script):
        print(f"Error: Conversion script not found: {convert_script}")
        return False
    
    # Create the output directory
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    # Run the conversion script
    cmd = [sys.executable, convert_script, "--source", SOURCE_ARCHIVE, "--output", OUTPUT_DIR]
    print(f"Running: {' '.join(cmd)}")
    
    try:
        process = subprocess.run(cmd, check=True, text=True)
        return process.returncode == 0
    except subprocess.CalledProcessError as e:
        print(f"Error running conversion script: {e}")
        return False
    except Exception as e:
        print(f"Unexpected error: {e}")
        return False

def validate_jcrd():
    """Validate the converted JCRD files."""
    print_header("STEP 3: Validate JCRD Files")
    
    # Run the validation script
    validate_script = os.path.join(SCRIPT_DIR, "validate_beatles_jcrd.py")
    if not os.path.exists(validate_script):
        print(f"Error: Validation script not found: {validate_script}")
        return False
    
    cmd = [sys.executable, validate_script]
    print(f"Running: {' '.join(cmd)}")
    
    try:
        process = subprocess.run(cmd, check=True, text=True)
        return process.returncode == 0
    except subprocess.CalledProcessError as e:
        print(f"Error running validation script: {e}")
        return False
    except Exception as e:
        print(f"Unexpected error: {e}")
        return False

def create_index():
    """Create an index file for the Beatles dataset."""
    print_header("STEP 4: Create Beatles Index")
    
    # Run the index creation script
    index_script = os.path.join(SCRIPT_DIR, "create_beatles_index.py")
    if not os.path.exists(index_script):
        print(f"Error: Index creation script not found: {index_script}")
        return False
    
    cmd = [sys.executable, index_script]
    print(f"Running: {' '.join(cmd)}")
    
    try:
        process = subprocess.run(cmd, check=True, text=True)
        return process.returncode == 0
    except subprocess.CalledProcessError as e:
        print(f"Error running index creation script: {e}")
        return False
    except Exception as e:
        print(f"Unexpected error: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description="Beatles Dataset Integration Workflow")
    parser.add_argument("--archive", help="Path to the Beatles Annotations tar.gz file")
    parser.add_argument("--skip-extract", action="store_true", help="Skip extraction step")
    parser.add_argument("--skip-convert", action="store_true", help="Skip conversion step")
    parser.add_argument("--skip-validate", action="store_true", help="Skip validation step")
    parser.add_argument("--skip-index", action="store_true", help="Skip index creation step")
    
    args = parser.parse_args()
    
    print_header("Beatles Dataset Integration Workflow")
    print(f"Repository root: {REPO_ROOT}")
    print(f"Source archive directory: {SOURCE_ARCHIVE}")
    print(f"Output JCRD directory: {OUTPUT_DIR}")
    
    # Step 1: Extract
    if not args.skip_extract:
        if not extract_annotations(args.archive):
            print("Extraction failed. Workflow stopped.")
            return 1
    else:
        print("Skipping extraction step.")
    
    # Step 2: Convert
    if not args.skip_convert:
        if not convert_annotations():
            print("Conversion failed. Workflow stopped.")
            return 1
    else:
        print("Skipping conversion step.")
    
    # Step 3: Validate
    if not args.skip_validate:
        if not validate_jcrd():
            print("Validation failed. Workflow stopped.")
            return 1
    else:
        print("Skipping validation step.")
    
    # Step 4: Create index
    if not args.skip_index:
        if not create_index():
            print("Index creation failed. Workflow stopped.")
            return 1
    else:
        print("Skipping index creation step.")
    
    print_header("Workflow Complete")
    print("The Beatles dataset has been successfully integrated into Songbase.")
    print(f"JCRD files are available in: {OUTPUT_DIR}")
    print(f"Index file is available in: {os.path.join(REPO_ROOT, 'data', 'metadata', 'beatles_index.json')}")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
