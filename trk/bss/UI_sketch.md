# Bass Module UI / UX Flow

## Bass Card Stack

-------------------------------------------------------
| Chord    | Root | 3rd | 5th | 7th | Custom | Glide |
|----------|------|-----|-----|-----|--------|-------|
| Cmaj7    | ●    | ○   | ●   | ●   |   +    |  20%  |
| Fm7      | ●    | ●   | ○   | ●   |   +    |  15%  |
| ...      |      |     |     |     |        |       |
-------------------------------------------------------
[Velocity Curve]   [Legato Slider]   [Swing %]   [FX]
-------------------------------------------------------
[Preview in REAPER] [Export Card] [Apply Stack]

## Description
- Auto-follows Chord Track (root note per chord)
- Triggered by drum track (kick by default)
- User can override/add scale degrees
- Groove/legato/velocity/FX controls
- Stackable cards: bass.card, groove.card, arp.card, fx.card
- Sends MIDI to REAPER, can render audio preview
