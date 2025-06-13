# JAMS to JCRD Conversion Tools

These scripts convert JAMS (JSON Annotated Music Specification) files to JCRD (JSON Chord) format for use with REAPER-based music arrangement tools.

## Scripts

- `jams_to_jcrd.py` - Core converter script for individual JAMS files
- `batch_convert_choco.py` - Batch converter for ChoCo dataset JAMS files 
- `inspect_jcrd.py` - Helper script to inspect converted JCRD files

## Usage

### Converting a single JAMS file

```bash
python jams_to_jcrd.py input.jams output.jcrd.json
```

Options:
- `--meta PATH` - Path to meta.csv for enrichment
- `--partition NAME` - Partition name (e.g., rock-corpus)
- `--log PATH` - Path to log file (default: conversion_log.txt)

### Batch converting multiple JAMS files

```bash
python batch_convert_choco.py INPUT_DIR OUTPUT_DIR
```

Options:
- `--schema PATH` - Path to JCRD schema file (default: ../jcrd.schema.json)
- `--recursive` - Search recursively for JAMS files
- `--limit N` - Limit number of files to process (0=all)
- `--log PATH` - Path to log file (default: batch_conversion_log.txt)
- `--meta PATH` - Path to meta.csv for enrichment
- `--partition NAME` - Partition name (e.g., rock-corpus)

### Inspecting a JCRD file

```bash
python inspect_jcrd.py output.jcrd.json
```

## ChoCo Dataset Conversion Notes

The ChoCo dataset contains JAMS files with various chord notation formats:
- Roman numeral notation (e.g., "F#:I")
- No chord annotations ("N", "N.C.")
- Traditional chord notation

This converter handles all these formats properly and produces JCRD files that validate against the schema.

## Examples

Converting all files in the rock-corpus partition:

```bash
python batch_convert_choco.py ../datasets/choco/choco-main/partitions/rock-corpus/choco/jams rock_corpus_output --partition rock-corpus --recursive
```
