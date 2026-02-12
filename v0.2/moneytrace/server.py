"""
Server entry point for MoneyTrace v0.2.0

Starts the FastAPI backend with uvicorn.
Designed to run on Android via Termux.
"""

import os
import sys
import argparse


def main():
    """Start the MoneyTrace server."""
    parser = argparse.ArgumentParser(description="MoneyTrace Server")
    parser.add_argument("--host", default="127.0.0.1", help="Host to bind to")
    parser.add_argument("--port", type=int, default=8000, help="Port to bind to")
    parser.add_argument("--reload", action="store_true", help="Enable hot reload")
    args = parser.parse_args()

    # Ensure package is importable
    package_dir = os.path.dirname(os.path.abspath(__file__))
    parent_dir = os.path.dirname(package_dir)
    if parent_dir not in sys.path:
        sys.path.insert(0, parent_dir)

    import uvicorn

    print(f"""
╔══════════════════════════════════════════╗
║          MoneyTrace v0.2.0               ║
║    Personal Finance Tracking             ║
╠══════════════════════════════════════════╣
║  Open in browser:                        ║
║  http://{args.host}:{args.port:<24}║
╚══════════════════════════════════════════╝
    """)

    uvicorn.run(
        "moneytrace.api.main:app",
        host=args.host,
        port=args.port,
        reload=args.reload,
    )


if __name__ == "__main__":
    main()

