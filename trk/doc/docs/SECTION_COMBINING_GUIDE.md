# Section Editor: Combining Sections

The Section Editor now includes a feature to combine multiple sections into a single section. This is useful for merging verse and chorus combinations or creating complex song structures.

## How to Combine Sections

1. Open the Section Editor from Songbase main interface
2. Load your song file (.jcrd)
3. Click the "Combine Sections" button at the top of the sections list
4. Select at least two sections to combine by checking the checkboxes beside each section name
5. Click "Confirm Combine" to merge the selected sections
6. The new combined section will appear in the section list with a name derived from the combined sections

## Features of Combined Sections

- **Automatic Naming**: The combined section is named by joining the names of the source sections with a "+" symbol. If the resulting name is too long, it will be truncated.

- **Chord Preservation**: All chords from the original sections are preserved in their original order.

- **Section Markers**: When combining more than one section, section names are inserted as chord comments (starting with "--") to mark where each original section begins.

- **Beats Per Chord Inheritance**: The new section inherits the beats-per-chord value from the first selected section.

## Tips for Using Combined Sections

- **Order Matters**: Sections are combined in the order they appear in the section list, not in the order you select them.

- **Easy Editing**: After combining, the new section is automatically selected for immediate editing.

- **Cancel Anytime**: If you change your mind while in combining mode, click "Cancel Combining" to return to normal editing mode.

- **Section Management**: After combining, the original sections are removed to avoid duplication. Make sure to save your work if you want to preserve the original sections.

## Example Use Cases

- **Combine verse and chorus** to create a common verse-chorus pattern that repeats throughout the song
- **Merge intro and verse** for songs where the intro shares the same chord progression as the verse
- **Combine multiple parts** of a complex bridge or instrumental section
- **Create extended sections** by combining repeated sections with slight variations

## Technical Implementation

This feature maintains the integrity of your song data while providing a flexible way to reorganize and structure your compositions. The section combining is performed in-memory and only becomes permanent when you save the song file.
