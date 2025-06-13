# Groove MIDI Machine (GMM)

## Overview

The Groove MIDI Machine is a user-guided drum pattern assistant for REAPER. It provides tools for browsing, organizing, and arranging drum patterns from the Groove MIDI Dataset and other sources.

## Key Features

- Pattern browser with filtering by style, tempo, and other attributes
- Component separation (kicks, snares, hats, etc.)
- Pattern stacking to create custom drum arrangements
- Context-aware pattern suggestions based on song sections
- Seamless integration with REAPER

## Directory Structure

- `lua/` - Lua scripts for the GMM user interface and REAPER integration
- `python/` - Python scripts for data processing, analysis, and pattern transformation
- `data/` - Local data storage for indices, metadata, and configuration
- `docs/` - Documentation for the GMM system

## Using as a Standalone Tool

The Groove MIDI Machine can be used as a standalone tool independently of the Songbase environment:

1. Ensure REAPER is configured to find scripts in this directory
2. Run `lua/gmm_launcher.lua` from REAPER's ReaScript menu
3. Use the pattern browser to find and apply drum patterns to your project

## Integration with Songbase

When used with Songbase, GMM provides additional functionality:

1. Section-aware pattern suggestions based on chord and section data
2. Arrangement tools that work with Songbase's project structure
3. Shared data for a unified workflow

## Dependencies

- REAPER 6.0+ with ReaImGui
- Python 3.7+ with required packages (see requirements.txt)
- Groove MIDI Dataset (can be downloaded with the included tools)
