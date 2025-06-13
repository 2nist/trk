#!/bin/bash

# Songbase Repository Cleanup Script
# This script helps execute the cleanup plan systematically

set -e

echo "🧹 Songbase Repository Cleanup Script"
echo "======================================"

# Function to confirm before proceeding
confirm() {
    read -p "$1 [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping..."
        return 1
    fi
    return 0
}

# Function to safely remove files/directories
safe_remove() {
    local target="$1"
    if [ -e "$target" ]; then
        echo "Removing: $target"
        rm -rf "$target"
    else
        echo "Not found: $target"
    fi
}

# Change to the repository directory
cd "$(dirname "$0")"

echo "Current directory: $(pwd)"
echo

# 1. Remove large directories
echo "📁 STEP 1: Remove large directories (760MB total)"
if confirm "Remove myenv/ directory (271MB Python virtual environment)?"; then
    safe_remove "myenv/"
fi

if confirm "Remove jcrddatasets/ directory (489MB dataset processing)?"; then
    safe_remove "jcrddatasets/"
fi

# 2. Remove duplicate theme configuration files
echo
echo "🎨 STEP 2: Remove duplicate theme configuration files"
if confirm "Remove duplicate theme config files?"; then
    safe_remove "theme_config_new.lua"
    safe_remove "theme_config_fixed.lua"
    safe_remove "style_config.lua"
fi

# 3. Remove duplicate UI dataset browser files
echo
echo "🖥️  STEP 3: Remove duplicate UI dataset browser files"
if confirm "Remove duplicate UI dataset browser files from root?"; then
    safe_remove "ui_dataset_browser.lua"
    safe_remove "ui_dataset_browser_v2.lua"
    safe_remove "ui_dataset_browser_cleaned.lua"
    safe_remove "ui_dataset_browser_fixed.lua"
fi

if confirm "Remove legacy UI dataset browser files?"; then
    safe_remove "ui/legacy/"
fi

# 4. Remove duplicate launcher scripts
echo
echo "🚀 STEP 4: Remove duplicate launcher scripts"
if confirm "Remove duplicate launcher scripts?"; then
    safe_remove "launch_dataset_browser.lua"
    safe_remove "launch_dataset_browser_fixed.lua"
    safe_remove "launch_grimidi.lua"
fi

# 5. Move orphaned test files
echo
echo "🧪 STEP 5: Move orphaned test files to tests/ directory"
if confirm "Move test files from root to tests/ directory?"; then
    mkdir -p tests/
    [ -f "test_theme.lua" ] && mv "test_theme.lua" "tests/"
    [ -f "test_phase2.lua" ] && mv "test_phase2.lua" "tests/"
    [ -f "test_theme_config.lua" ] && mv "test_theme_config.lua" "tests/"
    [ -f "test_ui_components.lua" ] && mv "test_ui_components.lua" "tests/"
    [ -f "test_style_config.lua" ] && mv "test_style_config.lua" "tests/"
    [ -f "test_hex_chord_builder.lua" ] && mv "test_hex_chord_builder.lua" "tests/"
fi

# 6. Remove compressed archives in datasets
echo
echo "📦 STEP 6: Remove compressed archives in datasets"
if confirm "Remove compressed archive files in datasets?"; then
    safe_remove "datasets/POP909/POP909-Dataset-master/POP909.zip"
    safe_remove "datasets/POP909/POP909-Dataset-master/data_process/pop-pickle.zip"
    safe_remove "datasets/los_angelos_midiain/Los-Angeles-MIDI-Dataset-main/TOTALS/LAMDa_TOTALS.zip"
    safe_remove "lucide_icon_pack.zip"
fi

# 7. Organize loose JSON files in datasets
echo
echo "📄 STEP 7: Organize loose JSON files in datasets"
if confirm "Move loose JSON files from datasets/ root to a 'misc' subdirectory?"; then
    mkdir -p "datasets/misc/"
    for file in datasets/*.json; do
        if [ -f "$file" ]; then
            echo "Moving: $file"
            mv "$file" "datasets/misc/"
        fi
    done
fi

# 8. Remove potential obsolete files
echo
echo "🗑️  STEP 8: Remove potentially obsolete files"
if confirm "Remove demo and test utility files?"; then
    safe_remove "reaimgui_demo.lua"
    safe_remove "v2.lua"
    safe_remove "path_fix.lua"
    safe_remove "path_test.lua"
    safe_remove "rename_project.lua"
    safe_remove "rebuild_structure.lua"
fi

# 9. Create scripts directory and move conversion scripts
echo
echo "📂 STEP 9: Organize conversion scripts"
if confirm "Move conversion scripts to scripts/ directory?"; then
    mkdir -p "scripts/"
    [ -f "batch_convert_rock_corpus.py" ] && mv "batch_convert_rock_corpus.py" "scripts/"
    [ -f "chord_annotation_to_jcrd.py" ] && mv "chord_annotation_to_jcrd.py" "scripts/"
    [ -f "isophonics_to_jcrd.py" ] && mv "isophonics_to_jcrd.py" "scripts/"
    [ -f "pop909_to_jcrd.py" ] && mv "pop909_to_jcrd.py" "scripts/"
    [ -f "rock_corpus_har_to_jcrd.py" ] && mv "rock_corpus_har_to_jcrd.py" "scripts/"
    [ -f "rock_corpus_mel_to_jcrd.py" ] && mv "rock_corpus_mel_to_jcrd.py" "scripts/"
    [ -f "run_python_tool.lua" ] && mv "run_python_tool.lua" "scripts/"
    [ -f "apply_tool_manifest_updates.lua" ] && mv "apply_tool_manifest_updates.lua" "scripts/"
    [ -f "update_tool_manifest.lua" ] && mv "update_tool_manifest.lua" "scripts/"
fi

echo
echo "✅ Cleanup completed!"
echo "📊 Check disk space saved with: du -sh ."
echo "🔍 Review changes with: git status"
echo "💡 Remember to:"
echo "   - Test that main.lua still works"
echo "   - Update any broken require/import paths"
echo "   - Recreate myenv if needed: python -m venv myenv"
echo "   - Commit changes: git add . && git commit -m 'Clean up repository: remove duplicates and large files'"
