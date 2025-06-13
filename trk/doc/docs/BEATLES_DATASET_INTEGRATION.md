# Beatles Dataset Integration Guide

This guide explains how to integrate the Beatles dataset into the Songbase project. The integration workflow involves extracting the original annotations, converting them to JCRD format, validating the conversion, and creating an index file for browsing and searching the dataset.

## Prerequisites

- Python 3.6 or later installed
- The Beatles Annotations archive file (`The Beatles Annotations.tar.gz`)
- Songbase repository set up with the new directory structure

## Directory Structure

The Beatles dataset will be integrated into the following directory structure:

```plaintext
songbase/
  data/
    source_archive/
      beatles/            # Original Beatles dataset files
        chords/           # Extracted chord annotations
    jcrd_library/
      beatles_full/       # Converted JCRD files
    metadata/
      beatles_index.json  # Index file for the Beatles dataset
```

## Integration Workflow

There are multiple ways to run the integration workflow:

### Option 1: Using the Python Workflow Script (Recommended)

The Python workflow script automates the entire process:

```bash
# Navigate to the tools directory
cd c:\Users\CraftAuto-Sales\AppData\Roaming\REAPER\Scripts\songbase\tools

# Run the workflow script
python beatles_integration_workflow.py --archive "path/to/The Beatles Annotations.tar.gz"
```

You can use the following options to customize the workflow:

- `--archive PATH`: Specify the path to the archive file
- `--skip-extract`: Skip the extraction step
- `--skip-convert`: Skip the conversion step
- `--skip-validate`: Skip the validation step
- `--skip-index`: Skip the index creation step

### Option 2: Using the Batch Workflow Script

The batch script provides a step-by-step guided workflow:

```bash
# Navigate to the tools directory
cd c:\Users\CraftAuto-Sales\AppData\Roaming\REAPER\Scripts\songbase\tools

# Run the batch workflow
beatles_integration_workflow.bat
```

Follow the on-screen prompts to complete each step.

### Option 3: Running Each Step Manually

You can also run each step of the workflow manually:

1. **Extract the Annotations**:

   ```bash
   python extract_beatles_annotations.py
   ```

2. **Convert to JCRD Format**:

   ```bash
   python convert_beatles_annotations.py
   ```

3. **Validate the JCRD Files**:

   ```bash
   python validate_beatles_jcrd.py
   ```

4. **Create the Index File**:

   ```bash
   python create_beatles_index.py
   ```

## Troubleshooting

If you encounter issues during the integration process:

### Extraction Issues

- Make sure the archive file is not corrupted
- Try extracting the file manually using a tool like 7-Zip
- Check if the extracted files follow the expected structure

### Conversion Issues

- Check if the source annotation files are present in the expected format
- Make sure the conversion script is using the correct paths
- Check for errors in the conversion script output

### Validation Issues

- Review the validation report to identify invalid JCRD files
- Check the structure and content of the JCRD files
- Make sure the conversion script is generating valid JCRD data

## Using the Beatles Dataset in Songbase

After successfully integrating the Beatles dataset, you can use it in the Songbase application:

1. The JCRD files are available in `data/jcrd_library/beatles_full/`
2. The index file is available in `data/metadata/beatles_index.json`

The dataset can be browsed and searched using the Songbase UI. The UI components that interact with the dataset will need to be updated to use the new file paths and index structure.

## Data Structure

### Original Beatles Dataset

The Beatles dataset follows this structure:

- Each album has a directory with chord, segment, beat, and key annotations
- Chord annotations (.lab files) contain timestamp-chord pairs
- Segment annotations (.lab files) contain timestamp-section pairs

### Converted JCRD Files

Each JCRD file contains:

- Metadata (title, artist, album, tempo, key, etc.)
- Sections (with name, start time, end time)
- Chords (with chord label, start time, end time)

## Additional Notes

- The Beatles dataset is one of the most widely used datasets for music information retrieval research
- The dataset contains annotations for 180 Beatles songs across 12 albums
- The annotations were created by the Centre for Digital Music at Queen Mary University of London

For more information about the Beatles dataset, see:

- [Isophonics Beatles Dataset](http://isophonics.net/content/reference-annotations-beatles)
- [Centre for Digital Music](http://c4dm.eecs.qmul.ac.uk/)
