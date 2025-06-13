#!/usr/bin/env python3
"""
batch_update_section_labels.py - Update section labels in McGill JCRD files to use SALAMI format

This script processes all JSON files in the mcgill_jcrd directory and updates them to use
the canonical section labels from the SALAMI dataset. It matches songs by title and artist
and handles cases where no direct SALAMI reference is available.

The SALAMI format uses section labels like "intro", "verse", "chorus", etc. with 
a consistent formatting pattern: "<LETTER>, <label>," (e.g., "A, intro,", "B, verse,")
"""

import os
import re
import json
import logging
from difflib import SequenceMatcher
import argparse
from pathlib import Path
import sys

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('section_label_update.log'),
        logging.StreamHandler(sys.stdout)
    ]
)

def normalize_title_artist(title, artist):
    """Normalize title and artist for matching by removing special characters and lowercasing."""
    if not title or not artist:
        return None, None
        
    def normalize(text):
        if not text:
            return ""
        text = text.lower()
        text = re.sub(r'[^\w\s]', '', text)  # Remove special characters
        text = re.sub(r'\s+', ' ', text).strip()  # Normalize whitespace
        return text
        
    return normalize(title), normalize(artist)

def extract_salami_section_labels(salami_path):
    """Extract canonical section labels from a SALAMI format file."""
    sections = []
    try:
        with open(salami_path, encoding="utf-8") as f:
            for line in f:
                # Match lines like: 22.346394557\tB, verse, | A:min | A:min...
                m = re.match(r"^[\d.eE+-]+\s+([A-Z]),\s*([^,]+),", line)
                if m:
                    # Extract both section letter and label
                    letter = m.group(1)
                    label = m.group(2).strip().lower()
                    sections.append({"letter": letter, "label": label})
    except Exception as e:
        logging.error(f"Error extracting labels from {salami_path}: {e}")
    
    return sections

def extract_salami_metadata(salami_path):
    """Extract title and artist from a SALAMI format file."""
    title, artist = None, None
    try:
        with open(salami_path, encoding="utf-8") as f:
            for line in f:
                if line.startswith("# title:"):
                    title = line.replace("# title:", "").strip()
                elif line.startswith("# artist:"):
                    artist = line.replace("# artist:", "").strip()
                # Stop once we've found both
                if title and artist:
                    break
    except Exception as e:
        logging.error(f"Error extracting metadata from {salami_path}: {e}")
    
    return title, artist

def build_salami_reference_map(salami_dir):
    """Build a map of normalized (title, artist) -> salami_path."""
    reference_map = {}
    metadata_map = {}
    
    # Walk through all subdirectories in the salami directory
    for root, dirs, files in os.walk(salami_dir):
        for filename in files:
            if filename == "salami_chords.txt":
                salami_path = os.path.join(root, filename)
                title, artist = extract_salami_metadata(salami_path)
                
                if title and artist:
                    norm_title, norm_artist = normalize_title_artist(title, artist)
                    if norm_title and norm_artist:
                        key = (norm_title, norm_artist)
                        reference_map[key] = salami_path
                        metadata_map[key] = (title, artist)  # Store original metadata
    
    logging.info(f"Built reference map with {len(reference_map)} SALAMI files")
    return reference_map, metadata_map

def find_best_matching_salami(jcrd_title, jcrd_artist, reference_map):
    """Find the best matching SALAMI file for a given JCRD file."""
    norm_title, norm_artist = normalize_title_artist(jcrd_title, jcrd_artist)
    
    if not norm_title or not norm_artist:
        return None
    
    # Direct match
    key = (norm_title, norm_artist)
    if key in reference_map:
        return reference_map[key]
    
    # Try fuzzy matching
    best_match = None
    best_score = 0
    
    for (ref_title, ref_artist), salami_path in reference_map.items():
        # Calculate similarity scores
        title_sim = SequenceMatcher(None, norm_title, ref_title).ratio()
        artist_sim = SequenceMatcher(None, norm_artist, ref_artist).ratio()
        
        # Combined score with more weight on title
        combined_score = (title_sim * 0.6) + (artist_sim * 0.4)
        
        if combined_score > best_score and combined_score > 0.85:  # Threshold for match
            best_score = combined_score
            best_match = salami_path
    
    return best_match

def update_jcrd_file(jcrd_path, sections, dry_run=False):
    """Update a JCRD file with section labels and letters from SALAMI."""
    try:
        with open(jcrd_path, encoding="utf-8") as f:
            data = json.load(f)
        
        # Backup original section labels
        original_labels = [section.get("sectionLabel", "") for section in data.get("sections", [])]
        
        # Update section labels and letters
        updated = 0
        for i, section in enumerate(data.get("sections", [])):
            if i < len(sections):
                salami_section = sections[i]
                # Update section label
                if section.get("sectionLabel") != salami_section["label"]:
                    section["sectionLabel"] = salami_section["label"]
                    updated += 1
                
                # Add or update section letter
                if section.get("sectionLetter") != salami_section["letter"]:
                    section["sectionLetter"] = salami_section["letter"]
                    updated += 1
        
        if updated > 0 and not dry_run:
            with open(jcrd_path, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2)
              logging.info(f"Updated {jcrd_path} with {updated} section changes")
            logging.debug(f"  Original: {original_labels}")
            section_info = []
            for section in data.get('sections', []):
                letter = section.get('sectionLetter', '')
                label = section.get('sectionLabel', '')
                section_info.append(f"{letter}:{label}")
            logging.debug(f"  Updated: {section_info}")        elif updated > 0:
            logging.info(f"Would update {jcrd_path} with {updated} section changes (dry run)")
            section_info = []
            for section in data.get('sections', []):
                letter = section.get('sectionLetter', '')
                label = section.get('sectionLabel', '')
                section_info.append(f"{letter}:{label}")
            logging.debug(f"  Would update to: {section_info}")
        
        return updated
    except Exception as e:
        logging.error(f"Error updating {jcrd_path}: {e}")
        return 0

