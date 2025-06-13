# Song Section Classification in Groove MIDI Machine

## Overview

The Groove MIDI Machine includes an intelligent system that analyzes drum patterns to suggest appropriate song sections (verse, chorus, bridge, etc.) where each pattern might best be used. This document explains the approach, algorithms, and implementation details.

## User-Guided Approach

The section classification system follows a user-guided design philosophy:

1. **Suggestions, Not Decisions**: The system provides recommendations with confidence levels, but the user makes the final creative decisions
2. **Transparent Reasoning**: Each suggestion comes with clear explanations of why a pattern might suit a particular section
3. **Multiple Options**: Rather than a single "right answer," the system provides multiple section suggestions with their respective confidence scores
4. **Manual Override**: Users can always override algorithmic suggestions, teaching the system through their choices
5. **Contextual Awareness**: Recommendations consider the surrounding musical context when available

This approach ensures that the tool enhances the user's creative process without attempting to replace their musical judgment.

## Classification Approach

The classification system uses a multi-faceted approach combining:

1. **Feature-based analysis** - Analyzing concrete metrics like energy, density, and complexity
2. **Pattern repetition analysis** - Using Supermaximal Repeats algorithm to identify recurring patterns
3. **Confidence scoring** - Providing reliability indicators for recommendations

## Key Features Analyzed

### Energy Features
- **Velocity dynamics** - Average velocity and variation
- **Note density** - Notes per time unit
- **Accent patterns** - Distribution of emphasized beats

### Complexity Features
- **Unique percussion elements** - Variety of drums used
- **Syncopation metrics** - Off-beat emphasis
- **Ghost note density** - Subtle notes that add texture

### Pattern Structure
- **Regularity** - How consistent the kick/snare patterns are
- **Repetition** - Identified through Supermaximal Repeats analysis
- **Variation patterns** - How the pattern evolves over time

## Supermaximal Repeats Algorithm

This algorithm, borrowed from computational biology, is used to identify the core repeating patterns in a drum sequence:

1. The MIDI drum pattern is converted to a string representation
2. A suffix tree is constructed from this string
3. Maximal repeats (patterns that recur and cannot be extended) are identified
4. The coverage and distribution of these repeats informs section classification

## Song Section Characteristics

### Verse
- **Energy**: Medium (30-60%)
- **Complexity**: Low to medium (20-60%)
- **Pattern**: Consistent, supportive, often with subtle variations
- **Supermaximal Repeats**: Medium repetition with variations

### Chorus
- **Energy**: Higher (60-100%)
- **Complexity**: Medium (40-80%)
- **Pattern**: Memorable, consistent, often more "hooks"
- **Supermaximal Repeats**: High repetition, low variation

### Bridge
- **Energy**: Variable (40-80%)
- **Complexity**: Higher (60-100%)
- **Pattern**: Often contrasting with verse/chorus
- **Supermaximal Repeats**: Low repetition, high variation

### Intro/Outro
- **Energy**: Variable, often building (intro) or resolving (outro)
- **Complexity**: Variable
- **Pattern**: May establish or conclude main patterns
- **Supermaximal Repeats**: Variable

### Transitions
- **Energy**: Often higher (50-90%)
- **Complexity**: Higher (60-100%)
- **Pattern**: Fill-heavy, breaking established patterns
- **Supermaximal Repeats**: Very low repetition, high variation

## Confidence Scoring

Each classification comes with a confidence score based on:

- How closely the pattern matches ideal characteristics
- How distinctly it matches one section versus others
- The strength of the pattern's defining features

Confidence is reported as:
- **High**: Strong match to section characteristics (>80%)
- **Medium**: Good match to section characteristics (60-80%)
- **Low**: Some characteristics match, but not definitive (<60%)

## Hidden Markov Models for Sequential Classification

When analyzing collections of patterns or entire songs, Hidden Markov Models help predict the most likely section sequence:

1. States represent different song sections (verse, chorus, etc.)
2. Observations are the features extracted from each pattern
3. The model learns transition probabilities between sections
4. Pattern sequences can be classified as the most likely state sequence

This approach helps ensure logical song structure when suggesting section assignments.

## Manual Verification Interface

The system includes a manual verification interface that:

- Shows algorithmic classifications with confidence scores
- Allows users to confirm or correct classifications
- Provides insights into why each classification was made
- Uses corrections to improve future classifications

## Usage in User-Guided Arrangement

The section classifications assist users in the following ways:

1. **Arrangement Templates** - Pre-defined song structures that users can select and customize
2. **Pattern Suggestions** - User-requested recommendations based on section context and user-selected patterns
3. **Energy Visualization** - Interactive visualization of song intensity to help users craft better arrangements
4. **Assisted Arrangement** - Tools to help users select patterns based on their desired song structure, always leaving final decisions to the user

## Technical Implementation

The classification system is implemented in Python with the following dependencies:
- `numpy` for numerical analysis
- `pretty_midi` for MIDI file processing
- `suffix_trees` for Supermaximal Repeats analysis
- `sklearn` for machine learning components

The system can be used through:
- The Groove MIDI Machine GUI
- Command-line tools for batch processing
- A programmable API for integration with other tools

## References

1. Dannenberg, R. B., & Goto, M. (2008). Music structure analysis from acoustic signals.
2. Mauch, M., et al. (2009). Discovering chord idioms through Beatles and Real Book songs.
3. Abou-Moustafa, K. T., & Ferrie, F. P. (2012). A note on metric properties of some divergence measures.
4. Gusfield, D. (1997). Algorithms on Strings, Trees, and Sequences: Computer Science and Computational Biology.
