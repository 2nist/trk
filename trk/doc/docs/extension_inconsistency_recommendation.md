# JCRD File Extension Inconsistency Analysis

## Overview

An analysis of the JCRD Toolbox codebase reveals an inconsistency in file extension usage between `.json` and `.jcrd`. This document summarizes the findings and provides recommendations for standardization.

## Current State

### `.json` Usage

- All files in the McGill JCRD SALAMI dataset use the `.json` extension
- The GUI application uses `*.json` pattern when searching for "JCRD Files"
- Most validation and processing scripts search for `.json` files
- No actual `.jcrd` files were found in the workspace

### `.jcrd` References

- Documentation and comments throughout the codebase refer to files as `.jcrd`
- The `chordify_midi_to_jcrd_1.py` script saves files with `.jcrd` extension
- The toolbox description mentions "import, enrich, validate, and export .jcrd files"

## Analysis

This inconsistency creates several issues:

1. Files created by the conversion script (`chordify_midi_to_jcrd_1.py`) may not be visible to other tools expecting `.json` extension
2. Documentation does not match actual file usage
3. Users may be confused about which extension to use

## Options for Resolution

### Option 1: Standardize on `.json` Extension (Recommended)

**Pros:**
- Compatible with existing dataset files (McGill JCRD SALAMI)
- JSON is a standard format with widespread tool support
- Minimal changes needed to existing code (only `chordify_midi_to_jcrd_1.py` needs updating)
- File extension accurately reflects the content format (JSON)

**Cons:**
- Loses the domain-specific `.jcrd` extension that indicates purpose

### Option 2: Standardize on `.jcrd` Extension

**Pros:**
- Creates a domain-specific file extension
- Matches documentation references
- Clearly identifies files as JCRD format files

**Cons:**
- Requires renaming all existing dataset files
- More code changes needed (all scripts that look for `.json`)
- May confuse tools that expect standard extensions

## Implementation Plan for Option 1 (Recommended)

1. Update `chordify_midi_to_jcrd_1.py` to save files with `.json` extension
   - Already prepared in `update_to_json_extension.py`

2. Update documentation to consistently reference `.json` files
   - Replace references to `.jcrd` in comments and docstrings with `.json`
   - Update README files

3. Update GUI descriptions to refer to "JCRD Format Files (.json)"

## Implementation Plan for Option 2

1. Rename existing `.json` files to `.jcrd`
   - Already prepared in `rename_json_to_jcrd.py`

2. Update all scripts to search for `.jcrd` files instead of `.json`
   - Modify file search patterns in all scripts

3. Update GUI to search for `*.jcrd` files

## Conclusion

Given the current state of the codebase and existing datasets, **Option 1** (standardizing on `.json`) is recommended as it requires fewer changes and maintains compatibility with existing files and tools.

The most important factor is consistency - either extension can work, but the same extension should be used throughout the codebase.
