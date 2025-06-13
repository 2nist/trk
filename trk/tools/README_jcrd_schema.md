# JCRD Schema Implementation

This directory contains scripts to update and validate the JCRD (JSON Chord) file format with enhanced section-based structure and forward compatibility. The new schema provides a foundation for harmony tagging, beat alignment, MIDI output, and other advanced music analysis features.

## Schema Overview

All JCRD files follow this standardized structure:

```json
{
  "title": "Imagine",
  "artist": "John Lennon",
  "bpm": 75,
  "key": "C major",                     // New: estimated or fetched
  "source": "SALAMI + Music4All",       // New: standardized data trace
  "beat_times": [0, 480, 960, ...],     // Optional: global beat timing
  "sections": [
    {
      "id": "verse_1",
      "start_ms": 0,
      "duration_ms": 16000,
      "chords": ["C", "F", "G", "C"],
      "romanNumerals": ["I", "IV", "V", "I"],  // New: harmony analysis
      "tags": ["verse", "auto_section"],       // New: flexible tagging
      "sectionLabel": "verse",                 // Section form label
      "sectionLetter": "B"                     // SALAMI section letter
    },
    // Additional sections...
  ]
}
```

## Key Features

- **Section-based structure**: Each song is divided into sections with unique IDs
- **Enhanced metadata**: Key, source, and beat times for complete song information
- **Roman numeral analysis**: Support for harmonic function labeling
- **Flexible tags**: Array-based tagging for structural and metadata annotations
- **SALAMI integration**: Section letters and labels from the SALAMI format

## Scripts

### 1. `update_jcrd_schema.py`

Updates all JCRD files to comply with the new schema structure.

```bash
python update_jcrd_schema.py [--dry-run] [--verbose] [--dir DIRECTORY] [--file FILENAME]
```

Options:
- `--dry-run`: Show changes without applying them
- `--verbose`: Show detailed logging information
- `--dir`: Specify a directory containing JCRD files
- `--file`: Update a single JCRD file

### 2. `validate_jcrd_schema.py`

Validates JCRD files against the schema and reports any inconsistencies.

```bash
python validate_jcrd_schema.py [--verbose] [--dir DIRECTORY] [--file FILENAME]
```

Options:
- `--verbose`: Show detailed logging information
- `--dir`: Specify a directory containing JCRD files
- `--file`: Validate a single JCRD file

### 3. `install_jcrd_schema.py`

Creates a `jcrd.schema.json` file in the project root for reference.

```bash
python install_jcrd_schema.py [--force] [--output OUTPUT_PATH]
```

Options:
- `--force`: Overwrite existing schema file
- `--output`: Specify an output path for the schema file

## Workflow

1. Install the schema:
   ```bash
   python install_jcrd_schema.py
   ```

2. Update all JCRD files:
   ```bash
   python update_jcrd_schema.py
   ```

3. Validate all JCRD files:
   ```bash
   python validate_jcrd_schema.py
   ```

## Forward Compatibility

The updated JCRD format now supports:

- **Harmony analysis**: Integration with Music21 for Roman numeral analysis
- **Beat quantization**: Support for LibROSA / RWC beat tracking
- **MIDI rendering**: Compatible with PrettyMIDI for MIDI output
- **DAW integration**: Region export to REAPER
- **Dataset indexing**: Enhanced filtering and organization capabilities
