"""
EnviREAment - Virtual REAPER Environment for Development and Testing

A comprehensive virtual environment that mimics REAPER's API and ImGui functionality
for developing and testing REAPER scripts without requiring the actual REAPER application.

Features:
- Complete ImGui API simulation with 70+ functions
- Virtual REAPER API with project management, track operations, and MIDI support
- Comprehensive test framework with performance metrics
- Cross-platform compatibility (Windows, macOS, Linux)
- Zero dependencies - works out of the box

Usage:
    import envireament
    
    # Run the test suite
    envireament.run_tests()
    
    # Run a demo
    envireament.run_demo()
    
    # Access core components
    from envireament import VirtualREAPER, TestRunner
"""

__version__ = "1.0.0"
__author__ = "Matthew @ Songbase"
__email__ = "contact@songbase.dev"
__license__ = "MIT"

import os
import subprocess
import sys
from pathlib import Path

# Get the package directory
PACKAGE_DIR = Path(__file__).parent.parent


class EnviREAment:
    """Main EnviREAment class for accessing virtual environment functionality."""
    
    def __init__(self):
        self.package_dir = PACKAGE_DIR
        self.virtual_reaper_path = self.package_dir / "enhanced_virtual_reaper.lua"
        self.test_runner_path = self.package_dir / "enhanced_test_runner.lua"
        
    def run_tests(self, verbose=False):
        """Run the EnviREAment test suite."""
        if not self.test_runner_path.exists():
            raise FileNotFoundError(f"Test runner not found at {self.test_runner_path}")
            
        cmd = ["lua", str(self.test_runner_path)]
        if verbose:
            cmd.append("--verbose")
            
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, cwd=self.package_dir)
            print(result.stdout)
            if result.stderr:
                print("STDERR:", result.stderr, file=sys.stderr)
            return result.returncode == 0
        except FileNotFoundError:
            print("Error: Lua interpreter not found. Please install Lua to use EnviREAment.")
            return False
            
    def run_demo(self):
        """Run the EnviREAment demo application."""
        demo_path = self.package_dir / "examples" / "main.lua"
        if not demo_path.exists():
            raise FileNotFoundError(f"Demo not found at {demo_path}")
            
        cmd = ["lua", str(demo_path)]
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, cwd=self.package_dir)
            print(result.stdout)
            if result.stderr:
                print("STDERR:", result.stderr, file=sys.stderr)
            return result.returncode == 0
        except FileNotFoundError:
            print("Error: Lua interpreter not found. Please install Lua to use EnviREAment.")
            return False
            
    def get_virtual_reaper_path(self):
        """Get the path to the virtual REAPER environment script."""
        return str(self.virtual_reaper_path)
        
    def get_examples_dir(self):
        """Get the path to the examples directory."""
        return str(self.package_dir / "examples")
        
    def get_docs_dir(self):
        """Get the path to the documentation directory."""
        return str(self.package_dir / "docs")


# Global instance for easy access
_instance = EnviREAment()

# Convenience functions
def run_tests(verbose=False):
    """Run the EnviREAment test suite."""
    return _instance.run_tests(verbose=verbose)

def run_demo():
    """Run the EnviREAment demo application."""
    return _instance.run_demo()

def get_virtual_reaper_path():
    """Get the path to the virtual REAPER environment script."""
    return _instance.get_virtual_reaper_path()

def get_examples_dir():
    """Get the path to the examples directory."""
    return _instance.get_examples_dir()

def get_docs_dir():
    """Get the path to the documentation directory."""
    return _instance.get_docs_dir()


# Version info
def get_version():
    """Get the EnviREAment version."""
    return __version__


# Main functionality access
VirtualREAPER = _instance
TestRunner = _instance

__all__ = [
    'EnviREAment', 'VirtualREAPER', 'TestRunner',
    'run_tests', 'run_demo', 'get_virtual_reaper_path', 
    'get_examples_dir', 'get_docs_dir', 'get_version'
]
