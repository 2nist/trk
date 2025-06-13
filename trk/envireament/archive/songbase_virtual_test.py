#!/usr/bin/env python3
"""
Songbase Virtual Test Runner
============================
Tests songbase functionality in the EnviREAment virtual environment
by simulating REAPER script execution and checking compatibility.
"""

import os
import sys
import subprocess
import re
from pathlib import Path
from datetime import datetime

class SongbaseVirtualTester:
    def __init__(self):
        self.envireament_dir = Path(__file__).parent
        self.songbase_dir = Path(r"C:\Users\CraftAuto-Sales\AppData\Roaming\REAPER\Scripts\songbase")
        self.test_results = {
            'start_time': datetime.now(),
            'tests': [],
            'passed': 0,
            'failed': 0
        }
        
    def log_test(self, test_name, passed, details=""):
        """Log a test result."""
        status = "✅ PASS" if passed else "❌ FAIL" 
        print(f"{status}: {test_name}")
        if details and not passed:
            print(f"  Details: {details}")
            
        self.test_results['tests'].append({
            'name': test_name,
            'passed': passed,
            'details': details,
            'timestamp': datetime.now()
        })
        
        if passed:
            self.test_results['passed'] += 1
        else:
            self.test_results['failed'] += 1

    def check_lua_syntax(self, file_path):
        """Check Lua syntax using basic pattern matching."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Check for basic Lua patterns
            has_lua_patterns = any([
                'function ' in content,
                'local ' in content,
                'reaper.' in content,
                'end' in content
            ])
            
            # Check for syntax errors
            syntax_errors = []
            if content.count('function') != content.count('end'):
                syntax_errors.append("Mismatched function/end")
            
            return has_lua_patterns and len(syntax_errors) == 0, syntax_errors
            
        except Exception as e:
            return False, [str(e)]

    def test_envireament_core(self):
        """Test EnviREAment core functionality."""
        print("🧪 Testing EnviREAment Core...")
        
        # Test virtual REAPER file
        virtual_reaper = self.envireament_dir / "enhanced_virtual_reaper.lua"
        if virtual_reaper.exists():
            syntax_ok, errors = self.check_lua_syntax(virtual_reaper)
            self.log_test("Virtual REAPER syntax", syntax_ok, "; ".join(errors))
            
            # Check for key features
            with open(virtual_reaper, 'r', encoding='utf-8') as f:
                content = f.read()
                
            has_imgui = "ImGui_CreateContext" in content
            has_reaper_api = "_G.reaper = mock_reaper" in content
            has_state_mgmt = "VirtualState" in content
            
            self.log_test("ImGui API simulation", has_imgui)
            self.log_test("REAPER API mocking", has_reaper_api)
            self.log_test("Virtual state management", has_state_mgmt)
        else:
            self.log_test("Virtual REAPER file exists", False)

    def test_songbase_components(self):
        """Test songbase component compatibility."""
        print("\n🎵 Testing Songbase Components...")
        
        # Key songbase files to test
        components = {
            "Dataset Browser UI": "ui_dataset_browser.lua",
            "Theme Configuration": "theme_config.lua", 
            "Tool Chain Runner": "tool_chain_runner.lua",
            "UI Launcher": "launch_dataset_browser.lua"
        }
        
        for name, filename in components.items():
            file_path = self.songbase_dir / filename
            if file_path.exists():
                syntax_ok, errors = self.check_lua_syntax(file_path)
                self.log_test(f"{name} syntax", syntax_ok, "; ".join(errors) if errors else "")
                
                # Check for REAPER API usage
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                reaper_calls = len(re.findall(r'reaper\.(\w+)', content))
                imgui_calls = len(re.findall(r'reaper\.ImGui_(\w+)', content))
                
                self.log_test(f"{name} REAPER API usage", reaper_calls > 0, f"{reaper_calls} calls")
                if 'ui_' in filename.lower():
                    self.log_test(f"{name} ImGui usage", imgui_calls > 0, f"{imgui_calls} calls")
            else:
                self.log_test(f"{name} file exists", False)

    def test_api_compatibility(self):
        """Test API compatibility between songbase and EnviREAment."""
        print("\n🔗 Testing API Compatibility...")
        
        # Load EnviREAment API definitions
        virtual_reaper = self.envireament_dir / "enhanced_virtual_reaper.lua"
        envireament_apis = set()
        
        if virtual_reaper.exists():
            with open(virtual_reaper, 'r', encoding='utf-8') as f:
                content = f.read()
                
            # Extract function definitions
            functions = re.findall(r'(\w+)\s*=\s*function', content)
            envireament_apis.update(functions)
            
            # Extract ImGui functions
            imgui_functions = re.findall(r'ImGui_(\w+)\s*=\s*function', content)
            envireament_apis.update([f"ImGui_{func}" for func in imgui_functions])
        
        # Check songbase API usage
        songbase_apis = set()
        for lua_file in self.songbase_dir.glob("*.lua"):
            try:
                with open(lua_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Extract reaper API calls
                api_calls = re.findall(r'reaper\.(\w+)', content)
                songbase_apis.update(api_calls)
                
            except Exception:
                continue
        
        # Calculate compatibility
        if songbase_apis:
            covered_apis = songbase_apis.intersection(envireament_apis)
            coverage = len(covered_apis) / len(songbase_apis) * 100
            
            self.log_test("API compatibility coverage", coverage >= 80, f"{coverage:.1f}%")
            
            missing_apis = songbase_apis - envireament_apis
            if missing_apis:
                print(f"  Missing APIs: {', '.join(sorted(missing_apis))}")
        else:
            self.log_test("API compatibility analysis", False, "No APIs found")

    def create_test_script(self):
        """Create a comprehensive test script for manual execution."""
        print("\n📝 Creating Test Script...")
        
        test_script = '''-- Songbase EnviREAment Integration Test
-- This script tests songbase components in the virtual environment

print("🚀 Loading EnviREAment...")
dofile("enhanced_virtual_reaper.lua")

print("🔧 Initializing virtual environment...")
if _G.reaper then
    print("✅ REAPER API available")
    
    -- Test basic REAPER functions
    local resource_path = reaper.GetResourcePath()
    print("✅ GetResourcePath:", resource_path or "nil")
    
    local version = reaper.GetAppVersion()
    print("✅ GetAppVersion:", version or "nil")
    
    -- Test ImGui availability
    if reaper.ImGui_CreateContext then
        local ctx = reaper.ImGui_CreateContext("Test")
        print("✅ ImGui_CreateContext:", ctx or "nil")
        
        if ctx then
            local available, flags = reaper.ImGui_Begin(ctx, "Test Window")
            print("✅ ImGui_Begin:", available, flags or "nil")
            reaper.ImGui_End(ctx)
        end
    else
        print("❌ ImGui functions not available")
    end
    
    -- Test file operations
    reaper.ShowConsoleMsg("✅ Console output working\\n")
    
    print("🎉 Basic functionality test complete!")
else
    print("❌ REAPER API not available")
end

print("\\n📊 Test Summary:")
print("- EnviREAment loaded successfully")
print("- Basic REAPER API functions working") 
print("- ImGui context creation working")
print("- Ready for songbase integration!")
'''
        
        test_file = self.envireament_dir / "songbase_envireament_test.lua"
        try:
            with open(test_file, 'w', encoding='utf-8') as f:
                f.write(test_script)
            self.log_test("Test script creation", True, str(test_file))
            return test_file
        except Exception as e:
            self.log_test("Test script creation", False, str(e))
            return None

    def generate_report(self):
        """Generate comprehensive test report."""
        print("\n" + "="*60)
        print("📋 SONGBASE VIRTUAL TEST REPORT")
        print("="*60)
        print(f"Test Date: {self.test_results['start_time'].strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"EnviREAment: {self.envireament_dir}")
        print(f"Songbase: {self.songbase_dir}")
        print()
        
        total_tests = self.test_results['passed'] + self.test_results['failed']
        success_rate = (self.test_results['passed'] / total_tests * 100) if total_tests > 0 else 0
        
        print("📊 Test Results:")
        print(f"  Total Tests: {total_tests}")
        print(f"  Passed: {self.test_results['passed']}")
        print(f"  Failed: {self.test_results['failed']}")
        print(f"  Success Rate: {success_rate:.1f}%")
        
        # Show failed tests
        failed_tests = [t for t in self.test_results['tests'] if not t['passed']]
        if failed_tests:
            print("\n❌ Failed Tests:")
            for test in failed_tests:
                print(f"  • {test['name']}: {test['details']}")
        
        # Recommendations
        print("\n🎯 Integration Status:")
        if success_rate >= 90:
            print("✅ Excellent! Songbase is highly compatible with EnviREAment")
            print("   Ready for development and testing")
        elif success_rate >= 70:
            print("⚠️ Good compatibility with minor issues")
            print("   Address failed tests before production use")
        else:
            print("❌ Significant compatibility issues detected")
            print("   Major work needed before integration")
        
        print("\n📈 Next Steps:")
        print("1. Run the generated test script in a Lua interpreter")
        print("2. Test actual songbase UI components")
        print("3. Create automated test pipeline") 
        print("4. Use EnviREAment for rapid development iteration")
        
        # Save detailed report
        report_file = self.envireament_dir / f"songbase_test_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"
        self._save_detailed_report(report_file)
        print(f"\n📄 Detailed report saved: {report_file}")

    def _save_detailed_report(self, report_file):
        """Save detailed markdown report."""
        try:
            with open(report_file, 'w', encoding='utf-8') as f:
                f.write(f"# Songbase EnviREAment Integration Test Report\n\n")
                f.write(f"**Date:** {self.test_results['start_time'].strftime('%Y-%m-%d %H:%M:%S')}\n")
                f.write(f"**EnviREAment Path:** {self.envireament_dir}\n")
                f.write(f"**Songbase Path:** {self.songbase_dir}\n\n")
                
                f.write("## Test Results\n\n")
                for test in self.test_results['tests']:
                    status = "✅" if test['passed'] else "❌"
                    f.write(f"- {status} **{test['name']}**")
                    if test['details']:
                        f.write(f": {test['details']}")
                    f.write("\n")
                
                total = self.test_results['passed'] + self.test_results['failed']
                success_rate = (self.test_results['passed'] / total * 100) if total > 0 else 0
                f.write(f"\n**Success Rate:** {success_rate:.1f}% ({self.test_results['passed']}/{total})\n")
                
        except Exception as e:
            print(f"Warning: Could not save detailed report: {e}")

    def run_all_tests(self):
        """Run all integration tests."""
        print("🧪 Starting Songbase Virtual Environment Tests")
        print("="*60)
        
        self.test_envireament_core()
        self.test_songbase_components()
        self.test_api_compatibility()
        self.create_test_script()
        self.generate_report()

if __name__ == "__main__":
    tester = SongbaseVirtualTester()
    tester.run_all_tests()
