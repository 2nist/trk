#!/usr/bin/env python3
"""
EnviREAment Workflow Optimization & Validation Script
Provides comprehensive system analysis and performance recommendations
"""

import os
import sys
import time
import json
from pathlib import Path
from datetime import datetime
import subprocess

class WorkflowOptimizer:
    def __init__(self):
        self.working_dir = Path.cwd()
        self.results = {}
        
    def check_system_resources(self):
        """Check system resources and performance."""
        print("🔍 Analyzing System Resources...")
        
        try:
            # Check disk space
            disk_usage = os.statvfs(self.working_dir) if hasattr(os, 'statvfs') else None
            if disk_usage:
                free_space = disk_usage.f_bavail * disk_usage.f_frsize
                total_space = disk_usage.f_blocks * disk_usage.f_frsize
                self.results['disk_space'] = {
                    'free_gb': round(free_space / (1024**3), 2),
                    'total_gb': round(total_space / (1024**3), 2),
                    'free_percent': round((free_space / total_space) * 100, 1)
                }
            
            # Check Python performance
            start_time = time.time()
            test_data = list(range(10000))
            processed = [x * 2 for x in test_data]
            python_perf = time.time() - start_time
            
            self.results['python_performance'] = {
                'list_processing_ms': round(python_perf * 1000, 2),
                'performance_rating': 'Excellent' if python_perf < 0.01 else 'Good' if python_perf < 0.05 else 'Adequate'
            }
            
            print(f"✅ System analysis complete")
            
        except Exception as e:
            print(f"⚠️  System analysis partial: {e}")
            
    def validate_project_files(self):
        """Validate all project files and their integrity."""
        print("📋 Validating Project Files...")
        
        critical_files = {
            'enhanced_virtual_reaper.lua': 'Main virtual environment',
            'generated_imgui_functions.lua': 'Generated ImGui functions',
            'imgui_api_generator_fixed.py': 'Enhanced API generator',
            'integrate_api_functions.py': 'API integration script'
        }
        
        file_status = {}
        
        for filename, description in critical_files.items():
            filepath = self.working_dir / filename
            if filepath.exists():
                size = filepath.stat().st_size
                file_status[filename] = {
                    'status': 'OK',
                    'size_kb': round(size / 1024, 2),
                    'description': description,
                    'last_modified': filepath.stat().st_mtime
                }
                print(f"✅ {filename}: {size/1024:.1f} KB")
            else:
                file_status[filename] = {
                    'status': 'MISSING',
                    'description': description
                }
                print(f"❌ {filename}: MISSING")
        
        self.results['files'] = file_status
        
    def analyze_imgui_coverage(self):
        """Analyze ImGui API coverage and completeness."""
        print("📊 Analyzing ImGui API Coverage...")
        
        try:
            # Read virtual reaper file
            vr_file = self.working_dir / 'enhanced_virtual_reaper.lua'
            if vr_file.exists():
                content = vr_file.read_text(encoding='utf-8')
                
                # Count ImGui functions
                import re
                imgui_functions = re.findall(r'ImGui_(\w+)\s*=', content)
                unique_functions = set(imgui_functions)
                
                # Categorize functions
                categories = {
                    'window': len([f for f in unique_functions if any(w in f.lower() for w in ['begin', 'end', 'window'])]),
                    'widgets': len([f for f in unique_functions if any(w in f.lower() for w in ['button', 'text', 'input', 'slider'])]),
                    'layout': len([f for f in unique_functions if any(w in f.lower() for w in ['same', 'next', 'separator', 'spacing'])]),
                    'tables': len([f for f in unique_functions if 'table' in f.lower()]),
                    'drawing': len([f for f in unique_functions if any(w in f.lower() for w in ['draw', 'line', 'rect', 'circle'])]),
                    'other': len(unique_functions)
                }
                
                categories['other'] -= sum(v for k, v in categories.items() if k != 'other')
                
                self.results['imgui_coverage'] = {
                    'total_functions': len(unique_functions),
                    'categories': categories,
                    'coverage_estimate': f"{min(100, (len(unique_functions) / 500) * 100):.1f}%"
                }
                
                print(f"✅ Found {len(unique_functions)} ImGui functions")
                
        except Exception as e:
            print(f"⚠️  ImGui analysis error: {e}")
            
    def check_git_status(self):
        """Check Git repository status and suggest optimizations."""
        print("🔀 Checking Git Repository Status...")
        
        try:
            # Check if we're in a git repository
            git_dir = self.working_dir / '.git'
            if not git_dir.exists():
                # Look for git in parent directories
                current = self.working_dir.parent
                while current != current.parent:
                    if (current / '.git').exists():
                        git_dir = current / '.git'
                        break
                    current = current.parent
            
            if git_dir.exists():
                # Get git status
                try:
                    result = subprocess.run(['git', 'status', '--porcelain'], 
                                          capture_output=True, text=True, cwd=git_dir.parent)
                    if result.returncode == 0:
                        changes = result.stdout.strip().split('\n') if result.stdout.strip() else []
                        self.results['git'] = {
                            'repository_found': True,
                            'uncommitted_changes': len(changes),
                            'changes': changes[:10]  # First 10 changes
                        }
                        print(f"✅ Git repository found, {len(changes)} uncommitted changes")
                    else:
                        print("⚠️  Git repository found but status check failed")
                except FileNotFoundError:
                    print("⚠️  Git not installed or not in PATH")
            else:
                print("ℹ️  No Git repository found")
                self.results['git'] = {'repository_found': False}
                
        except Exception as e:
            print(f"⚠️  Git check error: {e}")
            
    def recommend_optimizations(self):
        """Generate workflow optimization recommendations."""
        print("💡 Generating Optimization Recommendations...")
        
        recommendations = []
        
        # File system recommendations
        if 'disk_space' in self.results:
            free_percent = self.results['disk_space']['free_percent']
            if free_percent < 10:
                recommendations.append("🔴 CRITICAL: Low disk space - consider cleanup")
            elif free_percent < 25:
                recommendations.append("🟡 WARNING: Disk space getting low")
        
        # Performance recommendations
        if 'python_performance' in self.results:
            rating = self.results['python_performance']['performance_rating']
            if rating == 'Adequate':
                recommendations.append("💻 Consider upgrading Python or system resources")
        
        # Git workflow recommendations
        if 'git' in self.results and self.results['git']['repository_found']:
            changes = self.results['git']['uncommitted_changes']
            if changes > 5:
                recommendations.append(f"📝 Consider committing {changes} uncommitted changes")
            if changes == 0:
                recommendations.append("✅ Git repository is clean - good practice!")
        
        # ImGui coverage recommendations
        if 'imgui_coverage' in self.results:
            total = self.results['imgui_coverage']['total_functions']
            if total > 400:
                recommendations.append("🎉 Excellent ImGui coverage achieved!")
            elif total > 300:
                recommendations.append("✅ Good ImGui coverage")
            else:
                recommendations.append("📈 Consider adding more ImGui functions")
        
        # File management recommendations
        recommendations.extend([
            "📁 Keep regular backups of enhanced_virtual_reaper.lua",
            "🔄 Use automated testing for API changes",
            "📚 Document custom function implementations",
            "⚡ Consider using VS Code tasks for common operations"
        ])
        
        self.results['recommendations'] = recommendations
        
        for rec in recommendations:
            print(f"  {rec}")
            
    def generate_optimization_report(self):
        """Generate comprehensive optimization report."""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        report = f"""# EnviREAment Workflow Optimization Report
Generated: {timestamp}

## System Status
"""
        
        # Add system info
        if 'disk_space' in self.results:
            ds = self.results['disk_space']
            report += f"""
### Disk Space
- Free: {ds['free_gb']} GB ({ds['free_percent']}%)
- Total: {ds['total_gb']} GB
"""
        
        # Add performance info
        if 'python_performance' in self.results:
            pp = self.results['python_performance']
            report += f"""
### Python Performance
- List processing: {pp['list_processing_ms']} ms
- Rating: {pp['performance_rating']}
"""
        
        # Add file status
        if 'files' in self.results:
            report += "\n### Critical Files\n"
            for filename, info in self.results['files'].items():
                status = info['status']
                if status == 'OK':
                    report += f"- ✅ {filename}: {info['size_kb']} KB\n"
                else:
                    report += f"- ❌ {filename}: {status}\n"
        
        # Add ImGui coverage
        if 'imgui_coverage' in self.results:
            ic = self.results['imgui_coverage']
            report += f"""
### ImGui API Coverage
- Total Functions: {ic['total_functions']}
- Estimated Coverage: {ic['coverage_estimate']}
- Categories: {ic['categories']}
"""
        
        # Add recommendations
        if 'recommendations' in self.results:
            report += "\n### Optimization Recommendations\n"
            for rec in self.results['recommendations']:
                clean_rec = rec.replace('🔴', '').replace('🟡', '').replace('💻', '').replace('📝', '').replace('✅', '').replace('🎉', '').replace('📈', '').replace('📁', '').replace('🔄', '').replace('📚', '').replace('⚡', '').strip()
                report += f"- {clean_rec}\n"
        
        # Save report
        report_file = self.working_dir / f"workflow_optimization_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"
        report_file.write_text(report, encoding='utf-8')
        print(f"📄 Optimization report saved: {report_file}")

def main():
    """Main optimization analysis."""
    print("🚀 EnviREAment Workflow Optimization")
    print("=" * 50)
    
    optimizer = WorkflowOptimizer()
    
    # Run all analyses
    optimizer.check_system_resources()
    optimizer.validate_project_files()
    optimizer.analyze_imgui_coverage()
    optimizer.check_git_status()
    optimizer.recommend_optimizations()
    optimizer.generate_optimization_report()
    
    print(f"\n🎉 Optimization analysis complete!")
    print(f"📊 Results saved to workflow_optimization_report_*.md")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"💥 Error during optimization: {e}")
        import traceback
        traceback.print_exc()
