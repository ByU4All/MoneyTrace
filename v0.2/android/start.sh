#!/bin/bash
# MoneyTrace - Quick Start Script
# Run this to start the MoneyTrace server

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.."

echo "Starting MoneyTrace..."
echo "Open http://127.0.0.1:8000 in your browser"
echo ""

python -m moneytrace.server

