# JAMS to JCRD Conversion Tools

This directory contains scripts for converting JAMS files (JSON Annotated Music Specification) to JCRD format (JSON Chord) for use in REAPER-based music arrangement tools.

## Overview

These scripts solve several challenges in converting JAMS files to the JCRD format, including:

1. Handling various chord notations: Roman numerals, "N.C." (no chord), chord objects, etc.
2. Extracting time signature information
3. Handling sectional information
4. Ensuring schema compliance

## Scripts

### jams_to_jcrd.py

Converts a single JAMS file to JCRD format.

```
python jams_to_jcrd.py path/to/file.jams [output_path.jcrd.json] [--meta path/to/meta.csv] [--partition partition_name]
```

Arguments:
- `input`: Path to the JAMS file
- `output` (optional): Path to save the JCRD file. If not provided, uses `Title_Artist.jcrd.json` format in the same directory.
- `--meta` (optional): Path to metadata CSV for enrichment
- `--partition` (optional): Partition name (e.g., "rock-corpus")
- `--log` (optional): Path to log file (default: conversion_log.txt)

### batch_convert_choco.py

Batch converts JAMS files in a directory to JCRD format.

```
python batch_convert_choco.py input_directory output_directory [--recursive] [--schema path/to/schema.json] [--limit N] [--meta path/to/meta.csv] [--partition partition_name]
```

Arguments:
- `input_dir`: Directory containing JAMS files
- `output_dir`: Directory to save converted JCRD files
- `--recursive`: Search recursively for JAMS files
- `--schema`: Path to JCRD schema file (default: ../jcrd.schema.json)
- `--limit`: Limit number of files to process (0=all)
- `--log`: Path to log file (default: batch_conversion_log.txt)
- `--meta`: Path to metadata CSV for enrichment
- `--partition`: Partition name (e.g., "rock-corpus")

## ChoCo Dataset-Specific Notes

The ChoCo dataset contains JAMS files with various chord notations that required special handling:

1. Roman numeral chord notation (e.g., "F#:I")
2. "N", "N.C." notation for no chord
3. Dictionary-based chord values

These are all handled properly by the `safe_chord_value()` function in the scripts.

## File Naming Convention

Output files are named in the format `Title_Artist.jcrd.json` by default, with spaces replaced by underscores.

## Example Usage

### Converting a single file:

```
python jams_to_jcrd.py ../datasets/choco/choco-main/partitions/rock-corpus/choco/jams/rock-corpus_106.jams
```

### Batch converting files:

```
python batch_convert_choco.py --recursive ../datasets/choco/choco-main/partitions/rock-corpus/choco/jams ../output
```

### Processing with metadata:

```
python batch_convert_choco.py --recursive --meta ../datasets/choco/choco-main/choco/meta.csv --partition rock-corpus ../datasets/choco/choco-main/partitions/rock-corpus/choco/jams ../output
```
