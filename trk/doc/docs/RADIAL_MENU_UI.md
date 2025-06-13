# Radial Menu UI Spec

## Overview
A context-sensitive, radial (hex/petal) menu for stack/card management. Pops up on arrangement grid cell click. Enables fast, visual card/stack actions with minimal UI clutter.

## Core Features
- Center: Stack summary
- Petals: Cards (color, label, quick actions), Add/Remove/Preview/Save
- Card browser modal for adding cards
- Save stack as .stack.card
- Keyboard shortcuts (Esc to close)

## Integration
- Invoked by arrangement grid cell click
- Updates session/arrangement state
- Card browser filters by type
- Saved stacks in /cards/stack/

## TODOs
- Implement radial_menu.lua core logic
- Add helpers for drawing, style, icons
- Test for clean, rapid, low-clutter UX
