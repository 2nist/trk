# Lyric Track Module (lyr)

## Purpose
Lyric/wordtrack scratchpad and structure tool for songwriting.

## Features

- Per-line lyric entry
- Syllable, meter, rhyme overlays
- Card browser/load/save
- Rhyme suggestion/helper
- Snap-to-section/beat tools (stub)
- Drag-drop or assign card to arrangement (stub)
- Section tagging (verse, chorus, etc.)
- Export/import cards as .card files

## Usage
- Main script: `lyric_editor.lua`
- Card types: `lyric.card`, `rhyme.card`, `concept.card`, `hook.card`
- Test stubs in `/test/`

### Example: Adding a Lyric Line
```lua
local LyricEditor = require('lyr.lyric_editor')
LyricEditor.enter_lyric_line('When the night falls, I remember you')
```

## How to Test
- Run `test/test_lyric_entry.lua` to check module loading and function callability.

## Integration
- Links to chord/arrangement for section mapping
- Promotion: move best lines/cards to main arrangement/session manager (coming soon)
