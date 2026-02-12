#!/usr/bin/env python
"""
MoneyTrace Test Runner

Runs all tests with coverage and detailed output.
Usage:
    python test_runner.py              # Run all tests
    python test_runner.py -v           # Verbose mode
    python test_runner.py -k test_name # Run specific test
"""

import sys
import os
import pytest

# Add current directory to path for module resolution
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))


def main():
    """Run all tests with pytest."""

    # Base pytest arguments
    args = [
        "moneytrace/tests",           # Test directory
        "-v",                          # Verbose
        "--tb=short",                  # Short traceback format
        "--color=yes",                 # Colored output
        "-ra",                         # Show summary of all test outcomes
    ]

    # Add any command line arguments passed to this script
    args.extend(sys.argv[1:])

    print("=" * 70)
    print("MoneyTrace Test Suite")
    print("=" * 70)
    print(f"Running tests from: {os.path.join(os.getcwd(), 'moneytrace/tests')}")
    print("=" * 70)
    print()

    # Run pytest
    exit_code = pytest.main(args)

    print()
    print("=" * 70)
    if exit_code == 0:
        print("✓ All tests passed!")
    else:
        print(f"✗ Tests failed with exit code: {exit_code}")
    print("=" * 70)

    return exit_code


if __name__ == "__main__":
    sys.exit(main())

