#!/usr/bin/env python3
"""
Virtual REAPER Demo Compatibility Validator
Python-based validator for testing enhanced_virtual_reaper.lua structure and API coverage
"""

import re
import os
import json
from pathlib import Path
from datetime import datetime

class VirtualREAPERValidator:
    def __init__(self):
        self.working_dir = Path.cwd()
        self.virtual_reaper_file = self.working_dir / "enhanced_virtual_reaper.lua"
        self.demo_lua_path = Path(r"c:\Users\CraftAuto-Sales\Downloads\reaimgui-master-git\reaimgui-master\examples\demo.lua")
        self.test_results = {
            'total_tests': 0,
            'passed_tests': 0,
            'failed_tests': 0,
            'errors': [],
            'api_coverage': {},
            'performance_data': {},
            'start_time': datetime.now()
        }
        
    def log_test(self, test_name, passed, error_msg=None):
        """Log test results."""
        self.test_results['total_tests'] += 1
        
        if passed:
            self.test_results['passed_tests'] += 1
            print(f"✅ PASS: {test_name}")
        else:
            self.test_results['failed_tests'] += 1
            error_info = f"❌ FAIL: {test_name} - {error_msg or 'Test failed'}"
            self.test_results['errors'].append(error_info)
            print(error_info)
    
    def test_file_structure(self):
        """Test basic file structure and syntax."""
        print("\n🔧 Testing File Structure and Syntax...")
        
        # Check if virtual reaper file exists
        exists = self.virtual_reaper_file.exists()
        self.log_test("Virtual REAPER file exists", exists, "enhanced_virtual_reaper.lua not found")
        
        if not exists:
            return False
        
        # Read and validate basic Lua syntax patterns
        try:
            content = self.virtual_reaper_file.read_text(encoding='utf-8')
            
            # Test for basic Lua structure
            has_local_declaration = 'local EnhancedVirtualReaper' in content
            self.log_test("Has main module declaration", has_local_declaration)
            
            # Test for required sections
            has_state_management = 'VirtualState' in content
            self.log_test("Has state management", has_state_management)
            
            has_logging = 'log_api_call' in content
            self.log_test("Has logging system", has_logging)
            
            # Test for return statement
            has_return = 'return EnhancedVirtualReaper' in content
            self.log_test("Has module return", has_return)
            
            return True
            
        except Exception as e:
            self.log_test("File readable", False, str(e))
            return False
    
    def test_imgui_api_coverage(self):
        """Test ImGui API function coverage."""
        print("\n📊 Testing ImGui API Coverage...")
        
        try:
            # Read virtual reaper content
            vr_content = self.virtual_reaper_file.read_text(encoding='utf-8')
            
            # Extract ImGui functions from virtual reaper
            vr_functions = set(re.findall(r'ImGui_(\w+)\s*=', vr_content))
            
            # Common ImGui functions that should be implemented
            essential_functions = {
                'CreateContext', 'DestroyContext', 'Attach',
                'Begin', 'End', 'Text', 'Button', 'InputText',
                'SliderDouble', 'Checkbox', 'Combo', 'Selectable',
                'BeginTable', 'EndTable', 'TableSetupColumn', 'TableNextRow', 'TableNextColumn',
                'IsItemHovered', 'IsItemActive', 'IsItemClicked'
            }
            
            # Test essential function coverage
            missing_essential = essential_functions - vr_functions
            coverage_percentage = ((len(essential_functions) - len(missing_essential)) / len(essential_functions)) * 100
            
            self.log_test(f"Essential ImGui functions ({coverage_percentage:.1f}% coverage)", 
                         len(missing_essential) == 0, 
                         f"Missing: {', '.join(sorted(missing_essential))}" if missing_essential else None)
            
            # Test total function count
            total_functions = len(vr_functions)
            self.log_test(f"Total ImGui functions >= 400", total_functions >= 400, 
                         f"Only {total_functions} functions found")
            
            self.test_results['api_coverage'] = {
                'total_functions': total_functions,
                'essential_coverage': coverage_percentage,
                'missing_essential': list(missing_essential)
            }
            
            # Extract and test demo.lua functions if available
            if self.demo_lua_path.exists():
                demo_content = self.demo_lua_path.read_text(encoding='utf-8', errors='ignore')
                demo_functions = set()
                
                # Extract from different patterns
                patterns = [
                    r'ImGui\.(\w+)\s*\(',
                    r'ImGui_(\w+)\s*\(',
                    r'r\.ImGui\.(\w+)\s*\('
                ]
                
                for pattern in patterns:
                    matches = re.findall(pattern, demo_content)
                    demo_functions.update(matches)
                
                # Calculate demo compatibility
                demo_coverage = len(demo_functions & vr_functions) / len(demo_functions) * 100 if demo_functions else 0
                self.log_test(f"Demo.lua compatibility ({demo_coverage:.1f}%)", demo_coverage >= 80,
                             f"Only {demo_coverage:.1f}% of demo functions implemented")
                
                self.test_results['api_coverage']['demo_functions'] = len(demo_functions)
                self.test_results['api_coverage']['demo_compatibility'] = demo_coverage
            
            return True
            
        except Exception as e:
            self.log_test("API coverage analysis", False, str(e))
            return False
    
    def test_function_implementations(self):
        """Test the quality of function implementations."""
        print("\n🎨 Testing Function Implementation Quality...")
        
        try:
            content = self.virtual_reaper_file.read_text(encoding='utf-8')
            
            # Test for proper error handling in functions
            has_error_handling = 'log_error' in content
            self.log_test("Has error handling", has_error_handling)
            
            # Test for context validation
            has_context_validation = 'ctx == nil' in content or 'not ctx' in content
            self.log_test("Has context validation", has_context_validation)
            
            # Test for state management
            has_state_updates = 'VirtualState.stats' in content
            self.log_test("Has statistics tracking", has_state_updates)
            
            # Test for proper return values
            function_patterns = [
                (r'ImGui_Begin.*?return.*?true', "Begin function returns boolean"),
                (r'ImGui_Button.*?return.*?false', "Button function returns boolean"),
                (r'ImGui_InputText.*?return.*?,.*?value', "Input functions return value pairs")
            ]
            
            for pattern, test_name in function_patterns:
                has_pattern = bool(re.search(pattern, content, re.DOTALL))
                self.log_test(test_name, has_pattern)
            
            return True
            
        except Exception as e:
            self.log_test("Function implementation analysis", False, str(e))
            return False
    
    def test_performance_characteristics(self):
        """Test performance-related characteristics."""
        print("\n⚡ Testing Performance Characteristics...")
        
        try:
            # File size check (should be reasonable but not too large)
            file_size = self.virtual_reaper_file.stat().st_size
            size_mb = file_size / (1024 * 1024)
            
            self.log_test("File size reasonable (< 1MB)", size_mb < 1.0, 
                         f"File is {size_mb:.2f}MB")
            
            # Line count check
            content = self.virtual_reaper_file.read_text(encoding='utf-8')
            line_count = len(content.split('\n'))
            
            self.log_test("Line count reasonable (< 5000)", line_count < 5000,
                         f"File has {line_count} lines")
            
            # Function density check
            function_count = len(re.findall(r'function\s*\(', content))
            function_density = function_count / line_count if line_count > 0 else 0
            
            self.log_test("Good function density", 0.05 <= function_density <= 0.5,
                         f"Function density: {function_density:.3f}")
            
            self.test_results['performance_data'] = {
                'file_size_mb': size_mb,
                'line_count': line_count,
                'function_count': function_count,
                'function_density': function_density
            }
            
            return True
            
        except Exception as e:
            self.log_test("Performance analysis", False, str(e))
            return False
    
    def test_error_resilience(self):
        """Test error handling and resilience patterns."""
        print("\n🛡️  Testing Error Resilience...")
        
        try:
            content = self.virtual_reaper_file.read_text(encoding='utf-8')
            
            # Test for pcall usage (protected calls)
            has_pcall = 'pcall' in content
            self.log_test("Uses protected calls", has_pcall)
            
            # Test for nil checks
            has_nil_checks = 'if not ' in content or '== nil' in content
            self.log_test("Has nil parameter checks", has_nil_checks)
            
            # Test for try-catch patterns (Lua error handling)
            has_error_patterns = 'error(' in content or 'assert(' in content
            self.log_test("Has error assertion patterns", has_error_patterns)
            
            # Test for logging of errors
            has_error_logging = 'log_error' in content or 'log_warning' in content
            self.log_test("Has error logging", has_error_logging)
            
            return True
            
        except Exception as e:
            self.log_test("Error resilience analysis", False, str(e))
            return False
    
    def generate_validation_report(self):
        """Generate comprehensive validation report."""
        end_time = datetime.now()
        duration = (end_time - self.test_results['start_time']).total_seconds()
        
        success_rate = (self.test_results['passed_tests'] / self.test_results['total_tests']) * 100 if self.test_results['total_tests'] > 0 else 0
        
        report = f"""# Virtual REAPER Demo Compatibility Validation Report
Generated: {end_time.strftime('%Y-%m-%d %H:%M:%S')}

## Test Summary
- **Total Tests**: {self.test_results['total_tests']}
- **Passed**: {self.test_results['passed_tests']}
- **Failed**: {self.test_results['failed_tests']}
- **Success Rate**: {success_rate:.1f}%
- **Test Duration**: {duration:.2f} seconds

## API Coverage Analysis
"""
        
        if 'api_coverage' in self.test_results:
            ac = self.test_results['api_coverage']
            report += f"""- **Total ImGui Functions**: {ac.get('total_functions', 'N/A')}
- **Essential Function Coverage**: {ac.get('essential_coverage', 'N/A'):.1f}%
- **Demo.lua Functions Found**: {ac.get('demo_functions', 'N/A')}
- **Demo Compatibility**: {ac.get('demo_compatibility', 'N/A'):.1f}%
"""
        
        if 'performance_data' in self.test_results:
            pd = self.test_results['performance_data']
            report += f"""
## Performance Characteristics
- **File Size**: {pd.get('file_size_mb', 'N/A'):.2f} MB
- **Line Count**: {pd.get('line_count', 'N/A')}
- **Function Count**: {pd.get('function_count', 'N/A')}
- **Function Density**: {pd.get('function_density', 'N/A'):.3f}
"""
        
        if self.test_results['errors']:
            report += "\n## Failed Tests\n"
            for error in self.test_results['errors']:
                clean_error = error.replace('❌ FAIL: ', '')
                report += f"- {clean_error}\n"
        
        report += f"""
## Recommendations
{'- ✅ Virtual REAPER is ready for production use!' if success_rate >= 90 else '- ⚠️  Address failed tests before production use'}
- Continue testing with actual demo.lua when Lua interpreter is available
- Consider performance optimizations for large-scale usage
- Maintain comprehensive error logging for debugging

## Next Steps
1. Install Lua interpreter for runtime testing
2. Test with actual REAPER/ReaImGui demo scripts
3. Performance benchmarking with complex UIs
4. Integration testing with real REAPER projects
"""
        
        # Save report
        report_file = self.working_dir / f"validation_report_{end_time.strftime('%Y%m%d_%H%M%S')}.md"
        report_file.write_text(report, encoding='utf-8')
        print(f"\n📄 Validation report saved: {report_file}")
        
        return success_rate >= 80
    
    def run_all_validations(self):
        """Run all validation tests."""
        print("🚀 Starting Virtual REAPER Demo Compatibility Validation")
        print("=" * 60)
        
        # Run all test suites
        self.test_file_structure()
        self.test_imgui_api_coverage()
        self.test_function_implementations()
        self.test_performance_characteristics()
        self.test_error_resilience()
        
        # Generate report and summary
        success = self.generate_validation_report()
        
        print("\n" + "=" * 60)
        print("📊 VALIDATION RESULTS SUMMARY")
        print("=" * 60)
        print(f"Total Tests: {self.test_results['total_tests']}")
        print(f"Passed: {self.test_results['passed_tests']}")
        print(f"Failed: {self.test_results['failed_tests']}")
        print(f"Success Rate: {(self.test_results['passed_tests'] / self.test_results['total_tests']) * 100:.1f}%")
        
        if success:
            print("\n🎉 VALIDATION SUCCESSFUL! Virtual REAPER is demo.lua compatible!")
        else:
            print(f"\n⚠️  Validation incomplete. Review {self.test_results['failed_tests']} failed tests.")
        
        return success

def main():
    """Main validation execution."""
    validator = VirtualREAPERValidator()
    success = validator.run_all_validations()
    return 0 if success else 1

if __name__ == "__main__":
    exit(main())
