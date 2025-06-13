# Bass Module (bss)

## Purpose
Generates groove-locked, theory-aware bass lines based on the current chord progression, drum groove, and user choices.

## Workflow
- Follows Chord Track (root note per chord)
- Triggered by drum track (kick by default)
- User can override/add scale degrees
- Groove/legato/velocity/FX controls
- Stackable cards: `bass.card`, `groove.card`, `arp.card`, `fx.card`
- Sends MIDI to REAPER, can render audio preview

## Usage
- Entry: `bass_stack.lua`
- Requires chord outputs from `/crd/`
- Outputs: MIDI, optionally audio

## Example Cards
- `bass.card`: root/legato settings
- `fx.card`: tone, fuzz, sidechain

## Integration
- Pulls chord data from `/crd/` (e.g., `.jcrd` files)
- UI/logic stubs provided
