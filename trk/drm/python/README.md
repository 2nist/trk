# Groove MIDI Machine Python Module

This directory contains Python scripts for the Groove MIDI Machine module, which is responsible for:

1. Processing the Groove MIDI dataset
2. Separating drum patterns into components
3. Generating metadata for patterns
4. Classifying patterns by song section
5. Providing tools for pattern analysis

## Key Files

- `groove_midi_explorer.py` - Extract and organize MIDI patterns from the dataset
- `groove_midi_component_separator.py` - Split patterns into individual instrument parts
- `groove_midi_section_classifier.py` - Suggest appropriate song sections for patterns

## Dependencies

```text
numpy
pretty_midi
matplotlib
scikit-learn
suffix-trees
```

Install dependencies by running:

```bash
pip install -r requirements.txt
```

## Integration with Songbase

While these scripts can be used standalone, they also integrate with the Songbase environment for additional functionality.
