# Sketch Track Module (ske)

## Purpose
Freeform, non-destructive musical sketchbook for instant ideation and sandboxing.

## Usage
- Launch sandbox UI for quick sketch tracks
- Create tracks: Chord, Drums, Melody, Bass, Vox, Extras
- Drag/drop idea cards, rapid loop capture
- Export/commit best ideas to arrangement/project manager

### Example: Creating a Quick Track
```lua
local SketchMode = require('ske.sketchmode')
SketchMode.create_quick_track('Drums')
```

## How to Test
- Run `test/test_sketchmode_setup.lua` to check module loading and function callability.

## Integration
- Pathway to arrangement (promotion, cardization)
- Section mapping: assign sketches to sections by drag/drop or command (coming soon)
