# JCRD Format Standard (JSON Chord)

## Overview

The JCRD (JSON Chord) format is a standardized way to represent song chord progressions, sections, and musical analysis. It uses the `.json` file extension to store the data in standard JSON format, enabling easy compatibility with existing tools while providing specialized music analysis capabilities.

## Format Definition

- **Name**: JCRD (JSON Chord)
- **Extension**: `.json`
- **Format**: Standard JSON with structured music data

## Why JSON Extension?

While "JCRD" is the name of the data format, we use the `.json` extension for several important reasons:

1. **Tool Compatibility**: Standard JSON tools can parse and validate the files
2. **Existing Datasets**: The McGill JCRD SALAMI dataset uses `.json` extension
3. **Format Accuracy**: The underlying format is JSON, so the extension reflects this

## Importing Files

When importing files in the JCRD Toolbox:

1. Look for files with the `.json` extension
2. Files can be found in several locations:
   - `/jcrddatasets/mcgill_jcrd_salami/` - The McGill SALAMI dataset
   - `/jcrddatasets/mcgill_jcrd/` - The McGill dataset
   - `/jcrddatasets/new_jcrd/` - Validated files
   - `/raw/` - Raw conversion files

## Catalog Usage

The Catalog tab provides easy browsing of JCRD files across different directories:

1. Select a directory from the dropdown (McGill SALAMI, McGill Dataset, Validated Files, Raw Files)
2. Files will be displayed with their title, artist and section count
3. Select any file to preview or export it

## JCRD to JSON Relationship

Think of JCRD as the **format specification** and JSON as the **storage format**.

For example:
- MP3 is a format specification, but files use `.mp3` extension
- JCRD is a format specification, but files use `.json` extension

## For Developers

When writing code that processes JCRD files:

1. Always look for `.json` files when searching for JCRD format files
2. Validate that they follow the JCRD schema (see `/docs/JCRD_FORMAT.md`)
3. Reference the standard JCRD schema for required and optional fields
