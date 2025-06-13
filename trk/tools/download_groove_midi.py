#!/usr/bin/env python
"""
Download and Extract Groove MIDI Dataset

This script downloads the full Groove MIDI dataset from Magenta's website,
extracts it to the correct location, and prepares the data for use with 
the Groove MIDI Machine.

Steps:
1. Download the dataset archive
2. Extract the archive to the test resources directory
3. Run the extraction tool to organize files and create metadata
"""

import os
import sys
import shutil
import zipfile
import tarfile
import logging
import subprocess
import argparse
from pathlib import Path
from urllib.request import urlretrieve

# Try to import tqdm, provide a fallback if not available
try:
    from tqdm import tqdm
    tqdm_available = True
except ImportError:
    tqdm_available = False
    print("Warning: tqdm module not found. Progress bar will be disabled.")
    # Simple fallback for tqdm if not available
    class SimpleTqdm:
        def __init__(self, **kwargs):
            pass
        def update_to(self, b=1, bsize=1, tsize=None):
            pass
        def update(self, n=1):
            pass
        def __enter__(self):
            return self
        def __exit__(self, *args, **kwargs):
            pass

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger("groove_midi_downloader")

# Define constants
REPO_ROOT = Path(os.path.abspath(os.path.dirname(os.path.dirname(__file__))))
TEST_RESOURCES = REPO_ROOT / "tests" / "resources" / "mir_datasets"
DATASET_DIR = TEST_RESOURCES / "groove_midi"
DATA_DIR = REPO_ROOT / "data"
MIDI_OUTPUT_DIR = DATA_DIR / "midi" / "groove_midi"
METADATA_DIR = DATA_DIR / "metadata" / "groove_midi"

# Dataset URL
GROOVE_DATASET_URL = "https://storage.googleapis.com/magentadata/datasets/groove/groove-v1.0.0.zip"
# Alternative URL in case the first one fails
GROOVE_DATASET_BACKUP_URL = "https://github.com/magenta/magenta-js/raw/master/music/testdata/groove/groove_2bar-midionly.json"

