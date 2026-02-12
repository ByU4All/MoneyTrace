#!/usr/bin/env python3
"""
Quick test script to verify static files are accessible.
"""

import os
import sys
from pathlib import Path

# Add parent directory to path
parent_dir = Path(__file__).parent
sys.path.insert(0, str(parent_dir))

from moneytrace.api.main import app
from fastapi.testclient import TestClient

# Create test client
client = TestClient(app)

print("=" * 60)
print("MoneyTrace Static Files Test")
print("=" * 60)

# Test files
test_files = [
    ("/", "index.html"),
    ("/css/app.css", "CSS"),
    ("/js/api.js", "JavaScript API"),
    ("/js/screens.js", "JavaScript Screens"),
    ("/js/app.js", "JavaScript App"),
]

for url, description in test_files:
    response = client.get(url)
    status = "✓" if response.status_code == 200 else "✗"
    print(f"{status} {url:20s} - {response.status_code} ({description})")
    if response.status_code != 200:
        print(f"   Error: {response.text[:100]}")

print("=" * 60)

# Check if any route mounted
print("\nApp Routes:")
for route in app.routes:
    print(f"  - {route}")

print("\n" + "=" * 60)
print("If all tests pass, the server should work correctly!")
print("Start server with: python moneytrace/server.py")
print("=" * 60)

