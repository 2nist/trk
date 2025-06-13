"""
Try to extract a file using various archive formats.
"""

import os
import sys
import tarfile
import zipfile
import shutil
import traceback

def try_extract_file(file_path, extract_to):
    """Try to extract the file using various methods."""
    print(f"Trying to extract {file_path} to {extract_to}")
    os.makedirs(extract_to, exist_ok=True)
    
    success = False
    
    # Try as a plain TAR file
    print("\nAttempting to extract as plain TAR file...")
    try:
        with tarfile.open(file_path, "r") as tar:
            tar.extractall(path=extract_to)
        print("✓ Successfully extracted as TAR file!")
        success = True
    except Exception as e:
        print(f"✗ Failed to extract as TAR: {e}")
    
    # Try as a ZIP file
    if not success:
        print("\nAttempting to extract as ZIP file...")
        try:
            with zipfile.ZipFile(file_path, 'r') as zip_ref:
                zip_ref.extractall(extract_to)
            print("✓ Successfully extracted as ZIP file!")
            success = True
        except Exception as e:
            print(f"✗ Failed to extract as ZIP: {e}")
    
    # Try as a text file (might be a list of files or paths)
    if not success:
        print("\nAttempting to read as text file...")
        try:
            with open(file_path, 'r', encoding='utf-8', errors='replace') as f:
                content = f.read(1000)  # Read first 1000 chars for preview
                print(f"File appears to be a text file. First 1000 characters:\n{content}\n...")
            
            # Create a sample output file with the content
            sample_file = os.path.join(extract_to, "sample_content.txt")
            shutil.copy(file_path, sample_file)
            print(f"✓ Copied file to {sample_file}")
            success = True
        except Exception as e:
            print(f"✗ Failed to read as text: {e}")
    
    return success

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python try_extract.py <file_path> [extract_to]")
        sys.exit(1)
        
    file_path = sys.argv[1]
    extract_to = sys.argv[2] if len(sys.argv) > 2 else os.path.join(
        os.path.dirname(file_path), 
        "extracted_" + os.path.basename(file_path).split(".")[0]
    )
    
    if not os.path.exists(file_path):
        print(f"Error: File '{file_path}' does not exist.")
        sys.exit(1)
    
    success = try_extract_file(file_path, extract_to)
    
    if success:
        print(f"\nExtraction attempts completed. Check {extract_to} for extracted content.")
    else:
        print("\nAll extraction attempts failed.")