class DownloadProgressBar:
    def __init__(self, **kwargs):
        if tqdm_available:
            self.pbar = tqdm(**kwargs)
        else:
            self.pbar = SimpleTqdm(**kwargs)
            self.n = 0
            self.total = None
            print(f"Downloading {kwargs.get('desc', 'file')}...")
            
    def update_to(self, b=1, bsize=1, tsize=None):
        if tqdm_available:
            if tsize is not None:
                self.pbar.total = tsize
            self.pbar.update(b * bsize - self.pbar.n)
        else:
            if tsize is not None:
                self.total = tsize
            new_n = b * bsize
            if self.total and new_n % (self.total // 10) < bsize:  # Print status every ~10%
                percent = min(int(new_n * 100 / self.total), 100)
                print(f"Progress: {percent}%")
            self.n = new_n

    def __enter__(self):
        return self
        
    def __exit__(self, *args, **kwargs):
        if tqdm_available:
            self.pbar.__exit__(*args, **kwargs)
        else:
            print("Download complete.")

def download_url(url, output_path):
    """Download file with progress bar"""
    logger.info(f"Downloading {url} to {output_path}")
    with DownloadProgressBar(unit='B', unit_scale=True, miniters=1, desc=url.split('/')[-1]) as t:
        urlretrieve(url, filename=output_path, reporthook=t.update_to)

def ensure_dirs():
    """Create necessary directories if they don't exist"""
    dirs = [
        TEST_RESOURCES,
        DATASET_DIR,
        MIDI_OUTPUT_DIR,
        METADATA_DIR,
        DATA_DIR / "jcrd_library" / "groove_midi"
    ]
    
    for d in dirs:
        d.mkdir(parents=True, exist_ok=True)
        logger.info(f"Ensured directory exists: {d}")

def extract_archive(archive_path):
    """Extract the downloaded archive"""
    extract_dir = TEST_RESOURCES
    
    # Convert Path object to string for comparison
    archive_str = str(archive_path)
    
    if archive_str.endswith('.zip'):
        logger.info(f"Extracting zip archive to {extract_dir}")
        try:
            # Handle potential invalid filenames in the zip
            with zipfile.ZipFile(archive_path, 'r') as zip_ref:
                # Process each file in the archive
                for file_info in zip_ref.infolist():
                    try:
                        # Clean up filename by removing problematic characters
                        # Fix potential \r issues in file paths
                        cleaned_name = file_info.filename.replace('\r', '').replace('\\', '/')
                        
                        # Skip files with empty names after cleaning
                        if not cleaned_name:
                            logger.warning(f"Skipping file with invalid name: {file_info.filename}")
                            continue
                            
                        # Extract file with cleaned name
                        file_info.filename = cleaned_name
                        zip_ref.extract(file_info, extract_dir)
                        
                    except (OSError, zipfile.BadZipFile) as e:
                        logger.warning(f"Error extracting {file_info.filename}: {e}")
                        continue
        except Exception as e:
            logger.error(f"Error during zip extraction: {e}")
            return False
            
    elif archive_str.endswith('.tar.gz'):
        logger.info(f"Extracting tar.gz archive to {extract_dir}")
        try:
            with tarfile.open(archive_path, 'r:gz') as tar_ref:
                tar_ref.extractall(extract_dir)
        except Exception as e:
            logger.error(f"Error during tar.gz extraction: {e}")
            return False
    else:
        logger.error(f"Unsupported archive format: {archive_path}")
        return False
        
    logger.info("Extraction complete")
    return True

def run_extraction_tool():
    """Run the extraction tool to organize the MIDI files"""
    logger.info("Running extraction tool...")
    
    extract_script = REPO_ROOT / "tools" / "groove_midi_explorer.py"
    
    try:
        if os.name == 'nt':  # Windows
            result = subprocess.run(
                ["python", str(extract_script), "--extract", "--create-index", "--verbose"], 
                check=True
            )
        else:  # Unix-like
            result = subprocess.run(
                ["python3", str(extract_script), "--extract", "--create-index", "--verbose"], 
                check=True
            )
        logger.info("Extraction tool completed successfully")
        return True
    except subprocess.CalledProcessError as e:
        logger.error(f"Error running extraction tool: {e}")
        return False

def download_and_extract():
    """Main function to download and extract the dataset"""
    ensure_dirs()
    
    # Check if dataset already exists
    if (DATASET_DIR / "info.csv").exists():
        logger.info("Dataset info.csv found. Checking if MIDI files exist...")
        
        # Count MIDI files
        midi_count = 0
        for root, _, files in os.walk(DATASET_DIR):
            midi_count += sum(1 for f in files if f.endswith('.mid'))
        
        if midi_count > 10:  # Assuming more than 10 files means we have a good dataset
            logger.info(f"Found {midi_count} MIDI files. Dataset appears to be already downloaded.")
            proceed = input("Dataset appears to exist. Download again? (y/n): ")
            if proceed.lower() != 'y':
                logger.info("Skipping download, proceeding to extraction...")
                return run_extraction_tool()
    
    # Download the dataset
    download_path = REPO_ROOT / "downloads"
    download_path.mkdir(exist_ok=True)
    archive_path = download_path / "groove_midi_dataset.zip"
    
    try:
        download_url(GROOVE_DATASET_URL, archive_path)
    except Exception as e:
        logger.error(f"Error downloading from primary URL: {e}")
        logger.info("Trying backup URL...")
        try:
            download_url(GROOVE_DATASET_BACKUP_URL, archive_path)
        except Exception as e2:
            logger.error(f"Error downloading from backup URL: {e2}")
            return False
    
    # Extract the archive
    success = extract_archive(archive_path)
    if not success:
        return False
    
    # Run the extraction tool
    return run_extraction_tool()

def main():
    parser = argparse.ArgumentParser(description="Download and extract the Groove MIDI dataset")
    parser.add_argument("--skip-download", action="store_true", help="Skip downloading and just run extraction")
    parser.add_argument("--visualize", action="store_true", help="Generate visualizations of patterns after extraction")
    args = parser.parse_args()
    
    if args.skip_download:
        logger.info("Skipping download, running extraction tool only")
        success = run_extraction_tool()
    else:
        success = download_and_extract()
    
    if success and args.visualize:
        logger.info("Generating visualizations...")
        extract_script = REPO_ROOT / "tools" / "groove_midi_explorer.py"
        subprocess.run(["python", str(extract_script), "--visualize"])
    
    if success:
        logger.info("Process completed successfully!")
        logger.info(f"Dataset files are in: {DATASET_DIR}")
        logger.info(f"Organized MIDI files are in: {MIDI_OUTPUT_DIR}")
        logger.info(f"Metadata files are in: {METADATA_DIR}")
    else:
        logger.error("Process failed. See errors above.")

if __name__ == "__main__":
    main()
