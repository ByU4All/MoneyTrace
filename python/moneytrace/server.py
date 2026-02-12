# server.py
"""
Server entry point for MoneyTrace v0.1.0

Starts the FastAPI backend with uvicorn.
"""

import os
import sys
import uvicorn


def main():
    """Start the MoneyTrace server."""
    # Ensure parent directory is in path for module resolution
    parent_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    if parent_dir not in sys.path:
        sys.path.insert(0, parent_dir)

    uvicorn.run(
        "moneytrace.api.main:app",
        host="127.0.0.1",
        port=8000,
        reload=True,  # Enable hot reload for development
    )


if __name__ == "__main__":
    main()

