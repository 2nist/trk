# Melody Module (mel)

## Purpose

Capture user-created melodies (voice, MIDI, keyboard), shape them rhythmically/harmonically, and lock them to the groove.

## Workflow

- Record/import/keyboard input
- Transform grid: length, quantize, swing, pitch correction
- Preview in mini piano roll
- Export as card or MIDI

## Usage

- Entry: `melody_fx.lua`
- Requires chord/groove data from `/crd/`
- Outputs: MIDI, optionally audio

## Example Cards

- `melody.card`: phrase/grid settings
- `fx.card`: harmony, arpeggiation, effects

## Integration

- Pulls chord/groove data from `/crd/`
- UI/logic stubs provided
