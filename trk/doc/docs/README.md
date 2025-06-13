# SongBase - JCRD Toolbox

A comprehensive toolbox for working with JCRD (JSON Chord) format files, supporting imports from various sources, section analysis, and exports.

## Directory Structure

- `/jcrddatasets/` - Storage for JCRD format files
  - `/jcrddatasets/mcgill_jcrd_salami/` - McGill Billboard dataset with SALAMI annotations
  - `/jcrddatasets/mcgill_jcrd/` - McGill dataset (empty by default)
  - `/jcrddatasets/new_jcrd/` - Validated JCRD files from processing pipeline
- `/raw/` - Raw JCRD files from initial imports
- `/scripts/` - Processing scripts for import, validation, analysis, and export
- `/examples/` - Example JCRD files and usage patterns
- `/docs/` - Documentation for the JCRD format and tools

## File Format

The JCRD (JSON Chord) format uses standard JSON files (`.json` extension) to store chord progressions, section analysis, and metadata. See [JCRD Format Documentation](docs/JCRD_FORMAT.md) for details.

## Workflow

1. **Import**: Convert from various sources (MIDI, Chordify, Billboard)
2. **Analyze**: Add key estimation, Roman numerals, section labels
3. **Validate**: Check structure and correctness
4. **Export**: Generate MIDI, REAPER regions, or other formats

## GUI Tabs

- **Import**: Convert files from various sources
- **Harmony**: Add harmony analysis (key, Roman numerals)
- **Timing**: Add timing information (beats, sections)
- **MIDI**: MIDI export tools
- **Validation**: Validate structure and content
- **Export**: Export to various formats
- **Catalog**: Browse and preview JCRD files

## Using the Catalog

The catalog tab allows you to browse JCRD files across different locations:

1. Select a directory from the dropdown
   - McGill SALAMI - Contains pre-annotated files
   - Validated Files - Contains processed files
   - Raw Files - Contains newly converted files
2. Select any file to preview its content
3. Use the export option to convert to other formats

## About JCRD Files

JCRD is a standardized format that uses JSON (`.json` extension) to store chord progressions with section markers and analytical metadata. The format enables:

- Section-based analysis
- Chord progression representation
- Roman numeral analysis
- Key estimation
- Export to various formats

See [README_JCRD_FORMAT.md](README_JCRD_FORMAT.md) for more details on the JCRD format specification.
