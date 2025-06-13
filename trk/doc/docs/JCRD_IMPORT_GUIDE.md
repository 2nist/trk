# JCRD Import Guide

## Overview

This guide explains how to import data into the JCRD format from various sources using the SongBase toolbox.

## Import Sources

JCRD files can be created from several sources:

1. **Chordify MIDI Files**
   - Uses `chordify_midi_to_jcrd_1.py`
   - Imports chord information from Chordify-exported MIDI files
   - Output: JSON files saved to `/raw` directory by default

2. **Billboard Dataset**
   - Uses `billboard_to_jcrd_annotated.py` or `salami_billboard_to_jcrd.py`
   - Imports from the McGill Billboard dataset with annotations
   - Output: JSON files saved to specified output directory

3. **RWC Beat Files**
   - Uses `rwc_beat_to_jcrd.py`
   - Converts RWC dataset with beat annotations to JCRD
   - Output: JSON files in specified location

## Import Process

### Using the GUI

1. Go to the **Import** tab
2. Select the import source type
3. Browse for input file(s)
4. Set any required parameters
5. Click the import button
6. Files will be saved to the `/raw` directory by default

### Using Scripts Directly

For more control, you can run the import scripts directly:

```bash
# Import from Chordify MIDI
python3 scripts/chordify_midi_to_jcrd_1.py --input input.mid --output output.json

# Import from Billboard
python3 scripts/salami_billboard_to_jcrd.py --output_dir output_directory
```

## Where Are Imported Files?

After import, JCRD files are stored in different locations based on the import process:

1. **Raw Files**
   - Location: `/raw` directory
   - Contains newly imported files that haven't been validated
   - Default location for Chordify imports

2. **McGill JCRD SALAMI**
   - Location: `/jcrddatasets/mcgill_jcrd_salami`
   - Contains files imported from the McGill Billboard dataset with SALAMI annotations
   - Created by running the SALAMI import scripts

3. **McGill JCRD**
   - Location: `/jcrddatasets/mcgill_jcrd`
   - Contains processed/modified files from the McGill dataset
   - May contain files copied from SALAMI for further processing

4. **Validated Files**
   - Location: `/jcrddatasets/new_jcrd`
   - Contains files that have passed validation
   - Output location for validation scripts

## Post-Import Steps

After importing, you typically want to:

1. **Add Key Information**
   - Use `add_key_estimation.py` or `add_missing_keys.py`
   - Analyzes chords to determine the key

2. **Add Roman Numerals**
   - Use `add_roman_numerals.py`
   - Adds harmonic analysis based on the key

3. **Validate Structure**
   - Use validation scripts to ensure correct format
   - Fixes common issues like missing fields

4. **Browse in Catalog**
   - Use the Catalog tab to browse imported files
   - View file information and preview content
