#!/usr/bin/env python3
"""
TAR.GZ File Extractor for Songbase

This script extracts .tar.gz files, commonly used for datasets and libraries.
It can extract to a specified target directory and handles nested archives.
"""

import os
import sys
import tarfile
import argparse
import shutil
from pathlib import Path
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)

def extract_tar_gz(archive_path, extract_dir=None, preserve_structure=False):
    """
    Extract a .tar.gz file to the specified directory.
    
    Args:
        archive_path (str): Path to the .tar.gz file
        extract_dir (str): Directory to extract to. If None, extracts to same directory as archive
        preserve_structure (bool): Whether to preserve the directory structure in the archive
    
    Returns:
        bool: True if extraction was successful, False otherwise
    """
    try:
        # Validate archive path
        archive_path = os.path.abspath(archive_path)
        if not os.path.exists(archive_path):
            logger.error(f"Archive not found: {archive_path}")
            return False

        # Determine extraction directory
        if not extract_dir:
            # Default to the same directory as the archive
            extract_dir = os.path.dirname(archive_path)
        
        extract_dir = os.path.abspath(extract_dir)
        os.makedirs(extract_dir, exist_ok=True)
        
        logger.info(f"Extracting {archive_path} to {extract_dir}")
        
        # Open and extract the tar.gz file
        with tarfile.open(archive_path, "r:gz") as tar:
            if preserve_structure:
                # Extract with full paths
                tar.extractall(path=extract_dir)
            else:
                # Extract files directly (flatten directory structure)
                for member in tar.getmembers():
                    if member.isreg():  # Regular file
                        member.name = os.path.basename(member.name)
                        tar.extract(member, extract_dir)
        
        logger.info(f"Extraction completed successfully")
        
        # List extracted contents
        contents = os.listdir(extract_dir)
        logger.info(f"Extracted {len(contents)} items")
        for i, item in enumerate(contents[:10]):
            logger.info(f"  {i+1}. {item}")
            
        if len(contents) > 10:
            logger.info(f"  ... and {len(contents) - 10} more items")
        
        return True
    
    except tarfile.ReadError:
        logger.error(f"Failed to read {archive_path}. It may not be a valid .tar.gz file.")
        return False
    
    except Exception as e:
        logger.error(f"Error extracting {archive_path}: {str(e)}")
        return False

def main():
    """Main function to extract a .tar.gz file"""
    parser = argparse.ArgumentParser(description="Extract .tar.gz files")
    parser.add_argument("file", help="Path to the .tar.gz file")
    parser.add_argument("-d", "--directory", help="Directory to extract to (default: same as archive)")
    parser.add_argument("-p", "--preserve", action="store_true", help="Preserve directory structure in the archive")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose output")
    
    args = parser.parse_args()
    
    # Set logging level based on verbose flag
    if args.verbose:
        logger.setLevel(logging.DEBUG)
    
    # Extract the file
    success = extract_tar_gz(args.file, args.directory, args.preserve)
    
    if success:
        logger.info("Extraction completed successfully")
        return 0
    else:
        logger.error("Extraction failed")
        return 1

if __name__ == "__main__":
    sys.exit(main())
