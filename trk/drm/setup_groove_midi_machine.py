#!/usr/bin/env python3
"""
Groove MIDI Machine Setup Script

This script organizes the Groove MIDI Machine files into a standalone component
that can be used independently of Songbase or integrated with it.

It copies relevant files from the tools directory to the new structure
and creates necessary directories for data.
"""

import os
import shutil
import sys
from pathlib import Path

# Base directories
REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOOLS_DIR = os.path.join(REPO_ROOT, "tools")
GMM_ROOT = os.path.join(REPO_ROOT, "groove_midi_machine")

# Source files to copy
FILES_TO_COPY = {
    # Python files
    os.path.join(TOOLS_DIR, "groove_midi_explorer.py"): os.path.join(GMM_ROOT, "python", "groove_midi_explorer.py"),
    os.path.join(TOOLS_DIR, "groove_midi_component_separator.py"): os.path.join(GMM_ROOT, "python", "groove_midi_component_separator.py"),
    os.path.join(TOOLS_DIR, "groove_midi_section_classifier.py"): os.path.join(GMM_ROOT, "python", "groove_midi_section_classifier.py"),
    
    # Lua files
    os.path.join(TOOLS_DIR, "drum_pattern_browser.lua"): os.path.join(GMM_ROOT, "lua", "pattern_browser.lua"),
    os.path.join(TOOLS_DIR, "groove_midi_machine.lua"): os.path.join(GMM_ROOT, "lua", "pattern_stack.lua"),
    os.path.join(TOOLS_DIR, "load_groove_midi.lua"): os.path.join(GMM_ROOT, "lua", "load_helpers.lua"),
    
    # Batch files
    os.path.join(TOOLS_DIR, "extract_groove_midi.bat"): os.path.join(GMM_ROOT, "python", "extract_groove_midi.bat"),
    os.path.join(TOOLS_DIR, "Extract-GrooveMIDI.ps1"): os.path.join(GMM_ROOT, "python", "Extract-GrooveMIDI.ps1"),
}

# Directories to create
DATA_DIRS = [
    os.path.join(GMM_ROOT, "data", "midi"),
    os.path.join(GMM_ROOT, "data", "components"),
    os.path.join(GMM_ROOT, "data", "cards"),
    os.path.join(GMM_ROOT, "data", "metadata"),
]

def main():
    """Main execution function."""
    print("Setting up Groove MIDI Machine directory structure...")
    
    # Create data directories
    for directory in DATA_DIRS:
        os.makedirs(directory, exist_ok=True)
        print(f"Created directory: {directory}")
    
    # Copy files
    for src, dest in FILES_TO_COPY.items():
        if os.path.exists(src):
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            shutil.copy2(src, dest)
            print(f"Copied: {src} -> {dest}")
        else:
            print(f"Warning: Source file not found: {src}")
    
    # Create symlinks for data if they don't exist
    orig_midi_dir = os.path.join(REPO_ROOT, "data", "midi", "groove_midi")
    if os.path.exists(orig_midi_dir):
        symlink_path = os.path.join(GMM_ROOT, "data", "midi", "groove_midi")
        if not os.path.exists(symlink_path):
            # On Windows, use directory junction instead of symlink for compatibility
            if sys.platform == 'win32':
                os.system(f'mklink /J "{symlink_path}" "{orig_midi_dir}"')
            else:
                os.symlink(orig_midi_dir, symlink_path)
            print(f"Created data link: {symlink_path} -> {orig_midi_dir}")
    
    print("\nGroove MIDI Machine setup complete!")
    print("\nYou can now run the GMM either:")
    print("1. As a standalone tool by loading gmm_launcher.lua in REAPER")
    print("2. As part of Songbase through the main Songbase interface")
    
if __name__ == "__main__":
    main()
