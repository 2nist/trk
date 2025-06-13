# Beatles Dataset Integration Guide

This guide explains how to integrate the complete Beatles dataset into the Songbase system.

## Overview

The Beatles dataset (Isophonics Beatles Dataset) contains chord, structure, key, and beat annotations for 180 Beatles songs. This makes it a valuable resource for music analysis and chord research.

## Download and Integration Process

### Step 1: Install Requirements

```bash
pip install -r tools/requirements_beatles.txt
```

### Step 2: Download and Process the Dataset

Run the downloader and processor script:

```bash
python tools/download_and_process_beatles.py
```

This script will:

1. Download the official annotations from Isophonics
2. Extract and organize the files
3. Build a comprehensive dataset index
4. Convert all annotations to JCRD format
5. Save the results in `data/jcrd_library/beatles/`

The script may take several minutes to complete, depending on your internet connection.

### Step 3: Verify the Integration

To validate the Beatles integration:

```bash
python tools/validate_full_beatles.py --all
```

To view details for a specific song:

```bash
python tools/validate_full_beatles.py --file "Abbey_Road_Come_Together"
```

## Dataset Structure

The Beatles dataset is organized as follows:

- **Source annotations** (will be downloaded to):  
  `data/source_archive/beatles/`

- **Converted JCRD files**:  
  `data/jcrd_library/beatles/`

- **Temporary processing files**:  
  `data/staging_area/beatles_processing/`

## Usage in Songbase

The Beatles dataset will be automatically available in the Songbase UI after processing. The songs will appear in the dataset browser and can be loaded into the editor.

## Manual Validation (No ImGui Required)

If you encounter issues with ImGui, you can still validate and explore the Beatles dataset using the provided Python scripts:

- `tools/validate_full_beatles.py`: Comprehensive validation and statistics
- `tools/beatles_chord_chart.py`: Generate chord charts
- `tools/beatles_visual_analyzer.py`: Visual analysis of songs

## Additional Information

- Dataset Source: [Isophonics](https://isophonics.net/content/reference-annotations)
- Original Dataset Publication: C. Harte, M. Sandler, S. Abdallah, and E. Gómez, "Symbolic representation of musical chords: A proposed syntax for text annotations," in Proceedings of the 6th International Conference on Music Information Retrieval (ISMIR), 2005, pp. 66-71.
- Beatles Albums Included: Please Please Me, With The Beatles, A Hard Day's Night, Beatles For Sale, Help!, Rubber Soul, Revolver, Sgt. Pepper's Lonely Hearts Club Band, Magical Mystery Tour, The Beatles (White Album), Abbey Road, Let It Be
