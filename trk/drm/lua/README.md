# Lua Scripts for Groove MIDI Machine

This directory contains the Lua scripts that implement the Groove MIDI Machine user interface and REAPER integration:

## Main Files

- `gmm_launcher.lua` - Entry point for the Groove MIDI Machine
- `pattern_browser.lua` - Browse and preview patterns from the library
- `pattern_stack.lua` - Combine patterns into custom arrangements (coming soon)
- `section_assistant.lua` - Section-aware pattern suggestions (coming soon)

## Integrations

These scripts work both as standalone tools and as part of the Songbase environment. When running in Songbase, additional integrations are available:

- Integration with the section editor
- Access to song structure information
- Shared data with other Songbase tools

## Dependencies

These scripts depend on:

- REAPER with ReaImGui support
- ReaScript API
- Optional Songbase environment
