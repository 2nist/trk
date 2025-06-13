#!/usr/bin/env python3
"""
Songbase Compatibility Checker
Verifies that songbase main.lua and dependencies are properly structured
"""

import os
import sys
from pathlib import Path

def check_file_exists(file_path):
    """Check if file exists and is readable"""
    return Path(file_path).exists() and Path(file_path).is_file()

def check_dir_exists(dir_path):
    """Check if directory exists"""
    return Path(dir_path).exists() and Path(dir_path).is_dir()

def check_lua_syntax_basic(file_path):
    """Basic Lua syntax check by reading file and looking for common issues"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Basic checks
        issues = []
        
        # Check for balanced brackets/braces
        open_brackets = content.count('[')
        close_brackets = content.count(']')
        if open_brackets != close_brackets:
            issues.append(f"Unbalanced brackets: {open_brackets} '[' vs {close_brackets} ']'")
        
        open_braces = content.count('{')
        close_braces = content.count('}')
        if open_braces != close_braces:
            issues.append(f"Unbalanced braces: {open_braces} '{{' vs {close_braces} '}}'")
        
        open_parens = content.count('(')
        close_parens = content.count(')')
        if open_parens != close_parens:
            issues.append(f"Unbalanced parentheses: {open_parens} '(' vs {close_parens} ')'")
        
        # Check for common Lua keywords
        required_patterns = ['function', 'local', 'return']
        for pattern in required_patterns:
            if pattern not in content:
                issues.append(f"Missing expected pattern: {pattern}")
        
        return len(issues) == 0, issues
        
    except Exception as e:
        return False, [f"Error reading file: {str(e)}"]

def main():
    print("🔍 Songbase Compatibility Checker")
    print("=" * 60)
    
    # Define base path
    base_path = Path("C:/Users/CraftAuto-Sales/AppData/Roaming/REAPER/Scripts/songbase")
    
    if not base_path.exists():
        print(f"❌ Songbase directory not found: {base_path}")
        return False
    
    print(f"✓ Found songbase directory: {base_path}")
    
    # Critical files to check
    critical_files = [
        "main.lua",
        "config.lua", 
        "utils/json.lua",
        "utils/file_operations.lua",
        "ui/song_browser.lua",
        "ui/hex_chord_builder.lua"
    ]
    
    # Critical directories to check  
    critical_dirs = [
        "ui",
        "utils",
        "datasets"
    ]
    
    print("\n📁 Checking directory structure...")
    all_dirs_ok = True
    for dir_name in critical_dirs:
        dir_path = base_path / dir_name
        if check_dir_exists(dir_path):
            print(f"✓ Directory: {dir_name}")
        else:
            print(f"❌ Missing directory: {dir_name}")
            all_dirs_ok = False
    
    print("\n📄 Checking critical files...")
    all_files_ok = True
    for file_name in critical_files:
        file_path = base_path / file_name
        if check_file_exists(file_path):
            print(f"✓ File: {file_name}")
            
            # Check Lua syntax
            syntax_ok, issues = check_lua_syntax_basic(file_path)
            if syntax_ok:
                print(f"  ✓ Syntax check passed")
            else:
                print(f"  ⚠️  Syntax issues found:")
                for issue in issues:
                    print(f"     - {issue}")
        else:
            print(f"❌ Missing file: {file_name}")
            all_files_ok = False
    
    print("\n🎯 Checking main.lua structure...")
    main_lua_path = base_path / "main.lua"
    if check_file_exists(main_lua_path):
        try:
            with open(main_lua_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Check for key components
            checks = [
                ("VERSION declaration", "VERSION ="),
                ("Package path setup", "package.path ="),
                ("Config loading", 'require("config")'),
                ("ImGui context creation", "ImGui_CreateContext"),
                ("Main function", "function main()"),
                ("UI loop", "function ui_loop()"),
                ("Return statement", "return {")
            ]
            
            for check_name, pattern in checks:
                if pattern in content:
                    print(f"✓ {check_name}")
                else:
                    print(f"⚠️  {check_name} - pattern not found: {pattern}")
                    
        except Exception as e:
            print(f"❌ Error analyzing main.lua: {str(e)}")
            all_files_ok = False
    
    print("\n" + "=" * 60)
    
    if all_dirs_ok and all_files_ok:
        print("🎉 SUCCESS: Songbase appears to be properly structured!")
        print("\n📋 Next steps:")
        print("1. Run launch_songbase_test.lua from REAPER")
        print("2. Or run main.lua directly from REAPER")
        print("3. Check REAPER console for any runtime errors")
        return True
    else:
        print("❌ ISSUES FOUND: Songbase structure has problems")
        print("\n🔧 Fix the missing files/directories before running")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