def process_jcrd_files(jcrd_dir, reference_map, dry_run=False):
    """Process all JCRD files and update them with SALAMI section labels."""
    updated_files = 0
    total_files = 0
    unmatched_files = 0
    
    for filename in os.listdir(jcrd_dir):
        if not filename.endswith(".json"):
            continue
        
        total_files += 1
        jcrd_path = os.path.join(jcrd_dir, filename)
        
        try:
            with open(jcrd_path, encoding="utf-8") as f:
                data = json.load(f)
            
            title = data.get("title", "")
            artist = data.get("artist", "")
            
            # Find matching SALAMI file
            salami_path = find_best_matching_salami(title, artist, reference_map)
            
            if salami_path:
                # Extract section labels and update file
                sections = extract_salami_section_labels(salami_path)
                if sections:
                    if update_jcrd_file(jcrd_path, sections, dry_run) > 0:
                        updated_files += 1
                else:
                    logging.warning(f"No section labels found in {salami_path} for {filename}")
            else:
                logging.warning(f"No matching SALAMI file found for {filename} ({title} - {artist})")
                unmatched_files += 1
        except Exception as e:
            logging.error(f"Error processing {filename}: {e}")
    
    logging.info(f"Processed {total_files} files: {updated_files} updated, {unmatched_files} unmatched")
    return updated_files, total_files, unmatched_files

def generate_section_label_stats(jcrd_dir):
    """Generate statistics on section label usage."""
    section_labels = {}
    section_letters = {}
    letter_label_pairs = {}
    
    for filename in os.listdir(jcrd_dir):
        if not filename.endswith(".json"):
            continue
        
        jcrd_path = os.path.join(jcrd_dir, filename)
        
        try:
            with open(jcrd_path, encoding="utf-8") as f:
                data = json.load(f)
            
            for section in data.get("sections", []):
                # Count section labels
                label = section.get("sectionLabel", "")
                if label:
                    section_labels[label] = section_labels.get(label, 0) + 1
                
                # Count section letters
                letter = section.get("sectionLetter", "")
                if letter:
                    section_letters[letter] = section_letters.get(letter, 0) + 1
                
                # Count letter-label pairs
                if letter and label:
                    pair = f"{letter}:{label}"
                    letter_label_pairs[pair] = letter_label_pairs.get(pair, 0) + 1
        except Exception as e:
            logging.error(f"Error analyzing {filename}: {e}")
    
    # Sort by frequency
    sorted_labels = sorted(section_labels.items(), key=lambda x: x[1], reverse=True)
    sorted_letters = sorted(section_letters.items(), key=lambda x: x[1], reverse=True)
    sorted_pairs = sorted(letter_label_pairs.items(), key=lambda x: x[1], reverse=True)
    
    logging.info("Section label usage statistics:")
    for label, count in sorted_labels:
        logging.info(f"  {label}: {count}")
    
    logging.info("\nSection letter usage statistics:")
    for letter, count in sorted_letters:
        logging.info(f"  {letter}: {count}")
    
    logging.info("\nSection letter-label pair usage statistics:")
    for pair, count in sorted_pairs[:20]:  # Show top 20 pairs
        logging.info(f"  {pair}: {count}")
    
    return {
        "labels": sorted_labels,
        "letters": sorted_letters,
        "pairs": sorted_pairs
    }

def main():
    parser = argparse.ArgumentParser(description="Update McGill JCRD files with SALAMI format section labels")
    parser.add_argument("--dry-run", action="store_true", help="Don't actually update files")
    parser.add_argument("--stats-only", action="store_true", help="Only generate statistics, don't update files")
    parser.add_argument("--verbose", "-v", action="store_true", help="Enable verbose logging")
    args = parser.parse_args()
    
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    # Set paths based on script location
    script_dir = Path(__file__).parent
    jcrd_dir = script_dir.parent / "mcgill_jcrd"
    salami_dir = script_dir.parent / "Structure ref" / "McGill-Billboard"
    
    if not jcrd_dir.exists():
        logging.error(f"JCRD directory not found: {jcrd_dir}")
        return 1
    
    if not salami_dir.exists():
        logging.error(f"SALAMI directory not found: {salami_dir}")
        return 1
    
    logging.info(f"Processing JCRD files from {jcrd_dir}")
    logging.info(f"Using SALAMI references from {salami_dir}")
    
    if args.stats_only:
        generate_section_label_stats(jcrd_dir)
        return 0
    
    # Build reference map
    reference_map, metadata_map = build_salami_reference_map(salami_dir)
    
    # Process JCRD files
    updated_files, total_files, unmatched_files = process_jcrd_files(
        jcrd_dir, reference_map, args.dry_run
    )
    
    # Print summary
    logging.info("=" * 80)
    logging.info(f"Summary: {updated_files}/{total_files} files updated ({unmatched_files} unmatched)")
    
    # Generate statistics on updated files
    if not args.dry_run:
        generate_section_label_stats(jcrd_dir)
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
