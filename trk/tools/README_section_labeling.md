# SALAMI Section Labeling for McGill Billboard Dataset

This directory contains scripts to adapt the SALAMI dataset format for section labeling in the McGill Billboard dataset. The goal is to replace the current section labeling approach with a more standardized format based on canonical section structures from the SALAMI annotations.

## SALAMI Format

The SALAMI (Structural Analysis of Large Amounts of Music Information) format uses a hierarchical approach to section labeling with the following components:

1. **Section letter**: A capital letter (A, B, C, etc.) that represents the high-level form
2. **Section label**: A descriptive label (intro, verse, chorus, etc.) that identifies the function
3. **Format**: `<LETTER>, <label>, | <chords> |`

Example from a SALAMI file:
```
0.0	silence
7.3469387e-2	A, intro, | A:min | A:min | C:maj | C:maj |
22.346394557	B, verse, | A:min | A:min | C:maj | C:maj |, (voice
```

## Scripts

### 1. `extract_salami_section_labels.py`

Analyzes the SALAMI dataset to extract all unique section labels and their frequencies. This helps establish a standardized section naming scheme.

```
python extract_salami_section_labels.py
```

Output: `salami_section_labels.json` containing:
- Common section labels and their frequencies
- Common section sequences
- Canonical mapping of section letters to labels

### 2. `batch_update_section_labels.py`

Updates all McGill JCRD files to use the section labels from their corresponding SALAMI files.

```
python batch_update_section_labels.py [--dry-run] [--stats-only] [--verbose]
```

Options:
- `--dry-run`: Don't actually update files, just show what would change
- `--stats-only`: Only generate statistics on current section labels
- `--verbose`: Enable detailed logging

### 3. `standardize_section_labels.py`

Standardizes section labels across all files by normalizing names and applying a consistent format.

```
python standardize_section_labels.py [--dry-run] [--verbose]
```

Options:
- `--dry-run`: Don't actually update files, just show what would change
- `--verbose`: Enable detailed logging

## Workflow

1. Run `extract_salami_section_labels.py` to analyze the SALAMI dataset and generate the canonical mapping
2. Run `batch_update_section_labels.py` to update JCRD files with section labels from matching SALAMI files
3. Run `standardize_section_labels.py` to ensure consistent section labeling across all files

## Section Label Format

After processing, each section in the JCRD files will have:
- `sectionLabel`: A standardized descriptive label (e.g., "verse", "chorus", "intro")
- `sectionLetter`: The formal section identifier (e.g., "A", "B", "C")

This maintains compatibility with the current format while adding the additional SALAMI structure information.

## Common Section Labels

Based on analysis of the SALAMI dataset, the most common section labels are:

1. verse
2. chorus
3. intro
4. bridge
5. instrumental
6. outro
7. interlude
8. pre-chorus
9. transition
10. solo

## Section Letter Mapping

The canonical mapping of section letters to labels (most common usage in SALAMI):

- A: intro
- B: verse
- C: chorus
- D: bridge
- E: outro

## Examples

Original section label:
```json
"sectionLabel": "verse"
```

Updated section label with SALAMI format:
```json
"sectionLabel": "verse",
"sectionLetter": "B"
```
