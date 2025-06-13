#!/usr/bin/env python3
"""
Extract Archive File - Multi-format extractor

This script can extract various archive formats including .tar.gz, .tgz, .tar, .zip,
and will attempt to detect and extract appropriately.
"""

import os
import sys
import tarfile
import zipfile
import gzip
import shutil
import magic  # python-magic library for file type detection
from pathlib import Path

def detect_file_type(file_path):
    """Detect the file type using magic numbers."""
    mime = magic.Magic(mime=True)
    file_type = mime.from_file(file_path)
    print(f"Detected file type: {file_type}")
    return file_type

def extract_file(file_path, extract_dir=None):
    """
    Extract an archive file based on its detected type.
    
    Args:
        file_path: Path to the archive file
        extract_dir: Directory to extract to (default: same directory as archive)
    
    Returns:
        bool: True if extraction was successful
    """
    if not os.path.exists(file_path):
        print(f"Error: File not found: {file_path}")
        return False
    
    if not extract_dir:
        extract_dir = os.path.dirname(file_path)
    
    os.makedirs(extract_dir, exist_ok=True)
    print(f"Extracting to: {extract_dir}")
    
    try:
        # Try to detect file type
        file_type = detect_file_type(file_path)
        
        # Extract based on file type
        if "gzip" in file_type:
            print("Detected gzip compressed file")
            
            # For .tar.gz or .tgz
            if tarfile.is_tarfile(file_path):
                print("Extracting tar.gz file...")
                with tarfile.open(file_path, "r:gz") as tar:
                    tar.extractall(path=extract_dir)
            else:
                # Just a .gz file (not a tar archive)
                output_file = os.path.join(extract_dir, os.path.basename(file_path)[:-3])
                print(f"Extracting .gz file to {output_file}...")
                with gzip.open(file_path, 'rb') as f_in:
                    with open(output_file, 'wb') as f_out:
                        shutil.copyfileobj(f_in, f_out)
        
        elif "tar" in file_type or tarfile.is_tarfile(file_path):
            print("Extracting tar file...")
            with tarfile.open(file_path, "r") as tar:
                tar.extractall(path=extract_dir)
        
        elif "zip" in file_type or zipfile.is_zipfile(file_path):
            print("Extracting zip file...")
            with zipfile.ZipFile(file_path, 'r') as zip_ref:
                zip_ref.extractall(extract_dir)
        
        else:
            print(f"Error: Unsupported file format: {file_type}")
            return False
        
        print("Extraction completed successfully!")
        
        # List extracted contents
        contents = os.listdir(extract_dir)
        print(f"Extracted {len(contents)} items at root level")
        for i, item in enumerate(contents[:10]):
            item_path = os.path.join(extract_dir, item)
            if os.path.isdir(item_path):
                subcontents = os.listdir(item_path)
                print(f"  {i+1}. {item}/ ({len(subcontents)} items)")
            else:
                print(f"  {i+1}. {item}")
        
        if len(contents) > 10:
            print(f"  ... and {len(contents) - 10} more items")
        
        return True
    
    except Exception as e:
        print(f"Error extracting file: {str(e)}")
        
        # Try alternative methods if first attempt failed
        if "gzip" in file_type and not "tar.gz" in file_type:
            print("Trying alternative extraction method...")
            try:
                output_file = os.path.join(extract_dir, os.path.basename(file_path)[:-3])
                with gzip.open(file_path, 'rb') as f_in:
                    with open(output_file, 'wb') as f_out:
                        shutil.copyfileobj(f_in, f_out)
                print(f"Extracted to {output_file}")
                return True
            except Exception as e2:
                print(f"Alternative method failed: {str(e2)}")
                return False
        
        return False

def main():
    """Main function to extract an archive file."""
    if len(sys.argv) < 2:
        print("Usage: python extract_archive.py <archive_file> [extract_directory]")
        return 1
    
    file_path = sys.argv[1]
    extract_dir = sys.argv[2] if len(sys.argv) > 2 else None
    
    if extract_file(file_path, extract_dir):
        return 0
    else:
        return 1

if __name__ == "__main__":
    sys.exit(main())
