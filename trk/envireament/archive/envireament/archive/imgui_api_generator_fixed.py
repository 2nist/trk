#!/usr/bin/env python3
"""
Enhanced ImGui API Generator with Robust File System Handling
Fixes file creation issues and provides comprehensive error reporting
"""

import os
import sys
import re
import json
from pathlib import Path
from datetime import datetime

class EnhancedFileSystemManager:
    """Enhanced file system manager with robust error handling."""
    
    def __init__(self):
        self.working_dir = Path.cwd()
        self.output_dir = self.working_dir
        self.demo_lua_path = None
        self.verbose = True
        
    def setup_environment(self):
        """Setup and validate the working environment."""
        print("🔧 Setting up enhanced file system environment...")
        
        # Check current directory
        print(f"📁 Working directory: {self.working_dir}")
        
        # Check write permissions
        try:
            test_file = self.working_dir / "permission_test.tmp"
            test_file.write_text("test")
            test_file.unlink()
            print("✅ Write permissions: OK")
        except Exception as e:
            print(f"❌ Write permissions: FAILED - {e}")
            return False
            
        # Check for demo.lua
        demo_paths = [
            Path(r"c:\Users\CraftAuto-Sales\Downloads\reaimgui-master-git\reaimgui-master\examples\demo.lua"),
            self.working_dir / "demo.lua",
            self.working_dir.parent / "demo.lua"
        ]
        
        for path in demo_paths:
            if path.exists():
                self.demo_lua_path = path
                print(f"✅ Found demo.lua: {path}")
                break
        
        if not self.demo_lua_path:
            print("⚠️  demo.lua not found - will use fallback function list")
            
        return True
        
    def safe_write_file(self, filename, content, encoding='utf-8'):
        """Safely write a file with comprehensive error handling."""
        filepath = self.output_dir / filename
        
        try:
            # Ensure directory exists
            filepath.parent.mkdir(parents=True, exist_ok=True)
            
            # Write with explicit encoding and error handling
            with open(filepath, 'w', encoding=encoding, errors='replace') as f:
                f.write(content)
                f.flush()
                os.fsync(f.fileno())  # Force write to disk
                
            # Verify file was created
            if filepath.exists() and filepath.stat().st_size > 0:
                print(f"✅ Successfully created: {filename} ({filepath.stat().st_size} bytes)")
                return True
            else:
                print(f"❌ File creation failed: {filename}")
                return False
                
        except PermissionError as e:
            print(f"❌ Permission denied: {filename} - {e}")
            print("   Try running as administrator or check folder permissions")
            return False
        except OSError as e:
            print(f"❌ OS Error writing {filename}: {e}")
            return False
        except Exception as e:
            print(f"❌ Unexpected error writing {filename}: {e}")
            return False

