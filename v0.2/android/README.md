# MoneyTrace for Android (Termux)

This guide explains how to run MoneyTrace on your Android phone using Termux.

## Prerequisites

1. Install **Termux** from F-Droid (NOT from Play Store - that version is outdated)
   - Download: https://f-droid.org/en/packages/com.termux/

2. Grant Termux storage permissions (optional, for backups)

## Installation

### Option 1: Quick Setup (Recommended)

1. Open Termux
2. Copy the MoneyTrace folder to your phone (via USB or cloud)
3. Navigate to the folder:
   ```bash
   cd /path/to/MoneyTrace/v0.2
   ```
4. Run the setup script:
   ```bash
   bash android/setup.sh
   ```

### Option 2: Manual Setup

1. Open Termux and run:
   ```bash
   # Update packages
   pkg update && pkg upgrade
   
   # Install Python
   pkg install python
   
   # Install dependencies
   pip install fastapi uvicorn pydantic python-multipart
   ```

2. Copy MoneyTrace to your phone and navigate to the v0.2 folder

## Running MoneyTrace

1. Open Termux
2. Start the server:
   ```bash
   cd /path/to/MoneyTrace/v0.2
   python -m moneytrace.server
   ```
3. Open Chrome and go to: **http://127.0.0.1:8000**

## Install as App (PWA)

1. Open http://127.0.0.1:8000 in Chrome
2. Tap the **⋮** menu (three dots)
3. Select **"Add to Home screen"** or **"Install app"**
4. MoneyTrace will appear as an app on your home screen!

## Tips

### Create a Startup Shortcut

Install **Termux:Widget** from F-Droid to create home screen shortcuts:

1. Install Termux:Widget
2. Create folder: `~/.shortcuts/`
3. Add script:
   ```bash
   mkdir -p ~/.shortcuts
   echo '#!/bin/bash
   cd /path/to/MoneyTrace/v0.2
   python -m moneytrace.server' > ~/.shortcuts/MoneyTrace
   chmod +x ~/.shortcuts/MoneyTrace
   ```
4. Add Termux:Widget to home screen
5. Tap "MoneyTrace" to start server

### Keep Server Running

To keep the server running when Termux is in background:
```bash
# Acquire wake lock
termux-wake-lock

# Start server
python -m moneytrace.server
```

### Data Location

Your data is stored at:
```
~/.moneytrace/moneytrace.db
```

### Backup Your Data

1. Open MoneyTrace in browser
2. Tap ⚙️ Settings
3. Tap "Export Data"
4. Save the JSON file

## Troubleshooting

### "Address already in use"
The server is already running. Either:
- Use the existing server
- Kill it: `pkill -f "python -m moneytrace"`

### "Module not found"
Install dependencies:
```bash
pip install fastapi uvicorn pydantic python-multipart
```

### PWA not installing
- Make sure you're using Chrome
- The server must be running
- Try clearing Chrome cache

## Architecture

```
Your Phone (Termux)
├── Python Server (localhost:8000)
│   ├── FastAPI (REST API)
│   ├── SQLite (data storage)
│   └── Static files (PWA)
└── Chrome Browser
    └── MoneyTrace PWA
```

Everything runs locally. No internet required after setup.

