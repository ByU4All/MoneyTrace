#!/usr/bin/env python
"""
MoneyTrace v0.1.0 - Entry Point

Run this script to start the FastAPI backend:
    python run.py

Or run as module:
    python -m moneytrace.server

Access the app at: http://127.0.0.1:8000
"""

import os
import sys

# Add current directory to path for module resolution
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from moneytrace.server import main

if __name__ == "__main__":
    print("Starting MoneyTrace v0.1.0...")
    print("Open http://127.0.0.1:8000 in your browser")
    print("-" * 40)
    main()