class ImGuiAPIExtractor:
    """Extract ImGui API functions from demo.lua with fallback support."""
    
    def __init__(self, file_manager):
        self.file_manager = file_manager
        self.extracted_functions = set()
        
    def extract_from_demo(self):
        """Extract ImGui functions from demo.lua."""
        if not self.file_manager.demo_lua_path:
            return self.get_fallback_functions()
            
        try:
            with open(self.file_manager.demo_lua_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                
            # Extract ImGui function calls - multiple patterns for different naming conventions
            patterns = [
                r'ImGui\.(\w+)\s*\(',      # ImGui.Function() format
                r'ImGui_(\w+)\s*\(',       # ImGui_Function() format  
                r'r\.ImGui\.(\w+)\s*\(',   # r.ImGui.Function() format
            ]
            
            for pattern in patterns:
                matches = re.findall(pattern, content)
                for match in matches:
                    # Convert to ImGui_ format
                    func_name = f"ImGui_{match}"
                    self.extracted_functions.add(func_name)
                
            print(f"📊 Extracted {len(self.extracted_functions)} functions from demo.lua")
            
            if len(self.extracted_functions) < 50:  # If extraction seems too low, show sample
                print("🔍 Sample extracted functions:")
                for func in list(self.extracted_functions)[:10]:
                    print(f"   - {func}")
                    
            return list(self.extracted_functions)
            
        except Exception as e:
            print(f"⚠️  Error reading demo.lua: {e}")
            return self.get_fallback_functions()
    
    def get_fallback_functions(self):
        """Fallback list of common ImGui functions."""
        print("📋 Using fallback function list...")
        
        return [
            "ImGui_BeginTable", "ImGui_EndTable", "ImGui_TableNextColumn", "ImGui_TableNextRow",
            "ImGui_TableSetupColumn", "ImGui_TableHeadersRow", "ImGui_SliderAngle",
            "ImGui_SliderDouble2", "ImGui_SliderDouble3", "ImGui_SliderDouble4",
            "ImGui_SliderInt2", "ImGui_SliderInt3", "ImGui_SliderInt4",
            "ImGui_InputDouble2", "ImGui_InputDouble3", "ImGui_InputDouble4",
            "ImGui_InputInt2", "ImGui_InputInt3", "ImGui_InputInt4",
            "ImGui_ColorEdit4", "ImGui_ColorPicker3", "ImGui_ColorPicker4",
            "ImGui_BeginChild", "ImGui_EndChild", "ImGui_BeginGroup", "ImGui_EndGroup",
            "ImGui_BeginTooltip", "ImGui_EndTooltip", "ImGui_BeginPopup", "ImGui_EndPopup",
            "ImGui_IsItemHovered", "ImGui_IsItemActive", "ImGui_IsItemFocused",
            "ImGui_IsItemClicked", "ImGui_IsItemVisible", "ImGui_IsItemEdited",
            "ImGui_IsWindowHovered", "ImGui_IsWindowFocused", "ImGui_IsWindowCollapsed",
            "ImGui_GetItemRectMin", "ImGui_GetItemRectMax", "ImGui_GetItemRectSize",
            "ImGui_DrawList_AddLine", "ImGui_DrawList_AddRect", "ImGui_DrawList_AddText",
            "ImGui_DrawList_AddCircle", "ImGui_TreeNode", "ImGui_TreePop",
            "ImGui_Selectable", "ImGui_MenuItem", "ImGui_BeginCombo", "ImGui_EndCombo",
            "ImGui_BeginListBox", "ImGui_EndListBox", "ImGui_BeginMenuBar", "ImGui_EndMenuBar",
            "ImGui_BeginMainMenuBar", "ImGui_EndMainMenuBar", "ImGui_BeginTabBar", "ImGui_EndTabBar",
            "ImGui_BeginTabItem", "ImGui_EndTabItem", "ImGui_SetTabItemClosed", "ImGui_TabItemButton",
            "ImGui_BeginDragDropSource", "ImGui_EndDragDropSource", "ImGui_BeginDragDropTarget", "ImGui_EndDragDropTarget",
            "ImGui_PushID", "ImGui_PopID", "ImGui_PushStyleColor", "ImGui_PopStyleColor",
            "ImGui_PushStyleVar", "ImGui_PopStyleVar", "ImGui_PushFont", "ImGui_PopFont",
            "ImGui_PushItemWidth", "ImGui_PopItemWidth", "ImGui_SetNextItemWidth", "ImGui_CalcItemWidth",
            "ImGui_PushTextWrapPos", "ImGui_PopTextWrapPos", "ImGui_GetFont", "ImGui_GetFontSize"
        ]

class ImGuiFunctionGenerator:
    """Generate ImGui function implementations with intelligent categorization."""
    
    def __init__(self, file_manager):
        self.file_manager = file_manager
        
    def categorize_function(self, func_name):
        """Intelligently categorize ImGui functions."""
        name_lower = func_name.lower()
        
        if any(word in name_lower for word in ['begin', 'end']):
            return 'container'
        elif any(word in name_lower for word in ['table']):
            return 'table'
        elif any(word in name_lower for word in ['input', 'slider', 'drag', 'color']):
            return 'input'
        elif any(word in name_lower for word in ['is', 'get', 'want']):
            return 'query'
        elif any(word in name_lower for word in ['draw', 'line', 'rect', 'circle']):
            return 'drawing'
        elif any(word in name_lower for word in ['tree']):
            return 'tree'
        elif any(word in name_lower for word in ['push', 'pop']):
            return 'stack'
        else:
            return 'other'
    
    def generate_function_impl(self, func_name, category):
        """Generate a realistic function implementation."""
        
        implementations = {
            'container': '''    {func_name} = function(ctx, ...)
      log_api_call("{func_name}", ctx, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return true
    end,''',
            
            'table': '''    {func_name} = function(ctx, ...)
      log_api_call("{func_name}", ctx, ...)
      return true
    end,''',
            
            'input': '''    {func_name} = function(ctx, label, value, ...)
      log_api_call("{func_name}", ctx, label, value, ...)
      VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
      return false, value or 0
    end,''',
            
            'query': '''    {func_name} = function(ctx, ...)
      log_api_call("{func_name}", ctx, ...)
      return false
    end,''',
            
            'drawing': '''    {func_name} = function(draw_list, ...)
      log_api_call("{func_name}", draw_list, ...)
      return true
    end,''',
            
            'tree': '''    {func_name} = function(ctx, label, ...)
      log_api_call("{func_name}", ctx, label, ...)
      return false
    end,''',
            
            'stack': '''    {func_name} = function(ctx, ...)
      log_api_call("{func_name}", ctx, ...)
      return true
    end,''',
            
            'other': '''    {func_name} = function(ctx, ...)
      log_api_call("{func_name}", ctx, ...)
      return true
    end,'''
        }
        
        return implementations.get(category, implementations['other']).format(func_name=func_name)
    
    def generate_all_functions(self, function_list):
        """Generate implementations for all functions."""
        
        generated_content = """-- Generated ImGui Functions
-- Auto-generated virtual implementations for missing ImGui functions
-- Generated: {}

local generated_functions = {{
""".format(datetime.now().strftime("%Y-%m-%d %H:%M:%S"))

        categorized_count = {}
        
        for func_name in sorted(function_list):
            category = self.categorize_function(func_name)
            categorized_count[category] = categorized_count.get(category, 0) + 1
            
            implementation = self.generate_function_impl(func_name, category)
            generated_content += implementation + "\n\n"
        
        generated_content += "}\n\nreturn generated_functions"
        
        # Generate statistics
        stats_content = f"""
-- Generation Statistics
-- Total functions: {len(function_list)}
-- Categories: {dict(categorized_count)}
-- Generated: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
"""
        
        return generated_content, stats_content

def main():
    """Main execution function with comprehensive error handling."""
    
    print("🚀 Enhanced ImGui API Generator Starting...")
    print("=" * 60)
    
    # Initialize file system manager
    fs_manager = EnhancedFileSystemManager()
    
    # Setup environment
    if not fs_manager.setup_environment():
        print("❌ Environment setup failed. Exiting.")
        return False
    
    # Extract functions
    extractor = ImGuiAPIExtractor(fs_manager)
    function_list = extractor.extract_from_demo()
    
    if not function_list:
        print("❌ No functions extracted. Exiting.")
        return False
    
    # Generate implementations
    generator = ImGuiFunctionGenerator(fs_manager)
    generated_content, stats_content = generator.generate_all_functions(function_list)
    
    # Write output files
    success = True
    
    # Main generated functions file
    if not fs_manager.safe_write_file("generated_imgui_functions.lua", generated_content):
        success = False
    
    # Statistics file
    if not fs_manager.safe_write_file("generation_stats.txt", stats_content):
        success = False
    
    # Integration instructions
    instructions = f"""# Integration Instructions

## Generated Files:
- generated_imgui_functions.lua: {len(function_list)} function implementations
- generation_stats.txt: Generation statistics and metadata

## Next Steps:
1. Review generated_imgui_functions.lua
2. Run integration script to merge with enhanced_virtual_reaper.lua
3. Test with demo.lua compatibility

## Generated: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
"""
    
    if not fs_manager.safe_write_file("integration_instructions.md", instructions):
        success = False
    
    # Summary
    if success:
        print(f"\n🎉 SUCCESS! Generated {len(function_list)} ImGui functions")
        print(f"📁 Files created in: {fs_manager.output_dir}")
        print("✅ Ready for integration!")
    else:
        print("\n❌ PARTIAL FAILURE: Some files could not be created")
        print("   Check permissions and disk space")
    
    return success

if __name__ == "__main__":
    try:
        success = main()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n⏹️  Operation cancelled by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n💥 Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
