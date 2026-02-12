#!/bin/bash
# MoneyTrace - Termux Setup Script
# Run this once to set up MoneyTrace on your Android phone

echo "================================"
echo "MoneyTrace Setup for Termux"
echo "================================"
echo ""

# Update packages
echo "[1/4] Updating Termux packages..."
pkg update -y && pkg upgrade -y

# Install Python
echo "[2/4] Installing Python..."
pkg install -y python

# Install pip packages
echo "[3/4] Installing Python dependencies..."
pip install fastapi uvicorn[standard] pydantic python-multipart

# Create startup script
echo "[4/4] Creating startup script..."
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cat > ~/moneytrace-start.sh << EOF
#!/bin/bash
cd "$SCRIPT_DIR/.."
python -m moneytrace.server
EOF
chmod +x ~/moneytrace-start.sh

echo ""
echo "================================"
echo "Setup Complete!"
echo "================================"
echo ""
echo "To start MoneyTrace, run:"
echo "  ~/moneytrace-start.sh"
echo ""
echo "Then open Chrome and go to:"
echo "  http://127.0.0.1:8000"
echo ""
echo "To install as app:"
echo "  1. Open the URL in Chrome"
echo "  2. Tap the 3-dot menu"
echo "  3. Select 'Add to Home screen'"
echo ""

