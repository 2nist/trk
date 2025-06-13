"""
Command-line interface for EnviREAment.

Provides CLI commands for running tests, demos, and accessing EnviREAment functionality.
"""

import argparse
import sys
from . import run_tests, run_demo, get_version, get_examples_dir, get_docs_dir


def run_tests_cli():
    """CLI command to run EnviREAment tests."""
    parser = argparse.ArgumentParser(description="Run EnviREAment test suite")
    parser.add_argument("--verbose", "-v", action="store_true", 
                      help="Enable verbose output")
    args = parser.parse_args()
    
    success = run_tests(verbose=args.verbose)
    sys.exit(0 if success else 1)


def run_demo_cli():
    """CLI command to run EnviREAment demo."""
    parser = argparse.ArgumentParser(description="Run EnviREAment demo")
    args = parser.parse_args()
    
    success = run_demo()
    sys.exit(0 if success else 1)


def main():
    """Main CLI entry point."""
    parser = argparse.ArgumentParser(description="EnviREAment - Virtual REAPER Environment")
    parser.add_argument("--version", action="version", version=f"EnviREAment {get_version()}")
    
    subparsers = parser.add_subparsers(dest="command", help="Available commands")
    
    # Test command
    test_parser = subparsers.add_parser("test", help="Run test suite")
    test_parser.add_argument("--verbose", "-v", action="store_true", 
                           help="Enable verbose output")
    
    # Demo command
    demo_parser = subparsers.add_parser("demo", help="Run demo application")
    
    # Info command
    info_parser = subparsers.add_parser("info", help="Show package information")
    
    args = parser.parse_args()
    
    if args.command == "test":
        success = run_tests(verbose=args.verbose)
        sys.exit(0 if success else 1)
    elif args.command == "demo":
        success = run_demo()
        sys.exit(0 if success else 1)
    elif args.command == "info":
        print(f"EnviREAment v{get_version()}")
        print(f"Examples directory: {get_examples_dir()}")
        print(f"Documentation directory: {get_docs_dir()}")
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
