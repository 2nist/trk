import os
import tarfile
import shutil
import sys
import traceback

def extract_tar_gz(archive_path, extract_to):
    """
    Extract a tar.gz file to the specified directory.
    Uses a robust approach to handle potential issues.
    """
    print(f"Extracting {archive_path} to {extract_to}")
    
    # Ensure the extraction directory exists
    os.makedirs(extract_to, exist_ok=True)
    
    try:
        # First attempt - standard extraction
        with tarfile.open(archive_path, "r:gz") as tar:
            tar.extractall(path=extract_to)
        print("Extraction completed successfully.")
        return True
    except Exception as e:
        print(f"Standard extraction failed: {e}")
        print("Attempting fallback extraction method...")
        
        try:
            # Fallback method - extract individual files
            with tarfile.open(archive_path, "r:gz") as tar:
                for member in tar.getmembers():
                    try:
                        tar.extract(member, path=extract_to)
                        print(f"Extracted: {member.name}")
                    except Exception as ex:
                        print(f"Failed to extract {member.name}: {ex}")
            print("Fallback extraction completed.")
            return True
        except Exception as e2:
            print(f"Fallback extraction failed: {e2}")
            print(traceback.format_exc())
            return False

if __name__ == "__main__":
    # Check if archive path is provided as argument
    if len(sys.argv) > 1:
        archive_path = sys.argv[1]
    else:
        # Default path - adjust as needed
        archive_path = input("Enter the full path to the Beatles Annotations tar.gz file: ")
    
    # Destination directory
    extract_to = os.path.join(
        os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
        "data", "source_archive", "beatles", "chords"
    )
    
    success = extract_tar_gz(archive_path, extract_to)
    
    if success:
        print("\nNext steps:")
        print("1. Run the Beatles conversion script to generate .jcrd files")
        print("2. Validate the conversion output")
        print("3. Integrate the Beatles dataset into Songbase")
    else:
        print("\nExtraction failed. Please check the archive file and try again.")
