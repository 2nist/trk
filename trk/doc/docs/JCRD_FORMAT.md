# JCRD Format Documentation

## Overview

JCRD (JSON Chord) is a format for representing musical chord progressions and structural analysis in a JSON-based format. It provides a standardized way to store song information, section-based chord progressions, key analysis, and additional metadata.

## File Format

JCRD files use the `.json` extension and follow a standard JSON format. The naming convention JCRD (JSON Chord) indicates the purpose of the file while the `.json` extension indicates the format.

## Schema

All JCRD files follow this standardized structure:

```json
{
  "title": "Imagine",
  "artist": "John Lennon",
  "bpm": 75,
  "key": "C major",                     // Estimated or fetched key
  "source": "SALAMI + Music4All",       // Standardized data trace
  "beat_times": [0, 480, 960, ...],     // Optional: global beat timing
  "sections": [
    {
      "id": "verse_1",
      "start_ms": 0,
      "duration_ms": 16000,
      "chords": ["C", "F", "G", "C"],
      "romanNumerals": ["I", "IV", "V", "I"],  // Harmony analysis
      "tags": ["verse", "auto_section"],       // Flexible tagging
      "sectionLabel": "verse",                 // Section form label
      "sectionLetter": "B"                     // SALAMI section letter
    },
    // Additional sections...
  ]
}
```

## Required Fields

- `title`: The title of the song
- `artist`: The artist or performer
- `bpm`: Tempo in beats per minute
- `sections`: Array of section objects containing:
  - `id`: Unique section identifier
  - `start_ms`: Start time in milliseconds
  - `duration_ms`: Duration in milliseconds
  - `chords`: Array of chord symbols

## Optional Fields

- `key`: Estimated or provided key signature
- `source`: Source of the data or analysis
- `beat_times`: Array of timing points in milliseconds
- `romanNumerals`: Harmonic analysis in Roman numeral format
- `tags`: Additional metadata and classification information
- Section-specific labels and classifications

## File Extension Note

While some documentation may refer to the ".jcrd" extension, the standard file extension for JCRD format files is ".json". This ensures compatibility with standard JSON tools and maintains consistency with existing datasets.
