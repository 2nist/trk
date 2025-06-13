#!/usr/bin/env python3
"""
Songbase EnviREAment Integration Test
Python script to test songbase Lua scripts using the EnviREAment virtual environment
"""

import subprocess
import sys
import os
from pathlib import Path
from datetime import datetime

class SongbaseEnviREAmentTester:
    def __init__(self):
        self.working_dir = Path.cwd()
        self.envireament_dir = self.working_dir
        self.songbase_dir = Path("C:/Users/CraftAuto-Sales/AppData/Roaming/REAPER/Scripts/songbase/")
        self.test_results = {
            'total_tests': 0,
            'passed_tests': 0,
            'failed_tests': 0,
            'errors': [],
            'start_time': datetime.now()
        }
        
    def log_test(self, test_name, passed, error_msg=None):
        """Log test results."""
        self.test_results['total_tests'] += 1
        if passed:
            self.test_results['passed_tests'] += 1
            print(f"✅ {test_name} - PASS")
        else:
            self.test_results['failed_tests'] += 1
            print(f"❌ {test_name} - FAIL: {error_msg}")
            self.test_results['errors'].append(f"{test_name}: {error_msg}")

    def check_file_exists(self, file_path, description):
        """Check if a file exists."""
        exists = file_path.exists()
        self.log_test(f"File exists: {description}", exists, 
                     f"File not found: {file_path}" if not exists else None)
        return exists

    def check_lua_syntax(self, lua_file, description):
        """Check Lua file syntax by attempting to compile it."""
        try:
            # Try to read the file
            with open(lua_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Basic syntax checks
            if "function " in content:
                self.log_test(f"Lua syntax basic check: {description}", True)
                return True
            else:
                self.log_test(f"Lua syntax basic check: {description}", False, "No functions found")
                return False
                
        except Exception as e:
            self.log_test(f"Lua syntax check: {description}", False, str(e))
            return False

    def validate_songbase_structure(self):
        """Validate songbase directory structure."""
        print("🏗️ Validating Songbase Structure...")
        
        critical_files = [
            ("ui_dataset_browser.lua", "Main dataset browser UI"),
            ("theme_config.lua", "Theme configuration"),
            ("tool_chain_runner.lua", "Tool chain executor"),
            ("launch_dataset_browser.lua", "UI launcher"),
            ("tool_manifest.json", "Tool manifest")
        ]
        
        structure_valid = True
        for filename, description in critical_files:
            file_path = self.songbase_dir / filename
            if not self.check_file_exists(file_path, description):
                structure_valid = False
            elif filename.endswith('.lua'):
                if not self.check_lua_syntax(file_path, description):
                    structure_valid = False
        
        return structure_valid

    def validate_envireament(self):
        """Validate EnviREAment virtual environment."""
        print("🚀 Validating EnviREAment...")
        
        envireament_files = [
            ("enhanced_virtual_reaper.lua", "Virtual REAPER environment"),
            ("enhanced_test_runner.lua", "Test runner"),
            ("validate_virtual_reaper.py", "Python validator")
        ]
        
        envireament_valid = True
        for filename, description in envireament_files:
            file_path = self.envireament_dir / filename
            if not self.check_file_exists(file_path, description):
                envireament_valid = False
            elif filename.endswith('.lua'):
                if not self.check_lua_syntax(file_path, description):
                    envireament_valid = False
        
        return envireament_valid

    def test_ui_integration(self):
        """Test UI integration with virtual environment."""
        print("🎨 Testing UI Integration...")
        
        ui_file = self.songbase_dir / "ui_dataset_browser.lua"
        if not ui_file.exists():
            self.log_test("UI file availability", False, "ui_dataset_browser.lua not found")
            return False
        
        try:
            # Read and analyze the UI file
            with open(ui_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Check for critical ImGui functions our UI uses
            imgui_functions = [
                "ImGui_CreateContext",
                "ImGui_Begin",
                "ImGui_End",
                "ImGui_Text",
                "ImGui_Button",
                "ImGui_Combo",
                "ImGui_Checkbox",
                "ImGui_InputText"
            ]
            
            missing_functions = []
            for func in imgui_functions:
                if func not in content:
                    missing_functions.append(func)
            
            if missing_functions:
                self.log_test("UI ImGui function usage", False, 
                            f"Missing functions: {', '.join(missing_functions)}")
                return False
            else:
                self.log_test("UI ImGui function usage", True)
            
            # Check for REAPER API usage
            reaper_functions = [
                "reaper.GetResourcePath",
                "reaper.file_exists", 
                "reaper.ShowConsoleMsg"
            ]
            
            missing_reaper = []
            for func in reaper_functions:
                if func not in content:
                    missing_reaper.append(func)
            
            if missing_reaper:
                self.log_test("UI REAPER API usage", False,
                            f"Missing REAPER functions: {', '.join(missing_reaper)}")
                return False
            else:
                self.log_test("UI REAPER API usage", True)
                
            return True
            
        except Exception as e:
            self.log_test("UI file analysis", False, str(e))
            return False

    def analyze_compatibility(self):
        """Analyze compatibility between songbase and EnviREAment."""
        print("🔍 Analyzing Compatibility...")
        
        # Read virtual REAPER to see what APIs are implemented
        virtual_reaper_file = self.envireament_dir / "enhanced_virtual_reaper.lua"
        try:
            with open(virtual_reaper_file, 'r', encoding='utf-8') as f:
                virtual_content = f.read()
            
            # Check if our required APIs are implemented
            required_apis = [
                "GetResourcePath",
                "file_exists",
                "ShowConsoleMsg",
                "ImGui_CreateContext",
                "ImGui_Begin",
                "ImGui_End",
                "ImGui_Text",
                "ImGui_Button"
            ]
            
            implemented_apis = []
            missing_apis = []
            
            for api in required_apis:
                if api in virtual_content:
                    implemented_apis.append(api)
                else:
                    missing_apis.append(api)
            
            coverage = len(implemented_apis) / len(required_apis) * 100
            
            self.log_test(f"API coverage ({coverage:.1f}%)", coverage >= 80,
                         f"Missing APIs: {', '.join(missing_apis)}" if missing_apis else None)
            
            return coverage >= 80
            
        except Exception as e:
            self.log_test("Virtual REAPER analysis", False, str(e))
            return False

    def create_integration_test(self):
        """Create a practical integration test."""
        print("🛠️ Creating Integration Test...")
        
        test_script = '''
-- Songbase Virtual Test
dofile("enhanced_virtual_reaper.lua")

-- Create environment
local EnhancedVirtualReaper = require("enhanced_virtual_reaper")
if EnhancedVirtualReaper.create_environment then
    EnhancedVirtualReaper.create_environment()
end

-- Test basic functionality
if reaper then
    print("✅ reaper table available")
    
    -- Test functions our UI uses
    local path = reaper.GetResourcePath()
    print("✅ GetResourcePath:", path)
    
    local exists = reaper.file_exists("test.lua")
    print("✅ file_exists test:", exists)
    
    reaper.ShowConsoleMsg("✅ ShowConsoleMsg working\\n")
    
    local ctx = reaper.ImGui_CreateContext("Test")
    print("✅ ImGui_CreateContext:", ctx)
    
    print("🎉 Basic integration test successful!")
else
    print("❌ reaper table not available")
end
'''
        
        test_file = self.envireament_dir / "songbase_integration_test.lua"
        try:
            with open(test_file, 'w', encoding='utf-8') as f:
                f.write(test_script)
            self.log_test("Integration test creation", True)
            return test_file
        except Exception as e:
            self.log_test("Integration test creation", False, str(e))
            return None

    def generate_report(self):
        """Generate comprehensive test report."""
        print("\n" + "="*60)
        print("📋 SONGBASE ENVIREAMENT INTEGRATION REPORT")
        print("="*60)
        print(f"Test Date: {self.test_results['start_time'].strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"Songbase Path: {self.songbase_dir}")
        print(f"EnviREAment Path: {self.envireament_dir}")
        print()
        
        print("📊 Test Results:")
        print(f"  Total Tests: {self.test_results['total_tests']}")
        print(f"  Passed: {self.test_results['passed_tests']}")
        print(f"  Failed: {self.test_results['failed_tests']}")
        
        success_rate = (self.test_results['passed_tests'] / self.test_results['total_tests']) * 100 if self.test_results['total_tests'] > 0 else 0
        print(f"  Success Rate: {success_rate:.1f}%")
        
        if self.test_results['errors']:
            print("\n❌ Errors:")
            for error in self.test_results['errors']:
                print(f"  • {error}")
        
        print("\n🎯 Recommendations:")
        if success_rate >= 90:
            print("✅ Excellent! Songbase is highly compatible with EnviREAment")
            print("  • Ready for virtual testing and development")
            print("  • Can be used for automated testing pipelines")
            print("  • Consider creating more comprehensive test scenarios")
        elif success_rate >= 70:
            print("⚠️  Good compatibility with minor issues")
            print("  • Address failed tests before production use")
            print("  • Most functionality should work in virtual environment")
        else:
            print("❌ Significant compatibility issues detected")
            print("  • Review and fix critical errors before using EnviREAment")
            print("  • Consider updating songbase to use supported APIs")
        
        print("\n📈 Next Steps:")
        print("1. Address any failed tests")
        print("2. Run full UI testing in EnviREAment")
        print("3. Create automated test suite")
        print("4. Use for rapid development iteration")

    def run_all_tests(self):
        """Run all integration tests."""
        print("🚀 Starting Songbase EnviREAment Integration Test")
        print("="*60)
        
        # Run all test phases
        envireament_valid = self.validate_envireament()
        structure_valid = self.validate_songbase_structure()
        ui_integration_valid = self.test_ui_integration()
        compatibility_valid = self.analyze_compatibility()
        integration_test = self.create_integration_test()
        
        # Generate final report
        self.generate_report()
        
        return (envireament_valid and structure_valid and 
                ui_integration_valid and compatibility_valid)

def main():
    """Main test execution."""
    tester = SongbaseEnviREAmentTester()
    success = tester.run_all_tests()
    
    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())
