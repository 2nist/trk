# Groove MIDI Drum Pattern Library Guide

## Overview

The Groove MIDI Drum Pattern Library is a collection of high-quality drum MIDI patterns organized and integrated into the Songbase system. This library allows you to:

1. Browse and search drum patterns by style, tempo, and other attributes
2. Preview patterns directly in REAPER
3. Easily insert patterns into your REAPER projects
4. Build custom drum arrangements by combining patterns

## Dataset Organization

The Groove MIDI dataset contains drum performances by professional drummers across various styles and tempos. The patterns are organized as follows:

```
data/
  └─ midi/
     └─ groove_midi/
        ├─ funk/
        │  ├─ slow_under_80bpm/
        │  ├─ medium_80_to_100bpm/
        │  ├─ medium_100_to_120bpm/
        │  ├─ fast_120_to_140bpm/
        │  └─ very_fast_over_140bpm/
        ├─ rock/
        ├─ jazz/
        ├─ soul/
        └─ ...
```

Within each tempo range directory, you'll find MIDI files with descriptive filenames that include:
- Drummer ID
- Exact tempo
- Beat type (groove, fill, etc.)
- Style variation

## Using the Drum Pattern Browser

The Drum Pattern Browser is a ReaScript tool that provides a convenient interface for browsing and using the drum patterns.

### To Launch the Browser:

1. In REAPER, go to Actions > Show Action List
2. Click on "ReaScript: Run..." or press Alt+R
3. Navigate to `[Songbase]/tools/drum_pattern_browser.lua` and run it

### Browser Features:

- **Browse by Category**: Select styles and tempo ranges to narrow down the patterns
- **Search**: Use the search box to find patterns by keywords
- **Preview**: Listen to patterns before adding them to your project
- **Quick Load**: Add patterns directly to your REAPER project with a single click

## Extending the Library

### Adding New Patterns

You can extract more patterns from the Groove MIDI dataset using the extraction tool:

```
python tools/groove_midi_explorer.py --extract --create-index
```

Options include:
- `--extract`: Extract MIDI files from the dataset
- `--create-index`: Generate/update the master index
- `--style STYLE`: Extract only patterns of a specific style
- `--drummer DRUMMER`: Extract only patterns from a specific drummer
- `--visualize`: Generate visualizations of the patterns

### Converting to JCRD Format

You can convert the MIDI patterns to JCRD format for use with Songbase's chord and section editing tools:

```
python tools/groove_midi_explorer.py --convert
```

This will create JCRD files that represent the drum hits as chord events.

## Building a User-Guided Drum Machine

The organized pattern library can be used as the basis for a user-guided drum machine:

1. **Browse and select patterns** using the Drum Pattern Browser
2. **Arrange patterns** by inserting multiple patterns in sequence
3. **Modify patterns** using REAPER's MIDI editor
4. **Save your custom arrangements** as new MIDI files or REAPER projects

Future versions will include:

- User-controlled pattern combining tools
- Interactive pattern variation tools
- Integration with the Songbase section editor
- Context-aware pattern suggestions (when requested by user)

## Tips for Working with Drum Patterns

1. **Match tempos**: When inserting a pattern, consider adjusting your project tempo to match the pattern's original tempo
2. **Layer patterns**: Try combining different patterns for more complex arrangements
3. **Use with templates**: Create template projects with your preferred drum VST already set up
4. **Extract grooves**: Use REAPER's groove extraction to apply the feel of these patterns to other MIDI

## Troubleshooting

- **Missing index file**: If the browser can't find the index file, run the extraction tool with the `--create-index` option
- **Playback issues**: Ensure the MIDI files are accessible and haven't been moved from their extracted location
- **Browser not showing**: Make sure all required Lua libraries are installed for REAPER

## Resources

- [Groove MIDI Dataset](https://magenta.tensorflow.org/datasets/groove) - Original source of the patterns
- [REAPER MIDI Documentation](https://www.reaper.fm/sdk/js/midi.php) - For advanced MIDI editing
- [Songbase Documentation](docs/) - For integration with other Songbase features
