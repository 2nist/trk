# Section Combining Feature Test Plan

## Overview

This document provides a test plan for verifying the new section combining feature in the Songbase Section Editor.

## Test Environment Setup

1. Launch REAPER
2. Load the Songbase script via: `Actions > Show action list > ReaScript: Run`
3. Navigate to and select `launch_songbase.lua`
4. Open the Section Editor

## Test Cases

### Basic Functionality

1. **Toggle Combining Mode**
   - Click the "Combine Sections" button
   - Verify that checkboxes appear next to section names
   - Verify that "Confirm Combine" button appears
   - Click "Cancel Combining" to exit the mode
   - Verify return to normal selection mode

2. **Selection Validation**
   - Enter combining mode
   - Select only one section
   - Verify "Confirm Combine" is disabled
   - Select at least two sections
   - Verify "Confirm Combine" becomes enabled

### Combining Tests

3. **Basic Combining**
   - Create or load a song with at least 3 sections
   - Enter combining mode
   - Select sections 1 and 2
   - Click "Confirm Combine"
   - Verify:
     - A new combined section is created
     - Original sections are removed
     - The combined section contains chords from both original sections
     - Section names are properly combined with "+"

4. **Chord Organization**
   - Combine sections with different chord patterns
   - Verify section separators (-- comments) appear between the original sections
   - Verify all chords appear in the correct order

5. **Properties Inheritance**
   - Create sections with different beats-per-chord values
   - Combine these sections
   - Verify the new section inherits the beats-per-chord from the first selected section

6. **Edge Cases**
   - Combine all sections in a song
   - Combine sections with empty chord arrays
   - Combine many sections resulting in a very long section name

## Results Documentation

For each test case, record:
1. Pass/Fail status
2. Any unexpected behavior
3. Screenshots if applicable
4. Steps to reproduce any issues found

## Approval Criteria

The feature will be considered successfully implemented when:
1. All test cases pass
2. No errors occur during normal operation
3. The UI remains responsive throughout the combining process
4. Section data is correctly preserved and displayed after combining
